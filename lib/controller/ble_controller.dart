import 'package:coyote_app/services/ble_manager.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tuple/tuple.dart';

class Battery {
  int chargingStatus = 0;
  double batteryPercentage = 0;
  double batteryVoltage = 0;
  int currentCycle = 0;

  Battery.fromString(String data) {
    List<String> parts = data.split(':');

    chargingStatus = int.parse(parts[1]);
    batteryPercentage = double.parse(parts[2]);
    batteryVoltage = double.parse(parts[3]);
    currentCycle = int.parse(parts[4]);
  }
  Battery() {
    chargingStatus = 0;
    batteryPercentage = 0;
    batteryVoltage = 0;
    currentCycle = 0;
  }
}

class BleController extends GetxController {
  late final Tuple2<BleManager, BleManager> devices;
  final GetStorage _box = GetStorage();
  bool _hasTriedReconnect = false;
  BluetoothDevice deviceInfo1 = BluetoothDevice(
    remoteId: DeviceIdentifier("str"),
  );
  BluetoothDevice deviceInfo2 = BluetoothDevice(
    remoteId: DeviceIdentifier("str"),
  );
  String deviceInfoName1 = "";
  String deviceInfoName2 = "";
  Battery batteryInfo = Battery();
  int currentPressure = 0;
  int targetPressure = 0;
  int pumpStatus = 0;
  Map<String, int> preSets = {"sit": 8, "walk": 10, "run": 20};
  Presets selectedPreset = Presets.non;
  List<ScanResult> scanResults = [];

  BleController() {
    devices = Tuple2(
      BleManager(onDisconnected: () => _handleDisconnected(DeviceSide.left)),
      BleManager(onDisconnected: () => _handleDisconnected(DeviceSide.right)),
    );
  }

  @override
  void onInit() {
    super.onInit();

    _restoreState();
    FlutterBluePlus.adapterState.listen((state) {
      if (state == BluetoothAdapterState.off) {
        _handleBluetoothOff();
      } else if (state == BluetoothAdapterState.on) {
        _autoReconnect();
      }
    });
    // Try an initial reconnect if Bluetooth is already on.
    _autoReconnect();
  }

  /// When Bluetooth adapter is turned off, all connections are lost.
  /// Clear both sides and reset state immediately.
  void _handleBluetoothOff() {
    devices.item1.clearConnection();
    devices.item2.clearConnection();
    deviceInfo1 = BluetoothDevice(remoteId: const DeviceIdentifier('str'));
    deviceInfo2 = BluetoothDevice(remoteId: const DeviceIdentifier('str'));
    batteryInfo = Battery();
    currentPressure = 0;
    targetPressure = 0;
    pumpStatus = 0;
    selectedPreset = Presets.non;
    scanResults = [];
    _saveState();
    update();
  }

  /// Attempt to reconnect to previously known devices when Bluetooth is on.
  Future<void> _autoReconnect() async {
    if (_hasTriedReconnect) return;

    final state = await FlutterBluePlus.adapterState.first;
    if (state != BluetoothAdapterState.on) return;

    _hasTriedReconnect = true;

    final leftId = deviceInfo1.remoteId.str;
    final rightId = deviceInfo2.remoteId.str;

    try {
      if (leftId != 'str' && !devices.item1.isConnected) {
        await connect(device: deviceInfo1, deviceSide: DeviceSide.left);
      }
    } catch (_) {
      // Ignore auto-reconnect errors; user can connect manually.
    }

    try {
      if (rightId != 'str' && !devices.item2.isConnected) {
        await connect(device: deviceInfo2, deviceSide: DeviceSide.right);
      }
    } catch (_) {
      // Ignore auto-reconnect errors; user can connect manually.
    }
  }

  Future<void> connect({
    required BluetoothDevice device,
    required DeviceSide deviceSide,
  }) async {
    if (deviceSide == DeviceSide.left) {
      if (!devices.item1.isConnected) {
        deviceInfo1 = device;
        if (device.advName != "") {
          deviceInfoName1 = device.advName;
        }
        await devices.item1.connect(device);
        devices.item1.messageStream.listen((msg) {
          print(msg);
          splitData(msg);
        });
        sendInitalMessages(DeviceSide.left);
      }
    } else {
      if (!devices.item2.isConnected) {
        deviceInfo2 = device;
        if (device.advName != "") {
          deviceInfoName2 = device.advName;
        }
        await devices.item2.connect(device);
        devices.item2.messageStream.listen((msg) {
          print(msg);
          splitData(msg);
        });
        sendInitalMessages(DeviceSide.right);
      }
    }

    // Notify listeners that connection state changed so dependent UIs can rebuild.
    _saveState();
    update();
  }

  Future<void> disconnect(DeviceSide deviceSide) async {
    if (deviceSide == DeviceSide.left) {
      await devices.item1.disconnect();
      deviceInfo1 = BluetoothDevice(remoteId: DeviceIdentifier("str"));
      deviceInfoName1 = "";
    } else {
      await devices.item2.disconnect();
      deviceInfo2 = BluetoothDevice(remoteId: DeviceIdentifier("str"));
      deviceInfoName2 = "";
    }
    update();
    _saveState();
  }

  void splitData(String msg) {
    // Battery Info
    if (msg.isNotEmpty && msg[0] == '7') {
      batteryInfo = Battery.fromString(msg);
      print(batteryInfo);
    } else if (msg.isNotEmpty && msg[0] == '4') {
      List<String> parts = msg.split(':');
      currentPressure = int.parse(parts[1]) < 0 ? 0 : int.parse(parts[1]);
    } else if (msg.isNotEmpty && msg[0] == '6') {
      List<String> parts = msg.split(':');
      pumpStatus = int.parse(parts[1]);
    } else if (msg.isNotEmpty && msg[0] == '1') {
      List<String> parts = msg.split(':');
      pumpStatus = int.parse(parts[1]);
    } else if (msg.isNotEmpty && msg[0] == '2') {
      List<String> parts = msg.split(':');
      pumpStatus = int.parse(parts[1]);
    }
    // Trigger UI updates (e.g. ControlScreen battery widget)
    _saveState();
    update();
  }

  Future<void> sendInitalMessages(DeviceSide device) async {
    if (device == DeviceSide.left) {
      devices.item1.sendMessage("7");
      devices.item1.sendMessage("4");
      devices.item1.sendMessage("6");
    } else {
      devices.item2.sendMessage("7");
      devices.item1.sendMessage("4");
      devices.item1.sendMessage("6");
    }
  }

  Future<void> sendMessage({
    required String message,
    required DeviceSide deviceSide,
  }) async {
    if (deviceSide == DeviceSide.left) {
      print(devices.item1);
      if (devices.item1.isConnected) {
        devices.item1.sendMessage(message);
      }
    } else {
      if (devices.item2.isConnected) {
        devices.item2.sendMessage(message);
      }
    }
    devices.item1.messageStream.listen((msg) {
      print(msg);
    });
  }

  Future<void> setGuage({
    required int pressure,
    required DeviceSide deviceSide,
  }) async {
    targetPressure = pressure;
    await sendMessage(message: "5:${pressure.toInt()}", deviceSide: deviceSide);
    _saveState();
  }

  String getDeviceName(DeviceSide deviceSide) {
    if (deviceSide == DeviceSide.left) {
      return deviceInfo1.advName;
    } else {
      return deviceInfo2.advName;
    }
  }

  Future<void> scan() async {
    devices.item1.startScan().listen((results) {
      // scanResults = results;
      scanResults = results.where((result) {
        final name = result.device.advName;
        return name.startsWith('PUCK_');
      }).toList();
      print("scan");
      print(scanResults);
      // scanResults = results;
      update();
    });
    // await Future.delayed(Duration(seconds: 2));
    // return scanResults;
  }

  bool isConnected({required DeviceSide deviceSide}) {
    if (deviceSide == DeviceSide.left) {
      return devices.item1.isConnected;
    } else {
      return devices.item2.isConnected;
    }
  }

  /// True if [deviceSide] is connected and [device] is the connected device.
  bool isDeviceConnected(DeviceSide deviceSide, BluetoothDevice device) {
    if (!isConnected(deviceSide: deviceSide)) return false;
    final id = device.remoteId.str;
    if (deviceSide == DeviceSide.left) {
      return devices.item1.isConnected && deviceInfo1.remoteId.str == id;
    } else {
      return devices.item2.isConnected && deviceInfo2.remoteId.str == id;
    }
  }

  void _handleDisconnected(DeviceSide side) {
    // Clear device info for the disconnected side
    if (side == DeviceSide.left) {
      deviceInfo1 = BluetoothDevice(remoteId: const DeviceIdentifier('str'));
      deviceInfoName1 = "str";
    } else {
      deviceInfo2 = BluetoothDevice(remoteId: const DeviceIdentifier('str'));
      deviceInfoName2 = "str";
    }

    // If both sides are now disconnected, reset shared state
    if (!devices.item1.isConnected && !devices.item2.isConnected) {
      batteryInfo = Battery();
      currentPressure = 0;
      targetPressure = 0;
      pumpStatus = 0;
      selectedPreset = Presets.non;
      scanResults = [];
    }

    // Persist and notify UI to rebuild (ControlScreen, PairScreen, etc.)
    _saveState();
    update();
  }

  void _saveState() {
    // Persist last-known devices (by id and name)
    final leftId = deviceInfo1.remoteId.str;
    final rightId = deviceInfo2.remoteId.str;

    if (leftId != 'str') {
      _box.write('leftDeviceId', leftId);
      _box.write('leftDeviceName', deviceInfoName1);
    } else {
      _box.remove('leftDeviceId');
      _box.remove('leftDeviceName');
    }

    if (rightId != 'str') {
      _box.write('rightDeviceId', rightId);
      _box.write('rightDeviceName', deviceInfoName2);
    } else {
      _box.remove('rightDeviceId');
      _box.remove('rightDeviceName');
    }

    // Battery and runtime state
    _box.write('batteryChargingStatus', batteryInfo.chargingStatus);
    _box.write('batteryPercentage', batteryInfo.batteryPercentage);
    _box.write('batteryVoltage', batteryInfo.batteryVoltage);
    _box.write('batteryCurrentCycle', batteryInfo.currentCycle);

    _box.write('currentPressure', currentPressure);
    _box.write('targetPressure', targetPressure);
    _box.write('pumpStatus', pumpStatus);

    // Presets and selection
    _box.write('preSets', preSets);
    _box.write('selectedPresetIndex', selectedPreset.index);
  }

  void _restoreState() {
    // Restore last-known devices (so we know what was paired)
    final String? leftId = _box.read<String>('leftDeviceId');
    final String? rightId = _box.read<String>('rightDeviceId');

    if (leftId != null) {
      deviceInfo1 = BluetoothDevice(remoteId: DeviceIdentifier(leftId));
      deviceInfoName1 = _box.read<String>('leftDeviceName') ?? "str";
    }
    if (rightId != null) {
      deviceInfo2 = BluetoothDevice(remoteId: DeviceIdentifier(rightId));
      deviceInfoName2 = _box.read<String>('rightDeviceName') ?? "str";
    }

    // Battery info
    final int? chargingStatus = _box.read<int>('batteryChargingStatus');
    if (chargingStatus != null) {
      batteryInfo.chargingStatus = chargingStatus;
      final dynamic percent = _box.read('batteryPercentage');
      final dynamic voltage = _box.read('batteryVoltage');
      final int? cycle = _box.read<int>('batteryCurrentCycle');
      batteryInfo.batteryPercentage = percent is num
          ? percent.toDouble()
          : batteryInfo.batteryPercentage;
      batteryInfo.batteryVoltage = voltage is num
          ? voltage.toDouble()
          : batteryInfo.batteryVoltage;
      batteryInfo.currentCycle = cycle ?? batteryInfo.currentCycle;
    }

    // Pressures and pump
    final int? storedCurrent = _box.read<int>('currentPressure');
    final int? storedTarget = _box.read<int>('targetPressure');
    final int? storedPump = _box.read<int>('pumpStatus');
    if (storedCurrent != null) currentPressure = storedCurrent;
    if (storedTarget != null) targetPressure = storedTarget;
    if (storedPump != null) pumpStatus = storedPump;

    // Presets
    final dynamic storedPresets = _box.read('preSets');
    if (storedPresets is Map) {
      preSets = storedPresets.map(
        (key, value) => MapEntry(key.toString(), (value as num).toInt()),
      );
    }

    final int? presetIndex = _box.read<int>('selectedPresetIndex');
    if (presetIndex != null &&
        presetIndex >= 0 &&
        presetIndex < Presets.values.length) {
      selectedPreset = Presets.values[presetIndex];
    }

    update();
  }

  void ApplyPreset({
    required DeviceSide deviceSide,
    required Presets preset,
  }) async {
    if (deviceSide == DeviceSide.left) {
      if (!devices.item1.isConnected) {
        return;
      }
    }
    if (deviceSide == DeviceSide.right) {
      if (!devices.item2.isConnected) {
        return;
      }
    }
    selectedPreset = preset;
    int value = 0;
    if (preset == Presets.sit) {
      value = preSets["sit"] ?? 0;
    } else if (preset == Presets.walk) {
      value = preSets["walk"] ?? 0;
    } else {
      value = preSets["run"] ?? 0;
    }
    sendMessage(message: "5:$value", deviceSide: deviceSide);
    targetPressure = value;
    _saveState();
    update();
  }

  void setPreset({required Presets preset, required int value}) {
    if (preset == Presets.sit) {
      preSets["sit"] = value;
    } else if (preset == Presets.walk) {
      preSets["walk"] = value;
    } else {
      preSets["run"] = value;
    }

    _saveState();
    update();
  }

  void removePreset() {
    selectedPreset = Presets.non;
    _saveState();
    update();
  }
}

enum DeviceSide { left, right }

enum Presets { sit, walk, run, non }
