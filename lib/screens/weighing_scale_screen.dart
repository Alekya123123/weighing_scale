import 'package:flutter/material.dart';
import 'package:usb_serial/usb_serial.dart';
import 'dart:typed_data';
import 'dart:async';
import 'dart:developer' as developer;

class WeighingScaleScreen extends StatefulWidget {
  @override
  _WeighingScaleScreenState createState() => _WeighingScaleScreenState();
}

class _WeighingScaleScreenState extends State<WeighingScaleScreen> {
  UsbPort? _scalePort;
  UsbPort? _scannerPort;
  String _statusMessage = 'Disconnected';
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _barcodeController = TextEditingController();

  StreamSubscription<Uint8List>? _scaleSubscription;
  StreamSubscription<Uint8List>? _scannerSubscription;

  @override
  void initState() {
    super.initState();
    developer.log('[USB] Start requested', name: 'flutter');
    _startUsbConnection();
  }

  Future<void> _startUsbConnection() async {
    setState(() => _statusMessage = 'Connecting...');
    developer.log(
      '[USB] status=connecting message="Connecting..."',
      name: 'flutter',
    );

    List<UsbDevice> devices = await UsbSerial.listDevices();

    if (devices.isEmpty) {
      setState(() {
        _statusMessage = 'No scale/scanner found';
      });
      developer.log('[USB] Start failed: No devices', name: 'flutter');
      return;
    }

    developer.log('[USB] Start succeeded', name: 'flutter');

    for (var device in devices) {
      // FTDI Vendor ID is 1027 (0x0403)
      if (device.vid == 1027) {
        if (device.pid == 45250) {
          // 0xb0c2 (Usually Scale)
          developer.log(
            'I/UsbSerialManager: Opening device: VID=0x403 PID=0xb0c2 type=SCALE name=${device.deviceName}',
            name: 'UsbSerialManager',
          );
          await _setupScalePort(device);
        } else if (device.pid == 45249) {
          // 0xb0c1 (Usually Scanner)
          developer.log(
            'I/UsbSerialManager: Opening device: VID=0x403 PID=0xb0c1 type=SCANNER name=${device.deviceName}',
            name: 'UsbSerialManager',
          );
          await _setupScannerPort(device);
        } else {
          // Fallback if PIDs are different, try to guess or use first as Scale
          developer.log(
            'I/UsbSerialManager: Unknown FTDI device PID=${device.pid}',
            name: 'UsbSerialManager',
          );
          if (_scalePort == null) await _setupScalePort(device);
        }
      }
    }

    setState(() {
      _statusMessage = 'Scale connected';
    });
    developer.log(
      '[USB] status=connected message="Scale connected"',
      name: 'flutter',
    );
  }

  Future<void> _getWeight() async {
    if (_scalePort != null) {
      developer.log('[USB] Requested Weight', name: 'flutter');
      // Send 'W' or 'S' followed by CR
      await _scalePort!.write(Uint8List.fromList('W\r'.codeUnits));
    } else {
      setState(() => _statusMessage = 'Scale not connected');
    }
  }

  Future<void> _setupScalePort(UsbDevice device) async {
    _scalePort = await device.create();
    if (await _scalePort!.open()) {
      await _scalePort!.setPortParameters(
        9600,
        UsbPort.DATABITS_8,
        UsbPort.STOPBITS_1,
        UsbPort.PARITY_NONE,
      );
      _scaleSubscription = _scalePort!.inputStream?.listen((Uint8List data) {
        String reading = String.fromCharCodes(data);
        developer.log(
          'I/UsbSerialManager: RAW BYTES (SCALE): ${data.toString()}',
          name: 'UsbSerialManager',
        );

        // Magellan 9800i often sends weight with a specific prefix or as stable string
        // We clean the string and extract numbers/units
        String cleaned = reading.trim();
        if (cleaned.isNotEmpty) {
          setState(() {
            _weightController.text = cleaned;
          });
        }
      });
    }
  }

  Future<void> _setupScannerPort(UsbDevice device) async {
    _scannerPort = await device.create();
    if (await _scannerPort!.open()) {
      await _scannerPort!.setPortParameters(
        9600,
        UsbPort.DATABITS_8,
        UsbPort.STOPBITS_1,
        UsbPort.PARITY_NONE,
      );
      _scannerSubscription = _scannerPort!.inputStream?.listen((
        Uint8List data,
      ) {
        String barcode = String.fromCharCodes(data).trim();
        developer.log(
          'I/UsbSerialManager: RAW BYTES (SCAN): ${data.toString()}',
          name: 'UsbSerialManager',
        );
        developer.log(
          'I/flutter: [RAW] ${device.deviceName}: $barcode',
          name: 'flutter',
        );

        if (barcode.isNotEmpty) {
          setState(() {
            _barcodeController.text = barcode;
          });
          developer.log(
            'I/flutter: [SCAN] ${device.deviceName}: $barcode',
            name: 'flutter',
          );
        }
      });
    }
  }

  @override
  void dispose() {
    developer.log('[USB] Stop requested', name: 'flutter');
    _scaleSubscription?.cancel();
    _scannerSubscription?.cancel();
    _scalePort?.close();
    _scannerPort?.close();
    _weightController.dispose();
    _barcodeController.dispose();
    developer.log('[USB] Stop succeeded', name: 'flutter');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Magellan 9800i Integration'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.usb,
                          color:
                              _statusMessage.contains('connected')
                                  ? Colors.green
                                  : Colors.red,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Status: $_statusMessage',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Divider(),
                    SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        _scaleSubscription?.cancel();
                        _scannerSubscription?.cancel();
                        _scalePort?.close();
                        _scannerPort?.close();
                        _startUsbConnection();
                      },
                      icon: Icon(Icons.refresh),
                      label: Text('Reconnect Scale/Scanner'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 45),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Weighing Scale Data',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _weightController,
                    decoration: InputDecoration(
                      labelText: 'Weight',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.monitor_weight),
                    ),
                    readOnly: true,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _getWeight,
                  child: Text('Get Weight'),
                  style: ElevatedButton.styleFrom(minimumSize: Size(100, 60)),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Barcode Scanner Data',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _barcodeController,
              decoration: InputDecoration(
                labelText: 'Last Scanned Barcode',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.qr_code_scanner),
              ),
              readOnly: true,
              style: TextStyle(fontSize: 18, color: Colors.deepPurple),
            ),
          ],
        ),
      ),
    );
  }
}
