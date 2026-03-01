// lib/ble_manager.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleManager {
  BleManager({this.onDisconnected});

  static const String NUS_SERVICE_UUID = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E";
  static const String NUS_TX_CHAR_UUID = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E";
  static const String NUS_RX_CHAR_UUID = "6E400002-B5A3-F393-E0A9-E50E24DCCA9E";

  BluetoothDevice? _device;
  BluetoothCharacteristic? _txChar; // Receive from nRF
  BluetoothCharacteristic? _rxChar; // Send to nRF

  final StreamController<String> _messageController =
      StreamController<String>.broadcast();

  Stream<String> get messageStream => _messageController.stream;
  bool get isConnected => _device != null;

  /// Optional callback invoked when the underlying device disconnects,
  /// e.g. Bluetooth turned off or device powered down.
  final void Function()? onDisconnected;

  // ─── Scan ────────────────────────────────────────────────────────────────

  Stream<List<ScanResult>> startScan({Duration timeout = const Duration(seconds: 10)}) {
    FlutterBluePlus.startScan(
      withServices: [Guid(NUS_SERVICE_UUID)], // filter for Nordic devices
      timeout: timeout,
    );
    return FlutterBluePlus.scanResults;
  }

  void stopScan() => FlutterBluePlus.stopScan();

  // ─── Connect ─────────────────────────────────────────────────────────────

  Future<void> connect(BluetoothDevice device) async {
    _device = device;

    await device.connect(license: License.free);

    // Listen for disconnection
    device.connectionState.listen((state) {
      if (state == BluetoothConnectionState.disconnected) {
        _device = null;
        _txChar = null;
        _rxChar = null;
        onDisconnected?.call();
      }
    });

    await _discoverServices();
  }

  Future<void> disconnect() async {
    await _device?.disconnect();
    _device = null;
  }

  /// Clears connection state without disconnecting or invoking onDisconnected.
  /// Use when Bluetooth adapter is turned off and all connections are lost.
  void clearConnection() {
    _device = null;
    _txChar = null;
    _rxChar = null;
  }

  // ─── Discover Services & Characteristics ─────────────────────────────────

  Future<void> _discoverServices() async {
    if (_device == null) return;

    List<BluetoothService> services = await _device!.discoverServices();

    for (BluetoothService service in services) {
      if (service.uuid.toString().toUpperCase() == NUS_SERVICE_UUID) {
        for (BluetoothCharacteristic char in service.characteristics) {
          String uuid = char.uuid.toString().toUpperCase();

          if (uuid == NUS_TX_CHAR_UUID) {
            _txChar = char;
            await _subscribeToNotifications(); // Start receiving messages
          }

          if (uuid == NUS_RX_CHAR_UUID) {
            _rxChar = char;
          }
        }
      }
    }
  }

  // ─── Receive Messages (nRF → App) ────────────────────────────────────────

  Future<void> _subscribeToNotifications() async {
    if (_txChar == null) return;

    await _txChar!.setNotifyValue(true);

    _txChar!.lastValueStream.listen((value) {
      if (value.isNotEmpty) {
        String message = utf8.decode(value);
        _messageController.add(message);
      }
    });
  }

  // ─── Send Messages (App → nRF) ────────────────────────────────────────

  Future<void> sendMessage(String message) async {
    if (_rxChar == null) throw Exception("Not connected or RX char not found");

    List<int> bytes = utf8.encode(message);

    // nRF MTU is usually 20 bytes by default — chunk if needed
    const int chunkSize = 20;
    for (int i = 0; i < bytes.length; i += chunkSize) {
      int end = (i + chunkSize < bytes.length) ? i + chunkSize : bytes.length;
      await _rxChar!.write(bytes.sublist(i, end), withoutResponse: false);
    }
  }

  Future<void> sendBytes(List<int> bytes) async {
    if (_rxChar == null) throw Exception("Not connected");
    await _rxChar!.write(bytes, withoutResponse: false);
  }

  void dispose() {
    _messageController.close();
  }
}