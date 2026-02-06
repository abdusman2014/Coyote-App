import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
  int _sideIndex = 0;
  int _activityIndex = 0;
  int _gaugeValue = 12;

  @override
  Widget build(BuildContext context) {
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
                    ),
                    SegmentOption(
                      label: 'Right',
                      imageUri: _sideIndex == 1
                          ? "assets/images/right_white.svg"
                          : "assets/images/right_grey.svg",
                    ),
                  ],
                  selectedIndex: _sideIndex,
                  onChanged: (i) => setState(() => _sideIndex = i),
                ),
                const SizedBox(height: 20),
                Expanded(child: Container()),
                // Expanded(
                //   child: Center(
                //     child: CircularGauge(
                //       value: _gaugeValue,
                //       min: 0,
                //       max: 20,
                //       onChanged: (v) => setState(() => _gaugeValue = v),
                //       showAvatars: false,
                //       centerContent: Column(
                //         mainAxisSize: MainAxisSize.min,
                //         children: const [
                //           Text(
                //             'NO DEVICE\nCONNECTED',
                //             textAlign: TextAlign.center,
                //             style: TextStyle(
                //               fontSize: 20,
                //               fontWeight: FontWeight.w600,
                //               color: AppColors.textPrimary,
                //               letterSpacing: 1.2,
                //             ),
                //           ),
                //           SizedBox(height: 8),
                //           Text(
                //             'Target Vacuum',
                //             style: TextStyle(
                //               fontSize: 14,
                //               color: AppColors.textMuted,
                //             ),
                //           ),
                //           SizedBox(height: 24),
                //           Text(
                //             'NO DEVICE\nCONNECTED',
                //             textAlign: TextAlign.center,
                //             style: TextStyle(
                //               fontSize: 20,
                //               fontWeight: FontWeight.w600,
                //               color: AppColors.textPrimary,
                //               letterSpacing: 1.2,
                //             ),
                //           ),
                //           SizedBox(height: 8),
                //           Text(
                //             'Actual Vacuum',
                //             style: TextStyle(
                //               fontSize: 14,
                //               color: AppColors.textMuted,
                //             ),
                //           ),
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
                SegmentedControl<String>(
                  options: [
                    SegmentOption(
                      label: 'Sit',
                      imageUri: //"assets/images/walk_white.svg",
                      _activityIndex == 0
                          ? "assets/images/sit_white.svg"
                          : "assets/images/sit_grey.svg",
                    ),
                    SegmentOption(
                      label: 'Walk',
                      imageUri: _activityIndex == 1
                          ? "assets/images/walk_white.svg"
                          : "assets/images/walk_grey.svg",
                    ),
                    SegmentOption(
                      label: 'Run',
                      imageUri: _activityIndex == 2
                          ? "assets/images/run_white.svg"
                          : "assets/images/run_grey.svg",
                    ),
                  ],
                  selectedIndex: _activityIndex,
                  onChanged: (i) => setState(() => _activityIndex = i),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 76,
                  child: Row(
                    children: [
                      Expanded(
                        child: StatusCard(
                          title: 'Bluetooth',
                          subtitle: 'Connected',
                          imageUri: "assets/images/bluetooth.svg",
                          onTap: _onBluetoothTap,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatusCard(
                          title: 'Battery',
                          imageUri: "assets/images/battery.svg",
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.bolt,
                                size: 18,
                                color: AppColors.success,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '89%',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                          onTap: _onBatteryTap,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                PrimaryActionButton(
                  label: 'Turn Off',
                  icon: Icons.power_settings_new,
                  onPressed: _onTurnOff,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
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

  void _onTurnOff() {
    // TODO: Turn off device
  }
}
