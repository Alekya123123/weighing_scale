package com.example.magellan_scale

import android.content.Intent
import android.hardware.usb.UsbManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private var usbSerialManager: UsbSerialManager? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        usbSerialManager = UsbSerialManager(this).also { manager ->

            MethodChannel(
                flutterEngine.dartExecutor.binaryMessenger,
                "magellan_scale"
            ).setMethodCallHandler { call, result ->
                when (call.method) {
                    "start" -> {
                        manager.startListening()
                        result.success(null)
                    }
                    "stop" -> {
                        manager.stopListening()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }

            EventChannel(
                flutterEngine.dartExecutor.binaryMessenger,
                "magellan_scale/events"
            ).setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, eventSink: EventChannel.EventSink?) {
                    manager.setEventSink(eventSink)
                }

                override fun onCancel(arguments: Any?) {
                    manager.setEventSink(null)
                }
            })
        }

        handleUsbDeviceIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleUsbDeviceIntent(intent)
    }

    override fun onDestroy() {
        usbSerialManager?.dispose()
        usbSerialManager = null
        super.onDestroy()
    }

    private fun handleUsbDeviceIntent(intent: Intent?) {
        if (intent?.action == UsbManager.ACTION_USB_DEVICE_ATTACHED) {
            @Suppress("DEPRECATION")
            val device = intent.getParcelableExtra<android.hardware.usb.UsbDevice>(UsbManager.EXTRA_DEVICE)
            if (device != null && usbSerialManager != null) {
                usbSerialManager!!.connectToDevice(device)
            }
        }
    }
}
