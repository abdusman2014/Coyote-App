import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

  @override
  Widget build(BuildContext context) {
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
                          onTap: () => setState(() => _selectedIndex = 0),
                          imageUri: "assets/images/left.svg",
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _DeviceCard(
                          label: 'Right',
                          isSelected: _selectedIndex == 1,
                          onTap: () => setState(() => _selectedIndex = 1),
                          imageUri: "assets/images/right.svg",
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
                  if (!_isScanning) ...[
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
                          onPressed: _onScanPressed,
                          icon: SvgPicture.asset("assets/images/scanner.svg"),
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
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    const _ScanSection(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onScanPressed() {
    setState(() {
      _isScanning = true;
    });
  }
}

class _DeviceCard extends StatelessWidget {
  const _DeviceCard({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.imageUri,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final String imageUri;

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
              Row(
                children: [
                  Expanded(child: Container()),
                  Positioned(
                    right: 14,
                    top: 14,
                    child: _SelectionDot(isSelected: isSelected),
                  ),
                ],
              ),
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
                ],
              ),
              Expanded(child: Container()),
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
  const _ScanSection();

  @override
  Widget build(BuildContext context) {
    final devices = ['1A5F4H', 'KAJF82', 'KAJF83'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Center(
          child: Lottie.asset(
            'assets/animations/bluetooth_search.json',
            height: 150,
          ),
        ),
      
        const SizedBox(height: 28),
        const Text(
          'Available devices',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...devices.map(
          (id) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _DeviceListTile(deviceId: id),
          ),
        ),
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
  const _DeviceListTile({required this.deviceId});

  final String deviceId;

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
          TextButton(
            onPressed: () {
              // TODO: Implement connect action.
            },
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
