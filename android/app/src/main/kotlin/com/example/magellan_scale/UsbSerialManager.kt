package com.example.magellan_scale

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.hardware.usb.UsbDevice
import android.hardware.usb.UsbManager
import android.os.Handler
import android.os.Looper
import android.util.Log
import com.hoho.android.usbserial.driver.CdcAcmSerialDriver
import com.hoho.android.usbserial.driver.FtdiSerialDriver
import com.hoho.android.usbserial.driver.ProbeTable
import com.hoho.android.usbserial.driver.UsbSerialPort
import com.hoho.android.usbserial.driver.UsbSerialProber
import io.flutter.plugin.common.EventChannel
import org.json.JSONObject
import java.util.concurrent.atomic.AtomicBoolean

// Device type enum for separate scale vs scanner handling
enum class DeviceType { SCALE, SCANNER, UNKNOWN }

data class ConnectionInfo(
    var connection: android.hardware.usb.UsbDeviceConnection? = null,
    var port: UsbSerialPort? = null,
    var readThread: Thread? = null,
    var stopRead: AtomicBoolean = AtomicBoolean(false),
    var weightPollRunnable: Runnable? = null,
    var deviceType: DeviceType = DeviceType.UNKNOWN
)

class UsbSerialManager(
    private val context: Context
) {
    companion object {
        private const val TAG = "UsbSerialManager"

        // Datalogic Magellan VID — used as SCANNER
        private const val MAGELLAN_VID = 0x05F9
        private val MAGELLAN_PIDS = intArrayOf(0x2205, 0x2601, 0x2602)

        // FTDI VID 1027 (0x0403) — used as SCALE
        // Hardcoded: manufacturer=1027, product=45250 (0xB0C2) and product=45249 (0xB0C1)
        private const val FTDI_VID = 0x0403           // 1027 decimal
        private const val FTDI_PID_SCALE_1 = 0xB0C2  // 45250 decimal — SCALE
        private const val FTDI_PID_SCALE_2 = 0xB0C1  // 45249 decimal — SCALE
        private val FTDI_SCALE_PIDS = intArrayOf(FTDI_PID_SCALE_1, FTDI_PID_SCALE_2)

        private const val BAUD_RATE = 9600
        private const val READ_TIMEOUT_MS = 500
        private const val MAX_LOG_LINES = 200
        private const val WEIGHT_POLL_INTERVAL_MS = 500L
    }

    @Volatile
    private var eventSink: EventChannel.EventSink? = null
    @Volatile
    private var listening = false

    private val usbManager: UsbManager = context.getSystemService(Context.USB_SERVICE) as UsbManager
    private val mainHandler = Handler(Looper.getMainLooper())
    private val deviceConnections = mutableMapOf<String, ConnectionInfo>()
    private val pendingPermissions = mutableSetOf<Int>()
    private val rawLog = mutableListOf<String>()
    private var permissionReceiver: PermissionBroadcastReceiver? = null

    private val usbReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            when (intent?.action) {
                UsbManager.ACTION_USB_DEVICE_ATTACHED -> {
                    val device = intent.getParcelableExtra<UsbDevice>(UsbManager.EXTRA_DEVICE)
                    if (device != null && listening) {
                        mainHandler.post { tryConnect(device) }
                    }
                }
                UsbManager.ACTION_USB_DEVICE_DETACHED -> {
                    val device = intent.getParcelableExtra<UsbDevice>(UsbManager.EXTRA_DEVICE)
                    if (device != null) {
                        mainHandler.post { handleDetach(device) }
                    }
                }
            }
        }
    }

    init {
        val filter = IntentFilter().apply {
            addAction(UsbManager.ACTION_USB_DEVICE_ATTACHED)
            addAction(UsbManager.ACTION_USB_DEVICE_DETACHED)
        }
        context.registerReceiver(usbReceiver, filter, Context.RECEIVER_EXPORTED)
        permissionReceiver = PermissionBroadcastReceiver(this).also { receiver ->
            val permFilter = IntentFilter().apply { addAction(ACTION_USB_PERMISSION) }
            context.registerReceiver(receiver, permFilter, Context.RECEIVER_EXPORTED)
        }
    }

    fun setEventSink(sink: EventChannel.EventSink?) {
        eventSink = sink
    }

    fun startListening() {
        listening = true
        emitStatus("connecting", "Connecting...")
        findAndConnect()
    }

    fun connectToDevice(device: UsbDevice) {
        listening = true
        emitStatus("connecting", "Connecting...")
        tryConnect(device)
    }

    fun stopListening() {
        listening = false
        for ((key, info) in deviceConnections.toMap()) {
            closePort(info, key)
            deviceConnections.remove(key)
        }
        emitStatus("stopped", "Stopped")
    }

    fun dispose() {
        permissionReceiver?.let { context.unregisterReceiver(it) }
        permissionReceiver = null
        context.unregisterReceiver(usbReceiver)
        stopListening()
        eventSink = null
    }

    private fun findAndConnect() {
        val deviceList = usbManager.deviceList ?: return
        for (device in deviceList.values) {
            if (isTargetDevice(device) && deviceConnections[device.deviceName] == null) {
                tryConnect(device)
            }
        }
        if (deviceConnections.isEmpty()) {
            emitStatus("disconnected", "No device found")
        }
    }

    /** Determine if a USB device is one we handle (Magellan scanner OR FTDI scale). */
    private fun isTargetDevice(device: UsbDevice): Boolean {
        val vid = device.vendorId
        val pid = device.productId
        return when (vid) {
            MAGELLAN_VID -> MAGELLAN_PIDS.contains(pid)
            FTDI_VID -> true // Accept all FTDI devices; scale PIDs hardcoded above
            else -> false
        }
    }

    /** Identify whether a device is a SCALE or SCANNER. */
    private fun getDeviceType(device: UsbDevice): DeviceType {
        val vid = device.vendorId
        val pid = device.productId
        return when {
            vid == FTDI_VID && FTDI_SCALE_PIDS.contains(pid) -> DeviceType.SCALE
            vid == FTDI_VID -> DeviceType.SCALE  // All other FTDI = treat as scale
            vid == MAGELLAN_VID -> DeviceType.SCANNER
            else -> DeviceType.UNKNOWN
        }
    }

    private fun getCustomProber(): UsbSerialProber {
        val table = UsbSerialProber.getDefaultProbeTable()
        for (pid in MAGELLAN_PIDS) {
            table.addProduct(MAGELLAN_VID, pid, CdcAcmSerialDriver::class.java)
        }
        // Hardcoded FTDI scale PIDs: manufacturer=1027 (0x0403), product=45249 (0xB0C1) and 45250 (0xB0C2)
        table.addProduct(FTDI_VID, FTDI_PID_SCALE_1, FtdiSerialDriver::class.java)  // 45250
        table.addProduct(FTDI_VID, FTDI_PID_SCALE_2, FtdiSerialDriver::class.java)  // 45249
        return UsbSerialProber(table)
    }

    private fun tryConnect(device: UsbDevice) {
        if (!listening) return
        val key = device.deviceName
        if (deviceConnections[key] != null) return
        if (pendingPermissions.contains(device.deviceId)) {
            Log.d(TAG, "Already requesting permission for device ${device.deviceId}, skipping")
            return
        }
        if (!usbManager.hasPermission(device)) {
            pendingPermissions.add(device.deviceId)
            emitStatus("connecting", "Requesting permission...")
            usbManager.requestPermission(device, createPermissionIntent())
            return
        }
        openAndRead(device)
    }

    private fun createPermissionIntent(): android.app.PendingIntent {
        val flags = android.app.PendingIntent.FLAG_MUTABLE or android.app.PendingIntent.FLAG_UPDATE_CURRENT
        return android.app.PendingIntent.getBroadcast(context, 0, Intent(ACTION_USB_PERMISSION), flags)
    }

    fun onPermissionResult(granted: Boolean, device: UsbDevice?) {
        if (device != null) {
            pendingPermissions.remove(device.deviceId)
        }
        if (!granted || device == null) {
            emitStatus("error", "Permission denied")
            return
        }
        if (listening) openAndRead(device)
    }

    private fun openAndRead(device: UsbDevice) {
        val key = device.deviceName
        val deviceType = getDeviceType(device)

        Log.i(TAG, "Opening device: VID=0x${device.vendorId.toString(16)} PID=0x${device.productId.toString(16)} type=$deviceType name=$key")

        val conn = usbManager.openDevice(device) ?: run {
            emitStatus("error", "Failed to open device")
            return
        }

        val prober = getCustomProber()
        val driver = prober.probeDevice(device)
        if (driver == null) {
            conn.close()
            emitStatus("error", "No compatible driver for device VID=0x${device.vendorId.toString(16)} PID=0x${device.productId.toString(16)}")
            return
        }

        val ports = driver.ports
        if (ports.isEmpty()) {
            conn.close()
            emitStatus("error", "No ports for device")
            return
        }

        val usbPort = ports[0]
        try {
            usbPort.open(conn)
            usbPort.setParameters(BAUD_RATE, 8, UsbSerialPort.STOPBITS_1, UsbSerialPort.PARITY_NONE)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to configure port", e)
            try { usbPort.close() } catch (_: Exception) {}
            conn.close()
            emitStatus("error", "Port config failed: ${e.message}")
            return
        }

        val info = ConnectionInfo(
            connection = conn,
            port = usbPort,
            stopRead = AtomicBoolean(false),
            deviceType = deviceType
        )
        deviceConnections[key] = info

        val typeLabel = if (deviceType == DeviceType.SCALE) "Scale" else "Scanner"
        emitStatus("connected", "$typeLabel connected")
        Log.i(TAG, "$typeLabel connected at $key")

        startReadThread(info, key)

        // Only poll weight commands for SCALE devices
        if (deviceType == DeviceType.SCALE) {
            startWeightPolling(info, key)
        }
    }

    private fun startWeightPolling(info: ConnectionInfo, key: String) {
        info.weightPollRunnable?.let { mainHandler.removeCallbacks(it) }
        info.weightPollRunnable = object : Runnable {
            override fun run() {
                if (info.stopRead.get() || info.port == null) return
                try {
                    // Magellan/PSC over FTDI RS232 weight request commands
                    // ESC+W is the standard OBC (Open Bar Code) weight request
                    val commands = listOf(
                        byteArrayOf(0x1B, 'W'.code.toByte(), '\r'.code.toByte()),           // ESC W \r
                        byteArrayOf(0x1B, 'S'.code.toByte(), '\r'.code.toByte()),           // ESC S \r
                        byteArrayOf('W'.code.toByte(), '\r'.code.toByte(), '\n'.code.toByte()), // W \r\n
                        byteArrayOf('S'.code.toByte(), '\r'.code.toByte(), '\n'.code.toByte()), // S \r\n
                        // OBC protocol: STX + command + ETX
                        byteArrayOf(0x02, 'W'.code.toByte(), 0x03),                         // STX W ETX
                        byteArrayOf(0x02, 0x57, 0x03),                                      // STX 0x57 ETX
                    )
                    for (cmd in commands) {
                        try {
                            info.port?.write(cmd, 500)
                            Thread.sleep(50) // small gap between commands
                        } catch (e: Exception) {
                            Log.w(TAG, "cmd write failed: ${cmd.toList()}", e)
                        }
                    }
                } catch (e: Exception) {
                    Log.w(TAG, "Weight poll write failed on $key", e)
                }
                if (!info.stopRead.get() && info.port != null) {
                    mainHandler.postDelayed(this, WEIGHT_POLL_INTERVAL_MS)
                }
            }
        }
        mainHandler.postDelayed(info.weightPollRunnable!!, WEIGHT_POLL_INTERVAL_MS)
    }

    private fun stopWeightPolling(info: ConnectionInfo) {
        info.weightPollRunnable?.let { mainHandler.removeCallbacks(it) }
        info.weightPollRunnable = null
    }

    private fun startReadThread(info: ConnectionInfo, key: String) {
        info.readThread = Thread {
            val buffer = ByteArray(256)
            val lineBuffer = StringBuilder()
            val maxLineLength = 128
            val port = info.port ?: return@Thread
            while (!info.stopRead.get()) {
                try {
                    val n = port.read(buffer, READ_TIMEOUT_MS)
                    if (n > 0) {
                        for (i in 0 until n) {
                            val b = buffer[i].toInt().and(0xFF)
                            if (b == '\n'.code || b == '\r'.code) {
                                if (lineBuffer.isNotEmpty()) {
                                    val line = sanitizeLine(lineBuffer.toString())
                                    lineBuffer.setLength(0)
                                    if (line.isNotEmpty()) processLine(line, key, info.deviceType)
                                }
                            } else if (b >= 32 && b < 127) {
                                lineBuffer.append(b.toChar())
                                if (lineBuffer.length >= maxLineLength) {
                                    val line = sanitizeLine(lineBuffer.toString())
                                    lineBuffer.setLength(0)
                                    if (line.isNotEmpty()) processLine(line, key, info.deviceType)
                                }
                            }
                        }
                    }
                } catch (e: Exception) {
                    if (!info.stopRead.get()) {
                        Log.e(TAG, "Read error on $key", e)
                        mainHandler.post { handleDetach(port.driver.device) }
                    }
                    break
                }
            }
        }.apply { start() }
    }

    /** Strips ASCII control chars (STX/ETX/BCC etc.) and trailing garbage from USB data. */
    private fun sanitizeLine(raw: String): String {
        var s = raw.replace(Regex("[\\x00-\\x1F\\x7F]"), "").trim()
        if (s.length > 1 && !s.last().isLetterOrDigit() && s.last() != '.' && s.last() != ',') {
            s = s.dropLast(1).trim()
        }
        return s
    }

    private fun processLine(line: String, source: String, deviceType: DeviceType) {
        if (line.isEmpty()) return
        Log.i(TAG, "RECEIVED [$deviceType] from $source: $line")

        mainHandler.post {
            addRawLog("$source: $line")

            when (deviceType) {
                DeviceType.SCALE -> {
                    // Log every line from scale for debugging
                    Log.i(TAG, "SCALE LINE: '$line' len=${line.length} allDigits=${line.all{it.isDigit()}}")
                    val parsed = parseWeight(line)
                    Log.i(TAG, "SCALE PARSE RESULT: $parsed")
                    if (parsed != null) {
                        Log.i(TAG, "SCALE WEIGHT → $line")
                        emitWeight(parsed, "$source: $line")
                    } else if (line.all { it.isDigit() } && line.length in 6..13) {
                        // Pure digits = barcode from scale, emit as scan
                        Log.i(TAG, "SCALE BARCODE (no weight) → $line")
                        emitScan("$source: $line")
                    } else {
                        Log.i(TAG, "SCALE: unrecognized line → '$line'")
                    }
                }
                DeviceType.SCANNER -> {
                    // Scanner: emit as scan if it looks like a barcode
                    if (looksLikeBarcode(line)) {
                        Log.i(TAG, "SCAN RECEIVED → $line")
                        emitScan("$source: $line")
                    } else {
                        // Could still be weight data from a combo unit
                        val parsed = parseWeight(line)
                        if (parsed != null) {
                            Log.i(TAG, "SCANNER WEIGHT → $line")
                            emitWeight(parsed, "$source: $line")
                        }
                    }
                }
                DeviceType.UNKNOWN -> {
                    // Fallback: try weight, then barcode
                    val parsed = parseWeight(line)
                    if (parsed != null) {
                        emitWeight(parsed, "$source: $line")
                    } else if (looksLikeBarcode(line)) {
                        emitScan("$source: $line")
                    }
                }
            }
        }
    }

    /** Heuristic: line looks like barcode (e.g. 8–64 chars, mostly alphanumeric, no weight pattern). */
    private fun looksLikeBarcode(line: String): Boolean {
        if (line.length !in 4..64) return false
        val alphaNum = line.count { it.isLetterOrDigit() }
        if (alphaNum < line.length * 3 / 4) return false
        return !line.contains(Regex("""\d+[.,]\d+"""))
    }

    private fun addRawLog(line: String) {
        rawLog.add(line)
        if (rawLog.size > MAX_LOG_LINES) rawLog.removeAt(0)
        emitRaw(line)
    }

    private fun parseWeight(line: String): JSONObject? {
        val trimmed = line.trim()
        if (trimmed.isEmpty()) return null
        val upper = trimmed.uppercase()

        // Magellan 8500: S11abcd or S14x0abcd (weight in pounds as XX.XX)
        val magellanMatch = Regex("""S1(?:1(\d{4})|4[04]0(\d{4}))\s*$""", RegexOption.IGNORE_CASE).find(trimmed)
        if (magellanMatch != null) {
            val digits = magellanMatch.groupValues[1].ifEmpty { magellanMatch.groupValues[2] }
            if (digits.length == 4) {
                val weight = (digits.take(2) + "." + digits.takeLast(2)).toDoubleOrNull() ?: return null
                return JSONObject().apply {
                    put("weight", weight)
                    put("unit", "lb")
                    put("stable", true)
                }
            }
        }

        // OL = overload
        if (upper == "OL" || upper.startsWith("OL,") || upper.startsWith("OL ")) {
            return JSONObject().apply {
                put("weight", 0.0)
                put("unit", "kg")
                put("stable", false)
            }
        }

        // ST/US/S format: ST,GS,+00679.4Kg or US,NT,-002485LB
        val prefixedRegex = Regex(
            """(?:ST|US|S)[,\s]*(?:GS|NT)?,?\s*([+-]?\d+[.,]?\d*)\s*(kg|lb|g|oz)?""",
            RegexOption.IGNORE_CASE
        )
        val prefixedMatch = prefixedRegex.find(upper)
        if (prefixedMatch != null) {
            val stable = upper.startsWith("ST") || (upper.startsWith("S") && !upper.startsWith("US"))
            val numStr = prefixedMatch.groupValues[1].replace(',', '.')
            val unit = (prefixedMatch.groupValues.getOrElse(2) { "" }).lowercase().ifEmpty { "kg" }
            val weight = numStr.toDoubleOrNull() ?: return null
            return JSONObject().apply {
                put("weight", weight)
                put("unit", unit)
                put("stable", stable)
            }
        }

        // Fallback 1: "1.23 kg" or "123.45 lb" (decimal required)
        var fallbackMatch = Regex("""([+-]?\d+[.,]\d+)\s*(kg|lb|g|oz)?""", RegexOption.IGNORE_CASE).find(trimmed)
        if (fallbackMatch != null) {
            val numStr = fallbackMatch.groupValues[1].replace(',', '.')
            val unit = (fallbackMatch.groupValues.getOrElse(2) { "" }).lowercase().ifEmpty { "kg" }
            val weight = numStr.toDoubleOrNull() ?: return null
            return JSONObject().apply {
                put("weight", weight)
                put("unit", unit)
                put("stable", true)
            }
        }

        // Fallback 2: integer weight "123 kg" at end of line
        fallbackMatch = Regex("""([+-]?\d+)\s*(kg|lb|g|oz)\s*$""", RegexOption.IGNORE_CASE).find(trimmed)
        if (fallbackMatch != null) {
            val numStr = fallbackMatch.groupValues[1]
            val unit = fallbackMatch.groupValues[2].lowercase()
            val weight = numStr.toDoubleOrNull() ?: return null
            return JSONObject().apply {
                put("weight", weight)
                put("unit", unit)
                put("stable", true)
            }
        }

        // Fallback 3: standalone number at end
        val lastNum = Regex("""([+-]?\d+[.,]?\d*)\s*(kg|lb|g|oz)?\s*$""", RegexOption.IGNORE_CASE).find(trimmed)
        if (lastNum != null) {
            val numStr = lastNum.groupValues[1].replace(',', '.')
            if (numStr.replace(".", "").replace("-", "").length > 8 && !numStr.contains(".") && !numStr.contains(",")) return null
            val unit = (lastNum.groupValues.getOrElse(2) { "" }).lowercase().ifEmpty { "kg" }
            val weight = numStr.toDoubleOrNull() ?: return null
            if (weight >= 0.001 && weight <= 99999.999) {
                return JSONObject().apply {
                    put("weight", weight)
                    put("unit", unit)
                    put("stable", true)
                }
            }
        }

        // Fallback 4: barcode+weight concatenated (all digits, 10-16 chars)
        if (trimmed.all { it.isDigit() } && trimmed.length in 10..16) {
            if (trimmed.length >= 4) {
                val last4 = trimmed.takeLast(4)
                val weight4 = (last4.take(2) + "." + last4.takeLast(2)).toDoubleOrNull()
                if (weight4 != null && weight4 in 0.01..99.99) {
                    return JSONObject().apply {
                        put("weight", weight4)
                        put("unit", "kg")
                        put("stable", true)
                    }
                }
            }
            if (trimmed.length >= 5) {
                val last5 = trimmed.takeLast(5)
                val weight5 = (last5.take(3) + "." + last5.takeLast(2)).toDoubleOrNull()
                if (weight5 != null && weight5 in 0.001..999.99) {
                    return JSONObject().apply {
                        put("weight", weight5)
                        put("unit", "kg")
                        put("stable", true)
                    }
                }
            }
        }

        return null
    }

    private fun handleDetach(device: UsbDevice) {
        val key = device.deviceName
        val info = deviceConnections[key] ?: return
        val typeLabel = if (info.deviceType == DeviceType.SCALE) "Scale" else "Scanner"
        closePort(info, key)
        deviceConnections.remove(key)
        emitStatus("disconnected", "$typeLabel disconnected")
        if (listening) {
            emitStatus("connecting", "Reconnecting...")
            mainHandler.postDelayed({ findAndConnect() }, 1000)
        }
    }

    private fun closePort(info: ConnectionInfo, key: String) {
        stopWeightPolling(info)
        info.stopRead.set(true)
        info.readThread?.interrupt()
        info.readThread = null
        try { info.port?.close() } catch (_: Exception) {}
        info.port = null
        try { info.connection?.close() } catch (_: Exception) {}
        info.connection = null
    }

    private fun emitStatus(status: String, message: String) {
        mainHandler.post {
            try {
                val json = JSONObject().apply {
                    put("type", "status")
                    put("status", status)
                    put("message", message)
                }
                eventSink?.success(json.toString())
            } catch (_: Exception) {}
        }
    }

    private fun emitWeight(json: JSONObject, rawLine: String) {
        mainHandler.post {
            try {
                val w = json.getDouble("weight")
                val unit = json.getString("unit")
                val stable = json.getBoolean("stable")
                Log.i(TAG, "WEIGHT: $w $unit stable=$stable (raw: $rawLine)")
                val wrapper = JSONObject().apply {
                    put("type", "weight")
                    put("weight", w)
                    put("unit", unit)
                    put("stable", stable)
                    put("raw", rawLine)
                }
                eventSink?.success(wrapper.toString())
            } catch (_: Exception) {}
        }
    }

    private fun emitRaw(line: String) {
        mainHandler.post {
            try {
                val json = JSONObject().apply {
                    put("type", "raw")
                    put("raw", line)
                }
                eventSink?.success(json.toString()) ?: Log.w(TAG, "emitRaw: eventSink is null")
            } catch (e: Exception) {
                Log.e(TAG, "emitRaw failed", e)
            }
        }
    }

    private fun emitScan(line: String) {
        mainHandler.post {
            try {
                val json = JSONObject().apply {
                    put("type", "scan")
                    put("raw", line)
                }
                eventSink?.success(json.toString())
            } catch (e: Exception) {
                Log.e(TAG, "emitScan failed", e)
            }
        }
    }

    class PermissionBroadcastReceiver(
        private val manager: UsbSerialManager
    ) : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            if (intent?.action == ACTION_USB_PERMISSION) {
                val granted = intent.getBooleanExtra(UsbManager.EXTRA_PERMISSION_GRANTED, false)
                val device = intent.getParcelableExtra<UsbDevice>(UsbManager.EXTRA_DEVICE)
                manager.onPermissionResult(granted, device)
            }
        }
    }
}

const val ACTION_USB_PERMISSION = "com.example.magellan_scale.USB_PERMISSION"