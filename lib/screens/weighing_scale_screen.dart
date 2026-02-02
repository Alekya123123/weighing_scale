import 'package:flutter/material.dart';
import 'package:usb_serial/usb_serial.dart';
import 'dart:typed_data';
import 'dart:async';

class WeighingScaleScreen extends StatefulWidget {
  @override
  _WeighingScaleScreenState createState() => _WeighingScaleScreenState();
}

class _WeighingScaleScreenState extends State<WeighingScaleScreen> {
  UsbPort? _port;
  String _weight = '0.00 kg';
  final TextEditingController _weightController = TextEditingController();
  StreamSubscription<Uint8List>? _subscription;

  @override
  void initState() {
    super.initState();
    _connectToScale();
  }

  Future<void> _connectToScale() async {
    List<UsbDevice> devices = await UsbSerial.listDevices();
    if (devices.isEmpty) {
      setState(() => _weight = 'No scale found');
      return;
    }

    _port = await devices.first.create();
    if (!(await _port!.open())) {
      setState(() => _weight = 'Failed to open port');
      return;
    }

    // Scale config: 9600 baud, 8 data, no parity, 1 stop (common for RS232 scales)
    await _port!.setPortParameters(9600, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);
    await _port!.setDTR(true);
    await _port!.setRTS(true);

    // Listen for continuous data (scales send stable weight periodically)
    _subscription = _port!.inputStream?.listen((Uint8List data) {
      String reading = String.fromCharCodes(data).trim();
      if (reading.isNotEmpty && (reading.contains('kg') || reading.contains('g'))) {
        setState(() {
          _weight = reading;
          _weightController.text = reading; // Update edit box
        });
      }
    });

    setState(() => _weight = 'Connected');
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _port?.close();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ElevatedButton(onPressed: _connectToScale, child: Text('Connect Scale')),
          Text('Status: $_weight'),
          TextField(
            controller: _weightController,
            decoration: InputDecoration(labelText: 'Weight Value'),
            readOnly: true,
          ),
        ],
      ),
    );
  }
}
