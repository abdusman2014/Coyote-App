import 'package:coyote_app/services/ble_manager.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
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
  Tuple2<BleManager, BleManager> devices = Tuple2(BleManager(), BleManager());
  BluetoothDevice deviceInfo1 = BluetoothDevice(
    remoteId: DeviceIdentifier("str"),
  );
  BluetoothDevice deviceInfo2 = BluetoothDevice(
    remoteId: DeviceIdentifier("str"),
  );
  Battery batteryInfo = Battery();
  int currentPressure = 0;
  int targetPressure = 0;
  int pumpStatus = 0;
  Map<String, int> preSets = {"sit": 8, "walk": 10, "run": 20};
  Presets selectedPreset = Presets.non;
  List<ScanResult> scanResults = [];

  Future<void> connect({
    required BluetoothDevice device,
    required DeviceSide deviceSide,
  }) async {
    if (deviceSide == DeviceSide.left) {
      if (!devices.item1.isConnected) {
        deviceInfo1 = device;
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
        await devices.item2.connect(device);
        devices.item2.messageStream.listen((msg) {
          print(msg);
          splitData(msg);
        });
        sendInitalMessages(DeviceSide.right);
      }
    }

    // Notify listeners that connection state changed so dependent UIs can rebuild.
    update();
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
      devices.item1.sendMessage(message);
    } else {
      devices.item2.sendMessage(message);
    }
    devices.item1.messageStream.listen((msg) {
      print(msg);
    });
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

  void ApplyPreset({
    required DeviceSide deviceSide,
    required Presets preset,
  }) async {
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

    update();
  }

  void removePreset() {
    selectedPreset = Presets.non;
    update();
  }
}

enum DeviceSide { left, right }

enum Presets { sit, walk, run, non }
