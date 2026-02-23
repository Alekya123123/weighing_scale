// import 'dart:async';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:usb_serial/usb_serial.dart';
//
// // Complete Magellan Scanner-Scale Database
// class MagellanDeviceDatabase {
//   // Comprehensive Magellan device database with all models
//   static const Map<String, List<Map<String, dynamic>>> magellanDevices = {
//     ' Fixed / In-Counter Scanner & Scanner-Scale Models': [
//       {
//         'vid': 0x05F9, 'pid': 0x2204,
//         'model': 'Datalogic Magellan 9400i',
//         'type': 'In-counter scanner with adaptive scale',
//         'features': '• Reads 1D & 2D barcodes\n• All-Weighs™ scale platter\n• ScaleSentry™ system\n• Multi-interface support',
//         'dataBits': 8, 'stopBits': 1, 'parity': 'none', 'baud': 9600, 'rts': true, 'dtr': false,
//       },
//       {
//         'vid': 0x05F9, 'pid': 0x2205,
//         'model': 'Datalogic Magellan 9800i',
//         'type': 'High-performance in-counter scanner/scale',
//         'features': '• Advanced digital imaging\n• Customer-facing mobile reader\n• Large All-Weighs™ platter\n• ScaleSentry™ monitoring',
//         'dataBits': 8, 'stopBits': 1, 'parity': 'none', 'baud': 9600, 'rts': true, 'dtr': false,
//       },
//       {
//         'vid': 0x05F9, 'pid': 0x2202,
//         'model': 'Datalogic Magellan 9300i',
//         'type': 'In-counter scanner with optional scale',
//         'features': '• Full digital imagers for 1D/2D\n• Customer Service Scanner module\n• All-Weighs™ platter\n• Enhanced EAS support',
//         'dataBits': 8, 'stopBits': 1, 'parity': 'none', 'baud': 9600, 'rts': true, 'dtr': false,
//       },
//       // Scale-specific configuration for 9300i
//       {
//         'vid': 0x05F9, 'pid': 0x2202,
//         'model': 'Datalogic Magellan 9300i (Scale)',
//         'type': 'Scale Only Mode',
//         'features': '• Scale operation mode\n• 7-bit data with even parity',
//         'dataBits': 7, 'stopBits': 1, 'parity': 'even', 'baud': 9600, 'rts': true, 'dtr': false,
//       },
//     ],
//
//     '📦 Classic and Earlier Generation Magellan Models': [
//       {
//         'vid': 0x05F9, 'pid': 0x1100,
//         'model': 'Datalogic Magellan 2200VS',
//         'type': 'Horizontal fixed POS scanner (no scale)',
//         'features': '• Reads 1D barcodes\n• Multiple interface support\n• Compact design',
//         'dataBits': 8, 'stopBits': 1, 'parity': 'none', 'baud': 9600, 'rts': false, 'dtr': false,
//       },
//       {
//         'vid': 0x05F9, 'pid': 0x1101,
//         'model': 'DATALOGIC MAGELLAN 3300HSI',
//         'type': 'Handheld fixed scanner (multi-plane imaging)',
//         'features': '• Reads 1D & 2D barcodes\n• Suitable for small counters\n• Robust performance',
//         'dataBits': 8, 'stopBits': 1, 'parity': 'none', 'baud': 9600, 'rts': false, 'dtr': false,
//       },
//       {
//         'vid': 0x05F9, 'pid': 0x1102,
//         'model': 'MAGELLAN 3550HSi',
//         'type': 'Fixed barcode scanner (4-sided imaging)',
//         'features': '• 4-sided high-speed imaging\n• No orientation issues\n• Small POS counters',
//         'dataBits': 8, 'stopBits': 1, 'parity': 'none', 'baud': 9600, 'rts': false, 'dtr': false,
//       },
//       {
//         'vid': 0x05F9, 'pid': 0x1103,
//         'model': 'Datalogic Magellan 3450',
//         'type': 'Portable/handheld scanner',
//         'features': '• Reliable scanning\n• Entry-level scanner\n• Standard barcode reading',
//         'dataBits': 8, 'stopBits': 1, 'parity': 'none', 'baud': 9600, 'rts': false, 'dtr': false,
//       },
//       {
//         'vid': 0x05F9, 'pid': 0x1104,
//         'model': 'Wired Handheld M3450 VSI Magellan Scanner',
//         'type': 'Handheld scanner',
//         'features': '• Utility scanner\n• POS system compatible\n• Standard barcode reading',
//         'dataBits': 8, 'stopBits': 1, 'parity': 'none', 'baud': 9600, 'rts': false, 'dtr': false,
//       },
//     ],
//
//     // FTDI chips commonly used with Magellan scales
//     ' USB-Serial Adapters (FTDI)': [
//       {
//         'vid': 0x0403, 'pid': 0x6001,
//         'model': 'FTDI FT232R',
//         'type': 'USB-Serial Adapter',
//         'features': '• Common in Magellan USB cables\n• Converts scale to USB',
//         'dataBits': 8, 'stopBits': 1, 'parity': 'none', 'baud': 9600, 'rts': true, 'dtr': false,
//       },
//       {
//         'vid': 0x0403, 'pid': 0xB0C4,
//         'model': 'FTDI Serial Converter',
//         'type': 'USB-Serial Adapter',
//         'features': '• Magellan scale interface\n• High-speed conversion',
//         'dataBits': 8, 'stopBits': 1, 'parity': 'none', 'baud': 9600, 'rts': true, 'dtr': false,
//       },
//       {
//         'vid': 0x0403, 'pid': 0xB0C2,
//         'model': 'FTDI USB-Serial Converter',
//         'type': 'USB-Serial Adapter',
//         'features': '• Detected in your system\n• Magellan scale connection',
//         'dataBits': 8, 'stopBits': 1, 'parity': 'none', 'baud': 9600, 'rts': true, 'dtr': false,
//       },
//     ],
//   };
//
//   // Get all possible configurations for a device
//   static List<Map<String, dynamic>> getDeviceConfigurations(int? vid, int? pid) {
//     if (vid == null || pid == null) return [];
//
//     final configs = <Map<String, dynamic>>[];
//
//     for (var category in magellanDevices.keys) {
//       for (var device in magellanDevices[category]!) {
//         if (device['vid'] == vid && device['pid'] == pid) {
//           configs.add(device);
//         }
//       }
//     }
//
//     return configs;
//   }
//
//   // Get primary device info
//   static Map<String, dynamic>? identifyDevice(int? vid, int? pid) {
//     if (vid == null || pid == null) return null;
//
//     for (var category in magellanDevices.keys) {
//       for (var device in magellanDevices[category]!) {
//         if (device['vid'] == vid && device['pid'] == pid) {
//           return device;
//         }
//       }
//     }
//     return null;
//   }
//
//   // Get all devices for display
//   static List<Map<String, dynamic>> getAllDevices() {
//     final all = <Map<String, dynamic>>[];
//     for (var category in magellanDevices.keys) {
//       all.addAll(magellanDevices[category]!);
//     }
//     return all;
//   }
//
//   static String getParityString(int parity) {
//     switch (parity) {
//       case UsbPort.PARITY_NONE: return 'None';
//       case UsbPort.PARITY_ODD: return 'Odd';
//       case UsbPort.PARITY_EVEN: return 'Even';
//       default: return 'Unknown';
//     }
//   }
//
//   static int getParityValue(String parity) {
//     switch (parity.toLowerCase()) {
//       case 'none': return UsbPort.PARITY_NONE;
//       case 'odd': return UsbPort.PARITY_ODD;
//       case 'even': return UsbPort.PARITY_EVEN;
//       default: return UsbPort.PARITY_NONE;
//     }
//   }
// }
//
// // Connection error types
// enum ConnectionErrorType {
//   none,
//   noDevices,
//   noSerialDevices,
//   permissionDenied,
//   deviceBusy,
//   invalidConfiguration,
//   timeout,
//   disconnected,
//   unknown;
//
//   String get message {
//     switch (this) {
//       case ConnectionErrorType.none: return '';
//       case ConnectionErrorType.noDevices: return 'No USB devices found. Please connect the scale.';
//       case ConnectionErrorType.noSerialDevices: return 'No Magellan devices detected. Make sure the scale is properly connected.';
//       case ConnectionErrorType.permissionDenied: return 'Permission denied. Please grant USB access.';
//       case ConnectionErrorType.deviceBusy: return 'Device is busy. Close other applications using the scale.';
//       case ConnectionErrorType.invalidConfiguration: return 'Invalid configuration. Trying alternative settings...';
//       case ConnectionErrorType.timeout: return 'Connection timeout. Check cable and restart scale.';
//       case ConnectionErrorType.disconnected: return 'Scale disconnected. Attempting to reconnect...';
//       case ConnectionErrorType.unknown: return 'Unknown error occurred.';
//     }
//   }
//
//   IconData get icon {
//     switch (this) {
//       case ConnectionErrorType.none: return Icons.check_circle;
//       case ConnectionErrorType.noDevices: return Icons.usb_off;
//       case ConnectionErrorType.noSerialDevices: return Icons.sensors_off;
//       case ConnectionErrorType.permissionDenied: return Icons.block;
//       case ConnectionErrorType.deviceBusy: return Icons.access_time;
//       case ConnectionErrorType.invalidConfiguration: return Icons.settings_applications;
//       case ConnectionErrorType.timeout: return Icons.timer_off;
//       case ConnectionErrorType.disconnected: return Icons.link_off;
//       case ConnectionErrorType.unknown: return Icons.error;
//     }
//   }
//
//   Color get color {
//     switch (this) {
//       case ConnectionErrorType.none: return Colors.green;
//       case ConnectionErrorType.noDevices: return Colors.orange;
//       case ConnectionErrorType.noSerialDevices: return Colors.orange;
//       case ConnectionErrorType.permissionDenied: return Colors.red;
//       case ConnectionErrorType.deviceBusy: return Colors.orange;
//       case ConnectionErrorType.invalidConfiguration: return Colors.blue;
//       case ConnectionErrorType.timeout: return Colors.red;
//       case ConnectionErrorType.disconnected: return Colors.orange;
//       case ConnectionErrorType.unknown: return Colors.red;
//     }
//   }
// }
//
// class WeighingScaleScreen extends StatefulWidget {
//   final String productName;
//   final double unitPrice;
//   final String unit;
//
//   const WeighingScaleScreen({
//     super.key,
//     required this.productName,
//     required this.unitPrice,
//     this.unit = 'lb',
//   });
//
//   @override
//   State<WeighingScaleScreen> createState() => _WeighingScaleScreenState();
// }
//
// class _WeighingScaleScreenState extends State<WeighingScaleScreen> {
//   // Connection objects
//   UsbPort? _port;
//   StreamSubscription<Uint8List>? _subscription;
//   final _buffer = <int>[];
//   Timer? _reconnectTimer;
//   Timer? _dataCheckTimer;
//
//   // Device information - dynamically detected
//   UsbDevice? _currentDevice;
//   Map<String, dynamic>? _currentDeviceInfo;
//   List<Map<String, dynamic>> _detectedDevices = [];
//   List<Map<String, dynamic>> _allUsbDevices = [];
//
//   // Connection state
//   double _weight = 0.0;
//   bool _connected = false;
//   bool _isConnecting = false;
//   ConnectionErrorType _errorType = ConnectionErrorType.none;
//   String _errorDetails = '';
//   String _connectionMode = '';
//   int _attemptCount = 0;
//   int _totalAttempts = 0;
//   DateTime? _lastDataTime;
//   String _detectedModel = '';
//   String _detectedCategory = '';
//
//   // Manual entry
//   final TextEditingController _weightController = TextEditingController();
//   bool _isManualEntry = false;
//
//   // Logs
//   final List<Map<String, dynamic>> _logs = [];
//   final int _maxLogs = 200;
//
//   // Baud rates to try
//   final List<int> _baudRates = [9600, 4800, 19200, 38400, 115200, 57600];
//
//   @override
//   void initState() {
//     super.initState();
//     _weightController.addListener(_onManualWeightChanged);
//
//     // Start connection after build
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _connectScale();
//     });
//
//     // Monitor connection health
//     _dataCheckTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
//       _checkConnectionHealth();
//     });
//   }
//
//   @override
//   void dispose() {
//     _reconnectTimer?.cancel();
//     _dataCheckTimer?.cancel();
//     _weightController.removeListener(_onManualWeightChanged);
//     _weightController.dispose();
//     _cleanupPort();
//     super.dispose();
//   }
//
//   // Logging function with timestamp and type
//   void _log(String message, {String type = 'info', Map<String, dynamic>? data}) {
//     final logEntry = {
//       'time': DateTime.now(),
//       'message': message,
//       'type': type,
//       'data': data,
//     };
//
//     debugPrint('[$type] $message');
//
//     if (!mounted) return;
//     setState(() {
//       _logs.insert(0, logEntry);
//       if (_logs.length > _maxLogs) _logs.removeLast();
//     });
//   }
//
//   String _formatTime(DateTime time) {
//     return '${time.hour.toString().padLeft(2, '0')}:'
//         '${time.minute.toString().padLeft(2, '0')}:'
//         '${time.second.toString().padLeft(2, '0')}.'
//         '${(time.millisecond / 10).floor().toString().padLeft(2, '0')}';
//   }
//
//   void _onManualWeightChanged() {
//     final text = _weightController.text.trim();
//     if (text.isEmpty) {
//       setState(() { _weight = 0.0; _isManualEntry = false; });
//       return;
//     }
//     final parsed = double.tryParse(text);
//     if (parsed != null) {
//       setState(() { _weight = parsed; _isManualEntry = true; });
//       _log('Manual weight entered: $parsed ${widget.unit}', type: 'manual');
//     }
//   }
//
//   void _checkConnectionHealth() {
//     if (_connected && _lastDataTime != null) {
//       final now = DateTime.now();
//       final difference = now.difference(_lastDataTime!);
//
//       if (difference > const Duration(seconds: 10)) {
//         _log('⚠️ No data received for ${difference.inSeconds} seconds from $_detectedModel',
//             type: 'warning');
//
//         if (difference > const Duration(seconds: 30)) {
//           _log(' Connection appears dead - reconnecting $_detectedModel...', type: 'error');
//           _errorType = ConnectionErrorType.disconnected;
//           _errorDetails = 'No data for ${difference.inSeconds} seconds';
//           setState(() => _connected = false);
//           _attemptReconnection();
//         }
//       }
//     }
//   }
//
//   Future<void> _connectScale() async {
//     if (_isConnecting) return;
//
//     setState(() {
//       _isConnecting = true;
//       _errorType = ConnectionErrorType.none;
//       _errorDetails = '';
//       _attemptCount = 0;
//       _detectedDevices.clear();
//       _detectedModel = '';
//       _detectedCategory = '';
//     });
//
//     _log(' Starting Magellan scale detection...', type: 'scan');
//
//     try {
//       // Get all USB devices
//       final devices = await UsbSerial.listDevices();
//       _allUsbDevices = devices.map((d) {
//         return {
//           'device': d,
//           'name': d.productName ?? 'Unknown Device',
//           'vid': d.vid,
//           'pid': d.pid,
//           'manufacturer': d.manufacturerName ?? 'Unknown',
//           'serial': d.serial ?? 'N/A',
//         };
//       }).toList();
//
//       _log('📊 Found ${devices.length} total USB device(s):', type: 'scan');
//
//       if (devices.isEmpty) {
//         _setError(ConnectionErrorType.noDevices,
//             'No USB devices detected. Please connect your Magellan scale.');
//         _startContinuousScan();
//         return;
//       }
//
//       // Log all devices with detection
//       for (int i = 0; i < devices.length; i++) {
//         final d = devices[i];
//         final deviceInfo = MagellanDeviceDatabase.identifyDevice(d.vid, d.pid);
//         final modelName = deviceInfo?['model'] ?? 'Unknown Device';
//         final category = deviceInfo != null ?
//         _getCategoryForDevice(deviceInfo) : 'Non-Magellan Device';
//
//         _log('   Device ${i + 1}: ${d.productName ?? 'Unknown'}',
//             type: 'device',
//             data: {
//               'vid': '0x${d.vid?.toRadixString(16).toUpperCase().padLeft(4, '0')}',
//               'pid': '0x${d.pid?.toRadixString(16).toUpperCase().padLeft(4, '0')}',
//               'model': modelName,
//               'category': category,
//               'manufacturer': d.manufacturerName ?? 'Unknown',
//               'serial': d.serial ?? 'N/A',
//             });
//       }
//
//       // Filter Magellan and serial devices
//       final magellanDevices = devices.where((d) {
//         // Check if it's a known Magellan device
//         final known = MagellanDeviceDatabase.identifyDevice(d.vid, d.pid) != null;
//
//         // Check name for Magellan indicators
//         final name = (d.productName ?? '').toLowerCase();
//         final isMagellan = name.contains('magellan') ||
//             name.contains('datalogic') ||
//             name.contains('scale') ||
//             name.contains('scanner');
//
//         // Check for serial adapters commonly used with Magellan
//         final isSerialAdapter = (d.vid == 0x0403 && [0x6001, 0xB0C4, 0xB0C2].contains(d.pid)) ||
//             (d.vid == 0x067B && d.pid == 0x2303) ||
//             (d.vid == 0x10C4 && d.pid == 0xEA60) ||
//             (d.vid == 0x1A86 && [0x7523, 0x5512].contains(d.pid));
//
//         return known || isMagellan || isSerialAdapter;
//       }).toList();
//
//       if (magellanDevices.isEmpty) {
//         _setError(ConnectionErrorType.noSerialDevices,
//             'No Magellan devices found. Make sure your scale is connected properly.');
//
//         // Still show all devices for debugging
//         for (var d in devices) {
//           _detectedDevices.add({
//             'device': d,
//             'name': d.productName ?? 'Unknown',
//             'vid': d.vid,
//             'pid': d.pid,
//             'type': 'Non-Magellan Device',
//             'model': 'Unknown',
//           });
//         }
//         _startContinuousScan();
//         return;
//       }
//
//       _log('🔌 Found ${magellanDevices.length} Magellan/compatible device(s):', type: 'scan');
//
//       // Store detected devices with their info
//       for (var d in magellanDevices) {
//         final info = MagellanDeviceDatabase.identifyDevice(d.vid, d.pid);
//         final category = info != null ? _getCategoryForDevice(info) : 'Compatible Device';
//
//         _detectedDevices.add({
//           'device': d,
//           'name': d.productName ?? 'Unknown',
//           'vid': d.vid,
//           'pid': d.pid,
//           'model': info?['model'] ?? 'Magellan Compatible Device',
//           'type': info?['type'] ?? 'USB-Serial Adapter',
//           'category': category,
//           'features': info?['features'] ?? 'Standard USB-Serial interface',
//           'manufacturer': d.manufacturerName ?? 'Unknown',
//           'serial': d.serial ?? 'N/A',
//         });
//
//         _log('   ✅ ${info?['model'] ?? d.productName} - ${info?['type'] ?? 'Compatible Device'}',
//             type: 'device');
//       }
//
//       // Calculate total attempts
//       _totalAttempts = magellanDevices.length * _baudRates.length * 4; // 4 configs per baud
//
//       // Try each detected device
//       for (var deviceInfo in _detectedDevices) {
//         final device = deviceInfo['device'] as UsbDevice;
//         final configs = MagellanDeviceDatabase.getDeviceConfigurations(device.vid, device.pid);
//
//         if (configs.isNotEmpty) {
//           _log('⭐ Trying ${deviceInfo['model']} with manufacturer settings',
//               type: 'connection');
//
//           // Try manufacturer-recommended settings first
//           for (var config in configs) {
//             _attemptCount++;
//             final connected = await _tryConfiguration(
//               device,
//               config['baud'],
//               config['dataBits'],
//               config['stopBits'],
//               MagellanDeviceDatabase.getParityValue(config['parity']),
//               config['dtr'],
//               config['rts'],
//               deviceInfo,
//             );
//             if (connected) return;
//           }
//         }
//
//         // Try all combinations for this device
//         for (var baud in _baudRates) {
//           for (var config in _getConfigurations()) {
//             _attemptCount++;
//
//             setState(() {
//               _connectionMode = 'Trying ${deviceInfo['model']} @ '
//                   '${baud}/${config['dataBits']}${_getParityChar(config['parity'])}'
//                   '${config['stopBits']}';
//             });
//
//             final connected = await _tryConfiguration(
//               device,
//               baud,
//               config['dataBits'],
//               config['stopBits'],
//               config['parity'],
//               config['dtr'],
//               config['rts'],
//               deviceInfo,
//             );
//
//             if (connected) {
//               _log('✅ Success! Connected with: $baud baud, '
//                   '${config['dataBits']}${_getParityChar(config['parity'])}'
//                   '${config['stopBits']}', type: 'success');
//               return;
//             }
//
//             await Future.delayed(const Duration(milliseconds: 100));
//           }
//         }
//       }
//
//       // If we get here, no connection succeeded
//       _setError(ConnectionErrorType.invalidConfiguration,
//           'Tried all configurations but no data received. Check scale settings.');
//       _startContinuousScan();
//
//     } catch (e, st) {
//       _log(' Scan error: $e\n$st', type: 'error');
//       _setError(ConnectionErrorType.unknown, e.toString());
//       _startContinuousScan();
//     } finally {
//       if (mounted && !_connected) {
//         setState(() => _isConnecting = false);
//       }
//     }
//   }
//
//   String _getCategoryForDevice(Map<String, dynamic> device) {
//     for (var category in MagellanDeviceDatabase.magellanDevices.keys) {
//       if (MagellanDeviceDatabase.magellanDevices[category]!.contains(device)) {
//         return category;
//       }
//     }
//     return 'Other Devices';
//   }
//
//   List<Map<String, dynamic>> _getConfigurations() {
//     return [
//       // Standard configurations to try
//       {'dataBits': 8, 'stopBits': 1, 'parity': UsbPort.PARITY_NONE, 'dtr': true, 'rts': true},
//       {'dataBits': 8, 'stopBits': 1, 'parity': UsbPort.PARITY_NONE, 'dtr': false, 'rts': true},
//       {'dataBits': 8, 'stopBits': 1, 'parity': UsbPort.PARITY_NONE, 'dtr': false, 'rts': false},
//       {'dataBits': 7, 'stopBits': 1, 'parity': UsbPort.PARITY_EVEN, 'dtr': false, 'rts': true},
//       {'dataBits': 7, 'stopBits': 1, 'parity': UsbPort.PARITY_ODD, 'dtr': false, 'rts': true},
//       {'dataBits': 8, 'stopBits': 2, 'parity': UsbPort.PARITY_NONE, 'dtr': false, 'rts': true},
//     ];
//   }
//
//   String _getParityChar(int parity) {
//     switch (parity) {
//       case UsbPort.PARITY_NONE: return 'N';
//       case UsbPort.PARITY_ODD: return 'O';
//       case UsbPort.PARITY_EVEN: return 'E';
//       default: return '?';
//     }
//   }
//
//   Future<bool> _tryConfiguration(
//       UsbDevice device,
//       int baud,
//       int dataBits,
//       int stopBits,
//       int parity,
//       bool dtr,
//       bool rts,
//       Map<String, dynamic> deviceInfo,
//       ) async {
//     UsbPort? port;
//
//     try {
//       port = await device.create().timeout(
//         const Duration(seconds: 2),
//         onTimeout: () => null,
//       );
//
//       if (port == null) {
//         _log(' Failed to create port for ${deviceInfo['model']}', type: 'debug');
//         return false;
//       }
//
//       final opened = await port.open().timeout(
//         const Duration(seconds: 2),
//         onTimeout: () => false,
//       );
//
//       if (!opened) {
//         _log(' Failed to open port for ${deviceInfo['model']}', type: 'debug');
//         await _safeClose(port);
//         return false;
//       }
//
//       await port.setPortParameters(baud, dataBits, stopBits, parity);
//       await port.setDTR(dtr);
//       await port.setRTS(rts);
//
//       // Wait for scale to initialize
//       await Future.delayed(const Duration(milliseconds: 200));
//
//       _buffer.clear();
//
//       // Test for data
//       bool gotData = false;
//       final dataCompleter = Completer<bool>();
//       StreamSubscription<Uint8List>? testSub;
//
//       testSub = port.inputStream?.listen((data) {
//         if (data.isNotEmpty && !dataCompleter.isCompleted) {
//           dataCompleter.complete(true);
//         }
//       });
//
//       gotData = await dataCompleter.future
//           .timeout(const Duration(seconds: 2), onTimeout: () => false);
//
//       await testSub?.cancel();
//
//       if (!gotData) {
//         await _safeClose(port);
//         return false;
//       }
//
//       // Success! Setup permanent connection
//       await _setupPermanentConnection(port, device, deviceInfo, baud, dataBits, stopBits, parity, dtr, rts);
//       return true;
//
//     } catch (e) {
//       _log('  ⚠️ Connection error for ${deviceInfo['model']}: $e', type: 'debug');
//       await _safeClose(port);
//       return false;
//     }
//   }
//
//   Future<void> _setupPermanentConnection(
//       UsbPort port,
//       UsbDevice device,
//       Map<String, dynamic> deviceInfo,
//       int baud,
//       int dataBits,
//       int stopBits,
//       int parity,
//       bool dtr,
//       bool rts,
//       ) async {
//     await _subscription?.cancel();
//     _buffer.clear();
//
//     _currentDevice = device;
//     _currentDeviceInfo = deviceInfo;
//     _detectedModel = deviceInfo['model'];
//     _detectedCategory = deviceInfo['category'] ?? 'Magellan Device';
//
//     _subscription = port.inputStream?.listen(
//       _onData,
//       onError: (e) {
//         _log('❌ Stream error on $_detectedModel: $e', type: 'error');
//         _handleDisconnection('Stream error: $e');
//       },
//       onDone: () {
//         _log('⚠️ Stream closed for $_detectedModel', type: 'warning');
//         _handleDisconnection('Stream closed');
//       },
//     );
//
//     _port = port;
//     _connectionMode = '$baud/${dataBits}${_getParityChar(parity)}$stopBits';
//     _lastDataTime = DateTime.now();
//
//     if (mounted) {
//       setState(() {
//         _connected = true;
//         _isConnecting = false;
//         _errorType = ConnectionErrorType.none;
//       });
//     }
//
//     _log('✅ Connected to $_detectedModel', type: 'success', data: {
//       'model': deviceInfo['model'],
//       'type': deviceInfo['type'],
//       'features': deviceInfo['features'],
//       'baud': baud,
//       'dataBits': dataBits,
//       'stopBits': stopBits,
//       'parity': MagellanDeviceDatabase.getParityString(parity),
//       'dtr': dtr,
//       'rts': rts,
//     });
//   }
//
//   void _handleDisconnection(String reason) {
//     if (!mounted) return;
//
//     setState(() {
//       _connected = false;
//       _errorType = ConnectionErrorType.disconnected;
//       _errorDetails = reason;
//     });
//
//     _log('🔌 $_detectedModel disconnected: $reason', type: 'warning');
//     _attemptReconnection();
//   }
//
//   void _attemptReconnection() {
//     _reconnectTimer?.cancel();
//     _reconnectTimer = Timer(const Duration(seconds: 3), () {
//       if (mounted && !_connected && !_isConnecting) {
//         _log('🔄 Attempting to reconnect $_detectedModel...', type: 'info');
//         _connectScale();
//       }
//     });
//   }
//
//   void _startContinuousScan() {
//     _reconnectTimer?.cancel();
//     _reconnectTimer = Timer(const Duration(seconds: 5), () {
//       if (mounted && !_connected && !_isConnecting) {
//         _log('🔄 Rescanning for Magellan devices...', type: 'info');
//         _connectScale();
//       }
//     });
//   }
//
//   void _setError(ConnectionErrorType type, String details) {
//     if (mounted) {
//       setState(() {
//         _errorType = type;
//         _errorDetails = details;
//       });
//     }
//     _log('❌ ${type.message} $details', type: 'error');
//   }
//
//   Future<void> _safeClose(UsbPort? port) async {
//     try { await port?.close(); } catch (_) {}
//   }
//
//   Future<void> _cleanupPort() async {
//     await _subscription?.cancel();
//     _subscription = null;
//     await _safeClose(_port);
//     _port = null;
//   }
//
//   void _onData(Uint8List data) {
//     _lastDataTime = DateTime.now();
//     _buffer.addAll(data);
//
//     // Process newline-terminated frames
//     while (true) {
//       final idx = _buffer.indexOf(0x0A);
//       if (idx == -1) break;
//
//       final frame = _buffer.sublist(0, idx + 1);
//       _buffer.removeRange(0, idx + 1);
//
//       final line = String.fromCharCodes(frame).trim();
//       if (line.isNotEmpty) {
//         _log('📦 $_detectedModel: $line', type: 'data');
//         _applyWeight(_parseWeight(line));
//       }
//     }
//
//     // Handle data without newlines
//     if (_buffer.length > 32) {
//       final line = String.fromCharCodes(_buffer).trim();
//       _buffer.clear();
//       if (line.isNotEmpty) {
//         _log('📦 $_detectedModel (raw): $line', type: 'data');
//         _applyWeight(_parseWeight(line));
//       }
//     }
//   }
//
//   void _applyWeight(double? value) {
//     if (value == null || !mounted || _isManualEntry) return;
//
//     if (value >= 0 && value < 1000) {
//       setState(() {
//         _weight = value;
//         _weightController.removeListener(_onManualWeightChanged);
//         _weightController.text = _formatWeight(value);
//         _weightController.addListener(_onManualWeightChanged);
//       });
//     }
//   }
//
//   double? _parseWeight(String raw) {
//     final clean = raw.trim().replaceAll(RegExp(r'\s+'), ' ');
//
//     // Try to extract weight with unit
//     final unitMatch = RegExp(
//       r'([+-]?\d*\.?\d+)\s*(kg|g|lb|oz)',
//       caseSensitive: false,
//     ).firstMatch(clean);
//
//     if (unitMatch != null) {
//       final val = double.tryParse(unitMatch.group(1) ?? '');
//       final unit = unitMatch.group(2)?.toLowerCase() ?? '';
//       if (val != null) return _convert(val, unit);
//     }
//
//     // Try bare number
//     final numMatch = RegExp(r'([+-]?\d*\.?\d+)').firstMatch(clean);
//     if (numMatch != null) {
//       return double.tryParse(numMatch.group(1) ?? '');
//     }
//
//     return null;
//   }
//
//   double _convert(double value, String from) {
//     final to = widget.unit.toLowerCase();
//     switch (from) {
//       case 'kg': return to == 'lb' ? value * 2.20462 : value;
//       case 'lb': return to == 'kg' ? value / 2.20462 : value;
//       case 'g':
//         if (to == 'kg') return value / 1000;
//         if (to == 'lb') return value / 1000 * 2.20462;
//         return value;
//       case 'oz':
//         if (to == 'lb') return value / 16;
//         if (to == 'kg') return value * 0.0283495;
//         return value;
//       default: return value;
//     }
//   }
//
//   String _formatWeight(double v) => v.toStringAsFixed(3);
//   String _formatPrice(double v) => v.toStringAsFixed(2);
//
//   double get _calculatedPrice =>
//       (((_weight * widget.unitPrice) * 100).truncateToDouble()) / 100;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Magellan Scale Integration'),
//         backgroundColor: const Color(0xFFFF6B6B),
//         actions: [
//           if (_isConnecting)
//             const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 14),
//               child: SizedBox(
//                 width: 20,
//                 height: 20,
//                 child: CircularProgressIndicator(
//                     color: Colors.white,
//                     strokeWidth: 2
//                 ),
//               ),
//             )
//           else
//             IconButton(
//               icon: Icon(
//                 _connected ? Icons.usb : Icons.usb_off,
//                 color: _connected ? Colors.greenAccent : Colors.white70,
//               ),
//               onPressed: _connected ? _cleanupPort : _connectScale,
//             ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // Connection Status Card with Dynamic Model Name
//             _ConnectionStatusCard(
//               connected: _connected,
//               isConnecting: _isConnecting,
//               deviceModel: _detectedModel,
//               deviceCategory: _detectedCategory,
//               connectionMode: _connectionMode,
//               errorType: _errorType,
//               errorDetails: _errorDetails,
//               attemptCount: _attemptCount,
//               totalAttempts: _totalAttempts,
//               lastDataTime: _lastDataTime,
//               onRetry: _connectScale,
//             ),
//
//             const SizedBox(height: 16),
//
//             // Product Info Card
//             _ProductInfoCard(
//               productName: widget.productName,
//               unitPrice: widget.unitPrice,
//               unit: widget.unit,
//             ),
//
//             const SizedBox(height: 16),
//
//             // Weight Input Card
//             _WeightInputCard(
//               weight: _weight,
//               calculatedPrice: _calculatedPrice,
//               unit: widget.unit,
//               controller: _weightController,
//               isManualEntry: _isManualEntry,
//               deviceModel: _detectedModel,
//               onConfirm: _weight > 0 ? () {
//                 Navigator.of(context).pop({
//                   'weight': _weight,
//                   'finalPrice': _calculatedPrice,
//                   'device': _detectedModel,
//                 });
//               } : null,
//             ),
//
//             const SizedBox(height: 16),
//
//             // Detected Magellan Devices Card
//             _MagellanDevicesCard(
//               detectedDevices: _detectedDevices,
//               currentModel: _detectedModel,
//               allDevices: _allUsbDevices,
//             ),
//
//             const SizedBox(height: 16),
//
//             // Features Card (when connected)
//             if (_connected && _currentDeviceInfo != null)
//               _DeviceFeaturesCard(
//                 deviceInfo: _currentDeviceInfo!,
//               ),
//
//             const SizedBox(height: 16),
//
//             // Logs Card
//             _LogsCard(
//               logs: _logs,
//               formatTime: _formatTime,
//               onClear: () => setState(() => _logs.clear()),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // ==================== Enhanced UI Components ====================
//
// class _ConnectionStatusCard extends StatelessWidget {
//   final bool connected;
//   final bool isConnecting;
//   final String deviceModel;
//   final String deviceCategory;
//   final String connectionMode;
//   final ConnectionErrorType errorType;
//   final String errorDetails;
//   final int attemptCount;
//   final int totalAttempts;
//   final DateTime? lastDataTime;
//   final VoidCallback onRetry;
//
//   const _ConnectionStatusCard({
//     required this.connected,
//     required this.isConnecting,
//     required this.deviceModel,
//     required this.deviceCategory,
//     required this.connectionMode,
//     required this.errorType,
//     required this.errorDetails,
//     required this.attemptCount,
//     required this.totalAttempts,
//     required this.lastDataTime,
//     required this.onRetry,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 3,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Container(
//         decoration: BoxDecoration(
//           gradient: connected ? LinearGradient(
//             colors: [Colors.green.shade400, Colors.green.shade600],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ) : null,
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.2),
//                       shape: BoxShape.circle,
//                     ),
//                     child: Icon(
//                       connected ? Icons.check_circle :
//                       isConnecting ? Icons.sync :
//                       errorType != ConnectionErrorType.none ? errorType.icon :
//                       Icons.usb_off,
//                       color: connected ? Colors.white :
//                       isConnecting ? Colors.blue :
//                       errorType != ConnectionErrorType.none ? errorType.color :
//                       Colors.grey,
//                       size: 28,
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           connected ? 'Connected to:' :
//                           isConnecting ? 'Connecting...' :
//                           errorType != ConnectionErrorType.none ? 'Connection Error' :
//                           'No Device Connected',
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: connected ? Colors.white70 :
//                             isConnecting ? Colors.blueGrey :
//                             errorType != ConnectionErrorType.none ? errorType.color :
//                             Colors.grey,
//                           ),
//                         ),
//                         if (connected && deviceModel.isNotEmpty)
//                           Text(
//                             deviceModel,
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: connected ? Colors.white : Colors.black,
//                             ),
//                           ),
//                         if (connected && deviceCategory.isNotEmpty)
//                           Text(
//                             deviceCategory,
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: connected ? Colors.white70 : Colors.grey,
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//                   if (!connected && !isConnecting)
//                     ElevatedButton(
//                       onPressed: onRetry,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: errorType.color,
//                         foregroundColor: Colors.white,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                       ),
//                       child: const Text('Retry'),
//                     ),
//                 ],
//               ),
//
//               if (connected && connectionMode.isNotEmpty) ...[
//                 const SizedBox(height: 12),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     'Mode: $connectionMode',
//                     style: const TextStyle(color: Colors.white, fontSize: 12),
//                   ),
//                 ),
//               ],
//
//               if (errorType != ConnectionErrorType.none) ...[
//                 const SizedBox(height: 12),
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: errorType.color.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(color: errorType.color.withOpacity(0.3)),
//                   ),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: Text(
//                           errorDetails.isNotEmpty ? errorDetails : errorType.message,
//                           style: TextStyle(
//                             color: errorType.color,
//                             fontSize: 13,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//
//               if (isConnecting && totalAttempts > 0) ...[
//                 const SizedBox(height: 12),
//                 LinearProgressIndicator(
//                   value: attemptCount / totalAttempts,
//                   backgroundColor: Colors.grey[200],
//                   valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Scanning configurations: $attemptCount of $totalAttempts',
//                   style: const TextStyle(fontSize: 12, color: Colors.grey),
//                 ),
//               ],
//
//               if (connected && lastDataTime != null) ...[
//                 const SizedBox(height: 8),
//                 Row(
//                   children: [
//                     Icon(
//                       Icons.access_time,
//                       size: 14,
//                       color: DateTime.now().difference(lastDataTime!) >
//                           const Duration(seconds: 5) ? Colors.orange : Colors.white70,
//                     ),
//                     const SizedBox(width: 4),
//                     Text(
//                       'Last data: ${_formatTimeDifference(lastDataTime!)}',
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: DateTime.now().difference(lastDataTime!) >
//                             const Duration(seconds: 5) ? Colors.orange : Colors.white70,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   String _formatTimeDifference(DateTime time) {
//     final diff = DateTime.now().difference(time);
//     if (diff.inSeconds < 1) return 'just now';
//     if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
//     return '${diff.inMinutes}m ago';
//   }
// }
//
// class _MagellanDevicesCard extends StatelessWidget {
//   final List<Map<String, dynamic>> detectedDevices;
//   final String currentModel;
//   final List<Map<String, dynamic>> allDevices;
//
//   const _MagellanDevicesCard({
//     required this.detectedDevices,
//     required this.currentModel,
//     required this.allDevices,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 const Icon(Icons.scanner, color: Color(0xFFFF6B6B), size: 20),
//                 const SizedBox(width: 8),
//                 const Text(
//                   'Detected Magellan Devices',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                 ),
//                 const Spacer(),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                   decoration: BoxDecoration(
//                     color: Colors.blue.shade50,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Text(
//                     '${detectedDevices.length} found',
//                     style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//
//             if (detectedDevices.isEmpty) ...[
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.grey[50],
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.grey[300]!),
//                 ),
//                 child: const Center(
//                   child: Text(
//                     'No Magellan devices detected.\nConnect your scale and tap Retry.',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(color: Colors.grey),
//                   ),
//                 ),
//               ),
//             ] else
//               ...detectedDevices.map((device) => Container(
//                 margin: const EdgeInsets.only(bottom: 8),
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: device['model'] == currentModel
//                       ? Colors.green.shade50
//                       : Colors.grey[50],
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(
//                     color: device['model'] == currentModel
//                         ? Colors.green.shade300
//                         : Colors.grey[300]!,
//                     width: device['model'] == currentModel ? 2 : 1,
//                   ),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Expanded(
//                           child: Text(
//                             device['model'],
//                             style: TextStyle(
//                               fontWeight: device['model'] == currentModel
//                                   ? FontWeight.bold
//                                   : FontWeight.w600,
//                               color: device['model'] == currentModel
//                                   ? Colors.green.shade700
//                                   : Colors.black,
//                             ),
//                           ),
//                         ),
//                         if (device['model'] == currentModel)
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 8,
//                               vertical: 2,
//                             ),
//                             decoration: BoxDecoration(
//                               color: Colors.green,
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: const Text(
//                               'ACTIVE',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                       ],
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       device['type'],
//                       style: const TextStyle(fontSize: 12, color: Colors.grey),
//                     ),
//                     const SizedBox(height: 4),
//                     Wrap(
//                       spacing: 8,
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                           decoration: BoxDecoration(
//                             color: Colors.blue.shade50,
//                             borderRadius: BorderRadius.circular(4),
//                           ),
//                           child: Text(
//                             'VID:0x${device['vid']?.toRadixString(16).toUpperCase()}',
//                             style: TextStyle(fontSize: 10, color: Colors.blue.shade700),
//                           ),
//                         ),
//                         Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                           decoration: BoxDecoration(
//                             color: Colors.purple.shade50,
//                             borderRadius: BorderRadius.circular(4),
//                           ),
//                           child: Text(
//                             'PID:0x${device['pid']?.toRadixString(16).toUpperCase()}',
//                             style: TextStyle(fontSize: 10, color: Colors.purple.shade700),
//                           ),
//                         ),
//                       ],
//                     ),
//                     if (device['serial'] != 'N/A') ...[
//                       const SizedBox(height: 4),
//                       Text(
//                         'SN: ${device['serial']}',
//                         style: const TextStyle(fontSize: 11, color: Colors.grey),
//                       ),
//                     ],
//                   ],
//                 ),
//               )),
//
//             if (allDevices.length > detectedDevices.length) ...[
//               const SizedBox(height: 12),
//               Text(
//                 'Other USB devices: ${allDevices.length - detectedDevices.length}',
//                 style: const TextStyle(fontSize: 12, color: Colors.grey),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _DeviceFeaturesCard extends StatelessWidget {
//   final Map<String, dynamic> deviceInfo;
//
//   const _DeviceFeaturesCard({required this.deviceInfo});
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Colors.blue.shade50, Colors.white],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Icon(Icons.star, color: Colors.amber.shade600, size: 20),
//                   const SizedBox(width: 8),
//                   Text(
//                     deviceInfo['model'],
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 deviceInfo['type'],
//                 style: const TextStyle(
//                   fontSize: 13,
//                   color: Colors.blueGrey,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               const SizedBox(height: 12),
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.blue.shade100),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Features:',
//                       style: TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.blueGrey,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       deviceInfo['features'] ?? 'Standard Magellan features',
//                       style: const TextStyle(fontSize: 12, height: 1.5),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class _ProductInfoCard extends StatelessWidget {
//   final String productName;
//   final double unitPrice;
//   final String unit;
//
//   const _ProductInfoCard({
//     required this.productName,
//     required this.unitPrice,
//     required this.unit,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Row(
//           children: [
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Product',
//                     style: TextStyle(fontSize: 12, color: Colors.grey),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     productName,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Container(
//               width: 1,
//               height: 40,
//               color: Colors.grey[300],
//               margin: const EdgeInsets.symmetric(horizontal: 16),
//             ),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Unit Price',
//                     style: TextStyle(fontSize: 12, color: Colors.grey),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     '\$${unitPrice.toStringAsFixed(2)}/$unit',
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: Color(0xFFFF6B6B),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _WeightInputCard extends StatelessWidget {
//   final double weight;
//   final double calculatedPrice;
//   final String unit;
//   final TextEditingController controller;
//   final bool isManualEntry;
//   final String deviceModel;
//   final VoidCallback? onConfirm;
//
//   const _WeightInputCard({
//     required this.weight,
//     required this.calculatedPrice,
//     required this.unit,
//     required this.controller,
//     required this.isManualEntry,
//     required this.deviceModel,
//     required this.onConfirm,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Text(
//                             'Weight ($unit)',
//                             style: const TextStyle(fontSize: 12, color: Colors.grey),
//                           ),
//                           if (deviceModel.isNotEmpty) ...[
//                             const SizedBox(width: 8),
//                             Container(
//                               padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                               decoration: BoxDecoration(
//                                 color: Colors.green.shade50,
//                                 borderRadius: BorderRadius.circular(4),
//                               ),
//                               child: Text(
//                                 'via $deviceModel',
//                                 style: TextStyle(
//                                   fontSize: 9,
//                                   color: Colors.green.shade700,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ],
//                       ),
//                       const SizedBox(height: 8),
//                       TextField(
//                         controller: controller,
//                         keyboardType: TextInputType.numberWithOptions(decimal: true),
//                         decoration: InputDecoration(
//                           hintText: '0.000',
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           contentPadding: const EdgeInsets.symmetric(
//                             horizontal: 12,
//                             vertical: 12,
//                           ),
//                           suffixIcon: isManualEntry
//                               ? const Icon(Icons.edit, size: 16, color: Colors.blue)
//                               : deviceModel.isNotEmpty
//                               ? const Icon(Icons.sensors, size: 16, color: Colors.green)
//                               : null,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Price',
//                         style: TextStyle(fontSize: 12, color: Colors.grey),
//                       ),
//                       const SizedBox(height: 8),
//                       Container(
//                         height: 48,
//                         decoration: BoxDecoration(
//                           color: Colors.grey[100],
//                           borderRadius: BorderRadius.circular(8),
//                           border: Border.all(color: Colors.grey[300]!),
//                         ),
//                         alignment: Alignment.centerLeft,
//                         padding: const EdgeInsets.symmetric(horizontal: 12),
//                         child: Text(
//                           weight > 0 ? '\$${calculatedPrice.toStringAsFixed(2)}' : '0.00',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                             color: weight > 0 ? Colors.black : Colors.grey,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             SizedBox(
//               width: double.infinity,
//               height: 48,
//               child: ElevatedButton(
//                 onPressed: onConfirm,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFFFF6B6B),
//                   foregroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 child: Text(
//                   weight > 0 ? 'Confirm & Add (${weight.toStringAsFixed(3)} $unit)' : 'Confirm & Add',
//                   style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _LogsCard extends StatelessWidget {
//   final List<Map<String, dynamic>> logs;
//   final String Function(DateTime) formatTime;
//   final VoidCallback onClear;
//
//   const _LogsCard({
//     required this.logs,
//     required this.formatTime,
//     required this.onClear,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'Event Logs',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                 ),
//                 TextButton.icon(
//                   onPressed: onClear,
//                   icon: const Icon(Icons.delete_sweep, size: 16),
//                   label: const Text('Clear'),
//                   style: TextButton.styleFrom(
//                     foregroundColor: Colors.grey,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Container(
//               height: 200,
//               decoration: BoxDecoration(
//                 color: Colors.grey[50],
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: Colors.grey[300]!),
//               ),
//               child: logs.isEmpty
//                   ? const Center(
//                 child: Text(
//                   'No logs yet',
//                   style: TextStyle(color: Colors.grey),
//                 ),
//               )
//                   : ListView.builder(
//                 reverse: true,
//                 itemCount: logs.length,
//                 itemBuilder: (context, index) {
//                   final log = logs[index];
//                   final time = log['time'] as DateTime;
//                   final message = log['message'] as String;
//                   final type = log['type'] as String;
//
//                   Color color = Colors.black87;
//                   IconData? icon;
//
//                   switch (type) {
//                     case 'error':
//                       color = Colors.red;
//                       icon = Icons.error;
//                       break;
//                     case 'warning':
//                       color = Colors.orange;
//                       icon = Icons.warning;
//                       break;
//                     case 'success':
//                       color = Colors.green;
//                       icon = Icons.check_circle;
//                       break;
//                     case 'data':
//                       color = Colors.blue;
//                       icon = Icons.data_usage;
//                       break;
//                     case 'device':
//                       color = Colors.purple;
//                       icon = Icons.usb;
//                       break;
//                     case 'scan':
//                       color = Colors.teal;
//                       icon = Icons.search;
//                       break;
//                     case 'connection':
//                       color = Colors.indigo;
//                       icon = Icons.link;
//                       break;
//                     case 'manual':
//                       color = Colors.amber;
//                       icon = Icons.edit;
//                       break;
//                   }
//
//                   return Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 8,
//                       vertical: 6,
//                     ),
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         if (icon != null) ...[
//                           Icon(icon, size: 12, color: color),
//                           const SizedBox(width: 4),
//                         ],
//                         Text(
//                           '[${formatTime(time)}]',
//                           style: const TextStyle(
//                             fontSize: 10,
//                             color: Colors.grey,
//                             fontFamily: 'monospace',
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         Expanded(
//                           child: Text(
//                             message,
//                             style: TextStyle(
//                               fontSize: 11,
//                               color: color,
//                               fontFamily: 'monospace',
//                               fontWeight: type == 'success' ? FontWeight.bold : FontWeight.normal,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



//////

import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:usb_serial/usb_serial.dart';

// Complete Magellan Scanner-Scale Database
class MagellanDeviceDatabase {
  static const Map<String, List<Map<String, dynamic>>> magellanDevices = {
    ' Fixed / In-Counter Scanner & Scanner-Scale Models': [
      {
        'vid': 0x05F9, 'pid': 0x2204,
        'model': 'Datalogic Magellan 9400i',
        'type': 'In-counter scanner with adaptive scale',
        'features': '• Reads 1D & 2D barcodes\n• All-Weighs™ scale platter\n• ScaleSentry™ system\n• Multi-interface support',
        'dataBits': 8, 'stopBits': 1, 'parity': 'none', 'baud': 9600, 'rts': true, 'dtr': false,
      },
      {
        'vid': 0x05F9, 'pid': 0x2205,
        'model': 'Datalogic Magellan 9800i',
        'type': 'High-performance in-counter scanner/scale',
        'features': '• Advanced digital imaging\n• Customer-facing mobile reader\n• Large All-Weighs™ platter\n• ScaleSentry™ monitoring',
        'dataBits': 8, 'stopBits': 1, 'parity': 'none', 'baud': 9600, 'rts': true, 'dtr': false,
      },
      {
        'vid': 0x05F9, 'pid': 0x2202,
        'model': 'Datalogic Magellan 9300i',
        'type': 'In-counter scanner with optional scale',
        'features': '• Full digital imagers for 1D/2D\n• Customer Service Scanner module\n• All-Weighs™ platter\n• Enhanced EAS support',
        'dataBits': 8, 'stopBits': 1, 'parity': 'none', 'baud': 9600, 'rts': true, 'dtr': false,
      },
      {
        'vid': 0x05F9, 'pid': 0x2202,
        'model': 'Datalogic Magellan 9300i (Scale)',
        'type': 'Scale Only Mode',
        'features': '• Scale operation mode\n• 7-bit data with even parity',
        'dataBits': 7, 'stopBits': 1, 'parity': 'even', 'baud': 9600, 'rts': true, 'dtr': false,
      },
    ],
    '📦 Classic and Earlier Generation Magellan Models': [
      {
        'vid': 0x05F9, 'pid': 0x1100,
        'model': 'Datalogic Magellan 2200VS',
        'type': 'Horizontal fixed POS scanner (no scale)',
        'features': '• Reads 1D barcodes\n• Multiple interface support\n• Compact design',
        'dataBits': 8, 'stopBits': 1, 'parity': 'none', 'baud': 9600, 'rts': false, 'dtr': false,
      },
      {
        'vid': 0x05F9, 'pid': 0x1101,
        'model': 'DATALOGIC MAGELLAN 3300HSI',
        'type': 'Handheld fixed scanner (multi-plane imaging)',
        'features': '• Reads 1D & 2D barcodes\n• Suitable for small counters\n• Robust performance',
        'dataBits': 8, 'stopBits': 1, 'parity': 'none', 'baud': 9600, 'rts': false, 'dtr': false,
      },
      {
        'vid': 0x05F9, 'pid': 0x1102,
        'model': 'MAGELLAN 3550HSi',
        'type': 'Fixed barcode scanner (4-sided imaging)',
        'features': '• 4-sided high-speed imaging\n• No orientation issues\n• Small POS counters',
        'dataBits': 8, 'stopBits': 1, 'parity': 'none', 'baud': 9600, 'rts': false, 'dtr': false,
      },
      {
        'vid': 0x05F9, 'pid': 0x1103,
        'model': 'Datalogic Magellan 3450',
        'type': 'Portable/handheld scanner',
        'features': '• Reliable scanning\n• Entry-level scanner\n• Standard barcode reading',
        'dataBits': 8, 'stopBits': 1, 'parity': 'none', 'baud': 9600, 'rts': false, 'dtr': false,
      },
      {
        'vid': 0x05F9, 'pid': 0x1104,
        'model': 'Wired Handheld M3450 VSI Magellan Scanner',
        'type': 'Handheld scanner',
        'features': '• Utility scanner\n• POS system compatible\n• Standard barcode reading',
        'dataBits': 8, 'stopBits': 1, 'parity': 'none', 'baud': 9600, 'rts': false, 'dtr': false,
      },
    ],
    ' USB-Serial Adapters (FTDI)': [
      {
        'vid': 0x0403, 'pid': 0x6001,
        'model': 'FTDI FT232R',
        'type': 'USB-Serial Adapter',
        'features': '• Common in Magellan USB cables\n• Converts scale to USB',
        'dataBits': 8, 'stopBits': 1, 'parity': 'none', 'baud': 9600, 'rts': true, 'dtr': false,
      },
      {
        'vid': 0x0403, 'pid': 0xB0C4,
        'model': 'FTDI Serial Converter',
        'type': 'USB-Serial Adapter',
        'features': '• Magellan scale interface\n• High-speed conversion',
        'dataBits': 8, 'stopBits': 1, 'parity': 'none', 'baud': 9600, 'rts': true, 'dtr': false,
      },
      {
        'vid': 0x0403, 'pid': 0xB0C2,
        'model': 'FTDI USB-Serial Converter',
        'type': 'USB-Serial Adapter',
        'features': '• Detected in your system\n• Magellan scale connection',
        'dataBits': 8, 'stopBits': 1, 'parity': 'none', 'baud': 9600, 'rts': true, 'dtr': false,
      },
    ],
  };

  static List<Map<String, dynamic>> getDeviceConfigurations(int? vid, int? pid) {
    if (vid == null || pid == null) return [];
    final configs = <Map<String, dynamic>>[];
    for (var category in magellanDevices.keys) {
      for (var device in magellanDevices[category]!) {
        if (device['vid'] == vid && device['pid'] == pid) configs.add(device);
      }
    }
    return configs;
  }

  static Map<String, dynamic>? identifyDevice(int? vid, int? pid) {
    if (vid == null || pid == null) return null;
    for (var category in magellanDevices.keys) {
      for (var device in magellanDevices[category]!) {
        if (device['vid'] == vid && device['pid'] == pid) return device;
      }
    }
    return null;
  }

  static String getParityString(int parity) {
    switch (parity) {
      case UsbPort.PARITY_NONE: return 'None';
      case UsbPort.PARITY_ODD: return 'Odd';
      case UsbPort.PARITY_EVEN: return 'Even';
      default: return 'Unknown';
    }
  }

  static int getParityValue(String parity) {
    switch (parity.toLowerCase()) {
      case 'none': return UsbPort.PARITY_NONE;
      case 'odd': return UsbPort.PARITY_ODD;
      case 'even': return UsbPort.PARITY_EVEN;
      default: return UsbPort.PARITY_NONE;
    }
  }
}

// ── Input type classification (from POSPage logic) ──────────────────────────
enum InputType { weight, barcode, unknown }

class ParsedInput {
  final InputType type;
  final double? weight;       // kg value if type == weight
  final String? barcodeValue; // raw string if type == barcode
  final String raw;

  const ParsedInput({
    required this.type,
    required this.raw,
    this.weight,
    this.barcodeValue,
  });
}

/// Parses a raw string from either a keyboard wedge scanner or serial stream.
/// Priority: weight pattern → decimal number → pure barcode.
ParsedInput parsePOSInput(String value) {
  final normalized = value.trim().replaceAll(' ', '').toUpperCase();

  // Weight pattern: optional W prefix, digits, optional decimal, KG suffix
  final weightPattern = RegExp(r'^W?(\d+([.,]\d+)?)KG?$');
  final wMatch = weightPattern.firstMatch(normalized);
  if (wMatch != null) {
    final w = double.tryParse(wMatch.group(1)!.replaceAll(',', '.'));
    if (w != null) return ParsedInput(type: InputType.weight, raw: value, weight: w);
  }

  // Decimal number without unit → treat as weight (kg)
  if (normalized.contains(',') || normalized.contains('.')) {
    final w = double.tryParse(normalized.replaceAll(',', '.'));
    if (w != null) return ParsedInput(type: InputType.weight, raw: value, weight: w);
  }

  // Pure numeric / alphanumeric → barcode
  if (normalized.isNotEmpty) {
    return ParsedInput(type: InputType.barcode, raw: value, barcodeValue: normalized);
  }

  return ParsedInput(type: InputType.unknown, raw: value);
}

// ── Connection error types ───────────────────────────────────────────────────
enum ConnectionErrorType {
  none, noDevices, noSerialDevices, permissionDenied,
  deviceBusy, invalidConfiguration, timeout, disconnected, unknown;

  String get message {
    switch (this) {
      case ConnectionErrorType.none: return '';
      case ConnectionErrorType.noDevices: return 'No USB devices found. Please connect the scale.';
      case ConnectionErrorType.noSerialDevices: return 'No Magellan devices detected. Make sure the scale is properly connected.';
      case ConnectionErrorType.permissionDenied: return 'Permission denied. Please grant USB access.';
      case ConnectionErrorType.deviceBusy: return 'Device is busy. Close other applications using the scale.';
      case ConnectionErrorType.invalidConfiguration: return 'Invalid configuration. Trying alternative settings...';
      case ConnectionErrorType.timeout: return 'Connection timeout. Check cable and restart scale.';
      case ConnectionErrorType.disconnected: return 'Scale disconnected. Attempting to reconnect...';
      case ConnectionErrorType.unknown: return 'Unknown error occurred.';
    }
  }

  IconData get icon {
    switch (this) {
      case ConnectionErrorType.none: return Icons.check_circle;
      case ConnectionErrorType.noDevices: return Icons.usb_off;
      case ConnectionErrorType.noSerialDevices: return Icons.sensors_off;
      case ConnectionErrorType.permissionDenied: return Icons.block;
      case ConnectionErrorType.deviceBusy: return Icons.access_time;
      case ConnectionErrorType.invalidConfiguration: return Icons.settings_applications;
      case ConnectionErrorType.timeout: return Icons.timer_off;
      case ConnectionErrorType.disconnected: return Icons.link_off;
      case ConnectionErrorType.unknown: return Icons.error;
    }
  }

  Color get color {
    switch (this) {
      case ConnectionErrorType.none: return Colors.green;
      case ConnectionErrorType.noDevices: return Colors.orange;
      case ConnectionErrorType.noSerialDevices: return Colors.orange;
      case ConnectionErrorType.permissionDenied: return Colors.red;
      case ConnectionErrorType.deviceBusy: return Colors.orange;
      case ConnectionErrorType.invalidConfiguration: return Colors.blue;
      case ConnectionErrorType.timeout: return Colors.red;
      case ConnectionErrorType.disconnected: return Colors.orange;
      case ConnectionErrorType.unknown: return Colors.red;
    }
  }
}

// ── Main screen ──────────────────────────────────────────────────────────────
class WeighingScaleScreen extends StatefulWidget {
  final String productName;
  final double unitPrice;
  final String unit;

  const WeighingScaleScreen({
    super.key,
    required this.productName,
    required this.unitPrice,
    this.unit = 'lb',
  });

  @override
  State<WeighingScaleScreen> createState() => _WeighingScaleScreenState();
}

class _WeighingScaleScreenState extends State<WeighingScaleScreen> {
  // ── USB serial ──
  UsbPort? _port;
  StreamSubscription<Uint8List>? _subscription;
  final _buffer = <int>[];
  Timer? _reconnectTimer;
  Timer? _dataCheckTimer;

  UsbDevice? _currentDevice;
  Map<String, dynamic>? _currentDeviceInfo;
  List<Map<String, dynamic>> _detectedDevices = [];
  List<Map<String, dynamic>> _allUsbDevices = [];

  bool _connected = false;
  bool _isConnecting = false;
  ConnectionErrorType _errorType = ConnectionErrorType.none;
  String _errorDetails = '';
  String _connectionMode = '';
  int _attemptCount = 0;
  int _totalAttempts = 0;
  DateTime? _lastDataTime;
  String _detectedModel = '';
  String _detectedCategory = '';

  // ── POS state (merged from POSPage) ──
  double _weight = 0.0;
  String _barcode = '';
  bool _weightIsBarcode = false;   // true when the "weight field" is showing a barcode
  bool _isManualEntry = false;

  // ── Keyboard wedge (cross-platform fallback) ──
  final TextEditingController _wedgeController = TextEditingController();
  final FocusNode _wedgeFocusNode = FocusNode();

  // ── Weight text controller ──
  final TextEditingController _weightController = TextEditingController();

  // ── Logs ──
  final List<Map<String, dynamic>> _logs = [];
  final int _maxLogs = 200;

  final List<int> _baudRates = [9600, 4800, 19200, 38400, 115200, 57600];

  // ── Lifecycle ────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _weightController.addListener(_onManualWeightChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _connectScale();
      _wedgeFocusNode.requestFocus();
      _log('POS system initialized.', type: 'info');
    });

    _dataCheckTimer = Timer.periodic(const Duration(seconds: 3), (_) => _checkConnectionHealth());
  }

  @override
  void dispose() {
    _reconnectTimer?.cancel();
    _dataCheckTimer?.cancel();
    _weightController.removeListener(_onManualWeightChanged);
    _weightController.dispose();
    _wedgeController.dispose();
    _wedgeFocusNode.dispose();
    _cleanupPort();
    super.dispose();
  }

  // ── Logging ───────────────────────────────────────────────────────────────
  void _log(String message, {String type = 'info', Map<String, dynamic>? data}) {
    debugPrint('[$type] $message');
    if (!mounted) return;
    setState(() {
      _logs.insert(0, {'time': DateTime.now(), 'message': message, 'type': type, 'data': data});
      if (_logs.length > _maxLogs) _logs.removeLast();
    });
  }

  String _formatTime(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:'
          '${t.minute.toString().padLeft(2, '0')}:'
          '${t.second.toString().padLeft(2, '0')}.'
          '${(t.millisecond / 10).floor().toString().padLeft(2, '0')}';

  // ── POS input (keyboard wedge) ────────────────────────────────────────────
  void _onWedgeSubmitted(String value) {
    _log('Keyboard wedge input: $value', type: 'info');
    final parsed = parsePOSInput(value);

    switch (parsed.type) {
      case InputType.weight:
        _applyWeightKg(parsed.weight!);
        _log('Wedge weight: ${parsed.weight} kg', type: 'data');
        break;
      case InputType.barcode:
        _applyBarcode(parsed.barcodeValue!);
        _log('Wedge barcode: ${parsed.barcodeValue}', type: 'data');
        break;
      case InputType.unknown:
        _log('Wedge: unrecognised input "$value"', type: 'warning');
    }

    _wedgeController.clear();
    _wedgeFocusNode.requestFocus();
  }

  void _applyWeightKg(double kg) {
    final converted = _convertFromKg(kg);
    if (!mounted) return;
    setState(() {
      _weight = converted;
      _weightIsBarcode = false;
      _isManualEntry = false;
      _weightController.removeListener(_onManualWeightChanged);
      _weightController.text = _formatWeight(converted);
      _weightController.addListener(_onManualWeightChanged);
    });
  }

  void _applyBarcode(String code) {
    if (!mounted) return;
    setState(() {
      _barcode = code;
      _weightIsBarcode = true;
      _isManualEntry = false;
      // Show barcode value in weight field (greyed out) as POSPage does
      _weightController.removeListener(_onManualWeightChanged);
      _weightController.text = code;
      _weightController.addListener(_onManualWeightChanged);
    });
  }

  /// Converts a kg value to the widget's target unit.
  double _convertFromKg(double kg) {
    switch (widget.unit.toLowerCase()) {
      case 'lb': return kg * 2.20462;
      case 'g': return kg * 1000;
      case 'oz': return kg * 35.274;
      default: return kg;
    }
  }

  // ── Manual weight entry ───────────────────────────────────────────────────
  void _onManualWeightChanged() {
    if (_weightIsBarcode) return; // don't parse barcode as weight
    final text = _weightController.text.trim();
    if (text.isEmpty) {
      setState(() { _weight = 0.0; _isManualEntry = false; });
      return;
    }
    final parsed = double.tryParse(text);
    if (parsed != null) {
      setState(() { _weight = parsed; _isManualEntry = true; });
      _log('Manual weight: $parsed ${widget.unit}', type: 'manual');
    }
  }

  // ── Connection health ─────────────────────────────────────────────────────
  void _checkConnectionHealth() {
    if (_connected && _lastDataTime != null) {
      final diff = DateTime.now().difference(_lastDataTime!);
      if (diff > const Duration(seconds: 10)) {
        _log('⚠️ No data for ${diff.inSeconds}s from $_detectedModel', type: 'warning');
        if (diff > const Duration(seconds: 30)) {
          _log('❌ Connection dead – reconnecting...', type: 'error');
          setState(() { _connected = false; _errorType = ConnectionErrorType.disconnected; });
          _attemptReconnection();
        }
      }
    }
  }

  // ── USB connect / scan ────────────────────────────────────────────────────
  Future<void> _connectScale() async {
    if (_isConnecting) return;
    setState(() {
      _isConnecting = true;
      _errorType = ConnectionErrorType.none;
      _errorDetails = '';
      _attemptCount = 0;
      _detectedDevices.clear();
      _detectedModel = '';
      _detectedCategory = '';
    });

    _log('🔍 Starting Magellan scale detection...', type: 'scan');

    try {
      final devices = await UsbSerial.listDevices();
      _allUsbDevices = devices.map((d) => {
        'device': d, 'name': d.productName ?? 'Unknown',
        'vid': d.vid, 'pid': d.pid,
        'manufacturer': d.manufacturerName ?? 'Unknown', 'serial': d.serial ?? 'N/A',
      }).toList();

      _log('📊 Found ${devices.length} USB device(s)', type: 'scan');

      if (devices.isEmpty) {
        _setError(ConnectionErrorType.noDevices, 'No USB devices detected.');
        _startContinuousScan();
        return;
      }

      for (int i = 0; i < devices.length; i++) {
        final d = devices[i];
        final info = MagellanDeviceDatabase.identifyDevice(d.vid, d.pid);
        _log('  Device ${i + 1}: ${d.productName ?? 'Unknown'}', type: 'device', data: {
          'vid': '0x${d.vid?.toRadixString(16).toUpperCase().padLeft(4, '0')}',
          'pid': '0x${d.pid?.toRadixString(16).toUpperCase().padLeft(4, '0')}',
          'model': info?['model'] ?? 'Unknown',
        });
      }

      final magellanDevices = devices.where((d) {
        final known = MagellanDeviceDatabase.identifyDevice(d.vid, d.pid) != null;
        final name = (d.productName ?? '').toLowerCase();
        final isMagellan = name.contains('magellan') || name.contains('datalogic') ||
            name.contains('scale') || name.contains('scanner');
        final isSerial = (d.vid == 0x0403 && [0x6001, 0xB0C4, 0xB0C2].contains(d.pid)) ||
            (d.vid == 0x067B && d.pid == 0x2303) ||
            (d.vid == 0x10C4 && d.pid == 0xEA60) ||
            (d.vid == 0x1A86 && [0x7523, 0x5512].contains(d.pid));
        return known || isMagellan || isSerial;
      }).toList();

      if (magellanDevices.isEmpty) {
        _setError(ConnectionErrorType.noSerialDevices, 'No Magellan devices found.');
        for (var d in devices) {
          _detectedDevices.add({'device': d, 'name': d.productName ?? 'Unknown',
            'vid': d.vid, 'pid': d.pid, 'type': 'Non-Magellan', 'model': 'Unknown'});
        }
        _startContinuousScan();
        return;
      }

      for (var d in magellanDevices) {
        final info = MagellanDeviceDatabase.identifyDevice(d.vid, d.pid);
        final category = info != null ? _getCategoryForDevice(info) : 'Compatible Device';
        _detectedDevices.add({
          'device': d, 'name': d.productName ?? 'Unknown',
          'vid': d.vid, 'pid': d.pid,
          'model': info?['model'] ?? 'Magellan Compatible',
          'type': info?['type'] ?? 'USB-Serial Adapter',
          'category': category,
          'features': info?['features'] ?? 'Standard USB-Serial interface',
          'manufacturer': d.manufacturerName ?? 'Unknown', 'serial': d.serial ?? 'N/A',
        });
        _log('  ✅ ${info?['model'] ?? d.productName} – ${info?['type'] ?? 'Compatible'}', type: 'device');
      }

      _totalAttempts = _detectedDevices.length * _baudRates.length * 4;

      for (var deviceInfo in _detectedDevices) {
        final device = deviceInfo['device'] as UsbDevice;
        final configs = MagellanDeviceDatabase.getDeviceConfigurations(device.vid, device.pid);

        for (var config in configs) {
          _attemptCount++;
          if (await _tryConfiguration(device, config['baud'], config['dataBits'],
              config['stopBits'], MagellanDeviceDatabase.getParityValue(config['parity']),
              config['dtr'], config['rts'], deviceInfo)) return;
        }

        for (var baud in _baudRates) {
          for (var config in _getConfigurations()) {
            _attemptCount++;
            setState(() => _connectionMode =
            'Trying ${deviceInfo['model']} @ $baud/${config['dataBits']}${_getParityChar(config['parity'])}${config['stopBits']}');
            if (await _tryConfiguration(device, baud, config['dataBits'],
                config['stopBits'], config['parity'], config['dtr'], config['rts'], deviceInfo)) return;
            await Future.delayed(const Duration(milliseconds: 100));
          }
        }
      }

      _setError(ConnectionErrorType.invalidConfiguration, 'No config produced data. Check scale settings.');
      _startContinuousScan();
    } catch (e, st) {
      _log('❌ Scan error: $e\n$st', type: 'error');
      _setError(ConnectionErrorType.unknown, e.toString());
      _startContinuousScan();
    } finally {
      if (mounted && !_connected) setState(() => _isConnecting = false);
    }
  }

  String _getCategoryForDevice(Map<String, dynamic> device) {
    for (var category in MagellanDeviceDatabase.magellanDevices.keys) {
      if (MagellanDeviceDatabase.magellanDevices[category]!.contains(device)) return category;
    }
    return 'Other Devices';
  }

  List<Map<String, dynamic>> _getConfigurations() => [
    {'dataBits': 8, 'stopBits': 1, 'parity': UsbPort.PARITY_NONE, 'dtr': true,  'rts': true},
    {'dataBits': 8, 'stopBits': 1, 'parity': UsbPort.PARITY_NONE, 'dtr': false, 'rts': true},
    {'dataBits': 8, 'stopBits': 1, 'parity': UsbPort.PARITY_NONE, 'dtr': false, 'rts': false},
    {'dataBits': 7, 'stopBits': 1, 'parity': UsbPort.PARITY_EVEN, 'dtr': false, 'rts': true},
    {'dataBits': 7, 'stopBits': 1, 'parity': UsbPort.PARITY_ODD,  'dtr': false, 'rts': true},
    {'dataBits': 8, 'stopBits': 2, 'parity': UsbPort.PARITY_NONE, 'dtr': false, 'rts': true},
  ];

  String _getParityChar(int parity) {
    switch (parity) {
      case UsbPort.PARITY_NONE: return 'N';
      case UsbPort.PARITY_ODD:  return 'O';
      case UsbPort.PARITY_EVEN: return 'E';
      default: return '?';
    }
  }

  Future<bool> _tryConfiguration(UsbDevice device, int baud, int dataBits, int stopBits,
      int parity, bool dtr, bool rts, Map<String, dynamic> deviceInfo) async {
    UsbPort? port;
    try {
      port = await device.create().timeout(const Duration(seconds: 2), onTimeout: () => null);
      if (port == null) return false;

      final opened = await port.open().timeout(const Duration(seconds: 2), onTimeout: () => false);
      if (!opened) { await _safeClose(port); return false; }

      await port.setPortParameters(baud, dataBits, stopBits, parity);
      await port.setDTR(dtr);
      await port.setRTS(rts);
      await Future.delayed(const Duration(milliseconds: 200));

      _buffer.clear();
      final dataCompleter = Completer<bool>();
      StreamSubscription<Uint8List>? testSub;
      testSub = port.inputStream?.listen((data) {
        if (data.isNotEmpty && !dataCompleter.isCompleted) dataCompleter.complete(true);
      });

      final gotData = await dataCompleter.future
          .timeout(const Duration(seconds: 2), onTimeout: () => false);
      await testSub?.cancel();

      if (!gotData) { await _safeClose(port); return false; }

      await _setupPermanentConnection(port, device, deviceInfo, baud, dataBits, stopBits, parity, dtr, rts);
      return true;
    } catch (e) {
      _log('  ⚠️ ${deviceInfo['model']}: $e', type: 'debug');
      await _safeClose(port);
      return false;
    }
  }

  Future<void> _setupPermanentConnection(UsbPort port, UsbDevice device,
      Map<String, dynamic> deviceInfo, int baud, int dataBits, int stopBits,
      int parity, bool dtr, bool rts) async {
    await _subscription?.cancel();
    _buffer.clear();

    _currentDevice = device;
    _currentDeviceInfo = deviceInfo;
    _detectedModel = deviceInfo['model'];
    _detectedCategory = deviceInfo['category'] ?? 'Magellan Device';

    _subscription = port.inputStream?.listen(
      _onSerialData,
      onError: (e) { _log('❌ Stream error: $e', type: 'error'); _handleDisconnection('Stream error: $e'); },
      onDone: () { _log('⚠️ Stream closed', type: 'warning'); _handleDisconnection('Stream closed'); },
    );

    _port = port;
    _connectionMode = '$baud/${dataBits}${_getParityChar(parity)}$stopBits';
    _lastDataTime = DateTime.now();

    if (mounted) setState(() { _connected = true; _isConnecting = false; _errorType = ConnectionErrorType.none; });

    _log('✅ Connected to $_detectedModel', type: 'success', data: {
      'baud': baud, 'dataBits': dataBits, 'stopBits': stopBits,
      'parity': MagellanDeviceDatabase.getParityString(parity), 'dtr': dtr, 'rts': rts,
    });
  }

  void _handleDisconnection(String reason) {
    if (!mounted) return;
    setState(() { _connected = false; _errorType = ConnectionErrorType.disconnected; _errorDetails = reason; });
    _log('🔌 $_detectedModel disconnected: $reason', type: 'warning');
    _attemptReconnection();
  }

  void _attemptReconnection() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && !_connected && !_isConnecting) _connectScale();
    });
  }

  void _startContinuousScan() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && !_connected && !_isConnecting) _connectScale();
    });
  }

  void _setError(ConnectionErrorType type, String details) {
    if (mounted) setState(() { _errorType = type; _errorDetails = details; });
    _log('❌ ${type.message} $details', type: 'error');
  }

  Future<void> _safeClose(UsbPort? port) async { try { await port?.close(); } catch (_) {} }

  Future<void> _cleanupPort() async {
    await _subscription?.cancel();
    _subscription = null;
    await _safeClose(_port);
    _port = null;
  }

  // ── Serial data handler (scale + scanner) ─────────────────────────────────
  void _onSerialData(Uint8List data) {
    _lastDataTime = DateTime.now();
    _buffer.addAll(data);

    while (true) {
      final idx = _buffer.indexOf(0x0A);
      if (idx == -1) break;
      final frame = _buffer.sublist(0, idx + 1);
      _buffer.removeRange(0, idx + 1);
      final line = String.fromCharCodes(frame).trim();
      if (line.isNotEmpty) {
        _log('📦 $_detectedModel: $line', type: 'data');
        _handleSerialLine(line);
      }
    }

    if (_buffer.length > 32) {
      final line = String.fromCharCodes(_buffer).trim();
      _buffer.clear();
      if (line.isNotEmpty) {
        _log('📦 $_detectedModel (raw): $line', type: 'data');
        _handleSerialLine(line);
      }
    }
  }

  /// Unified handler: parses serial output as weight or barcode using POSPage logic.
  void _handleSerialLine(String line) {
    // First try the shared POS parser (handles weight patterns + plain numbers)
    final parsed = parsePOSInput(line);

    if (parsed.type == InputType.weight && parsed.weight != null) {
      // Serial weight is already in the device unit; convert to widget unit
      final converted = _convertSerialWeight(line, parsed.weight!);
      if (!_isManualEntry) _applyWeightValue(converted);
      return;
    }

    if (parsed.type == InputType.barcode) {
      _applyBarcode(parsed.barcodeValue!);
      return;
    }

    // Fallback: try to extract a numeric weight directly
    final w = _parseWeightFromSerial(line);
    if (w != null && !_isManualEntry) _applyWeightValue(w);
  }

  /// Converts a parsed serial weight (could be KG, lbs, oz) to the widget unit.
  double _convertSerialWeight(String raw, double fallbackKg) {
    final clean = raw.trim().replaceAll(RegExp(r'\s+'), ' ');
    final unitMatch = RegExp(r'([+-]?\d*\.?\d+)\s*(kg|g|lb|oz)', caseSensitive: false)
        .firstMatch(clean);
    if (unitMatch != null) {
      final val = double.tryParse(unitMatch.group(1) ?? '');
      final unit = unitMatch.group(2)?.toLowerCase() ?? '';
      if (val != null) return _convertUnit(val, unit);
    }
    // No unit found – assume kg
    return _convertFromKg(fallbackKg);
  }

  double? _parseWeightFromSerial(String raw) {
    final clean = raw.trim().replaceAll(RegExp(r'\s+'), ' ');
    final unitMatch = RegExp(r'([+-]?\d*\.?\d+)\s*(kg|g|lb|oz)', caseSensitive: false)
        .firstMatch(clean);
    if (unitMatch != null) {
      final val = double.tryParse(unitMatch.group(1) ?? '');
      final unit = unitMatch.group(2)?.toLowerCase() ?? '';
      if (val != null) return _convertUnit(val, unit);
    }
    final numMatch = RegExp(r'([+-]?\d*\.?\d+)').firstMatch(clean);
    if (numMatch != null) return double.tryParse(numMatch.group(1) ?? '');
    return null;
  }

  double _convertUnit(double value, String from) {
    final to = widget.unit.toLowerCase();
    switch (from) {
      case 'kg': return to == 'lb' ? value * 2.20462 : to == 'g' ? value * 1000 : to == 'oz' ? value * 35.274 : value;
      case 'lb': return to == 'kg' ? value / 2.20462 : to == 'g' ? value / 2.20462 * 1000 : to == 'oz' ? value * 16 : value;
      case 'g':  return to == 'kg' ? value / 1000 : to == 'lb' ? value / 1000 * 2.20462 : to == 'oz' ? value / 1000 * 35.274 : value;
      case 'oz': return to == 'lb' ? value / 16 : to == 'kg' ? value * 0.0283495 : to == 'g' ? value * 28.3495 : value;
      default: return value;
    }
  }

  void _applyWeightValue(double value) {
    if (!mounted || _isManualEntry) return;
    if (value >= 0 && value < 1000) {
      setState(() {
        _weight = value;
        _weightIsBarcode = false;
        _weightController.removeListener(_onManualWeightChanged);
        _weightController.text = _formatWeight(value);
        _weightController.addListener(_onManualWeightChanged);
      });
    }
  }

  String _formatWeight(double v) => v.toStringAsFixed(3);

  double get _calculatedPrice =>
      (((_weight * widget.unitPrice) * 100).truncateToDouble()) / 100;

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Magellan Scale Integration'),
        backgroundColor: const Color(0xFFFF6B6B),
        actions: [
          if (_isConnecting)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: SizedBox(width: 20, height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
            )
          else
            IconButton(
              icon: Icon(_connected ? Icons.usb : Icons.usb_off,
                  color: _connected ? Colors.greenAccent : Colors.white70),
              onPressed: _connected ? _cleanupPort : _connectScale,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Keyboard wedge input (hidden, always focused as fallback) ──
            _KeyboardWedgeInput(
              controller: _wedgeController,
              focusNode: _wedgeFocusNode,
              onSubmitted: _onWedgeSubmitted,
            ),

            const SizedBox(height: 8),

            _ConnectionStatusCard(
              connected: _connected,
              isConnecting: _isConnecting,
              deviceModel: _detectedModel,
              deviceCategory: _detectedCategory,
              connectionMode: _connectionMode,
              errorType: _errorType,
              errorDetails: _errorDetails,
              attemptCount: _attemptCount,
              totalAttempts: _totalAttempts,
              lastDataTime: _lastDataTime,
              onRetry: _connectScale,
            ),

            const SizedBox(height: 16),

            // ── Barcode result (shown when scanner read a barcode) ──
            if (_barcode.isNotEmpty)
              _BarcodeResultCard(barcode: _barcode, onClear: () {
                setState(() { _barcode = ''; _weightIsBarcode = false; _weight = 0.0; _weightController.text = ''; });
              }),

            if (_barcode.isNotEmpty) const SizedBox(height: 16),

            _ProductInfoCard(
              productName: widget.productName,
              unitPrice: widget.unitPrice,
              unit: widget.unit,
            ),

            const SizedBox(height: 16),

            _WeightInputCard(
              weight: _weight,
              calculatedPrice: _calculatedPrice,
              unit: widget.unit,
              controller: _weightController,
              isManualEntry: _isManualEntry,
              weightIsBarcode: _weightIsBarcode,
              deviceModel: _detectedModel,
              onConfirm: (_weight > 0 && !_weightIsBarcode) ? () {
                Navigator.of(context).pop({
                  'weight': _weight,
                  'finalPrice': _calculatedPrice,
                  'barcode': _barcode,
                  'device': _detectedModel,
                });
              } : null,
            ),

            const SizedBox(height: 16),

            _MagellanDevicesCard(
              detectedDevices: _detectedDevices,
              currentModel: _detectedModel,
              allDevices: _allUsbDevices,
            ),

            const SizedBox(height: 16),

            if (_connected && _currentDeviceInfo != null)
              _DeviceFeaturesCard(deviceInfo: _currentDeviceInfo!),

            const SizedBox(height: 16),

            _LogsCard(
              logs: _logs,
              formatTime: _formatTime,
              onClear: () => setState(() => _logs.clear()),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Keyboard wedge hidden input ──────────────────────────────────────────────
class _KeyboardWedgeInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onSubmitted;

  const _KeyboardWedgeInput({
    required this.controller,
    required this.focusNode,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      autofocus: true,
      onSubmitted: onSubmitted,
      decoration: const InputDecoration(
        hintText: 'Scan barcode or enter weight (e.g. 1.23KG)',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.qr_code_scanner),
        labelText: 'Scanner / Manual Input',
      ),
    );
  }
}

// ── Barcode result card ───────────────────────────────────────────────────────
class _BarcodeResultCard extends StatelessWidget {
  final String barcode;
  final VoidCallback onClear;

  const _BarcodeResultCard({required this.barcode, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.amber.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.qr_code, color: Colors.amber, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Barcode Scanned', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text(barcode,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.grey),
              onPressed: onClear,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Connection status card ────────────────────────────────────────────────────
class _ConnectionStatusCard extends StatelessWidget {
  final bool connected, isConnecting;
  final String deviceModel, deviceCategory, connectionMode, errorDetails;
  final ConnectionErrorType errorType;
  final int attemptCount, totalAttempts;
  final DateTime? lastDataTime;
  final VoidCallback onRetry;

  const _ConnectionStatusCard({
    required this.connected, required this.isConnecting,
    required this.deviceModel, required this.deviceCategory,
    required this.connectionMode, required this.errorType,
    required this.errorDetails, required this.attemptCount,
    required this.totalAttempts, required this.lastDataTime,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          gradient: connected ? LinearGradient(
            colors: [Colors.green.shade400, Colors.green.shade600],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ) : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                child: Icon(
                  connected ? Icons.check_circle : isConnecting ? Icons.sync :
                  errorType != ConnectionErrorType.none ? errorType.icon : Icons.usb_off,
                  color: connected ? Colors.white : isConnecting ? Colors.blue :
                  errorType != ConnectionErrorType.none ? errorType.color : Colors.grey,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  connected ? 'Connected to:' : isConnecting ? 'Connecting...' :
                  errorType != ConnectionErrorType.none ? 'Connection Error' : 'No Device Connected',
                  style: TextStyle(fontSize: 14,
                      color: connected ? Colors.white70 : isConnecting ? Colors.blueGrey :
                      errorType != ConnectionErrorType.none ? errorType.color : Colors.grey),
                ),
                if (connected && deviceModel.isNotEmpty)
                  Text(deviceModel, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                      color: connected ? Colors.white : Colors.black)),
                if (connected && deviceCategory.isNotEmpty)
                  Text(deviceCategory, style: TextStyle(fontSize: 12,
                      color: connected ? Colors.white70 : Colors.grey)),
              ])),
              if (!connected && !isConnecting)
                ElevatedButton(onPressed: onRetry,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: errorType.color, foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                    child: const Text('Retry')),
            ]),

            if (connected && connectionMode.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20)),
                child: Text('Mode: $connectionMode',
                    style: const TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ],

            if (errorType != ConnectionErrorType.none) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: errorType.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: errorType.color.withOpacity(0.3)),
                ),
                child: Text(errorDetails.isNotEmpty ? errorDetails : errorType.message,
                    style: TextStyle(color: errorType.color, fontSize: 13)),
              ),
            ],

            if (isConnecting && totalAttempts > 0) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(value: attemptCount / totalAttempts,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue)),
              const SizedBox(height: 8),
              Text('Scanning: $attemptCount of $totalAttempts',
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],

            if (connected && lastDataTime != null) ...[
              const SizedBox(height: 8),
              Row(children: [
                Icon(Icons.access_time, size: 14,
                    color: DateTime.now().difference(lastDataTime!) > const Duration(seconds: 5)
                        ? Colors.orange : Colors.white70),
                const SizedBox(width: 4),
                Text('Last data: ${_timeDiff(lastDataTime!)}',
                    style: TextStyle(fontSize: 12,
                        color: DateTime.now().difference(lastDataTime!) > const Duration(seconds: 5)
                            ? Colors.orange : Colors.white70)),
              ]),
            ],
          ]),
        ),
      ),
    );
  }

  String _timeDiff(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inSeconds < 1) return 'just now';
    if (d.inSeconds < 60) return '${d.inSeconds}s ago';
    return '${d.inMinutes}m ago';
  }
}

// ── Magellan devices card ─────────────────────────────────────────────────────
class _MagellanDevicesCard extends StatelessWidget {
  final List<Map<String, dynamic>> detectedDevices;
  final String currentModel;
  final List<Map<String, dynamic>> allDevices;

  const _MagellanDevicesCard({
    required this.detectedDevices, required this.currentModel, required this.allDevices});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.scanner, color: Color(0xFFFF6B6B), size: 20),
            const SizedBox(width: 8),
            const Text('Detected Magellan Devices',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12)),
              child: Text('${detectedDevices.length} found',
                  style: TextStyle(fontSize: 12, color: Colors.blue.shade700)),
            ),
          ]),
          const SizedBox(height: 12),
          if (detectedDevices.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!)),
              child: const Center(child: Text('No Magellan devices detected.\nConnect your scale and tap Retry.',
                  textAlign: TextAlign.center, style: TextStyle(color: Colors.grey))),
            )
          else
            ...detectedDevices.map((device) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: device['model'] == currentModel ? Colors.green.shade50 : Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: device['model'] == currentModel ? Colors.green.shade300 : Colors.grey[300]!,
                  width: device['model'] == currentModel ? 2 : 1,
                ),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(device['model'],
                      style: TextStyle(
                          fontWeight: device['model'] == currentModel ? FontWeight.bold : FontWeight.w600,
                          color: device['model'] == currentModel ? Colors.green.shade700 : Colors.black))),
                  if (device['model'] == currentModel)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(12)),
                      child: const Text('ACTIVE',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                ]),
                const SizedBox(height: 4),
                Text(device['type'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                Wrap(spacing: 8, children: [
                  _chip('VID:0x${device['vid']?.toRadixString(16).toUpperCase()}', Colors.blue),
                  _chip('PID:0x${device['pid']?.toRadixString(16).toUpperCase()}', Colors.purple),
                ]),
                if (device['serial'] != null && device['serial'] != 'N/A') ...[
                  const SizedBox(height: 4),
                  Text('SN: ${device['serial']}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ]),
            )),

          if (allDevices.length > detectedDevices.length) ...[
            const SizedBox(height: 12),
            Text('Other USB devices: ${allDevices.length - detectedDevices.length}',
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ]),
      ),
    );
  }

  Widget _chip(String label, MaterialColor color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(color: color.shade50, borderRadius: BorderRadius.circular(4)),
    child: Text(label, style: TextStyle(fontSize: 10, color: color.shade700)),
  );
}

// ── Device features card ──────────────────────────────────────────────────────
class _DeviceFeaturesCard extends StatelessWidget {
  final Map<String, dynamic> deviceInfo;
  const _DeviceFeaturesCard({required this.deviceInfo});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.blue.shade50, Colors.white],
              begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(Icons.star, color: Colors.amber.shade600, size: 20),
              const SizedBox(width: 8),
              Text(deviceInfo['model'],
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 8),
            Text(deviceInfo['type'],
                style: const TextStyle(fontSize: 13, color: Colors.blueGrey, fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade100)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Features:', style: TextStyle(fontSize: 12,
                    fontWeight: FontWeight.w600, color: Colors.blueGrey)),
                const SizedBox(height: 4),
                Text(deviceInfo['features'] ?? 'Standard Magellan features',
                    style: const TextStyle(fontSize: 12, height: 1.5)),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

// ── Product info card ─────────────────────────────────────────────────────────
class _ProductInfoCard extends StatelessWidget {
  final String productName, unit;
  final double unitPrice;
  const _ProductInfoCard({required this.productName, required this.unitPrice, required this.unit});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Product', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(productName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ])),
          Container(width: 1, height: 40, color: Colors.grey[300],
              margin: const EdgeInsets.symmetric(horizontal: 16)),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Unit Price', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            Text('\$${unitPrice.toStringAsFixed(2)}/$unit',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
                    color: Color(0xFFFF6B6B))),
          ])),
        ]),
      ),
    );
  }
}

// ── Weight input card ─────────────────────────────────────────────────────────
class _WeightInputCard extends StatelessWidget {
  final double weight, calculatedPrice;
  final String unit, deviceModel;
  final TextEditingController controller;
  final bool isManualEntry, weightIsBarcode;
  final VoidCallback? onConfirm;

  const _WeightInputCard({
    required this.weight, required this.calculatedPrice, required this.unit,
    required this.controller, required this.isManualEntry, required this.weightIsBarcode,
    required this.deviceModel, required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(weightIsBarcode ? 'Barcode (as weight)' : 'Weight ($unit)',
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                if (deviceModel.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(4)),
                    child: Text('via $deviceModel',
                        style: TextStyle(fontSize: 9, color: Colors.green.shade700)),
                  ),
                ],
              ]),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(
                    color: weightIsBarcode ? Colors.grey : Colors.black,
                    fontStyle: weightIsBarcode ? FontStyle.italic : FontStyle.normal),
                decoration: InputDecoration(
                  hintText: '0.000',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  suffixIcon: weightIsBarcode
                      ? const Icon(Icons.qr_code, size: 16, color: Colors.amber)
                      : isManualEntry
                      ? const Icon(Icons.edit, size: 16, color: Colors.blue)
                      : deviceModel.isNotEmpty
                      ? const Icon(Icons.sensors, size: 16, color: Colors.green)
                      : null,
                ),
              ),
            ])),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Price', style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 8),
              Container(
                height: 48,
                decoration: BoxDecoration(color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!)),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  (!weightIsBarcode && weight > 0) ? '\$${calculatedPrice.toStringAsFixed(2)}' : '—',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
                      color: (!weightIsBarcode && weight > 0) ? Colors.black : Colors.grey),
                ),
              ),
            ])),
          ]),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity, height: 48,
            child: ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: onConfirm != null ? const Color(0xFFFF6B6B) : Colors.grey,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                !weightIsBarcode && weight > 0
                    ? 'Confirm & Add (${weight.toStringAsFixed(3)} $unit)'
                    : weightIsBarcode
                    ? 'Waiting for weight reading...'
                    : 'Confirm & Add',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Logs card ─────────────────────────────────────────────────────────────────
class _LogsCard extends StatelessWidget {
  final List<Map<String, dynamic>> logs;
  final String Function(DateTime) formatTime;
  final VoidCallback onClear;

  const _LogsCard({required this.logs, required this.formatTime, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Event Logs', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            TextButton.icon(onPressed: onClear,
                icon: const Icon(Icons.delete_sweep, size: 16),
                label: const Text('Clear'),
                style: TextButton.styleFrom(foregroundColor: Colors.grey)),
          ]),
          const SizedBox(height: 12),
          Container(
            height: 200,
            decoration: BoxDecoration(color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!)),
            child: logs.isEmpty
                ? const Center(child: Text('No logs yet', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
              reverse: true,
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final log = logs[index];
                final time = log['time'] as DateTime;
                final message = log['message'] as String;
                final type = log['type'] as String;

                final (color, icon) = switch (type) {
                  'error'      => (Colors.red, Icons.error),
                  'warning'    => (Colors.orange, Icons.warning),
                  'success'    => (Colors.green, Icons.check_circle),
                  'data'       => (Colors.blue, Icons.data_usage),
                  'device'     => (Colors.purple, Icons.usb),
                  'scan'       => (Colors.teal, Icons.search),
                  'connection' => (Colors.indigo, Icons.link),
                  'manual'     => (Colors.amber, Icons.edit),
                  'barcode'    => (Colors.amber.shade700, Icons.qr_code),
                  _            => (Colors.black87, Icons.info_outline),
                };

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Icon(icon, size: 12, color: color),
                    const SizedBox(width: 4),
                    Text('[${formatTime(time)}]',
                        style: const TextStyle(fontSize: 10, color: Colors.grey, fontFamily: 'monospace')),
                    const SizedBox(width: 8),
                    Expanded(child: Text(message,
                        style: TextStyle(fontSize: 11, color: color, fontFamily: 'monospace',
                            fontWeight: type == 'success' ? FontWeight.bold : FontWeight.normal))),
                  ]),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}
