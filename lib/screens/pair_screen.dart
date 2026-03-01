import 'dart:math' as math;
import 'package:coyote_app/controller/ble_controller.dart';
import 'package:coyote_app/services/ble_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../theme/app_colors.dart';
import 'package:lottie/lottie.dart';

/// Pairing screen showing available devices and "Add New Device" section.
class PairScreen extends StatefulWidget {
  const PairScreen({super.key});

  @override
  State<PairScreen> createState() => _PairScreenState();
}

class _PairScreenState extends State<PairScreen> {
  int _selectedIndex = 0; // 0 = Left, 1 = Right
  bool _isScanning = false;

  // final BleManager _ble = BleManager();
  final BleController _bleController = Get.find<BleController>();
  final TextEditingController _inputController = TextEditingController();
  final List<String> _messages = [];
  List<ScanResult> _scanResults = [];
  bool _isConnected = false;
  List<_ConnectState> _connectStates = [];

  @override
  void initState() {
    super.initState();
    _requestPermissions().then((_) {
      // _startScan();
    });
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();
  }

  Future<void> _startScan() async {
    setState(() {
      _scanResults = [];
      _isScanning = true;
      _connectStates = [];
    });
    List<ScanResult> result = [];
    _bleController.devices.item1.startScan().listen((results) {
      // scanResults = results;
      result.addAll(
        results.where((result) {
          final name = result.device.advName;
          return name.startsWith('PUCK_');
        }).toList(),
      );

      // result = results.where((result) {
      //   final name = result.device.advName;
      //   return name.startsWith('PUCK_');
      // }).toList();
      print("scan");
      print(result);
      setState(() {
        _scanResults = result;
        _connectStates = List<_ConnectState>.filled(
          result.length,
          _ConnectState.idle,
        );
        // _isScanning = false;
      });
      // scanResults = results;
      // update();
    });
    // await Future.delayed(Duration(seconds: 5));
    print(result);

    // setState(() {
    //   _scanResults = result;
    //   _connectStates = List<_ConnectState>.filled(
    //     result.length,
    //     _ConnectState.idle,
    //   );
    //   // _isScanning = false;
    // });
    // Future.delayed(const Duration(seconds: 10), () {
    //   setState(() => _isScanning = false);
    // });
  }

  Future<void> _connect(BluetoothDevice device) async {
    await _bleController.connect(
      device: device,
      deviceSide: _selectedIndex == 0 ? DeviceSide.left : DeviceSide.right,
    );
  }

  void _onSideSelected(int index) {
    setState(() {
      _selectedIndex = index;
      _scanResults = [];
      _connectStates = [];
      _isScanning = false;
    });
    // If this side is already connected, just show it as connected.
    final side = index == 0 ? DeviceSide.left : DeviceSide.right;
    final alreadyConnected = _bleController.isConnected(deviceSide: side);
    if (!alreadyConnected) {
      // Automatically start a fresh scan for the newly selected side.
      _startScan();
    }
  }

  // Future<void> _sendMessage() async {
  //   String text = _inputController.text.trim();
  //   if (text.isEmpty) return;

  //   // await _ble.sendMessage(text);

  //   // setState(() => _messages.add("Me: $text"));
  //   _inputController.clear();
  // }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BleController>(
      init: _bleController,
      builder: (_) {
        return Scaffold(
          body: SingleChildScrollView(
            child: Container(
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      const Text(
                        'Devices',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: _DeviceCard(
                              label: 'Left',
                              isSelected: _selectedIndex == 0,
                              onTap: () => _onSideSelected(0),
                              imageUri: _selectedIndex == 0
                                  ? "assets/images/left_white.svg"
                                  : "assets/images/left_grey.svg",
                              deviceName: _bleController
                                  .getDeviceName(DeviceSide.left)
                                  .replaceFirst('PUCK_', ''),
                              onDisconnect: () {
                                _bleController.disconnect(DeviceSide.left);
                                setState(() {
                                  _isScanning = false;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _DeviceCard(
                              label: 'Right',
                              isSelected: _selectedIndex == 1,
                              onTap: () => _onSideSelected(1),
                              imageUri: _selectedIndex == 1
                                  ? "assets/images/right_white.svg"
                                  : "assets/images/right_grey.svg",
                              deviceName: _bleController
                                  .getDeviceName(DeviceSide.right)
                                  .replaceFirst('PUCK_', ''),
                              onDisconnect: () {
                                _bleController.disconnect(DeviceSide.left);
                                setState(() {
                                  _isScanning = false;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 36),
                      const Text(
                        'Add New Device',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Builder(
                        builder: (context) {
                          final side = _selectedIndex == 0
                              ? DeviceSide.left
                              : DeviceSide.right;
                          // final sideConnected = _bleController.isConnected(
                          //   deviceSide: side,
                          // );

                          // if (sideConnected) {
                          //   return _DeviceListTile(
                          //     deviceId: _bleController
                          //         .getDeviceName(
                          //           _selectedIndex == 0
                          //               ? DeviceSide.left
                          //               : DeviceSide.right,
                          //         )
                          //         .replaceFirst('PUCK_', ''),
                          //     state:
                          //         _bleController.isConnected(
                          //           deviceSide: _selectedIndex == 0
                          //               ? DeviceSide.left
                          //               : DeviceSide.right,
                          //         )
                          //         ? _ConnectState.connected
                          //         : _ConnectState.idle,
                          //     onConnect: () {},
                          //   );

                          // }

                          if (!_isScanning) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "To get your new device set up, select it from the section above and then hit the 'Scan' button located below.",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    height: 1.5,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                const SizedBox(height: 28),
                                Center(
                                  child: SizedBox(
                                    width: 170,
                                    child: FilledButton.icon(
                                      onPressed: () async {
                                        // Check if Bluetooth is on
                                        BluetoothAdapterState state =
                                            await FlutterBluePlus
                                                .adapterState
                                                .first;

                                        if (state != BluetoothAdapterState.on) {
                                          // Android: programmatically turn on
                                          await FlutterBluePlus.turnOn();

                                          // Wait until it's actually on
                                          await FlutterBluePlus.adapterState
                                              .where(
                                                (s) =>
                                                    s ==
                                                    BluetoothAdapterState.on,
                                              )
                                              .first;
                                        }
                                        _startScan();
                                      },
                                      icon: SvgPicture.asset(
                                        "assets/images/scanner.svg",
                                      ),
                                      label: const Text(
                                        'Scan',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      style: FilledButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: AppColors.textPrimary,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                          horizontal: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            22,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }
                          if ((_selectedIndex == 0 &&
                                  !_bleController.isConnected(
                                    deviceSide: DeviceSide.left,
                                  ) ||
                              _selectedIndex == 1 &&
                                  !_bleController.isConnected(
                                    deviceSide: DeviceSide.right,
                                  ))) {
                            return _ScanSection(
                              devices: _scanResults,
                              connectStates: _connectStates,
                              bleController: _bleController,
                              deviceSide: _selectedIndex == 0
                                  ? DeviceSide.left
                                  : DeviceSide.right,
                              onConnect: (int index) async {
                                setState(() {
                                  if (index < _connectStates.length) {
                                    _connectStates[index] =
                                        _ConnectState.connecting;
                                  }
                                });
                                try {
                                  await _connect(_scanResults[index].device);
                                  setState(() {
                                    if (index < _connectStates.length) {
                                      _connectStates[index] =
                                          _ConnectState.connected;
                                      _isConnected = true;
                                    }
                                  });
                                } catch (_) {
                                  setState(() {
                                    if (index < _connectStates.length) {
                                      _connectStates[index] =
                                          _ConnectState.idle;
                                    }
                                  });
                                }
                              },
                            );
                          }
                          return Container();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // void _onScanPressed() {
  //   setState(() {
  //     _isScanning = true;
  //   });

  //   _ble.startScan().listen((results) {
  //     setState(() {
  //       _scanResults = results;
  //     });
  //   });
  //   print("asd: " + _ble.isConnected.toString());
  // }
}

class _DeviceCard extends StatelessWidget {
  const _DeviceCard({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.imageUri,
    required this.deviceName,
    required this.onDisconnect,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final String imageUri;
  final String deviceName;
  final VoidCallback onDisconnect;

  @override
  Widget build(BuildContext context) {
    final background = isSelected
        ? AppColors.primary
        : AppColors.segmentContainer;
    final borderColor = isSelected
        ? AppColors.primary
        : Colors.white.withOpacity(0.06);

    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 0.9,
        child: Container(
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: borderColor, width: 2),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.35),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : const [],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: _SelectionDot(isSelected: isSelected),
              ),
              // Row(
              //   children: [
              //     Expanded(child: Container()),
              //     Positioned(
              //       right: 14,
              //       top: 14,
              //       child: _SelectionDot(isSelected: isSelected),
              //     ),
              //   ],
              // ),
              Expanded(child: Container()),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(imageUri, height: 30),
                  const SizedBox(height: 18),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: isSelected
                          ? AppColors.textPrimary
                          : AppColors.textMuted,
                    ),
                  ),
                  Text(
                    deviceName,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: isSelected
                          ? AppColors.textPrimary
                          : AppColors.textMuted,
                    ),
                  ),
                  if (deviceName != "")
                    GestureDetector(
                      onTap: onDisconnect,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.gaugeTrackMin),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: EdgeInsets.all(6),
                        child: Text(
                          "Disconnect",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            color: isSelected
                                ? AppColors.textPrimary
                                : AppColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              // Expanded(child: Container()),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectionDot extends StatelessWidget {
  const _SelectionDot({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected
        ? Colors.white
        : Colors.white.withOpacity(0.25);

    return Container(
      width: 20,
      height: 20,
      padding: EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 2),
        color: Colors.transparent,
      ),
      child: isSelected
          ? Container(
              // height: 5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
            )
          : Container(),
    );
  }
}

class _FootIcon extends StatelessWidget {
  const _FootIcon({required this.isHighlighted});

  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final color = Colors.white.withOpacity(isHighlighted ? 1.0 : 0.9);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 32,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ],
    );
  }
}

class _ScanSection extends StatelessWidget {
  const _ScanSection({
    required this.devices,
    required this.connectStates,
    required this.bleController,
    required this.deviceSide,
    required this.onConnect,
  });

  final List<ScanResult> devices;
  final List<_ConnectState> connectStates;
  final BleController bleController;
  final DeviceSide deviceSide;
  final Future<void> Function(int index) onConnect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Center(
          child: Lottie.asset(
            'assets/animations/bluetooth_search.json',
            height: 250,
          ),
        ),
        const Text(
          'Available devices',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(devices.length, (index) {
          final device = devices[index];
          final localState = index < connectStates.length
              ? connectStates[index]
              : _ConnectState.idle;
          // Show connected only if device is actually connected; otherwise
          // use local state (connecting/idle) so we don't show stale tick after disconnect.
          final state =
              bleController.isDeviceConnected(deviceSide, device.device)
              ? _ConnectState.connected
              : localState;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _DeviceListTile(
              deviceId: device.device.advName.replaceFirst('PUCK_', ''),
              state: state,
              onConnect: () => onConnect(index),
            ),
          );
        }),
      ],
    );
  }
}

class _BluetoothRadarPainter extends CustomPainter {
  const _BluetoothRadarPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    final rect = Rect.fromCircle(center: center, radius: radius);

    // Background semicircle
    final bgPaint = Paint()
      ..color = Colors.black.withOpacity(0.15)
      ..style = PaintingStyle.fill;
    canvas.drawArc(rect, math.pi, math.pi, true, bgPaint);

    // Sweep sector
    final sweepPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.primary.withOpacity(0.9),
          AppColors.primary.withOpacity(0.2),
        ],
      ).createShader(rect)
      ..style = PaintingStyle.fill;
    final sweepPath = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(rect, math.pi * 1.05, math.pi * 0.55, false)
      ..close();
    canvas.drawPath(sweepPath, sweepPaint);

    // Concentric arcs
    final arcPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (var i = 0; i < 3; i++) {
      final r = radius * (0.45 + i * 0.17);
      final arcRect = Rect.fromCircle(center: center, radius: r);
      canvas.drawArc(arcRect, math.pi, math.pi, false, arcPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DeviceListTile extends StatelessWidget {
  const _DeviceListTile({
    required this.deviceId,
    required this.state,
    required this.onConnect,
  });

  final String deviceId;
  final _ConnectState state;
  final VoidCallback onConnect;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          SvgPicture.asset("assets/images/bluetooth.svg"),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              deviceId,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (state == _ConnectState.connecting)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          else if (state == _ConnectState.connected)
            const Icon(Icons.check_circle, color: AppColors.success)
          else
            TextButton(
              onPressed: onConnect,
              child: const Text(
                'Connect',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

enum _ConnectState { idle, connecting, connected }
