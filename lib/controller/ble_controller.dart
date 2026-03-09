// import 'dart:async';
// import 'package:coyote_app/services/ble_manager.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:tuple/tuple.dart';

// class Battery {
//   int chargingStatus = 10;
//   double batteryPercentage = 10;
//   double batteryVoltage = 10;
//   double currentCycle = 10;

//   Battery.fromString(String data) {
//     List<String> parts = data.split(':');

//     chargingStatus = int.parse(parts[1]);
//     batteryPercentage = double.parse(parts[2]);
//     batteryVoltage = double.parse(parts[3]);
//     currentCycle = double.parse(parts[4]);
//   }
//   Battery() {
//     chargingStatus = 20;
//     batteryPercentage = 20;
//     batteryVoltage = 20;
//     currentCycle = 20;
//   }
// }

// class BleController extends GetxController {
//   late final Tuple2<BleManager, BleManager> devices;
//   final GetStorage _box = GetStorage();
//   bool isReconnecting = false;
//   Timer? _leftReconnectTimer;
//   Timer? _rightReconnectTimer;
//   BluetoothDevice deviceInfo1 = BluetoothDevice(
//     remoteId: DeviceIdentifier("str"),
//   );
//   BluetoothDevice deviceInfo2 = BluetoothDevice(
//     remoteId: DeviceIdentifier("str"),
//   );
//   String deviceInfoName1 = "";
//   String deviceInfoName2 = "";
//   // Per-device state (left = 1, right = 2)
//   Battery batteryInfo1 = Battery();
//   Battery batteryInfo2 = Battery();
//   int currentPressure1 = 0;
//   int currentPressure2 = 0;
//   int targetPressure1 = 0;
//   int targetPressure2 = 0;
//   int pumpStatus1 = 0;
//   int pumpStatus2 = 0;
//   Presets selectedPreset1 = Presets.non;
//   Presets selectedPreset2 = Presets.non;
//   Map<String, int> preSets = {"sit": 8, "walk": 10, "run": 20};
//   List<ScanResult> scanResults = [];

//   Battery getBatteryInfo(DeviceSide side) =>
//       side == DeviceSide.left ? batteryInfo1 : batteryInfo2;
//   int getCurrentPressure(DeviceSide side) =>
//       side == DeviceSide.left ? currentPressure1 : currentPressure2;
//   int getTargetPressure(DeviceSide side) =>
//       side == DeviceSide.left ? targetPressure1 : targetPressure2;
//   int getPumpStatus(DeviceSide side) {
//     if (side == DeviceSide.left) {
//       if (devices.item1.isConnected) {
//         return pumpStatus1;
//       } else {
//         return 0;
//       }
//     } else {
//       if (devices.item2.isConnected) {
//         return pumpStatus2;
//       } else {
//         return 0;
//       }
//     }
//     // return side == DeviceSide.left ? pumpStatus1 : pumpStatus2;
//   }

//   Presets getSelectedPreset(DeviceSide side) =>
//       side == DeviceSide.left ? selectedPreset1 : selectedPreset2;

//   BleController() {
//     devices = Tuple2(
//       BleManager(onDisconnected: () => _handleDisconnected(DeviceSide.left)),
//       BleManager(onDisconnected: () => _handleDisconnected(DeviceSide.right)),
//     );
//   }

//   @override
//   void onInit() {
//     super.onInit();

//     _restoreState();
//     FlutterBluePlus.adapterState.listen((state) {
//       if (state == BluetoothAdapterState.off) {
//         _handleBluetoothOff();
//       } else if (state == BluetoothAdapterState.on) {
//         _autoReconnect();
//       }
//     });
//     // Try an initial reconnect if Bluetooth is already on.
//     _autoReconnect();
//   }

//   /// When Bluetooth adapter is turned off, all connections are lost.
//   /// Clear both sides and reset state immediately.
//   void _handleBluetoothOff() {
//     devices.item1.clearConnection();
//     devices.item2.clearConnection();
//     deviceInfo1 = BluetoothDevice(remoteId: const DeviceIdentifier('str'));
//     deviceInfo2 = BluetoothDevice(remoteId: const DeviceIdentifier('str'));
//     batteryInfo1 = Battery();
//     batteryInfo2 = Battery();
//     currentPressure1 = 0;
//     currentPressure2 = 0;
//     targetPressure1 = 0;
//     targetPressure2 = 0;
//     pumpStatus1 = 0;
//     pumpStatus2 = 0;
//     selectedPreset1 = Presets.non;
//     selectedPreset2 = Presets.non;
//     scanResults = [];
//     isReconnecting = false;
//     _stopReconnectLoop(DeviceSide.left);
//     _stopReconnectLoop(DeviceSide.right);
//     _saveState();
//     update();
//   }

//   /// Attempt to reconnect to previously known devices when Bluetooth is on.
//   Future<void> _autoReconnect() async {
//     if (isReconnecting) return;

//     final state = await FlutterBluePlus.adapterState.first;
//     if (state != BluetoothAdapterState.on) return;

//     final leftId = deviceInfo1.remoteId.str;
//     final rightId = deviceInfo2.remoteId.str;

//     // Nothing to reconnect to
//     if (leftId == 'str' && rightId == 'str') {
//       return;
//     }

//     isReconnecting = true;
//     update();

//     try {
//       if (leftId != 'str' && !devices.item1.isConnected) {
//         await connect(device: deviceInfo1, deviceSide: DeviceSide.left);
//       }

//       if (rightId != 'str' && !devices.item2.isConnected) {
//         await connect(device: deviceInfo2, deviceSide: DeviceSide.right);
//       }
//     } catch (_) {
//       // Ignore auto-reconnect errors; user can connect manually.
//     } finally {
//       isReconnecting = false;
//       update();
//     }
//   }

//   Future<void> connect({
//     required BluetoothDevice device,
//     required DeviceSide deviceSide,
//   }) async {
//     if (deviceSide == DeviceSide.left) {
//       if (!devices.item1.isConnected) {
//         deviceInfo1 = device;
//         if (device.advName != "") {
//           deviceInfoName1 = device.advName;
//         }
//         await devices.item1.connect(device);

//         devices.item1.messageStream.listen((msg) {
//           print(msg);
//           splitData(msg, DeviceSide.left);
//         });
//         await sendInitalMessages(DeviceSide.left);
//         startFiveSecondTimerLeft();
//       }
//     } else {
//       if (!devices.item2.isConnected) {
//         deviceInfo2 = device;
//         if (device.advName != "") {
//           deviceInfoName2 = device.advName;
//         }
//         await devices.item2.connect(device);
//         devices.item2.messageStream.listen((msg) {
//           print(msg);
//           splitData(msg, DeviceSide.right);
//         });
//         await sendInitalMessages(DeviceSide.right);
//         startFiveSecondTimerRight();
//       }
//     }

//     // Notify listeners that connection state changed so dependent UIs can rebuild.
//     _stopReconnectLoop(deviceSide);
//     _saveState();
//     update();
//   }

//   Future<void> disconnect(DeviceSide deviceSide) async {
//     devices.item1.isConnected;
//     if (deviceSide == DeviceSide.left) {
//       _timerLeft?.cancel();
//       _timerLeft = null;
//       if (devices.item1.isConnected) {
//         await devices.item1.disconnect();
//       }
//       deviceInfo1 = BluetoothDevice(remoteId: DeviceIdentifier("str"));
//       deviceInfoName1 = "";
//       batteryInfo1 = Battery();
//       currentPressure1 = 0;
//       targetPressure1 = 0;
//       pumpStatus1 = 0;
//       selectedPreset1 = Presets.non;
//     } else {
//       _timerRight?.cancel();
//       _timerRight = null;
//       if (devices.item2.isConnected) {
//         await devices.item2.disconnect();
//       }
//       deviceInfo2 = BluetoothDevice(remoteId: DeviceIdentifier("str"));
//       deviceInfoName2 = "";
//       batteryInfo2 = Battery();
//       currentPressure2 = 0;
//       targetPressure2 = 0;
//       pumpStatus2 = 0;
//       selectedPreset2 = Presets.non;
//     }
//     _stopReconnectLoop(deviceSide);
//     update();
//     _saveState();
//   }

//   void splitData(String msg, DeviceSide side) {
//     if (msg.isEmpty) return;
//     if (msg[0] == '7') {
//       final battery = Battery.fromString(msg);
//       if (side == DeviceSide.left) {
//         batteryInfo1 = battery;
//       } else {
//         batteryInfo2 = battery;
//       }
//       print(battery);
//     } else if (msg[0] == '4') {
//       final parts = msg.split(':');
//       final value = int.parse(parts[1]) < 0 ? 0 : int.parse(parts[1]);
//       if (side == DeviceSide.left) {
//         currentPressure1 = value;
//       } else {
//         currentPressure2 = value;
//       }
//     } else if (msg[0] == '6' || msg[0] == '1' || msg[0] == '2') {
//       final parts = msg.split(':');
//       final value = int.parse(parts[1]);
//       if (side == DeviceSide.left) {
//         pumpStatus1 = value;
//       } else {
//         pumpStatus2 = value;
//       }
//     }
//     _saveState();
//     update();
//   }

//   Future<void> sendInitalMessages(DeviceSide device) async {
//     if (device == DeviceSide.left) {
//       devices.item1.sendMessage("7");
//       devices.item1.sendMessage("4");
//       devices.item1.sendMessage("6");
//     } else {
//       devices.item2.sendMessage("7");
//       devices.item2.sendMessage("4");
//       devices.item2.sendMessage("6");
//     }
//   }

//   Timer? _timerLeft;

//   void startFiveSecondTimerLeft() {
//     _timerLeft = Timer.periodic(Duration(seconds: 5), (timer) {
//       if (devices.item1.isConnected) {
//         sendCommands(DeviceSide.left);
//       }
//     });
//   }

//   Timer? _timerRight;

//   void startFiveSecondTimerRight() {
//     _timerRight = Timer.periodic(const Duration(seconds: 5), (timer) {
//       if (devices.item2.isConnected) {
//         sendCommands(DeviceSide.right);
//       }
//     });
//   }

//   void sendCommands(DeviceSide deviceSide) {
//     sendMessage(message: "4", deviceSide: deviceSide);
//     sendMessage(message: "6", deviceSide: deviceSide);
//     sendMessage(message: "7", deviceSide: deviceSide);
//   }

//   Future<void> sendMessage({
//     required String message,
//     required DeviceSide deviceSide,
//   }) async {
//     if (deviceSide == DeviceSide.left) {
//       if (devices.item1.isConnected) {
//         try {
//           await devices.item1.sendMessage(message);
//         } catch (e) {
//           // show a snackbar, log it, etc.
//           print("Send error: $e");
//         }
//       }
//     } else {
//       if (devices.item2.isConnected) {
//         try {
//           await devices.item2.sendMessage(message);
//         } catch (e) {
//           // show a snackbar, log it, etc.
//           print("Send error: $e");
//         }
//       }
//     }
//   }

//   Future<void> setGuage({
//     required int pressure,
//     required DeviceSide deviceSide,
//   }) async {
//     if (deviceSide == DeviceSide.left) {
//       targetPressure1 = pressure;
//     } else {
//       targetPressure2 = pressure;
//     }
//     await sendMessage(message: "5:${pressure.toInt()}", deviceSide: deviceSide);
//     _saveState();
//   }

//   String getDeviceName(DeviceSide deviceSide) {
//     if (deviceSide == DeviceSide.left) {
//       return deviceInfo1.advName;
//     } else {
//       return deviceInfo2.advName;
//     }
//   }

//   Future<void> scan() async {
//     devices.item1.startScan().listen((results) {
//       // scanResults = results;
//       scanResults = results.where((result) {
//         final name = result.device.advName;
//         return name.startsWith('PUCK_');
//       }).toList();
//       print("scan");
//       print(scanResults);
//       // scanResults = results;
//       update();
//     });
//     // await Future.delayed(Duration(seconds: 2));
//     // return scanResults;
//   }

//   bool isConnected({required DeviceSide deviceSide}) {
//     if (deviceSide == DeviceSide.left) {
//       return devices.item1.isConnected;
//     } else {
//       return devices.item2.isConnected;
//     }
//   }

//   /// True if [deviceSide] is connected and [device] is the connected device.
//   bool isDeviceConnected(DeviceSide deviceSide, BluetoothDevice device) {
//     if (!isConnected(deviceSide: deviceSide)) return false;
//     final id = device.remoteId.str;
//     if (deviceSide == DeviceSide.left) {
//       return devices.item1.isConnected && deviceInfo1.remoteId.str == id;
//     } else {
//       return devices.item2.isConnected && deviceInfo2.remoteId.str == id;
//     }
//   }

//   void _handleDisconnected(DeviceSide side) {
//     // Clear volatile state for the disconnected side only.
//     if (side == DeviceSide.left) {
//       batteryInfo1 = Battery();
//       currentPressure1 = 0;
//       pumpStatus1 = 0;
//       _timerLeft?.cancel();
//       _timerLeft = null;
//     } else {
//       batteryInfo2 = Battery();
//       currentPressure2 = 0;
//       pumpStatus2 = 0;
//       _timerRight?.cancel();
//       _timerRight = null;
//     }
//     if (!devices.item1.isConnected && !devices.item2.isConnected) {
//       scanResults = [];
//     }

//     _startReconnectLoop(side);
//     _saveState();
//     update();
//   }

//   void _saveState() {
//     // Persist last-known devices (by id and name)
//     final leftId = deviceInfo1.remoteId.str;
//     final rightId = deviceInfo2.remoteId.str;

//     if (leftId != 'str') {
//       _box.write('leftDeviceId', leftId);
//       _box.write('leftDeviceName', deviceInfoName1);
//     } else {
//       _box.remove('leftDeviceId');
//       _box.remove('leftDeviceName');
//     }

//     if (rightId != 'str') {
//       _box.write('rightDeviceId', rightId);
//       _box.write('rightDeviceName', deviceInfoName2);
//     } else {
//       _box.remove('rightDeviceId');
//       _box.remove('rightDeviceName');
//     }

//     // Per-side battery and runtime state
//     _box.write('batteryChargingStatus1', batteryInfo1.chargingStatus);
//     _box.write('batteryPercentage1', batteryInfo1.batteryPercentage);
//     _box.write('batteryVoltage1', batteryInfo1.batteryVoltage);
//     _box.write('batteryCurrentCycle1', batteryInfo1.currentCycle);
//     _box.write('currentPressure1', currentPressure1);
//     _box.write('targetPressure1', targetPressure1);
//     _box.write('pumpStatus1', pumpStatus1);
//     _box.write('selectedPresetIndex1', selectedPreset1.index);

//     _box.write('batteryChargingStatus2', batteryInfo2.chargingStatus);
//     _box.write('batteryPercentage2', batteryInfo2.batteryPercentage);
//     _box.write('batteryVoltage2', batteryInfo2.batteryVoltage);
//     _box.write('batteryCurrentCycle2', batteryInfo2.currentCycle);
//     _box.write('currentPressure2', currentPressure2);
//     _box.write('targetPressure2', targetPressure2);
//     _box.write('pumpStatus2', pumpStatus2);
//     _box.write('selectedPresetIndex2', selectedPreset2.index);

//     _box.write('preSets', preSets);
//   }

//   void _restoreState() {
//     // Restore last-known devices (so we know what was paired)
//     final String? leftId = _box.read<String>('leftDeviceId');
//     final String? rightId = _box.read<String>('rightDeviceId');

//     if (leftId != null) {
//       deviceInfo1 = BluetoothDevice(remoteId: DeviceIdentifier(leftId));
//       deviceInfoName1 = _box.read<String>('leftDeviceName') ?? "str";
//     }
//     if (rightId != null) {
//       deviceInfo2 = BluetoothDevice(remoteId: DeviceIdentifier(rightId));
//       deviceInfoName2 = _box.read<String>('rightDeviceName') ?? "str";
//     }

//     // Side 1
//     final int? c1 = _box.read<int>('batteryChargingStatus1');
//     if (c1 != null) {
//       batteryInfo1.chargingStatus = c1;
//       final dynamic p1 = _box.read('batteryPercentage1');
//       final dynamic v1 = _box.read('batteryVoltage1');
//       final double? cy1 = _box.read<double>('batteryCurrentCycle1');
//       batteryInfo1.batteryPercentage = p1 is num
//           ? p1.toDouble()
//           : batteryInfo1.batteryPercentage;
//       batteryInfo1.batteryVoltage = v1 is num
//           ? v1.toDouble()
//           : batteryInfo1.batteryVoltage;
//       batteryInfo1.currentCycle = cy1 ?? batteryInfo1.currentCycle;
//     }
//     final int? cur1 = _box.read<int>('currentPressure1');
//     final int? tgt1 = _box.read<int>('targetPressure1');
//     final int? pump1 = _box.read<int>('pumpStatus1');
//     if (cur1 != null) currentPressure1 = cur1;
//     if (tgt1 != null) targetPressure1 = tgt1;
//     if (pump1 != null) pumpStatus1 = pump1;
//     final int? sp1 = _box.read<int>('selectedPresetIndex1');
//     if (sp1 != null && sp1 >= 0 && sp1 < Presets.values.length) {
//       selectedPreset1 = Presets.values[sp1];
//     }

//     // Side 2
//     final int? c2 = _box.read<int>('batteryChargingStatus2');
//     if (c2 != null) {
//       batteryInfo2.chargingStatus = c2;
//       final dynamic p2 = _box.read('batteryPercentage2');
//       final dynamic v2 = _box.read('batteryVoltage2');
//       final double? cy2 = _box.read<double>('batteryCurrentCycle2');
//       batteryInfo2.batteryPercentage = p2 is num
//           ? p2.toDouble()
//           : batteryInfo2.batteryPercentage;
//       batteryInfo2.batteryVoltage = v2 is num
//           ? v2.toDouble()
//           : batteryInfo2.batteryVoltage;
//       batteryInfo2.currentCycle = cy2 ?? batteryInfo2.currentCycle;
//     }
//     final int? cur2 = _box.read<int>('currentPressure2');
//     final int? tgt2 = _box.read<int>('targetPressure2');
//     final int? pump2 = _box.read<int>('pumpStatus2');
//     if (cur2 != null) currentPressure2 = cur2;
//     if (tgt2 != null) targetPressure2 = tgt2;
//     if (pump2 != null) pumpStatus2 = pump2;
//     final int? sp2 = _box.read<int>('selectedPresetIndex2');
//     if (sp2 != null && sp2 >= 0 && sp2 < Presets.values.length) {
//       selectedPreset2 = Presets.values[sp2];
//     }

//     // Shared presets
//     final dynamic storedPresets = _box.read('preSets');
//     if (storedPresets is Map) {
//       preSets = storedPresets.map(
//         (key, value) => MapEntry(key.toString(), (value as num).toInt()),
//       );
//     }

//     update();
//   }

//   void _startReconnectLoop(DeviceSide side) {
//     if (side == DeviceSide.left) {
//       if (_leftReconnectTimer != null && _leftReconnectTimer!.isActive) return;
//       _leftReconnectTimer = Timer.periodic(
//         const Duration(seconds: 5),
//         (_) => _attemptSideReconnect(DeviceSide.left),
//       );
//     } else {
//       if (_rightReconnectTimer != null && _rightReconnectTimer!.isActive)
//         return;
//       _rightReconnectTimer = Timer.periodic(
//         const Duration(seconds: 5),
//         (_) => _attemptSideReconnect(DeviceSide.right),
//       );
//     }
//   }

//   void _stopReconnectLoop(DeviceSide side) {
//     if (side == DeviceSide.left) {
//       _leftReconnectTimer?.cancel();
//       _leftReconnectTimer = null;
//     } else {
//       _rightReconnectTimer?.cancel();
//       _rightReconnectTimer = null;
//     }
//   }

//   Future<void> _attemptSideReconnect(DeviceSide side) async {
//     final state = await FlutterBluePlus.adapterState.first;
//     if (state != BluetoothAdapterState.on) {
//       _stopReconnectLoop(side);
//       return;
//     }

//     if (side == DeviceSide.left) {
//       final id = deviceInfo1.remoteId.str;
//       if (id == 'str' || devices.item1.isConnected) {
//         _stopReconnectLoop(DeviceSide.left);
//         return;
//       }
//       try {
//         await connect(device: deviceInfo1, deviceSide: DeviceSide.left);
//       } catch (_) {
//         // Ignore and let the timer try again later.
//       }
//     } else {
//       final id = deviceInfo2.remoteId.str;
//       if (id == 'str' || devices.item2.isConnected) {
//         _stopReconnectLoop(DeviceSide.right);
//         return;
//       }
//       try {
//         await connect(device: deviceInfo2, deviceSide: DeviceSide.right);
//       } catch (_) {
//         // Ignore and let the timer try again later.
//       }
//     }
//   }

//   void ApplyPreset({
//     required DeviceSide deviceSide,
//     required Presets preset,
//   }) async {
//     if (deviceSide == DeviceSide.left && !devices.item1.isConnected) return;
//     if (deviceSide == DeviceSide.right && !devices.item2.isConnected) return;

//     int value = 0;
//     if (preset == Presets.sit) {
//       value = preSets["sit"] ?? 0;
//     } else if (preset == Presets.walk) {
//       value = preSets["walk"] ?? 0;
//     } else {
//       value = preSets["run"] ?? 0;
//     }

//     if (deviceSide == DeviceSide.left) {
//       selectedPreset1 = preset;
//       targetPressure1 = value;
//     } else {
//       selectedPreset2 = preset;
//       targetPressure2 = value;
//     }
//     sendMessage(message: "5:$value", deviceSide: deviceSide);
//     _saveState();
//     update();
//   }

//   void setPreset({required Presets preset, required int value}) {
//     if (preset == Presets.sit) {
//       preSets["sit"] = value;
//     } else if (preset == Presets.walk) {
//       preSets["walk"] = value;
//     } else {
//       preSets["run"] = value;
//     }

//     _saveState();
//     update();
//   }

//   void removePreset(DeviceSide deviceSide) {
//     if (deviceSide == DeviceSide.left) {
//       selectedPreset1 = Presets.non;
//     } else {
//       selectedPreset2 = Presets.non;
//     }
//     _saveState();
//     update();
//   }
// }

// enum DeviceSide { left, right }

// enum Presets { sit, walk, run, non }

import 'dart:async';
import 'package:coyote_app/services/ble_manager.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tuple/tuple.dart';

class Battery {
  int chargingStatus = 10;
  double batteryPercentage = 10;
  double batteryVoltage = 10;
  double currentCycle = 10;

  Battery.fromString(String data) {
    List<String> parts = data.split(':');

    chargingStatus = int.parse(parts[1]);
    batteryPercentage = double.parse(parts[2]);
    batteryVoltage = double.parse(parts[3]);
    currentCycle = double.parse(parts[4]);
  }
  Battery() {
    chargingStatus = 20;
    batteryPercentage = 20;
    batteryVoltage = 20;
    currentCycle = 20;
  }
}

class BleController extends GetxController {
  late final Tuple2<BleManager, BleManager> devices;
  final GetStorage _box = GetStorage();
  bool isReconnecting = false;
  Timer? _leftReconnectTimer;
  Timer? _rightReconnectTimer;

  // ── Fixed: one subscription per side to prevent ghost listeners ──────────
  StreamSubscription? _leftSubscription;
  StreamSubscription? _rightSubscription;
  // ─────────────────────────────────────────────────────────────────────────

  BluetoothDevice deviceInfo1 = BluetoothDevice(
    remoteId: DeviceIdentifier("str"),
  );
  BluetoothDevice deviceInfo2 = BluetoothDevice(
    remoteId: DeviceIdentifier("str"),
  );
  String deviceInfoName1 = "";
  String deviceInfoName2 = "";
  // Per-device state (left = 1, right = 2)
  Battery batteryInfo1 = Battery();
  Battery batteryInfo2 = Battery();
  int currentPressure1 = 0;
  int currentPressure2 = 0;
  int targetPressure1 = 0;
  int targetPressure2 = 0;
  int pumpStatus1 = 0;
  int pumpStatus2 = 0;
  Presets selectedPreset1 = Presets.non;
  Presets selectedPreset2 = Presets.non;
  Map<String, int> preSets = {"sit": 8, "walk": 10, "run": 20};
  List<ScanResult> scanResults = [];

  Battery getBatteryInfo(DeviceSide side) =>
      side == DeviceSide.left ? batteryInfo1 : batteryInfo2;
  int getCurrentPressure(DeviceSide side) =>
      side == DeviceSide.left ? currentPressure1 : currentPressure2;
  int getTargetPressure(DeviceSide side) =>
      side == DeviceSide.left ? targetPressure1 : targetPressure2;
  int getPumpStatus(DeviceSide side) {
    if (side == DeviceSide.left) {
      if (devices.item1.isConnected) {
        return pumpStatus1;
      } else {
        return 0;
      }
    } else {
      if (devices.item2.isConnected) {
        return pumpStatus2;
      } else {
        return 0;
      }
    }
  }

  Presets getSelectedPreset(DeviceSide side) =>
      side == DeviceSide.left ? selectedPreset1 : selectedPreset2;

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
    _autoReconnect();
  }

  void _handleBluetoothOff() {
    // ── Fixed: cancel subscriptions before clearing ────────────────────────
    _leftSubscription?.cancel();
    _leftSubscription = null;
    _rightSubscription?.cancel();
    _rightSubscription = null;
    // ─────────────────────────────────────────────────────────────────────────

    devices.item1.clearConnection();
    devices.item2.clearConnection();
    deviceInfo1 = BluetoothDevice(remoteId: const DeviceIdentifier('str'));
    deviceInfo2 = BluetoothDevice(remoteId: const DeviceIdentifier('str'));
    batteryInfo1 = Battery();
    batteryInfo2 = Battery();
    currentPressure1 = 0;
    currentPressure2 = 0;
    targetPressure1 = 0;
    targetPressure2 = 0;
    pumpStatus1 = 0;
    pumpStatus2 = 0;
    selectedPreset1 = Presets.non;
    selectedPreset2 = Presets.non;
    scanResults = [];
    isReconnecting = false;
    _stopReconnectLoop(DeviceSide.left);
    _stopReconnectLoop(DeviceSide.right);
    _saveState();
    update();
  }

  Future<void> _autoReconnect() async {
    if (isReconnecting) return;

    final state = await FlutterBluePlus.adapterState.first;
    if (state != BluetoothAdapterState.on) return;

    final leftId = deviceInfo1.remoteId.str;
    final rightId = deviceInfo2.remoteId.str;

    if (leftId == 'str' && rightId == 'str') return;

    isReconnecting = true;
    update();

    try {
      if (leftId != 'str' && !devices.item1.isConnected) {
        await connect(device: deviceInfo1, deviceSide: DeviceSide.left);
      }
      if (rightId != 'str' && !devices.item2.isConnected) {
        await connect(device: deviceInfo2, deviceSide: DeviceSide.right);
      }
    } catch (_) {
      // Ignore auto-reconnect errors; user can connect manually.
    } finally {
      isReconnecting = false;
      update();
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

        // ── Fixed: cancel old subscription before attaching a new one ──────
        _leftSubscription?.cancel();
        _leftSubscription = devices.item1.messageStream.listen((msg) {
          print(msg);
          splitData(msg, DeviceSide.left);
        });
        // ───────────────────────────────────────────────────────────────────

        await sendInitalMessages(DeviceSide.left);
        startFiveSecondTimerLeft();
      }
    } else {
      if (!devices.item2.isConnected) {
        deviceInfo2 = device;
        if (device.advName != "") {
          deviceInfoName2 = device.advName;
        }
        await devices.item2.connect(device);

        // ── Fixed: cancel old subscription before attaching a new one ──────
        _rightSubscription?.cancel();
        _rightSubscription = devices.item2.messageStream.listen((msg) {
          print(msg);
          splitData(msg, DeviceSide.right);
        });
        // ───────────────────────────────────────────────────────────────────

        await sendInitalMessages(DeviceSide.right);
        startFiveSecondTimerRight();
      }
    }

    _stopReconnectLoop(deviceSide);
    _saveState();
    update();
  }

  Future<void> disconnect(DeviceSide deviceSide) async {
    if (deviceSide == DeviceSide.left) {
      _timerLeft?.cancel();
      _timerLeft = null;
      // ── Fixed: cancel subscription on disconnect ──────────────────────
    await  _leftSubscription?.cancel();
      _leftSubscription = null;
      // ───────────────────────────────────────────────────────────────────
      if (devices.item1.isConnected) {
        await devices.item1.disconnect();
      }
      deviceInfo1 = BluetoothDevice(remoteId: DeviceIdentifier("str"));
      deviceInfoName1 = "";
      batteryInfo1 = Battery();
      currentPressure1 = 0;
      targetPressure1 = 0;
      pumpStatus1 = 0;
      selectedPreset1 = Presets.non;
    } else {
      _timerRight?.cancel();
      _timerRight = null;
      // ── Fixed: cancel subscription on disconnect ──────────────────────
     await _rightSubscription?.cancel();
      _rightSubscription = null;
      // ───────────────────────────────────────────────────────────────────
      if (devices.item2.isConnected) {
        await devices.item2.disconnect();
      }
      deviceInfo2 = BluetoothDevice(remoteId: DeviceIdentifier("str"));
      deviceInfoName2 = "";
      batteryInfo2 = Battery();
      currentPressure2 = 0;
      targetPressure2 = 0;
      pumpStatus2 = 0;
      selectedPreset2 = Presets.non;
    }
    _stopReconnectLoop(deviceSide);
    update();
    _saveState();
  }

  void splitData(String msg, DeviceSide side) {
    if (msg.isEmpty) return;

    if (msg[0] == '7') {
      final battery = Battery.fromString(msg);
      if (side == DeviceSide.left) {
        batteryInfo1 = battery;
      } else {
        batteryInfo2 = battery;
      }
      print(battery);
    } else if (msg[0] == '4') {
      final parts = msg.split(':');
      final value = int.parse(parts[1]) < 0 ? 0 : int.parse(parts[1]);
      if (side == DeviceSide.left) {
        currentPressure1 = value;
      } else {
        currentPressure2 = value;
      }
    } else if (msg[0] == '6' || msg[0] == '1' || msg[0] == '2') {
      final parts = msg.split(':');
      final value = int.parse(parts[1]);
      if (side == DeviceSide.left) {
        pumpStatus1 = value;
      } else {
        pumpStatus2 = value;
      }
    }
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
      devices.item2.sendMessage("4");
      devices.item2.sendMessage("6");
    }
  }

  Timer? _timerLeft;

  void startFiveSecondTimerLeft() {
    _timerLeft?.cancel();
    _timerLeft = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (devices.item1.isConnected) {
        sendCommands(DeviceSide.left);
      }
    });
  }

  Timer? _timerRight;

  void startFiveSecondTimerRight() {
    _timerRight?.cancel();
    _timerRight = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (devices.item2.isConnected) {
        sendCommands(DeviceSide.right);
      }
    });
  }

  void sendCommands(DeviceSide deviceSide) {
    sendMessage(message: "4", deviceSide: deviceSide);
    sendMessage(message: "6", deviceSide: deviceSide);
    sendMessage(message: "7", deviceSide: deviceSide);
  }

  Future<void> sendMessage({
    required String message,
    required DeviceSide deviceSide,
  }) async {
    if (deviceSide == DeviceSide.left) {
      if (devices.item1.isConnected) {
        try {
          await devices.item1.sendMessage(message);
        } catch (e) {
          print("Send error: $e");
        }
      }
    } else {
      if (devices.item2.isConnected) {
        try {
          await devices.item2.sendMessage(message);
        } catch (e) {
          print("Send error: $e");
        }
      }
    }
  }

  Future<void> setGuage({
    required int pressure,
    required DeviceSide deviceSide,
  }) async {
    if (deviceSide == DeviceSide.left) {
      targetPressure1 = pressure;
    } else {
      targetPressure2 = pressure;
    }
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
      scanResults = results.where((result) {
        final name = result.device.advName;
        return name.startsWith('PUCK_');
      }).toList();
      print("scan");
      print(scanResults);
      update();
    });
  }

  bool isConnected({required DeviceSide deviceSide}) {
    if (deviceSide == DeviceSide.left) {
      return devices.item1.isConnected;
    } else {
      return devices.item2.isConnected;
    }
  }

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
    // ── Fixed: cancel subscription for the disconnected side ──────────────
    if (side == DeviceSide.left) {
      _leftSubscription?.cancel();
      _leftSubscription = null;
      batteryInfo1 = Battery();
      currentPressure1 = 0;
      pumpStatus1 = 0;
      _timerLeft?.cancel();
      _timerLeft = null;
    } else {
      _rightSubscription?.cancel();
      _rightSubscription = null;
      batteryInfo2 = Battery();
      currentPressure2 = 0;
      pumpStatus2 = 0;
      _timerRight?.cancel();
      _timerRight = null;
    }
    // ─────────────────────────────────────────────────────────────────────────

    if (!devices.item1.isConnected && !devices.item2.isConnected) {
      scanResults = [];
    }

    _startReconnectLoop(side);
    _saveState();
    update();
  }

  void _saveState() {
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

    _box.write('batteryChargingStatus1', batteryInfo1.chargingStatus);
    _box.write('batteryPercentage1', batteryInfo1.batteryPercentage);
    _box.write('batteryVoltage1', batteryInfo1.batteryVoltage);
    _box.write('batteryCurrentCycle1', batteryInfo1.currentCycle);
    _box.write('currentPressure1', currentPressure1);
    _box.write('targetPressure1', targetPressure1);
    _box.write('pumpStatus1', pumpStatus1);
    _box.write('selectedPresetIndex1', selectedPreset1.index);

    _box.write('batteryChargingStatus2', batteryInfo2.chargingStatus);
    _box.write('batteryPercentage2', batteryInfo2.batteryPercentage);
    _box.write('batteryVoltage2', batteryInfo2.batteryVoltage);
    _box.write('batteryCurrentCycle2', batteryInfo2.currentCycle);
    _box.write('currentPressure2', currentPressure2);
    _box.write('targetPressure2', targetPressure2);
    _box.write('pumpStatus2', pumpStatus2);
    _box.write('selectedPresetIndex2', selectedPreset2.index);

    _box.write('preSets', preSets);
  }

  void _restoreState() {
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

    // Side 1
    final int? c1 = _box.read<int>('batteryChargingStatus1');
    if (c1 != null) {
      batteryInfo1.chargingStatus = c1;
      final dynamic p1 = _box.read('batteryPercentage1');
      final dynamic v1 = _box.read('batteryVoltage1');
      final double? cy1 = _box.read<double>('batteryCurrentCycle1');
      batteryInfo1.batteryPercentage = p1 is num
          ? p1.toDouble()
          : batteryInfo1.batteryPercentage;
      batteryInfo1.batteryVoltage = v1 is num
          ? v1.toDouble()
          : batteryInfo1.batteryVoltage;
      batteryInfo1.currentCycle = cy1 ?? batteryInfo1.currentCycle;
    }
    final int? cur1 = _box.read<int>('currentPressure1');
    final int? tgt1 = _box.read<int>('targetPressure1');
    final int? pump1 = _box.read<int>('pumpStatus1');
    if (cur1 != null) currentPressure1 = cur1;
    if (tgt1 != null) targetPressure1 = tgt1;
    if (pump1 != null) pumpStatus1 = pump1;
    final int? sp1 = _box.read<int>('selectedPresetIndex1');
    if (sp1 != null && sp1 >= 0 && sp1 < Presets.values.length) {
      selectedPreset1 = Presets.values[sp1];
    }

    // Side 2
    final int? c2 = _box.read<int>('batteryChargingStatus2');
    if (c2 != null) {
      batteryInfo2.chargingStatus = c2;
      final dynamic p2 = _box.read('batteryPercentage2');
      final dynamic v2 = _box.read('batteryVoltage2');
      final double? cy2 = _box.read<double>('batteryCurrentCycle2');
      batteryInfo2.batteryPercentage = p2 is num
          ? p2.toDouble()
          : batteryInfo2.batteryPercentage;
      batteryInfo2.batteryVoltage = v2 is num
          ? v2.toDouble()
          : batteryInfo2.batteryVoltage;
      batteryInfo2.currentCycle = cy2 ?? batteryInfo2.currentCycle;
    }
    final int? cur2 = _box.read<int>('currentPressure2');
    final int? tgt2 = _box.read<int>('targetPressure2');
    final int? pump2 = _box.read<int>('pumpStatus2');
    if (cur2 != null) currentPressure2 = cur2;
    if (tgt2 != null) targetPressure2 = tgt2;
    if (pump2 != null) pumpStatus2 = pump2;
    final int? sp2 = _box.read<int>('selectedPresetIndex2');
    if (sp2 != null && sp2 >= 0 && sp2 < Presets.values.length) {
      selectedPreset2 = Presets.values[sp2];
    }

    // Shared presets
    final dynamic storedPresets = _box.read('preSets');
    if (storedPresets is Map) {
      preSets = storedPresets.map(
        (key, value) => MapEntry(key.toString(), (value as num).toInt()),
      );
    }

    update();
  }

  void _startReconnectLoop(DeviceSide side) {
    if (side == DeviceSide.left) {
      if (_leftReconnectTimer != null && _leftReconnectTimer!.isActive) return;
      _leftReconnectTimer = Timer.periodic(
        const Duration(seconds: 5),
        (_) => _attemptSideReconnect(DeviceSide.left),
      );
    } else {
      if (_rightReconnectTimer != null && _rightReconnectTimer!.isActive)
        return;
      _rightReconnectTimer = Timer.periodic(
        const Duration(seconds: 5),
        (_) => _attemptSideReconnect(DeviceSide.right),
      );
    }
  }

  void _stopReconnectLoop(DeviceSide side) {
    if (side == DeviceSide.left) {
      _leftReconnectTimer?.cancel();
      _leftReconnectTimer = null;
    } else {
      _rightReconnectTimer?.cancel();
      _rightReconnectTimer = null;
    }
  }

  Future<void> _attemptSideReconnect(DeviceSide side) async {
    final state = await FlutterBluePlus.adapterState.first;
    if (state != BluetoothAdapterState.on) {
      _stopReconnectLoop(side);
      return;
    }

    if (side == DeviceSide.left) {
      final id = deviceInfo1.remoteId.str;
      if (id == 'str' || devices.item1.isConnected) {
        _stopReconnectLoop(DeviceSide.left);
        return;
      }
      try {
        await connect(device: deviceInfo1, deviceSide: DeviceSide.left);
      } catch (_) {}
    } else {
      final id = deviceInfo2.remoteId.str;
      if (id == 'str' || devices.item2.isConnected) {
        _stopReconnectLoop(DeviceSide.right);
        return;
      }
      try {
        await connect(device: deviceInfo2, deviceSide: DeviceSide.right);
      } catch (_) {}
    }
  }

  void ApplyPreset({
    required DeviceSide deviceSide,
    required Presets preset,
  }) async {
    if (deviceSide == DeviceSide.left && !devices.item1.isConnected) return;
    if (deviceSide == DeviceSide.right && !devices.item2.isConnected) return;

    int value = 0;
    if (preset == Presets.sit) {
      value = preSets["sit"] ?? 0;
    } else if (preset == Presets.walk) {
      value = preSets["walk"] ?? 0;
    } else {
      value = preSets["run"] ?? 0;
    }

    if (deviceSide == DeviceSide.left) {
      selectedPreset1 = preset;
      targetPressure1 = value;
    } else {
      selectedPreset2 = preset;
      targetPressure2 = value;
    }
    sendMessage(message: "5:$value", deviceSide: deviceSide);
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

  void removePreset(DeviceSide deviceSide) {
    if (deviceSide == DeviceSide.left) {
      selectedPreset1 = Presets.non;
    } else {
      selectedPreset2 = Presets.non;
    }
    _saveState();
    update();
  }
}

enum DeviceSide { left, right }

enum Presets { sit, walk, run, non }
