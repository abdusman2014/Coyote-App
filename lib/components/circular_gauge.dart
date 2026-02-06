import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Circular gauge with min/max track, central value, optional profile avatars,
/// and a draggable handle. Track runs from left (min) to right (max).
class CircularGauge extends StatefulWidget {
  const CircularGauge({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    this.onChanged,
    this.showAvatars = true,
    this.avatarRadius = 20,
    this.centerContent,
  });

  final int value;
  final int min;
  final int max;
  final ValueChanged<int>? onChanged;
  final bool showAvatars;
  final double avatarRadius;
  final Widget? centerContent;

  @override
  State<CircularGauge> createState() => _CircularGaugeState();
}

class _CircularGaugeState extends State<CircularGauge> {
  static const double _trackStrokeWidth = 12;
  static const double _handleRadius = 14;
  final GlobalKey _gaugeKey = GlobalKey();

  double _angleFromValue(int v) {
    final t = (v - widget.min) / (widget.max - widget.min).clamp(1, double.infinity);
    return math.pi + t * math.pi;
  }

  Offset _positionFromAngle(double angle, double radius) {
    return Offset(
      radius * math.cos(angle),
      radius * math.sin(angle),
    );
  }

  int _valueFromAngle(double angle) {
    final t = (angle - math.pi) / math.pi;
    final v = widget.min + t * (widget.max - widget.min);
    return v.round().clamp(widget.min, widget.max);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, constraints.maxHeight);
        final center = size / 2;
        final radius = center - _trackStrokeWidth - _handleRadius - 8;

        final valueAngle = _angleFromValue(widget.value);
        final startAngle = math.pi;
        final sweepAngle = math.pi;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onPanUpdate: widget.onChanged != null
                  ? (d) {
                      final box = _gaugeKey.currentContext?.findRenderObject() as RenderBox?;
                      if (box == null) return;
                      final gaugeTopLeft = box.localToGlobal(Offset.zero);
                      final local = Offset(
                        d.globalPosition.dx - gaugeTopLeft.dx,
                        d.globalPosition.dy - gaugeTopLeft.dy,
                      );
                      final angle = math.atan2(local.dy - center, local.dx - center);
                      final v = _valueFromAngle(angle);
                      if (v != widget.value) widget.onChanged!(v);
                    }
                  : null,
              child: SizedBox(
                key: _gaugeKey,
                width: size,
                height: size,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: Size(size, size),
                      painter: _GaugeTrackPainter(
                        center: center,
                        radius: radius,
                        trackStrokeWidth: _trackStrokeWidth,
                        handleRadius: _handleRadius,
                        startAngle: startAngle,
                        sweepAngle: sweepAngle,
                        valueAngle: valueAngle,
                        value: widget.value,
                        min: widget.min,
                        max: widget.max,
                      ),
                    ),
                    Center(
                      child: widget.centerContent ??
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${widget.value}',
                                style: const TextStyle(
                                  fontSize: 52,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              if (widget.showAvatars) ...[
                                const SizedBox(height: 12),
                                _buildAvatarStack(),
                              ],
                            ],
                          ),
                    ),
                    _GaugeHandle(
                      center: center,
                      radius: radius,
                      handleRadius: _handleRadius,
                      valueAngle: valueAngle,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: size,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Minimum (${widget.min})',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Maximum (${widget.max})',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAvatarStack() {
    final r = widget.avatarRadius;
    return SizedBox(
      width: r * 2.2,
      height: r * 2,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: r * 2,
              height: r * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface,
                border: Border.all(color: AppColors.background, width: 2),
              ),
              child: Icon(Icons.person, size: r, color: AppColors.textMuted),
            ),
          ),
          Positioned(
            left: r * 1.2,
            top: 0,
            child: Container(
              width: r * 2,
              height: r * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface,
                border: Border.all(color: AppColors.background, width: 2),
              ),
              child: Icon(Icons.person, size: r, color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}

class _GaugeHandle extends StatelessWidget {
  const _GaugeHandle({
    required this.center,
    required this.radius,
    required this.handleRadius,
    required this.valueAngle,
  });

  final double center;
  final double radius;
  final double handleRadius;
  final double valueAngle;

  @override
  Widget build(BuildContext context) {
    final dx = center + radius * math.cos(valueAngle);
    final dy = center + radius * math.sin(valueAngle);
    return Positioned(
      left: dx - handleRadius,
      top: dy - handleRadius,
      child: Container(
        width: handleRadius * 2,
        height: handleRadius * 2,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Container(
            width: handleRadius * 0.5,
            height: handleRadius * 0.5,
            decoration: const BoxDecoration(
              color: Color(0xFF2563EB),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

class _GaugeTrackPainter extends CustomPainter {
  _GaugeTrackPainter({
    required this.center,
    required this.radius,
    required this.trackStrokeWidth,
    required this.handleRadius,
    required this.startAngle,
    required this.sweepAngle,
    required this.valueAngle,
    required this.value,
    required this.min,
    required this.max,
  });

  final double center;
  final double radius;
  final double trackStrokeWidth;
  final double handleRadius;
  final double startAngle;
  final double sweepAngle;
  final double valueAngle;
  final int value;
  final int min;
  final int max;

  @override
  void paint(Canvas canvas, Size size) {
    final minSweep = (value - min) / (max - min).clamp(1, double.infinity) * sweepAngle;
    final maxSweep = sweepAngle - minSweep;

    final minPaint = Paint()
      ..color = AppColors.gaugeTrackMin
      ..style = PaintingStyle.stroke
      ..strokeWidth = trackStrokeWidth
      ..strokeCap = StrokeCap.round;

    final maxPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = trackStrokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.save();
    canvas.translate(center, center);

    if (minSweep > 0.02) {
      _drawDashedArc(canvas, radius, startAngle, minSweep, minPaint);
    }
    if (maxSweep > 0.02) {
      _drawDashedArc(canvas, radius, startAngle + minSweep, maxSweep, maxPaint);
    }

    canvas.restore();
  }

  void _drawDashedArc(Canvas canvas, double r, double start, double sweep, Paint p) {
    const dashLength = 4.0;
    const gapLength = 3.0;
    const step = dashLength + gapLength;
    final circumference = r * sweep;
    final dashCount = (circumference / step).floor();

    for (var i = 0; i < dashCount; i++) {
      final t0 = (i * step) / circumference;
      final t1 = ((i * step + dashLength) / circumference).clamp(0.0, 1.0);
      final a0 = start + t0 * sweep;
      final a1 = start + t1 * sweep;
      final path = Path()
        ..moveTo(r * math.cos(a0), r * math.sin(a0))
        ..arcToPoint(
          Offset(r * math.cos(a1), r * math.sin(a1)),
          radius: Radius.circular(r),
          clockwise: false,
        );
      canvas.drawPath(path, p);
    }
  }

  @override
  bool shouldRepaint(covariant _GaugeTrackPainter old) {
    return old.value != value ||
        old.center != center ||
        old.radius != radius ||
        old.valueAngle != valueAngle;
  }
}
