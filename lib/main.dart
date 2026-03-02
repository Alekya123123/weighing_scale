import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MagellanScaleApp());
}

class MagellanScaleApp extends StatelessWidget {
  const MagellanScaleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Magellan Scale',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ScaleScreen(),
    );
  }
}

class ScaleScreen extends StatefulWidget {
  const ScaleScreen({super.key});

  @override
  State<ScaleScreen> createState() => _ScaleScreenState();
}

class _ScaleScreenState extends State<ScaleScreen> {
  static const MethodChannel _channel = MethodChannel('magellan_scale');
  static const EventChannel _eventChannel = EventChannel('magellan_scale/events');

  StreamSubscription<dynamic>? _subscription;
  final StreamController<Map<String, dynamic>> _streamController =
      StreamController<Map<String, dynamic>>.broadcast();

  String _connectionStatus = 'Stopped';
  String _connectionMessage = '';
  double _weight = 0.0;
  String _unit = 'kg';
  bool _stable = false;
  String _lastScan = '';
  final List<String> _rawLog = [];
  bool _listening = false;

  @override
  void initState() {
    super.initState();
    _subscription = _eventChannel.receiveBroadcastStream().listen(
      _onEvent,
      onError: _onError,
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _streamController.close();
    super.dispose();
  }

  void _onEvent(dynamic event) {
    if (event == null) return;
    try {
      final map = jsonDecode(event.toString()) as Map<String, dynamic>;
      _streamController.add(map);
      final type = map['type'] as String?;
      // Console logs for debugging
      if (type == 'status') {
        final status = map['status'] as String? ?? '';
        final message = map['message'] as String? ?? '';
        debugPrint('[USB] status=$status message="$message"');
      } else if (type == 'weight') {
        final w = (map['weight'] as num?)?.toDouble() ?? 0.0;
        final unit = map['unit'] as String? ?? 'kg';
        final stable = map['stable'] as bool? ?? false;
        debugPrint('[WEIGHT] $w $unit stable=$stable');
      } else if (type == 'raw') {
        final raw = map['raw'] as String?;
        if (raw != null && raw.isNotEmpty) {
          debugPrint('[RAW] $raw');
        }
      } else if (type == 'scan') {
        final raw = map['raw'] as String?;
        if (raw != null && raw.isNotEmpty) {
          debugPrint('[SCAN] $raw');
        }
      }
      if (!mounted) return;
      setState(() {
        if (type == 'status') {
          _connectionStatus = map['status'] as String? ?? '';
          _connectionMessage = map['message'] as String? ?? '';
        } else if (type == 'weight') {
          _weight = (map['weight'] as num?)?.toDouble() ?? 0.0;
          _unit = map['unit'] as String? ?? 'kg';
          _stable = map['stable'] as bool? ?? false;
          final raw = map['raw'] as String?;
          if (raw != null && raw.isNotEmpty) {
            if (_rawLog.isEmpty || _rawLog.last != raw) _rawLog.add(raw);
            if (_rawLog.length > 200) _rawLog.removeAt(0);
          }
        } else if (type == 'raw') {
          final raw = map['raw'] as String?;
          if (raw != null && raw.isNotEmpty) {
            _rawLog.add(raw);
            if (_rawLog.length > 200) _rawLog.removeAt(0);
          }
        } else if (type == 'scan') {
          final raw = map['raw'] as String?;
          if (raw != null && raw.isNotEmpty) {
            _lastScan = raw;
            // raw already added via 'raw' event, no need to add again
          }
        }
      });
    } catch (_) {}
  }

  void _onError(dynamic error) {
    debugPrint('[USB] error: ${error?.toString() ?? 'Unknown error'}');
    if (mounted) {
      setState(() {
        _connectionStatus = 'error';
        _connectionMessage = error?.toString() ?? 'Unknown error';
      });
    }
  }

  Future<void> _start() async {
    debugPrint('[USB] Start requested');
    try {
      await _channel.invokeMethod('start');
      debugPrint('[USB] Start succeeded');
      if (mounted) setState(() => _listening = true);
    } on PlatformException catch (e) {
      debugPrint('[USB] Start failed: ${e.message ?? e.toString()}');
      if (mounted) {
        setState(() {
          _connectionStatus = 'error';
          _connectionMessage = e.message ?? e.toString();
        });
      }
    }
  }

  Future<void> _stop() async {
    debugPrint('[USB] Stop requested');
    try {
      await _channel.invokeMethod('stop');
      debugPrint('[USB] Stop succeeded');
      if (mounted) setState(() => _listening = false);
    } on PlatformException catch (e) {
      debugPrint('[USB] Stop failed: ${e.message ?? e.toString()}');
      if (mounted) {
        setState(() {
          _connectionStatus = 'error';
          _connectionMessage = e.message ?? e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Magellan Scale'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _StatusChip(
              status: _connectionStatus,
              message: _connectionMessage,
              listening: _listening,
            ),
            const SizedBox(height: 24),
            StreamBuilder<Map<String, dynamic>>(
              stream: _streamController.stream,
              builder: (context, snapshot) {
                return Column(
                  children: [
                    Text(
                      _listening
                          ? '${_weight.toStringAsFixed(3)} $_unit'
                          : '—',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                    ),
                    if (_listening) ...[
                      const SizedBox(height: 8),
                      Chip(
                        avatar: Icon(
                          _stable ? Icons.check_circle : Icons.hourglass_empty,
                          color: _stable ? Colors.green : Colors.orange,
                          size: 18,
                        ),
                        label: Text(_stable ? 'Stable' : 'Settling'),
                      ),
                    ],
                    if (_lastScan.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Chip(
                        avatar: const Icon(Icons.qr_code_scanner, color: Colors.blue, size: 18),
                        label: Text(
                          'Scan: $_lastScan',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontFamily: 'monospace',
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _listening ? null : _start,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: !_listening ? null : _stop,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.stop),
                        SizedBox(width: 8),
                        Text('Stop'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Raw data log (${_rawLog.length} lines)',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                constraints: const BoxConstraints(minHeight: 120),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _rawLog.isEmpty
                    ? Center(
                        child: Text(
                          _listening
                              ? 'Waiting for data… Place item on scale or scan.'
                              : 'Tap Start and connect scale.',
                          style: TextStyle(color: Theme.of(context).hintColor),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        reverse: true,
                        itemCount: _rawLog.length,
                        itemBuilder: (context, index) {
                          final line = _rawLog[_rawLog.length - 1 - index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            child: Text(
                              line,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontFamily: 'monospace',
                                  ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  final String message;
  final bool listening;

  const _StatusChip({
    required this.status,
    required this.message,
    required this.listening,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    String label;
    switch (status) {
      case 'connected':
        color = Colors.green;
        icon = Icons.check_circle;
        label = 'Connected';
        break;
      case 'connecting':
        color = Colors.orange;
        icon = Icons.hourglass_empty;
        label = 'Connecting';
        break;
      case 'disconnected':
        color = Colors.grey;
        icon = Icons.link_off;
        label = 'Disconnected';
        break;
      case 'stopped':
        color = Colors.grey;
        icon = Icons.stop_circle;
        label = 'Stopped';
        break;
      case 'error':
        color = Colors.red;
        icon = Icons.error;
        label = 'Error';
        break;
      default:
        color = Colors.grey;
        icon = Icons.circle_outlined;
        label = status.isNotEmpty ? status : 'Stopped';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Chip(
          avatar: Icon(icon, color: color, size: 18),
          label: Text(label),
        ),
        if (message.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            message,
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}
