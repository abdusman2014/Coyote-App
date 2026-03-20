// import 'dart:async';

// import 'package:coyote_app/components/action_widget.dart';
// import 'package:coyote_app/components/vacuum_gauge_slider.dart';
// import 'package:coyote_app/controller/ble_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:get/get.dart';
// import '../theme/app_colors.dart';
// import '../components/components.dart';

// /// Full Coyote control screen: Left/Right, circular gauge, Sit/Walk/Run,
// /// Bluetooth & Battery status, and Turn Off button.
// class ControlScreen extends StatefulWidget {
//   const ControlScreen({super.key});

//   @override
//   State<ControlScreen> createState() => _ControlScreenState();
// }

// class _ControlScreenState extends State<ControlScreen> {
//   final BleController _bleController = Get.find<BleController>();
//   int _sideIndex = 0;
//   int _activityIndex = 0;
//   int _targetVacuum = 12;
//   double _actualVacuum = 8.4;

//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<BleController>(
//       init: _bleController,
//       builder: (_) {
//         return Scaffold(
//           body: CoyoteBackground(
//             child: SafeArea(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 24),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     SizedBox(height: 20),
//                     _buildHeader(),
//                     const SizedBox(height: 28),
//                     SegmentedControl<String>(
//                       options: [
//                         SegmentOption(
//                           label: 'Left',
//                           imageUri: _sideIndex == 0
//                               ? "assets/images/left_white.svg"
//                               : "assets/images/left_grey.svg",
//                           isConnected: true,
//                         ),
//                         SegmentOption(
//                           label: 'Right',
//                           imageUri: _sideIndex == 1
//                               ? "assets/images/right_white.svg"
//                               : "assets/images/right_grey.svg",
//                           isConnected: true,
//                         ),
//                       ],
//                       selectedIndex: _sideIndex,
//                       onChanged: (i) => setState(() => _sideIndex = i),
//                     ),
//                     const SizedBox(height: 20),

//                     Expanded(
//                       child:
//                           _bleController.isConnected(
//                             deviceSide: _sideIndex == 0
//                                 ? DeviceSide.left
//                                 : DeviceSide.right,
//                           )
//                           ? VacuumGaugeSlider(
//                               minValue: 0,
//                               maxValue: 20,
//                               currentValue: _bleController
//                                   .getCurrentPressure(
//                                     _sideIndex == 0
//                                         ? DeviceSide.left
//                                         : DeviceSide.right,
//                                   )
//                                   .toDouble(),
//                               targetValue: _bleController
//                                   .getTargetPressure(
//                                     _sideIndex == 0
//                                         ? DeviceSide.left
//                                         : DeviceSide.right,
//                                   )
//                                   .toDouble(),
//                               onChanged: (value) async {
//                                 final side = _sideIndex == 0
//                                     ? DeviceSide.left
//                                     : DeviceSide.right;
//                                 _bleController.removePreset(side);
//                                 _bleController.setGuage(
//                                   pressure: value.toInt(),
//                                   deviceSide: side,
//                                 );
//                               },
//                             )
//                           : SvgPicture.asset("assets/images/value_bar.svg"),
//                     ),
//                     Container(
//                       height: 58,

//                       decoration: BoxDecoration(
//                         color: AppColors.segmentContainer,
//                         borderRadius: BorderRadius.circular(12),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withValues(alpha: 0.2),
//                             blurRadius: 4,
//                             offset: const Offset(0, 1),
//                           ),
//                         ],
//                       ),
//                       child: Row(
//                         // mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           ActionWidget(
//                             imageUri:
//                                 _bleController.getSelectedPreset(
//                                           _sideIndex == 0
//                                               ? DeviceSide.left
//                                               : DeviceSide.right,
//                                         ) ==
//                                         Presets.sit &&
//                                     _bleController.isConnected(
//                                       deviceSide: _sideIndex == 0
//                                           ? DeviceSide.left
//                                           : DeviceSide.right,
//                                     )
//                                 ? "assets/images/sit_white.svg"
//                                 : "assets/images/sit_grey.svg",
//                             label: "Sit",
//                             isSelected:
//                                 _bleController.getSelectedPreset(
//                                       _sideIndex == 0
//                                           ? DeviceSide.left
//                                           : DeviceSide.right,
//                                     ) ==
//                                     Presets.sit &&
//                                 _bleController.isConnected(
//                                   deviceSide: _sideIndex == 0
//                                       ? DeviceSide.left
//                                       : DeviceSide.right,
//                                 ),
//                             onPress: () => _onPresetPressed(Presets.sit),
//                           ),
//                           ActionWidget(
//                             imageUri:
//                                 _bleController.getSelectedPreset(
//                                           _sideIndex == 0
//                                               ? DeviceSide.left
//                                               : DeviceSide.right,
//                                         ) ==
//                                         Presets.walk &&
//                                     _bleController.isConnected(
//                                       deviceSide: _sideIndex == 0
//                                           ? DeviceSide.left
//                                           : DeviceSide.right,
//                                     )
//                                 ? "assets/images/walk_white.svg"
//                                 : "assets/images/walk_grey.svg",
//                             label: "Walk",
//                             isSelected:
//                                 _bleController.getSelectedPreset(
//                                       _sideIndex == 0
//                                           ? DeviceSide.left
//                                           : DeviceSide.right,
//                                     ) ==
//                                     Presets.walk &&
//                                 _bleController.isConnected(
//                                   deviceSide: _sideIndex == 0
//                                       ? DeviceSide.left
//                                       : DeviceSide.right,
//                                 ),
//                             onPress: () => _onPresetPressed(Presets.walk),
//                           ),
//                           ActionWidget(
//                             imageUri:
//                                 _bleController.getSelectedPreset(
//                                           _sideIndex == 0
//                                               ? DeviceSide.left
//                                               : DeviceSide.right,
//                                         ) ==
//                                         Presets.run &&
//                                     _bleController.isConnected(
//                                       deviceSide: _sideIndex == 0
//                                           ? DeviceSide.left
//                                           : DeviceSide.right,
//                                     )
//                                 ? "assets/images/run_white.svg"
//                                 : "assets/images/run_grey.svg",
//                             label: "Run",
//                             isSelected:
//                                 _bleController.getSelectedPreset(
//                                       _sideIndex == 0
//                                           ? DeviceSide.left
//                                           : DeviceSide.right,
//                                     ) ==
//                                     Presets.run &&
//                                 _bleController.isConnected(
//                                   deviceSide: _sideIndex == 0
//                                       ? DeviceSide.left
//                                       : DeviceSide.right,
//                                 ),
//                             onPress: () => _onPresetPressed(Presets.run),
//                           ),
//                         ],
//                       ),
//                     ),

//                     const SizedBox(height: 32),
//                     SizedBox(
//                       height: 76,
//                       child: Row(
//                         children: [
//                           Expanded(
//                             child: StatusCard(
//                               title: 'Bluetooth',
//                               isConnected: _bleController.isConnected(
//                                 deviceSide: _sideIndex == 0
//                                     ? DeviceSide.left
//                                     : DeviceSide.right,
//                               ),
//                               subtitle:
//                                   _bleController.isConnected(
//                                     deviceSide: _sideIndex == 0
//                                         ? DeviceSide.left
//                                         : DeviceSide.right,
//                                   )
//                                   ? 'Connected'
//                                   : "Disconnected",
//                               imageUri: "assets/images/bluetooth.svg",
//                               onTap: _onBluetoothTap,
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           Expanded(
//                             child: StatusCard(
//                               title: 'Battery',
//                               isConnected: _bleController.isConnected(
//                                 deviceSide: _sideIndex == 0
//                                     ? DeviceSide.left
//                                     : DeviceSide.right,
//                               ),
//                               imageUri: "assets/images/battery.svg",
//                               trailing:
//                                   _bleController.isConnected(
//                                     deviceSide: _sideIndex == 0
//                                         ? DeviceSide.left
//                                         : DeviceSide.right,
//                                   )
//                                   ? Row(
//                                       mainAxisSize: MainAxisSize.min,
//                                       children: [
//                                         if (_bleController
//                                                 .getBatteryInfo(
//                                                   _sideIndex == 0
//                                                       ? DeviceSide.left
//                                                       : DeviceSide.right,
//                                                 )
//                                                 .chargingStatus ==
//                                             1) ...[
//                                           Icon(
//                                             Icons.bolt,
//                                             size: 18,
//                                             color: AppColors.success,
//                                           ),
//                                           const SizedBox(width: 4),
//                                         ],
//                                         Text(
//                                           '${_bleController.getBatteryInfo(_sideIndex == 0 ? DeviceSide.left : DeviceSide.right).batteryPercentage.toStringAsFixed(0)}%',
//                                           style: const TextStyle(
//                                             fontSize: 15,
//                                             fontWeight: FontWeight.w600,
//                                             color: AppColors.success,
//                                           ),
//                                         ),
//                                       ],
//                                     )
//                                   : Container(),
//                               onTap: _onBatteryTap,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     PrimaryActionButton(
//                       label:
//                           _bleController.getPumpStatus(
//                                 _sideIndex == 0
//                                     ? DeviceSide.left
//                                     : DeviceSide.right,
//                               ) ==
//                               1
//                           ? 'Turn Off'
//                           : 'Turn On',
//                       icon: Icons.power_settings_new,
//                       onPressed: _onTurnOff,
//                       isOn:
//                           _bleController.getPumpStatus(
//                             _sideIndex == 0
//                                 ? DeviceSide.left
//                                 : DeviceSide.right,
//                           ) ==
//                           1,
//                     ),
//                     // const SizedBox(height: 20),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildHeader() {
//     return Row(
//       children: [
//         SvgPicture.asset("assets/images/logo.svg"),
//         // Text(
//         //   'Coyote',
//         //   style: TextStyle(
//         //     fontSize: 24,
//         //     fontWeight: FontWeight.bold,
//         //     color: AppColors.textPrimary,
//         //   ),
//         // ),
//         // const SizedBox(width: 4),
//         // Icon(Icons.pets, color: AppColors.textPrimary, size: 26),
//       ],
//     );
//   }

//   void _onBluetoothTap() {
//     // TODO: Open Bluetooth settings or status
//   }

//   void _onPresetPressed(Presets preset) {
//     final side = _sideIndex == 0 ? DeviceSide.left : DeviceSide.right;
//     if (!_bleController.isConnected(deviceSide: side)) {
//       _showDisconnectedSnackBar(context);
//       return;
//     }
//     _bleController.ApplyPreset(deviceSide: side, preset: preset);
//   }

//   void _onBatteryTap() async {
//     final side = _sideIndex == 0 ? DeviceSide.left : DeviceSide.right;

//     if (!_bleController.isConnected(deviceSide: side)) {
//       _showDisconnectedSnackBar(context);
//       return;
//     }

//     await _bleController.sendMessage(deviceSide: side, message: "7");
//     if (!context.mounted) return;
//     _showInfoDialog(context);
//   }

//   void _showInfoDialog(BuildContext context) {
//     final side = _sideIndex == 0 ? DeviceSide.left : DeviceSide.right;
//     final battery = _bleController.getBatteryInfo(side);
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Battery Information'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 "Charging Status:  ${battery.chargingStatus == 1 ? "Charging" : "Not Charging"}",
//               ),
//               const SizedBox(height: 8),
//               Text('Battery Percentage: ${battery.batteryPercentage}'),
//               const SizedBox(height: 8),
//               Text('Battery Voltage: ${battery.batteryVoltage}'),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('Close'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _onTurnOff() async {
//     final side = _sideIndex == 0 ? DeviceSide.left : DeviceSide.right;

//     if (!_bleController.isConnected(deviceSide: side)) {
//       _showDisconnectedSnackBar(context);
//       return;
//     }

//     await _bleController.sendMessage(
//       message: _bleController.getPumpStatus(side) == 1 ? "2" : "1",
//       deviceSide: side,
//     );
//   }

//   void _showDisconnectedSnackBar(BuildContext context) {
//     if (!context.mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text(
//           'Device disconnected. Connect your device from the Pair screen.',
//         ),
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//   }
// }

import 'dart:async';

import 'package:coyote_app/components/action_widget.dart';
import 'package:coyote_app/components/vacuum_gauge_slider.dart';
import 'package:coyote_app/controller/ble_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../components/components.dart';

/// Full Coyote control screen: Left/Right, circular gauge, Sit/Walk/Run,
/// Bluetooth & Battery status, and Turn Off button.
class ControlScreen extends StatefulWidget {
  const ControlScreen({super.key});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  final BleController _bleController = Get.find<BleController>();
  int _sideIndex = 0;
  int _activityIndex = 0;
  int _targetVacuum = 12;
  double _actualVacuum = 8.4;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BleController>(
      init: _bleController,
      builder: (_) {
        return Scaffold(
          body: CoyoteBackground(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 20),
                    _buildHeader(),
                    const SizedBox(height: 28),
                    SegmentedControl<String>(
                      options: [
                        SegmentOption(
                          label: 'Left',
                          imageUri: _sideIndex == 0
                              ? "assets/images/left_white.svg"
                              : "assets/images/left_grey.svg",
                          isConnected: true,
                        ),
                        SegmentOption(
                          label: 'Right',
                          imageUri: _sideIndex == 1
                              ? "assets/images/right_white.svg"
                              : "assets/images/right_grey.svg",
                          isConnected: true,
                        ),
                      ],
                      selectedIndex: _sideIndex,
                      onChanged: (i) => setState(() => _sideIndex = i),
                    ),
                    const SizedBox(height: 20),

                    Expanded(
                      child:
                          _bleController.isConnected(
                            deviceSide: _sideIndex == 0
                                ? DeviceSide.left
                                : DeviceSide.right,
                          )
                          ? Align(
                              alignment: Alignment.center,
                              child: VacuumGaugeSlider(
                                minValue: 0,
                                maxValue: 20,
                                currentValue: _bleController
                                    .getCurrentPressure(
                                      _sideIndex == 0
                                          ? DeviceSide.left
                                          : DeviceSide.right,
                                    )
                                    .toDouble(),
                                targetValue: _bleController
                                    .getTargetPressure(
                                      _sideIndex == 0
                                          ? DeviceSide.left
                                          : DeviceSide.right,
                                    )
                                    .toDouble(),
                                onChanged: (value) async {
                                  final side = _sideIndex == 0
                                      ? DeviceSide.left
                                      : DeviceSide.right;
                                  _bleController.removePreset(side);
                                  _bleController.setGuage(
                                    pressure: value.toInt(),
                                    deviceSide: side,
                                  );
                                },
                              ),
                            )
                          : SvgPicture.asset("assets/images/value_bar.svg"),
                    ),
                    Container(
                      height: 58,

                      decoration: BoxDecoration(
                        color: AppColors.segmentContainer,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ActionWidget(
                            imageUri:
                                _bleController.getSelectedPreset(
                                          _sideIndex == 0
                                              ? DeviceSide.left
                                              : DeviceSide.right,
                                        ) ==
                                        Presets.sit &&
                                    _bleController.isConnected(
                                      deviceSide: _sideIndex == 0
                                          ? DeviceSide.left
                                          : DeviceSide.right,
                                    )
                                ? "assets/images/sit_white.svg"
                                : "assets/images/sit_grey.svg",
                            label: "Sit",
                            isSelected:
                                _bleController.getSelectedPreset(
                                      _sideIndex == 0
                                          ? DeviceSide.left
                                          : DeviceSide.right,
                                    ) ==
                                    Presets.sit &&
                                _bleController.isConnected(
                                  deviceSide: _sideIndex == 0
                                      ? DeviceSide.left
                                      : DeviceSide.right,
                                ),
                            onPress: () => _onPresetPressed(Presets.sit),
                          ),
                          ActionWidget(
                            imageUri:
                                _bleController.getSelectedPreset(
                                          _sideIndex == 0
                                              ? DeviceSide.left
                                              : DeviceSide.right,
                                        ) ==
                                        Presets.walk &&
                                    _bleController.isConnected(
                                      deviceSide: _sideIndex == 0
                                          ? DeviceSide.left
                                          : DeviceSide.right,
                                    )
                                ? "assets/images/walk_white.svg"
                                : "assets/images/walk_grey.svg",
                            label: "Walk",
                            isSelected:
                                _bleController.getSelectedPreset(
                                      _sideIndex == 0
                                          ? DeviceSide.left
                                          : DeviceSide.right,
                                    ) ==
                                    Presets.walk &&
                                _bleController.isConnected(
                                  deviceSide: _sideIndex == 0
                                      ? DeviceSide.left
                                      : DeviceSide.right,
                                ),
                            onPress: () => _onPresetPressed(Presets.walk),
                          ),
                          ActionWidget(
                            imageUri:
                                _bleController.getSelectedPreset(
                                          _sideIndex == 0
                                              ? DeviceSide.left
                                              : DeviceSide.right,
                                        ) ==
                                        Presets.run &&
                                    _bleController.isConnected(
                                      deviceSide: _sideIndex == 0
                                          ? DeviceSide.left
                                          : DeviceSide.right,
                                    )
                                ? "assets/images/run_white.svg"
                                : "assets/images/run_grey.svg",
                            label: "Run",
                            isSelected:
                                _bleController.getSelectedPreset(
                                      _sideIndex == 0
                                          ? DeviceSide.left
                                          : DeviceSide.right,
                                    ) ==
                                    Presets.run &&
                                _bleController.isConnected(
                                  deviceSide: _sideIndex == 0
                                      ? DeviceSide.left
                                      : DeviceSide.right,
                                ),
                            onPress: () => _onPresetPressed(Presets.run),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                    SizedBox(
                      height: 76,
                      child: Row(
                        children: [
                          Expanded(
                            child: StatusCard(
                              title: 'Bluetooth',
                              isConnected: _bleController.isConnected(
                                deviceSide: _sideIndex == 0
                                    ? DeviceSide.left
                                    : DeviceSide.right,
                              ),
                              subtitle:
                                  _bleController.isConnected(
                                    deviceSide: _sideIndex == 0
                                        ? DeviceSide.left
                                        : DeviceSide.right,
                                  )
                                  ? 'Connected'
                                  : "UnConnected",
                              imageUri: "assets/images/bluetooth.svg",
                              onTap: _onBluetoothTap,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: StatusCard(
                              title: 'Battery',
                              isConnected: _bleController.isConnected(
                                deviceSide: _sideIndex == 0
                                    ? DeviceSide.left
                                    : DeviceSide.right,
                              ),
                              imageUri: "assets/images/battery.svg",
                              trailing:
                                  _bleController.isConnected(
                                    deviceSide: _sideIndex == 0
                                        ? DeviceSide.left
                                        : DeviceSide.right,
                                  )
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (_bleController
                                                .getBatteryInfo(
                                                  _sideIndex == 0
                                                      ? DeviceSide.left
                                                      : DeviceSide.right,
                                                )
                                                .chargingStatus ==
                                            1) ...[
                                          Icon(
                                            Icons.bolt,
                                            size: 18,
                                            color: AppColors.success,
                                          ),
                                          const SizedBox(width: 4),
                                        ],
                                        Text(
                                          '${_bleController.getBatteryInfo(_sideIndex == 0 ? DeviceSide.left : DeviceSide.right).batteryPercentage.toStringAsFixed(0)}%',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.success,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Container(),
                              onTap: _onBatteryTap,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    PrimaryActionButton(
                      label:
                          _bleController.getPumpStatus(
                                _sideIndex == 0
                                    ? DeviceSide.left
                                    : DeviceSide.right,
                              ) ==
                              1
                          ? 'Turn Off'
                          : 'Turn On',
                      icon: Icons.power_settings_new,
                      onPressed: _onTurnOff,
                      isOn:
                          _bleController.getPumpStatus(
                            _sideIndex == 0
                                ? DeviceSide.left
                                : DeviceSide.right,
                          ) ==
                          1,
                    ),
                    // const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        SvgPicture.asset("assets/images/logo.svg"),
        // Text(
        //   'Coyote',
        //   style: TextStyle(
        //     fontSize: 24,
        //     fontWeight: FontWeight.bold,
        //     color: AppColors.textPrimary,
        //   ),
        // ),
        // const SizedBox(width: 4),
        // Icon(Icons.pets, color: AppColors.textPrimary, size: 26),
      ],
    );
  }

  void _onBluetoothTap() {
    // TODO: Open Bluetooth settings or status
  }

  void _onPresetPressed(Presets preset) {
    final side = _sideIndex == 0 ? DeviceSide.left : DeviceSide.right;
    if (!_bleController.isConnected(deviceSide: side)) {
      _showDisconnectedSnackBar(context);
      return;
    }
    _bleController.ApplyPreset(deviceSide: side, preset: preset);
  }

  void _onBatteryTap() async {
    final side = _sideIndex == 0 ? DeviceSide.left : DeviceSide.right;

    if (!_bleController.isConnected(deviceSide: side)) {
      _showDisconnectedSnackBar(context);
      return;
    }

    await _bleController.sendMessage(deviceSide: side, message: "7");
    if (!context.mounted) return;
    _showInfoDialog(context);
  }

  void _showInfoDialog(BuildContext context) {
    final side = _sideIndex == 0 ? DeviceSide.left : DeviceSide.right;
    final battery = _bleController.getBatteryInfo(side);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Battery Information'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Charging Status:  ${battery.chargingStatus == 1 ? "Charging" : "Not Charging"}",
              ),
              const SizedBox(height: 8),
              Text('Battery Percentage: ${battery.batteryPercentage}'),
              const SizedBox(height: 8),
              Text('Battery Voltage: ${battery.batteryVoltage}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _onTurnOff() async {
    final side = _sideIndex == 0 ? DeviceSide.left : DeviceSide.right;

    if (!_bleController.isConnected(deviceSide: side)) {
      _showDisconnectedSnackBar(context);
      return;
    }

    await _bleController.sendMessage(
      message: _bleController.getPumpStatus(side) == 1 ? "2" : "1",
      deviceSide: side,
    );
  }

  void _showDisconnectedSnackBar(BuildContext context) {
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      const SnackBar(
        content: Text(
          'Device disconnected. Connect your device from the Pair screen.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
