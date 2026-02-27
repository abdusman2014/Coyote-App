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
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1E293B), AppColors.background],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
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
                          ? VacuumGaugeSlider(
                              minValue: 0,
                              maxValue: 20,
                              currentValue: _bleController.currentPressure
                                  .toDouble(),
                              targetValue: 14,
                              onChanged: (value) async {
                                // Handle value changes
                                await _bleController.sendMessage(
                                  message: "5:${value.toInt()}",
                                  deviceSide: _sideIndex == 0
                                      ? DeviceSide.left
                                      : DeviceSide.right,
                                );
                              },
                            )
                          : SvgPicture.asset("assets/images/value_bar.svg"),
                    ),
                    SegmentedControl<String>(
                      options: [
                        SegmentOption(
                          label: 'Sit',
                          imageUri: //"assets/images/walk_white.svg",
                          _activityIndex == 0
                              ? "assets/images/sit_white.svg"
                              : "assets/images/sit_grey.svg",
                          isConnected: _bleController.isConnected(
                            deviceSide: _sideIndex == 0
                                ? DeviceSide.left
                                : DeviceSide.right,
                          ),
                        ),
                        SegmentOption(
                          label: 'Walk',
                          imageUri: _activityIndex == 1
                              ? "assets/images/walk_white.svg"
                              : "assets/images/walk_grey.svg",
                          isConnected: _bleController.isConnected(
                            deviceSide: _sideIndex == 0
                                ? DeviceSide.left
                                : DeviceSide.right,
                          ),
                        ),
                        SegmentOption(
                          label: 'Run',
                          imageUri: _activityIndex == 2
                              ? "assets/images/run_white.svg"
                              : "assets/images/run_grey.svg",
                          isConnected: _bleController.isConnected(
                            deviceSide: _sideIndex == 0
                                ? DeviceSide.left
                                : DeviceSide.right,
                          ),
                        ),
                      ],
                      selectedIndex: _activityIndex,
                      onChanged: (i) async {
                        // await _bleController.sendMessage(
                        //   deviceSide: DeviceSide.left,
                        //   message: "Hello World",
                        // );
                        setState(() => _activityIndex = i);
                      },
                    ),
                    const SizedBox(height: 14),
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
                          const SizedBox(width: 12),
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
                                                .batteryInfo
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
                                          '${_bleController.batteryInfo.batteryPercentage.toStringAsFixed(0)}%',
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
                    const SizedBox(height: 20),
                    PrimaryActionButton(
                      label: _bleController.pumpStatus == 1
                          ? 'Turn Off'
                          : 'Turn On',
                      icon: Icons.power_settings_new,
                      onPressed: _onTurnOff,
                      isOn: _bleController.pumpStatus == 1,
                    ),
                    const SizedBox(height: 20),
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

  void _onBatteryTap() {
    // TODO: Open battery details
  }

  void _onTurnOff() async {
    await _bleController.sendMessage(
      message: _bleController.pumpStatus == 1 ? "2" : "1",
      deviceSide: _sideIndex == 0 ? DeviceSide.left : DeviceSide.right,
    );
  }
}
