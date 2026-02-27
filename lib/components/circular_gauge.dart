import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Circular gauge matching design: semi-circular track (7→5 o'clock),
/// beige left / blue right, dashed lines, purple outline, rounded-rect thumb
/// for target, small circle for actual. Center shows Target Vacuum & Actual Vacuum with avatars.
class CircularGauge extends StatefulWidget {
  const CircularGauge({
    super.key,
    required this.targetValue,
    required this.actualValue,
    required this.min,
    required this.max,
    this.onChanged,
    this.showAvatars = true,
    this.avatarRadius = 14,
    this.centerContent,
  });

  final int targetValue;
  final double actualValue;
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
  static const double _trackStrokeWidth = 14;
  static const double _thumbWidth = 20;
  static const double _thumbHeight = 28;
  static const double _actualIndicatorRadius = 8;
  final GlobalKey _gaugeKey = GlobalKey();

  // Arc: 7 o'clock to 5 o'clock (bottom semicircle)
  static const double _startAngle = 7 * math.pi / 6;
  static const double _sweepAngle = 2 * math.pi / 3;

  double _angleFromValue(double value) {
    final t = (value - widget.min) / (widget.max - widget.min).clamp(1, double.infinity);
    return _startAngle + t * _sweepAngle;
  }

  int _valueFromAngle(double angle) {
    double t = (angle - _startAngle) / _sweepAngle;
    t = t.clamp(0.0, 1.0);
    return (widget.min + t * (widget.max - widget.min)).round().clamp(widget.min, widget.max);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, constraints.maxHeight);
        final center = size / 2;
        final radius = center - _trackStrokeWidth - _thumbHeight / 2 - 12;

        final targetAngle = _angleFromValue(widget.targetValue.toDouble());
        final actualAngle = _angleFromValue(widget.actualValue);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onPanUpdate: widget.onChanged != null
                  ? (d) {
                      final box = _gaugeKey.currentContext?.findRenderObject() as RenderBox?;
                      if (box == null) return;
                      final topLeft = box.localToGlobal(Offset.zero);
                      final local = Offset(
                        d.globalPosition.dx - topLeft.dx,
                        d.globalPosition.dy - topLeft.dy,
                      );
                      final angle = math.atan2(local.dy - center, local.dx - center);
                      final v = _valueFromAngle(angle);
                      if (v != widget.targetValue) widget.onChanged!(v);
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
                        startAngle: _startAngle,
                        sweepAngle: _sweepAngle,
                        targetValue: widget.targetValue,
                        actualValue: widget.actualValue,
                        min: widget.min,
                        max: widget.max,
                      ),
                    ),
                    Center(
                      child: widget.centerContent ?? _buildDefaultCenterContent(),
                    ),
                    _TargetThumb(
                      center: center,
                      radius: radius,
                      angle: targetAngle,
                      width: _thumbWidth,
                      height: _thumbHeight,
                    ),
                    _ActualIndicator(
                      center: center,
                      radius: radius,
                      angle: actualAngle,
                      radiusPx: _actualIndicatorRadius,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: size,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Minimum (${widget.min})',
                    style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                  ),
                  Text(
                    'Maximum (${widget.max})',
                    style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDefaultCenterContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${widget.targetValue}',
          style: const TextStyle(
            fontSize: 44,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'Target Vacuum',
          style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
        ),
        if (widget.showAvatars) ...[
          const SizedBox(height: 6),
          _buildAvatarStack(),
        ],
        const SizedBox(height: 14),
        Text(
          widget.actualValue.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'Actual Vacuum',
          style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
        ),
        if (widget.showAvatars) ...[
          const SizedBox(height: 6),
          _buildAvatarStack(),
        ],
      ],
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
                border: Border.all(color: AppColors.background, width: 1.5),
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
                border: Border.all(color: AppColors.background, width: 1.5),
              ),
              child: Icon(Icons.person, size: r, color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}

class _TargetThumb extends StatelessWidget {
  const _TargetThumb({
    required this.center,
    required this.radius,
    required this.angle,
    required this.width,
    required this.height,
  });

  final double center;
  final double radius;
  final double angle;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final dx = center + radius * math.cos(angle);
    final dy = center + radius * math.sin(angle);
    return Positioned(
      left: dx - width / 2,
      top: dy - height / 2,
      child: Transform.rotate(
        angle: angle + math.pi / 2,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFF1A1A1A), width: 1),
          ),
        ),
      ),
    );
  }
}

class _ActualIndicator extends StatelessWidget {
  const _ActualIndicator({
    required this.center,
    required this.radius,
    required this.angle,
    required this.radiusPx,
  });

  final double center;
  final double radius;
  final double angle;
  final double radiusPx;

  @override
  Widget build(BuildContext context) {
    final dx = center + radius * math.cos(angle);
    final dy = center + radius * math.sin(angle);
    return Positioned(
      left: dx - radiusPx,
      top: dy - radiusPx,
      child: Container(
        width: radiusPx * 2,
        height: radiusPx * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary.withOpacity(0.9),
          border: Border.all(color: AppColors.accent, width: 2),
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
    required this.startAngle,
    required this.sweepAngle,
    required this.targetValue,
    required this.actualValue,
    required this.min,
    required this.max,
  });

  final double center;
  final double radius;
  final double trackStrokeWidth;
  final double startAngle;
  final double sweepAngle;
  final int targetValue;
  final double actualValue;
  final int min;
  final int max;

  @override
  void paint(Canvas canvas, Size size) {
    final range = (max - min).clamp(1, double.infinity);
    final minSweep = (targetValue - min) / range * sweepAngle;
    final maxSweep = sweepAngle - minSweep;

    canvas.save();
    canvas.translate(center, center);

    final rect = Rect.fromCircle(center: Offset.zero, radius: radius);

    // Purple outline
    final outline = Paint()
      ..color = const Color(0xFF4A3A5C).withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = trackStrokeWidth + 2
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, startAngle, sweepAngle, false, outline);

    // Beige segment (min → target)
    final beigePaint = Paint()
      ..color = AppColors.gaugeTrackMin
      ..style = PaintingStyle.stroke
      ..strokeWidth = trackStrokeWidth
      ..strokeCap = StrokeCap.round;
    if (minSweep > 0.02) {
      _drawDashedArc(canvas, radius, startAngle, minSweep, beigePaint);
    }

    // Blue segment (target → max)
    final bluePaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = trackStrokeWidth
      ..strokeCap = StrokeCap.round;
    if (maxSweep > 0.02) {
      _drawDashedArc(canvas, radius, startAngle + minSweep, maxSweep, bluePaint);
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
    return old.targetValue != targetValue ||
        old.actualValue != actualValue ||
        old.center != center ||
        old.radius != radius;
  }
}
