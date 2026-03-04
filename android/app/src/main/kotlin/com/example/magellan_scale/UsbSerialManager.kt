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
        private const val FTDI_VID = 0x0403 // 1027 decimal
        private const val FTDI_PID_SCALE_1 = 0xB0C2 // 45250 decimal — SCALE
        private const val FTDI_PID_SCALE_2 = 0xB0C1 // 45249 decimal — SCALE
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
            Log.d(TAG, "USB broadcast received - action: ${intent?.action}")
            when (intent?.action) {
                UsbManager.ACTION_USB_DEVICE_ATTACHED -> {
                    @Suppress("DEPRECATION")
                    val device = intent?.getParcelableExtra<UsbDevice>(UsbManager.EXTRA_DEVICE)
                    Log.d(TAG, "DEVICE ATTACHED - device: ${device?.deviceName} VID=0x${device?.vendorId?.toString(16)} PID=0x${device?.productId?.toString(16)}")
                    if (device != null && listening) {
                        mainHandler.post { tryConnect(device) }
                    }
                }
                UsbManager.ACTION_USB_DEVICE_DETACHED -> {
                    @Suppress("DEPRECATION")
                    val device = intent?.getParcelableExtra<UsbDevice>(UsbManager.EXTRA_DEVICE)
                    Log.d(TAG, "DEVICE DETACHED - device: ${device?.deviceName} VID=0x${device?.vendorId?.toString(16)} PID=0x${device?.productId?.toString(16)}")
                    if (device != null) {
                        mainHandler.post { handleDetach(device) }
                    }
                }
            }
        }
    }

    init {
        Log.i(TAG, "UsbSerialManager init started - registering receivers")
        val filter = IntentFilter().apply {
            addAction(UsbManager.ACTION_USB_DEVICE_ATTACHED)
            addAction(UsbManager.ACTION_USB_DEVICE_DETACHED)
        }
        if (android.os.Build.VERSION.SDK_INT >= 33) {
            context.registerReceiver(usbReceiver, filter, Context.RECEIVER_EXPORTED)
        } else {
            context.registerReceiver(usbReceiver, filter)
        }
        Log.i(TAG, "USB receiver registered successfully")

        permissionReceiver = PermissionBroadcastReceiver(this).also { receiver ->
            val permFilter = IntentFilter().apply { addAction(ACTION_USB_PERMISSION) }
            if (android.os.Build.VERSION.SDK_INT >= 33) {
                context.registerReceiver(receiver, permFilter, Context.RECEIVER_EXPORTED)
            } else {
                context.registerReceiver(receiver, permFilter)
            }
            Log.i(TAG, "Permission receiver registered successfully")
        }
    }

    fun setEventSink(sink: EventChannel.EventSink?) {
        Log.d(TAG, "setEventSink called - sink is ${if (sink != null) "NOT NULL" else "NULL"}")
        eventSink = sink
    }

    fun startListening() {
        Log.i(TAG, "startListening() called - setting listening=true")
        listening = true
        emitStatus("connecting", "Connecting...")
        findAndConnect()
    }

    fun connectToDevice(device: UsbDevice) {
        Log.i(TAG, "connectToDevice() called for device: ${device.deviceName}")
        listening = true
        emitStatus("connecting", "Connecting...")
        tryConnect(device)
    }

    fun stopListening() {
        Log.i(TAG, "stopListening() called - closing all connections")
        listening = false
        for ((key, info) in deviceConnections.toMap()) {
            closePort(info, key)
            deviceConnections.remove(key)
        }
        emitStatus("stopped", "Stopped")
    }

    fun dispose() {
        Log.i(TAG, "dispose() called - cleaning up everything")
        permissionReceiver?.let { context.unregisterReceiver(it) }
        permissionReceiver = null
        context.unregisterReceiver(usbReceiver)
        stopListening()
        eventSink = null
        Log.i(TAG, "dispose completed")
    }

    private fun findAndConnect() {
        Log.d(TAG, "findAndConnect() - scanning for devices")
        val deviceList = usbManager.deviceList ?: run {
            Log.w(TAG, "findAndConnect - deviceList is null")
            return
        }
        Log.d(TAG, "findAndConnect - found ${deviceList.size} total USB devices")
        for (device in deviceList.values) {
            Log.d(TAG, "Checking device: ${device.deviceName} VID=0x${device.vendorId.toString(16)} PID=0x${device.productId.toString(16)}")
            if (isTargetDevice(device) && deviceConnections[device.deviceName] == null) {
                Log.i(TAG, "Target device found - attempting connect: ${device.deviceName}")
                tryConnect(device)
            }
        }
        if (deviceConnections.isEmpty()) {
            Log.w(TAG, "findAndConnect - no target devices connected")
            emitStatus("disconnected", "No device found")
        }
    }

    /** Determine if a USB device is one we handle (Magellan scanner OR FTDI scale). */
    private fun isTargetDevice(device: UsbDevice): Boolean {
        val vid = device.vendorId
        val pid = device.productId
        Log.d(TAG, "isTargetDevice() - VID=0x${vid.toString(16)} PID=0x${pid.toString(16)}")
        val result = when (vid) {
            MAGELLAN_VID -> {
                val match = MAGELLAN_PIDS.contains(pid)
                Log.d(TAG, "MAGELLAN VID match: $match (PID in list)")
                match
            }
            FTDI_VID -> {
                Log.d(TAG, "FTDI VID - accepting ALL FTDI devices as potential SCALE")
                true
            }
            else -> {
                Log.d(TAG, "Unknown VID - not target device")
                false
            }
        }
        Log.d(TAG, "isTargetDevice() final result: $result")
        return result
    }

    /** Identify whether a device is a SCALE or SCANNER. */
    private fun getDeviceType(device: UsbDevice): DeviceType {
        val vid = device.vendorId
        val pid = device.productId
        Log.d(TAG, "getDeviceType() - VID=0x${vid.toString(16)} PID=0x${pid.toString(16)}")
        val type = when {
            vid == FTDI_VID && FTDI_SCALE_PIDS.contains(pid) -> {
                Log.i(TAG, "FTDI SCALE (exact PID match) → DeviceType.SCALE")
                DeviceType.SCALE
            }
            vid == FTDI_VID -> {
                Log.i(TAG, "FTDI device (any PID) → DeviceType.SCALE")
                DeviceType.SCALE
            }
            vid == MAGELLAN_VID -> {
                Log.i(TAG, "MAGELLAN VID → DeviceType.SCANNER")
                DeviceType.SCANNER
            }
            else -> {
                Log.w(TAG, "Unknown device → DeviceType.UNKNOWN")
                DeviceType.UNKNOWN
            }
        }
        Log.d(TAG, "getDeviceType() returning: $type")
        return type
    }

    private fun getCustomProber(): UsbSerialProber {
        Log.d(TAG, "getCustomProber() - building custom probe table")
        val table = UsbSerialProber.getDefaultProbeTable()
        for (pid in MAGELLAN_PIDS) {
            table.addProduct(MAGELLAN_VID, pid, CdcAcmSerialDriver::class.java)
            Log.d(TAG, "Added Magellan PID 0x${pid.toString(16)} as CdcAcm")
        }
        table.addProduct(FTDI_VID, FTDI_PID_SCALE_1, FtdiSerialDriver::class.java)
        table.addProduct(FTDI_VID, FTDI_PID_SCALE_2, FtdiSerialDriver::class.java)
        Log.d(TAG, "Added FTDI scale PIDs as FtdiSerialDriver")
        return UsbSerialProber(table)
    }

    private fun tryConnect(device: UsbDevice) {
        Log.i(TAG, "tryConnect() started for ${device.deviceName}")
        if (!listening) {
            Log.w(TAG, "tryConnect - listening=false, skipping")
            return
        }
        val key = device.deviceName
        if (deviceConnections[key] != null) {
            Log.d(TAG, "tryConnect - already connected, skipping")
            return
        }
        if (pendingPermissions.contains(device.deviceId)) {
            Log.d(TAG, "Already requesting permission for device ${device.deviceId}, skipping")
            return
        }
        if (!usbManager.hasPermission(device)) {
            Log.i(TAG, "No permission - requesting for device ${device.deviceId}")
            pendingPermissions.add(device.deviceId)
            emitStatus("connecting", "Requesting permission...")
            usbManager.requestPermission(device, createPermissionIntent())
            return
        }
        Log.i(TAG, "Has permission - proceeding to openAndRead")
        openAndRead(device)
    }

    private fun createPermissionIntent(): android.app.PendingIntent {
        val flags = android.app.PendingIntent.FLAG_MUTABLE or android.app.PendingIntent.FLAG_UPDATE_CURRENT
        return android.app.PendingIntent.getBroadcast(context, 0, Intent(ACTION_USB_PERMISSION), flags)
    }

    fun onPermissionResult(granted: Boolean, device: UsbDevice?) {
        Log.i(TAG, "onPermissionResult - granted=$granted device=${device?.deviceName}")
        if (device != null) {
            pendingPermissions.remove(device.deviceId)
        }
        if (!granted || device == null) {
            Log.e(TAG, "Permission denied or device null")
            emitStatus("error", "Permission denied")
            return
        }
        if (listening) {
            Log.i(TAG, "Permission granted - calling openAndRead")
            openAndRead(device)
        }
    }

    private fun openAndRead(device: UsbDevice) {
        val key = device.deviceName
        val deviceType = getDeviceType(device)
        Log.i(TAG, "openAndRead() - VID=0x${device.vendorId.toString(16)} PID=0x${device.productId.toString(16)} type=$deviceType name=$key")

        val conn = usbManager.openDevice(device) ?: run {
            Log.e(TAG, "Failed to open USB device connection")
            emitStatus("error", "Failed to open device")
            return
        }
        Log.d(TAG, "USB device connection opened successfully")

        val prober = getCustomProber()
        val driver = prober.probeDevice(device)
        if (driver == null) {
            Log.e(TAG, "No compatible driver found for this device")
            conn.close()
            emitStatus("error", "No compatible driver for device VID=0x${device.vendorId.toString(16)} PID=0x${device.productId.toString(16)}")
            return
        }
        Log.i(TAG, "Driver found: ${driver.javaClass.simpleName}")

        val ports = driver.ports
        Log.d(TAG, "Driver has ${ports.size} ports")
        if (ports.isEmpty()) {
            Log.e(TAG, "No ports available")
            conn.close()
            emitStatus("error", "No ports for device")
            return
        }
        val usbPort = ports[0]

        try {
            usbPort.open(conn)
            if (deviceType == DeviceType.SCALE) {
                // Magellan 9800i/8500 scales typically use 9600 7E1
                usbPort.setParameters(BAUD_RATE, 7, UsbSerialPort.STOPBITS_1, UsbSerialPort.PARITY_EVEN)
                Log.i(TAG, "Port opened and parameters set (9600,7,E,1) for SCALE")
            } else {
                usbPort.setParameters(BAUD_RATE, 8, UsbSerialPort.STOPBITS_1, UsbSerialPort.PARITY_NONE)
                Log.i(TAG, "Port opened and parameters set (9600,8,N,1) for SCANNER")
            }
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
        Log.i(TAG, "$typeLabel connected at $key - deviceType=$deviceType")

        startReadThread(info, key)

        // Only poll weight commands for SCALE devices
        if (deviceType == DeviceType.SCALE) {
            Log.i(TAG, "SCALE device detected - starting weight polling")
            startWeightPolling(info, key)
        } else {
            Log.i(TAG, "SCANNER device detected - NO weight polling (only scanner mode)")
        }
    }

    private fun startWeightPolling(info: ConnectionInfo, key: String) {
        Log.d(TAG, "startWeightPolling() for $key")
        info.weightPollRunnable?.let { mainHandler.removeCallbacks(it) }
        info.weightPollRunnable = object : Runnable {
            override fun run() {
                if (info.stopRead.get() || info.port == null) {
                    Log.d(TAG, "Weight poll stopped for $key")
                    return
                }
                try {
                    Log.d(TAG, "=== SENDING WEIGHT POLL COMMANDS for SCALE $key ===")
                    // Magellan/PSC over FTDI RS232 weight request commands
                    val commands = listOf(
                        byteArrayOf('W'.code.toByte(), '\r'.code.toByte()), // W \r
                        byteArrayOf('S'.code.toByte(), '\r'.code.toByte()), // S \r
                        byteArrayOf(0x1B, 'W'.code.toByte(), '\r'.code.toByte()), // ESC W \r
                        byteArrayOf(0x1B, 'S'.code.toByte(), '\r'.code.toByte()), // ESC S \r
                        byteArrayOf('W'.code.toByte(), '\r'.code.toByte(), '\n'.code.toByte()), // W \r\n
                        byteArrayOf('S'.code.toByte(), '\r'.code.toByte(), '\n'.code.toByte()), // S \r\n
                        byteArrayOf(0x02, 'W'.code.toByte(), 0x03), // STX W ETX
                        byteArrayOf(0x02, 0x57, 0x03), // STX 0x57 ETX
                    )
                    for (cmd in commands) {
                        val hex = cmd.joinToString(" ") { "%02X".format(it) }
                        Log.d(TAG, "Sending poll cmd: $hex")
                        try {
                            info.port?.write(cmd, 500)
                            Thread.sleep(50)
                        } catch (e: Exception) {
                            Log.w(TAG, "cmd write failed: $hex", e)
                        }
                    }
                    Log.d(TAG, "=== WEIGHT POLL CYCLE COMPLETE for $key ===")
                } catch (e: Exception) {
                    Log.w(TAG, "Weight poll write failed on $key", e)
                }
                if (!info.stopRead.get() && info.port != null) {
                    mainHandler.postDelayed(this, WEIGHT_POLL_INTERVAL_MS)
                }
            }
        }
        mainHandler.postDelayed(info.weightPollRunnable!!, WEIGHT_POLL_INTERVAL_MS)
        Log.i(TAG, "Weight polling scheduled every 500ms for $key")
    }

    private fun stopWeightPolling(info: ConnectionInfo) {
        Log.d(TAG, "stopWeightPolling() called")
        info.weightPollRunnable?.let { mainHandler.removeCallbacks(it) }
        info.weightPollRunnable = null
    }

    private fun startReadThread(info: ConnectionInfo, key: String) {
        Log.i(TAG, "startReadThread() - launching background read for $key type=${info.deviceType}")
        info.readThread = Thread {
            val buffer = ByteArray(256)
            val lineBuffer = StringBuilder()
            val maxLineLength = 128
            val port = info.port ?: run {
                Log.e(TAG, "Read thread - port is null, exiting")
                return@Thread
            }

            Log.i(TAG, "Read thread STARTED successfully for $key")
            while (!info.stopRead.get()) {
                try {
                    val n = port.read(buffer, READ_TIMEOUT_MS)
                    if (n > 0) {
                        // For Scales, we might get 7-bit data even if port is set to 8. 
                        // Masking helps in case the driver doesn't strip parity.
                        val rawHex = buffer.take(n).joinToString(" ") { "%02X".format(it.toInt().and(0xFF)) }
                        Log.d(TAG, "RAW BYTES READ ($n bytes) from $key [${info.deviceType}]: $rawHex")

                        for (i in 0 until n) {
                            val b = buffer[i].toInt().and(0x7F) // Mask to 7 bits to handle parity reliably
                            if (b == 0x0A || b == 0x0D || b == 0x03) { // LF, CR, ETX
                                if (lineBuffer.isNotEmpty()) {
                                    val line = lineBuffer.toString().trim()
                                    lineBuffer.setLength(0)
                                    if (line.isNotEmpty()) processLine(line, key, info.deviceType)
                                }
                            } else if (b == 0x02) { // STX
                                lineBuffer.setLength(0)
                            } else if (b in 32..126) {
                                lineBuffer.append(b.toChar())
                                if (lineBuffer.length >= maxLineLength) {
                                    val line = lineBuffer.toString().trim()
                                    lineBuffer.setLength(0)
                                    if (line.isNotEmpty()) processLine(line, key, info.deviceType)
                                }
                            }
                        }
                    }
                } catch (e: Exception) {
                    if (!info.stopRead.get()) {
                        Log.e(TAG, "CRITICAL READ ERROR on $key - will trigger detach", e)
                        mainHandler.post { handleDetach(port.driver.device) }
                    }
                    break
                }
            }
            Log.i(TAG, "Read thread EXITED for $key")
        }.apply { start() }
    }

    /** Strips ASCII control chars (STX/ETX/BCC etc.) and trailing garbage from USB data. */
    private fun sanitizeLine(raw: String): String {
        Log.d(TAG, "sanitizeLine() input: '$raw'")
        var s = raw.replace(Regex("[\\x00-\\x1F\\x7F]"), "").trim()
        if (s.length > 1 && !s.last().isLetterOrDigit() && s.last() != '.' && s.last() != ',') {
            s = s.dropLast(1).trim()
        }
        Log.d(TAG, "sanitizeLine() output: '$s'")
        return s
    }

    private fun processLine(line: String, source: String, deviceType: DeviceType) {
        if (line.isEmpty()) return
        Log.i(TAG, "RECEIVED [$deviceType] from $source: '$line' (length=${line.length})")
        mainHandler.post {
            addRawLog("$source: $line")
            when (deviceType) {
                DeviceType.SCALE -> {
                    Log.d(TAG, "Processing SCALE line: '$line'")
                    val parsed = parseWeight(line)
                    if (parsed != null) {
                        val w = parsed.getDouble("weight")
                        val unit = parsed.getString("unit")
                        Log.i(TAG, "✅ SCALE WEIGHT IDENTIFIED: $w $unit")
                        emitWeight(parsed, "$source: $line")
                    } else if (line.all { it.isDigit() } && line.length in 6..13) {
                        Log.i(TAG, "SCALE BARCODE → $line")
                        emitScan("$source: $line")
                    } else {
                        val reason = when {
                            line.isEmpty() -> "empty data"
                            !line.any { it.isDigit() } -> "no numeric values found"
                            line.length < 3 -> "line too short"
                            else -> "format not recognized as weight"
                        }
                        Log.w(TAG, "❌ SCALE PARSE FAILED: '$line' (Reason: $reason)")
                        // Also add the reason to the raw log so the user sees it in the UI
                        addRawLog("Parse Fail: $line [$reason]")
                    }
                }
                DeviceType.SCANNER -> {
                    Log.d(TAG, "SCANNER mode - checking if barcode or weight")
                    if (looksLikeBarcode(line)) {
                        Log.i(TAG, "SCAN RECEIVED → $line")
                        emitScan("$source: $line")
                    } else {
                        Log.d(TAG, "Not barcode - trying weight parse anyway")
                        val parsed = parseWeight(line)
                        if (parsed != null) {
                            Log.i(TAG, "SCANNER WEIGHT → $line")
                            emitWeight(parsed, "$source: $line")
                        } else {
                            Log.d(TAG, "SCANNER: no weight parsed from line")
                        }
                    }
                }
                DeviceType.UNKNOWN -> {
                    Log.d(TAG, "UNKNOWN device type - fallback parse")
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
        Log.d(TAG, "looksLikeBarcode() checking: '$line' (len=${line.length})")
        if (line.length !in 4..64) {
            Log.d(TAG, "looksLikeBarcode → false (length out of range)")
            return false
        }
        val alphaNum = line.count { it.isLetterOrDigit() }
        if (alphaNum < line.length * 3 / 4) {
            Log.d(TAG, "looksLikeBarcode → false (too few alphanumeric chars)")
            return false
        }
        val hasWeightPattern = line.contains(Regex("""\d+[.,]\d+"""))
        val result = !hasWeightPattern
        Log.d(TAG, "looksLikeBarcode → $result")
        return result
    }

    private fun addRawLog(line: String) {
        rawLog.add(line)
        if (rawLog.size > MAX_LOG_LINES) rawLog.removeAt(0)
        emitRaw(line)
    }

    private fun parseWeight(line: String): JSONObject? {
        val trimmed = line.trim()
        if (trimmed.isEmpty()) {
            Log.d(TAG, "parseWeight - empty line, returning null")
            return null
        }
        val upper = trimmed.uppercase()
        Log.d(TAG, "parseWeight START - line='$trimmed' upper='$upper'")

        // Magellan 8500: S11abcd or S14x0abcd
        Log.d(TAG, "Trying Magellan regex...")
        val magellanMatch = Regex("""S1(?:1(\d{4})|4[04]0(\d{4}))\s*$""", RegexOption.IGNORE_CASE).find(trimmed)
        if (magellanMatch != null) {
            val digits = magellanMatch.groupValues[1].ifEmpty { magellanMatch.groupValues[2] }
            Log.i(TAG, "MAGELLAN MATCH! digits=$digits")
            if (digits.length == 4) {
                val weight = (digits.take(2) + "." + digits.takeLast(2)).toDoubleOrNull() ?: return null
                Log.i(TAG, "MAGELLAN WEIGHT PARSED: $weight lb")
                return JSONObject().apply {
                    put("weight", weight)
                    put("unit", "lb")
                    put("stable", true)
                }
            }
        }

        // OL = overload
        if (upper == "OL" || upper.startsWith("OL,") || upper.startsWith("OL ")) {
            Log.i(TAG, "OL OVERLOAD detected")
            return JSONObject().apply {
                put("weight", 0.0)
                put("unit", "kg")
                put("stable", false)
            }
        }

        // ST/US/S format
        Log.d(TAG, "Trying prefixedRegex (ST/US/S)...")
        val prefixedRegex = Regex(
            """(?:ST|US|S)[,\s]*(?:GS|NT)?,?\s*([+-]?\d+[.,]?\d*)\s*(kg|lb|g|oz)?""",
            RegexOption.IGNORE_CASE
        )
        val prefixedMatch = prefixedRegex.find(upper)
        if (prefixedMatch != null) {
            Log.i(TAG, "PREFIXED MATCH! group1=${prefixedMatch.groupValues[1]}")
            val stable = upper.startsWith("ST") || (upper.startsWith("S") && !upper.startsWith("US"))
            val numStr = prefixedMatch.groupValues[1].replace(',', '.')
            val unit = (prefixedMatch.groupValues.getOrElse(2) { "" }).lowercase().ifEmpty { "kg" }
            val weight = numStr.toDoubleOrNull() ?: return null
            Log.i(TAG, "PREFIXED WEIGHT PARSED: $weight $unit stable=$stable")
            return JSONObject().apply {
                put("weight", weight)
                put("unit", unit)
                put("stable", stable)
            }
        }

        // Fallback 1: decimal weight (e.g. "0.00 lb" or "  0.12 kg")
        Log.d(TAG, "Trying fallback decimal regex...")
        var fallbackMatch = Regex("""([+-]?\d+[.,]\d+)\s*(kg|lb|g|oz)?""", RegexOption.IGNORE_CASE).find(trimmed)
        if (fallbackMatch != null) {
            Log.i(TAG, "FALLBACK DECIMAL MATCH!")
            val numStr = fallbackMatch.groupValues[1].replace(',', '.')
            val unit = (fallbackMatch.groupValues.getOrElse(2) { "" }).lowercase().ifEmpty { "kg" }
            val weight = numStr.toDoubleOrNull() ?: return null
            Log.i(TAG, "DECIMAL WEIGHT PARSED: $weight $unit")
            return JSONObject().apply {
                put("weight", weight)
                put("unit", unit)
                put("stable", true)
            }
        }

        // Fallback 2: NCI/Mettler format (e.g. "00.00lb")
        val nciMatch = Regex("""(\d{1,3}[.,]\d{2,3})\s*(lb|kg|g|oz)?""", RegexOption.IGNORE_CASE).find(trimmed)
        if (nciMatch != null) {
            val numStr = nciMatch.groupValues[1].replace(',', '.')
            val unit = nciMatch.groupValues.getOrElse(2) { "lb" }.lowercase()
            val weight = numStr.toDoubleOrNull() ?: return null
            Log.i(TAG, "NCI WEIGHT PARSED: $weight $unit")
            return JSONObject().apply {
                put("weight", weight)
                put("unit", unit)
                put("stable", true)
            }
        }

        // Fallback 3: integer weight
        Log.d(TAG, "Trying fallback integer regex...")
        fallbackMatch = Regex("""([+-]?\d+)\s*(kg|lb|g|oz)\s*$""", RegexOption.IGNORE_CASE).find(trimmed)
        if (fallbackMatch != null) {
            Log.i(TAG, "FALLBACK INTEGER MATCH!")
            val numStr = fallbackMatch.groupValues[1]
            val unit = fallbackMatch.groupValues[2].lowercase()
            val weight = numStr.toDoubleOrNull() ?: return null
            Log.i(TAG, "INTEGER WEIGHT PARSED: $weight $unit")
            return JSONObject().apply {
                put("weight", weight)
                put("unit", unit)
                put("stable", true)
            }
        }

        // Fallback 3: standalone number
        Log.d(TAG, "Trying fallback standalone number...")
        val lastNum = Regex("""([+-]?\d+[.,]?\d*)\s*(kg|lb|g|oz)?\s*$""", RegexOption.IGNORE_CASE).find(trimmed)
        if (lastNum != null) {
            val numStr = lastNum.groupValues[1].replace(',', '.')
            if (numStr.replace(".", "").replace("-", "").length > 8 && !numStr.contains(".") && !numStr.contains(",")) {
                Log.d(TAG, "Standalone number too long - skipping")
                return null
            }
            val unit = (lastNum.groupValues.getOrElse(2) { "" }).lowercase().ifEmpty { "kg" }
            val weight = numStr.toDoubleOrNull() ?: return null
            if (weight >= 0.001 && weight <= 99999.999) {
                Log.i(TAG, "STANDALONE NUMBER PARSED: $weight $unit")
                return JSONObject().apply {
                    put("weight", weight)
                    put("unit", unit)
                    put("stable", true)
                }
            }
        }

        // Fallback 4: barcode+weight concatenated
        Log.d(TAG, "Trying concatenated barcode+weight fallback...")
        if (trimmed.all { it.isDigit() } && trimmed.length in 10..16) {
            if (trimmed.length >= 4) {
                val last4 = trimmed.takeLast(4)
                val weight4 = (last4.take(2) + "." + last4.takeLast(2)).toDoubleOrNull()
                if (weight4 != null && weight4 in 0.01..99.99) {
                    Log.i(TAG, "CONCATENATED 4-digit weight parsed: $weight4 kg")
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
                    Log.i(TAG, "CONCATENATED 5-digit weight parsed: $weight5 kg")
                    return JSONObject().apply {
                        put("weight", weight5)
                        put("unit", "kg")
                        put("stable", true)
                    }
                }
            }
        }

        Log.d(TAG, "parseWeight END - NO MATCH for line: '$trimmed'")
        return null
    }

    private fun handleDetach(device: UsbDevice) {
        val key = device.deviceName
        Log.i(TAG, "handleDetach() called for $key")
        val info = deviceConnections[key] ?: run {
            Log.d(TAG, "handleDetach - no connection info for $key, ignoring")
            return
        }
        val typeLabel = if (info.deviceType == DeviceType.SCALE) "Scale" else "Scanner"
        Log.w(TAG, "DEVICE DETACH CONFIRMED - $typeLabel $key - closing port")
        closePort(info, key)
        deviceConnections.remove(key)
        emitStatus("disconnected", "$typeLabel disconnected")
        if (listening) {
            Log.i(TAG, "Reconnecting in 1s after detach...")
            emitStatus("connecting", "Reconnecting...")
            mainHandler.postDelayed({ findAndConnect() }, 1000)
        }
    }

    private fun closePort(info: ConnectionInfo, key: String) {
        Log.d(TAG, "closePort() for $key")
        stopWeightPolling(info)
        info.stopRead.set(true)
        info.readThread?.interrupt()
        info.readThread = null
        try { info.port?.close() } catch (_: Exception) { Log.d(TAG, "port.close() exception ignored") }
        info.port = null
        try { info.connection?.close() } catch (_: Exception) { Log.d(TAG, "connection.close() exception ignored") }
        info.connection = null
        Log.i(TAG, "Port fully closed for $key")
    }

    private fun emitStatus(status: String, message: String) {
        Log.d(TAG, "emitStatus - status=$status message='$message'")
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
                Log.i(TAG, "=== WEIGHT EMITTED === $w $unit stable=$stable (raw: $rawLine)")
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
                Log.i(TAG, "=== SCAN EMITTED === $line")
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
            Log.d(TAG, "PermissionBroadcastReceiver onReceive - action=${intent?.action}")
            if (intent?.action == ACTION_USB_PERMISSION) {
                val granted = intent.getBooleanExtra(UsbManager.EXTRA_PERMISSION_GRANTED, false)
                @Suppress("DEPRECATION")
                val device = intent?.getParcelableExtra<UsbDevice>(UsbManager.EXTRA_DEVICE)
                manager.onPermissionResult(granted, device)
            }
        }
    }
}

const val ACTION_USB_PERMISSION = "com.example.magellan_scale.USB_PERMISSION"