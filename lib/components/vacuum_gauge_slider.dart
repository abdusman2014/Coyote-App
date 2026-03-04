// import 'dart:math' as math;
// import 'dart:ui' as ui;
// import 'package:flutter/material.dart';

// class VacuumGaugeSlider extends StatefulWidget {
//   final double minValue;
//   final double maxValue;
//   final double currentValue;
//   final double targetValue;
//   final ValueChanged<double>? onChanged;

//   const VacuumGaugeSlider({
//     Key? key,
//     this.minValue = 0,
//     this.maxValue = 20,
//     this.currentValue = 8.4,
//     this.targetValue = 12,
//     this.onChanged,
//   }) : super(key: key);

//   @override
//   State<VacuumGaugeSlider> createState() => _VacuumGaugeSliderState();
// }

// class _VacuumGaugeSliderState extends State<VacuumGaugeSlider> {
//   late double _targetValue;

//   @override
//   void initState() {
//     super.initState();
//     _targetValue = widget.targetValue;
//   }

//   @override
//   void didUpdateWidget(VacuumGaugeSlider oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.targetValue != widget.targetValue) {
//       setState(() {
//         _targetValue = widget.targetValue;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 300,
//       height: 300,
//       child: GestureDetector(
//         onPanUpdate: (details) {
//           _updateTargetFromTouch(details.localPosition, notify: false);
//         },
//         onPanDown: (details) {
//           _updateTargetFromTouch(details.localPosition, notify: false);
//         },
//         onPanEnd: (details) {
//           widget.onChanged?.call(_targetValue);
//         },
//         child: CustomPaint(
//           painter: VacuumGaugePainter(
//             minValue: widget.minValue,
//             maxValue: widget.maxValue,
//             currentValue: widget.currentValue,
//             targetValue: _targetValue,
//           ),
//         ),
//       ),
//     );
//   }

//   void _updateTargetFromTouch(Offset position, {bool notify = true}) {
//     final center = Offset(150, 150);
//     final dx = position.dx - center.dx;
//     final dy = position.dy - center.dy;

//     double angle = math.atan2(dy, dx);

//     // Normalize to 0-2π
//     if (angle < 0) angle += 2 * math.pi;

//     // Start at 135° (3π/4) after 90° anticlockwise rotation and go 270° clockwise
//     final startAngle = 3 * math.pi / 4;
//     final totalSweep = 3 * math.pi / 2;

//     // Calculate angle relative to start
//     double relativeAngle = angle - startAngle;
//     if (relativeAngle < 0) relativeAngle += 2 * math.pi;

//     // Only update if within the arc range
//     if (relativeAngle <= totalSweep) {
//       final progress = relativeAngle / totalSweep;
//       final newValue =
//           widget.minValue + (widget.maxValue - widget.minValue) * progress;

//       setState(() {
//         _targetValue = newValue.clamp(widget.minValue, widget.maxValue);
//       });

//       if (notify) widget.onChanged?.call(_targetValue);
//     }
//   }
// }

// class VacuumGaugePainter extends CustomPainter {
//   final double minValue;
//   final double maxValue;
//   final double currentValue;
//   final double targetValue;

//   VacuumGaugePainter({
//     required this.minValue,
//     required this.maxValue,
//     required this.currentValue,
//     required this.targetValue,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     final center = Offset(size.width / 2, size.height / 2);
//     final radius = size.width / 2 - 40;
//     final strokeWidth = 45.0;

//     final startAngle = 3 * math.pi / 4;
//     final sweepAngle = 3 * math.pi / 2;

//     // Calculate progress
//     final targetProgress = (targetValue - minValue) / (maxValue - minValue);
//     final currentProgress = (currentValue - minValue) / (maxValue - minValue);

//     // Draw the complete background arc
//     _drawSolidArc(
//       canvas,
//       center,
//       radius,
//       startAngle,
//       sweepAngle,
//       strokeWidth,
//       const Color(0xFF161F2E),
//     );

//     // Draw target value arc (#1974FE)
//     if (targetProgress > 0) {
//       _drawSolidArc(
//         canvas,
//         center,
//         radius,
//         startAngle,
//         sweepAngle * targetProgress,
//         strokeWidth,
//         const Color(0xFF1974FE),
//       );
//     }

//     // Draw current value arc (yellow) with butt cap so the right end is flat
//     if (currentProgress > 0) {
//       _drawSolidArc(
//         canvas,
//         center,
//         radius,
//         startAngle,
//         sweepAngle * currentProgress,
//         strokeWidth,
//         const Color(0xFFFFF6BC),
//         strokeCap: StrokeCap.butt,
//       );

//       // Restore round cap on the START side only (left/min end of yellow arc)
//       final capX = center.dx + radius * math.cos(startAngle);
//       final capY = center.dy + radius * math.sin(startAngle);
//       canvas.drawCircle(
//         Offset(capX, capY),
//         strokeWidth / 2,
//         Paint()..color = const Color(0xFFFFF6BC),
//       );

//       // Draw slightly rounded end cap aligned with arc tangent
//       final endAngle = startAngle + sweepAngle * currentProgress;
//       final endX = center.dx + radius * math.cos(endAngle);
//       final endY = center.dy + radius * math.sin(endAngle);

//       final endCapPaint = Paint()
//         ..color = const Color(0xFFFFF6BC)
//         ..style = PaintingStyle.fill;

//       const cornerRadius = 6.0; // ← adjust this to control rounding amount

//       canvas.save();
//       canvas.translate(endX, endY);
//       canvas.rotate(endAngle); // align with arc tangent direction
//       canvas.drawRRect(
//         RRect.fromRectAndRadius(
//           Rect.fromCenter(
//             center: Offset.zero,
//             width: strokeWidth, // matches arc thickness
//             height: 14.0, // slight overhang to cover the butt edge
//           ),
//           const Radius.circular(cornerRadius),
//         ),
//         endCapPaint,
//       );
//       canvas.restore();
//     }

//     // Draw dashes
//     _drawDots(
//       canvas,
//       center,
//       radius,
//       startAngle,
//       sweepAngle,
//       strokeWidth,
//       targetProgress,
//       currentProgress,
//     );

//     // Draw black bar at the end of actual vacuum
//     if (currentProgress > 0) {
//       _drawEndCap(
//         canvas,
//         center,
//         radius,
//         startAngle + sweepAngle * currentProgress,
//         strokeWidth - 6,
//       );
//     }

//     // Draw the handle
//     _drawHandle(
//       canvas,
//       center,
//       radius,
//       startAngle + sweepAngle * targetProgress,
//     );

//     // Draw center text
//     _drawCenterText(canvas, center);

//     // Draw labels
//     _drawLabels(canvas, center, radius + strokeWidth / 2);
//   }

//   void _drawSolidArc(
//     Canvas canvas,
//     Offset center,
//     double radius,
//     double startAngle,
//     double sweepAngle,
//     double strokeWidth,
//     Color color, {
//     StrokeCap strokeCap = StrokeCap.round,
//   }) {
//     final rect = Rect.fromCircle(center: center, radius: radius);

//     final paint = Paint()
//       ..color = color
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = strokeWidth
//       ..strokeCap = strokeCap;

//     canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
//   }

//   void _drawEndCap(
//     Canvas canvas,
//     Offset center,
//     double radius,
//     double angle,
//     double strokeWidth,
//   ) {
//     final capX = center.dx + radius * math.cos(angle);
//     final capY = center.dy + radius * math.sin(angle);
//     final capPosition = Offset(capX, capY);

//     final capPaint = Paint()
//       ..color = const Color(0xFF161F2E)
//       ..style = PaintingStyle.fill;

//     final barLength = 10.0;
//     final barWidth = strokeWidth + 4;

//     final barRect = RRect.fromRectAndRadius(
//       Rect.fromCenter(center: capPosition, width: barWidth, height: barLength),
//       const Radius.circular(5),
//     );

//     canvas.save();
//     canvas.translate(capPosition.dx, capPosition.dy);
//     canvas.rotate(angle);
//     canvas.translate(-capPosition.dx, -capPosition.dy);

//     canvas.drawRRect(barRect, capPaint);

//     canvas.restore();
//   }

//   void _drawDots(
//     Canvas canvas,
//     Offset center,
//     double radius,
//     double startAngle,
//     double sweepAngle,
//     double strokeWidth,
//     double targetProgress,
//     double currentProgress,
//   ) {
//     final dotCount = 40;
//     final dashLength = 6.0;
//     final dashThickness = 3.5;

//     for (int i = 0; i <= dotCount; i++) {
//       final progress = i / dotCount;
//       final angle = startAngle + sweepAngle * progress;

//       Color dashColor;
//       if (progress <= currentProgress) {
//         dashColor = const Color(0xFF161F2E);
//       } else if (progress <= targetProgress) {
//         dashColor = const Color(0xFF6BA4FF);
//       } else {
//         dashColor = const Color(0xFF2A3648);
//       }

//       final dashPaint = Paint()
//         ..color = dashColor
//         ..style = PaintingStyle.stroke
//         ..strokeWidth = dashThickness
//         ..strokeCap = StrokeCap.round;

//       final dotX = center.dx + radius * math.cos(angle);
//       final dotY = center.dy + radius * math.sin(angle);

//       final perpAngle = angle + math.pi / 2;

//       final startX = dotX + (dashLength / 2) * math.cos(perpAngle);
//       final startY = dotY + (dashLength / 2) * math.sin(perpAngle);
//       final endX = dotX - (dashLength / 2) * math.cos(perpAngle);
//       final endY = dotY - (dashLength / 2) * math.sin(perpAngle);

//       canvas.drawLine(Offset(startX, startY), Offset(endX, endY), dashPaint);
//     }
//   }

//   void _drawHandle(Canvas canvas, Offset center, double radius, double angle) {
//     final handleX = center.dx + radius * math.cos(angle);
//     final handleY = center.dy + radius * math.sin(angle);
//     final handlePosition = Offset(handleX, handleY);

//     final shadowPaint = Paint()
//       ..color = Colors.black.withOpacity(0.4)
//       ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
//     canvas.drawCircle(handlePosition + const Offset(0, 3), 24, shadowPaint);

//     final middleRingPaint = Paint()
//       ..color = const Color(0xFF1F2937)
//       ..style = PaintingStyle.fill;
//     canvas.drawCircle(handlePosition, 20, middleRingPaint);

//     final innerCirclePaint = Paint()
//       ..color = const Color(0xFF1974FE)
//       ..style = PaintingStyle.fill;
//     canvas.drawCircle(handlePosition, 8, innerCirclePaint);
//   }

//   void _drawCenterText(Canvas canvas, Offset center) {
//     final targetTextPainter = TextPainter(
//       text: TextSpan(
//         text: targetValue.toStringAsFixed(0),
//         style: const TextStyle(
//           color: Color(0xFF1974FE),
//           fontSize: 60,
//           fontWeight: FontWeight.w500,
//           height: 1,
//         ),
//       ),
//       textDirection: TextDirection.ltr,
//     );
//     targetTextPainter.layout();
//     targetTextPainter.paint(
//       canvas,
//       Offset(center.dx - targetTextPainter.width / 2, center.dy - 65),
//     );

//     final targetLabelPainter = TextPainter(
//       text: const TextSpan(
//         text: 'Target Vacuum',
//         style: TextStyle(
//           color: Color(0xFF9E9E9E),
//           fontSize: 10,
//           fontWeight: FontWeight.w400,
//         ),
//       ),
//       textDirection: TextDirection.ltr,
//     );
//     targetLabelPainter.layout();
//     targetLabelPainter.paint(
//       canvas,
//       Offset(center.dx - targetLabelPainter.width / 2, center.dy - 10),
//     );

//     final currentTextPainter = TextPainter(
//       text: TextSpan(
//         text: currentValue.toStringAsFixed(1),
//         style: const TextStyle(
//           color: Colors.white,
//           fontSize: 36,
//           fontWeight: FontWeight.w500,
//           height: 1,
//         ),
//       ),
//       textDirection: TextDirection.ltr,
//     );
//     currentTextPainter.layout();
//     currentTextPainter.paint(
//       canvas,
//       Offset(center.dx - currentTextPainter.width / 2, center.dy + 15),
//     );

//     final currentLabelPainter = TextPainter(
//       text: const TextSpan(
//         text: 'Actual Vacuum',
//         style: TextStyle(
//           color: Color(0xFF9E9E9E),
//           fontSize: 10,
//           fontWeight: FontWeight.w400,
//         ),
//       ),
//       textDirection: TextDirection.ltr,
//     );
//     currentLabelPainter.layout();
//     currentLabelPainter.paint(
//       canvas,
//       Offset(center.dx - currentLabelPainter.width / 2, center.dy + 58),
//     );
//   }

//   void _drawLabels(Canvas canvas, Offset center, double outerRadius) {
//     final startAngle = 3 * math.pi / 4;
//     final actualEndAngle = math.pi / 4;

//     final minLabelPainter = TextPainter(
//       text: TextSpan(
//         text: 'Minimum (${minValue.toInt()})',
//         style: const TextStyle(
//           color: Color(0xFF757575),
//           fontSize: 11,
//           fontWeight: FontWeight.w400,
//         ),
//       ),
//       textDirection: TextDirection.ltr,
//     );
//     minLabelPainter.layout();

//     final minX = center.dx + outerRadius * math.cos(startAngle);
//     final minY = center.dy + outerRadius * math.sin(startAngle) + 10;

//     minLabelPainter.paint(
//       canvas,
//       Offset(minX - minLabelPainter.width / 2, minY + 10),
//     );

//     final maxLabelPainter = TextPainter(
//       text: TextSpan(
//         text: 'Maximum (${maxValue.toInt()})',
//         style: const TextStyle(
//           color: Color(0xFF757575),
//           fontSize: 11,
//           fontWeight: FontWeight.w400,
//         ),
//       ),
//       textDirection: TextDirection.ltr,
//     );
//     maxLabelPainter.layout();

//     final maxX = center.dx + outerRadius * math.cos(actualEndAngle);
//     final maxY = center.dy + outerRadius * math.sin(actualEndAngle) + 10;

//     maxLabelPainter.paint(
//       canvas,
//       Offset(maxX - maxLabelPainter.width / 2, maxY + 10),
//     );
//   }

//   @override
//   bool shouldRepaint(covariant VacuumGaugePainter oldDelegate) {
//     return oldDelegate.currentValue != currentValue ||
//         oldDelegate.targetValue != targetValue;
//   }
// }

// // Example usage widget
// class VacuumGaugeDemo extends StatefulWidget {
//   const VacuumGaugeDemo({Key? key}) : super(key: key);

//   @override
//   State<VacuumGaugeDemo> createState() => _VacuumGaugeDemoState();
// }

// class _VacuumGaugeDemoState extends State<VacuumGaugeDemo> {
//   double targetValue = 12.0;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Center(
//         child: VacuumGaugeSlider(
//           minValue: 0,
//           maxValue: 20,
//           currentValue: 8.4,
//           targetValue: targetValue,
//           onChanged: (value) {
//             setState(() {
//               targetValue = value;
//             });
//           },
//         ),
//       ),
//     );
//   }
// }


import 'dart:math' as math;
import 'package:flutter/material.dart';

class VacuumGaugeSlider extends StatefulWidget {
  final double minValue;
  final double maxValue;
  final double currentValue;
  final double targetValue;
  final ValueChanged<double>? onChanged;

  const VacuumGaugeSlider({
    Key? key,
    this.minValue = 0,
    this.maxValue = 20,
    this.currentValue = 8.4,
    this.targetValue = 12,
    this.onChanged,
  }) : super(key: key);

  @override
  State<VacuumGaugeSlider> createState() => _VacuumGaugeSliderState();
}

class _VacuumGaugeSliderState extends State<VacuumGaugeSlider>
    with SingleTickerProviderStateMixin {
  late double _targetValue;
  late AnimationController _animationController;
  late Animation<double> _currentValueAnimation;
  late double _animatedCurrentValue;

  @override
  void initState() {
    super.initState();
    _targetValue = widget.targetValue;
    _animatedCurrentValue = widget.currentValue;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _currentValueAnimation = Tween<double>(
      begin: widget.currentValue,
      end: widget.currentValue,
    ).animate(_animationController);

    _animationController.addListener(() {
      setState(() {
        _animatedCurrentValue = _currentValueAnimation.value;
      });
    });
  }

  @override
  void didUpdateWidget(VacuumGaugeSlider oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.targetValue != widget.targetValue) {
      setState(() {
        _targetValue = widget.targetValue;
      });
    }

    // Animate yellow arc when currentValue changes
    if (oldWidget.currentValue != widget.currentValue) {
      _currentValueAnimation = Tween<double>(
        begin: _animatedCurrentValue,
        end: widget.currentValue,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ));

      _animationController.forward(from: 0).then((_) {
        setState(() {
          _animatedCurrentValue = widget.currentValue;
        });
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 300,
      child: GestureDetector(
        onPanUpdate: (details) {
          _updateTargetFromTouch(details.localPosition);
        },
        onPanDown: (details) {
          _updateTargetFromTouch(details.localPosition);
        },
        onPanEnd: (details) {
          widget.onChanged?.call(_targetValue);
        },
        child: CustomPaint(
          painter: VacuumGaugePainter(
            minValue: widget.minValue,
            maxValue: widget.maxValue,
            currentValue: _animatedCurrentValue, // uses animated value
            targetValue: _targetValue,
          ),
        ),
      ),
    );
  }

  void _updateTargetFromTouch(Offset position) {
    final center = Offset(150, 150);
    final dx = position.dx - center.dx;
    final dy = position.dy - center.dy;

    double angle = math.atan2(dy, dx);

    // Normalize to 0-2π
    if (angle < 0) angle += 2 * math.pi;

    final startAngle = 3 * math.pi / 4;
    final totalSweep = 3 * math.pi / 2;

    double relativeAngle = angle - startAngle;
    if (relativeAngle < 0) relativeAngle += 2 * math.pi;

    // Clamp to arc range for smooth edges
    final clampedAngle = relativeAngle.clamp(0.0, totalSweep);
    final progress = clampedAngle / totalSweep;
    final newValue =
        widget.minValue + (widget.maxValue - widget.minValue) * progress;

    setState(() {
      _targetValue = newValue;
    });

    widget.onChanged?.call(_targetValue);
  }
}

class VacuumGaugePainter extends CustomPainter {
  final double minValue;
  final double maxValue;
  final double currentValue;
  final double targetValue;

  VacuumGaugePainter({
    required this.minValue,
    required this.maxValue,
    required this.currentValue,
    required this.targetValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 40;
    final strokeWidth = 45.0;

    final startAngle = 3 * math.pi / 4;
    final sweepAngle = 3 * math.pi / 2;

    // Calculate progress
    final targetProgress = (targetValue - minValue) / (maxValue - minValue);
    final currentProgress = (currentValue - minValue) / (maxValue - minValue);

    // Draw the complete background arc
    _drawSolidArc(
      canvas,
      center,
      radius,
      startAngle,
      sweepAngle,
      strokeWidth,
      const Color(0xFF161F2E),
    );

    // Draw target value arc (#1974FE)
    if (targetProgress > 0) {
      _drawSolidArc(
        canvas,
        center,
        radius,
        startAngle,
        sweepAngle * targetProgress,
        strokeWidth,
        const Color(0xFF1974FE),
      );
    }

    // Draw current value arc (yellow) with butt cap so the right end is flat
    if (currentProgress > 0) {
      _drawSolidArc(
        canvas,
        center,
        radius,
        startAngle,
        sweepAngle * currentProgress,
        strokeWidth,
        const Color(0xFFFFF6BC),
        strokeCap: StrokeCap.butt,
      );

      // Restore round cap on the START side only (left/min end of yellow arc)
      final capX = center.dx + radius * math.cos(startAngle);
      final capY = center.dy + radius * math.sin(startAngle);
      canvas.drawCircle(
        Offset(capX, capY),
        strokeWidth / 2,
        Paint()..color = const Color(0xFFFFF6BC),
      );

      // Draw slightly rounded end cap aligned with arc tangent
      final endAngle = startAngle + sweepAngle * currentProgress;
      final endX = center.dx + radius * math.cos(endAngle);
      final endY = center.dy + radius * math.sin(endAngle);

      final endCapPaint = Paint()
        ..color = const Color(0xFFFFF6BC)
        ..style = PaintingStyle.fill;

      const cornerRadius = 6.0;

      canvas.save();
      canvas.translate(endX, endY);
      canvas.rotate(endAngle);
      canvas.translate(-endX, -endY);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(endX, endY),
            width: strokeWidth,
            height: 14.0,
          ),
          const Radius.circular(cornerRadius),
        ),
        endCapPaint,
      );
      canvas.restore();
    }

    // Draw dashes
    _drawDots(
      canvas,
      center,
      radius,
      startAngle,
      sweepAngle,
      strokeWidth,
      targetProgress,
      currentProgress,
    );

    // Draw black bar at the end of actual vacuum
    if (currentProgress > 0) {
      _drawEndCap(
        canvas,
        center,
        radius,
        startAngle + sweepAngle * currentProgress,
        strokeWidth - 6,
      );
    }

    // Draw the handle
    _drawHandle(
      canvas,
      center,
      radius,
      startAngle + sweepAngle * targetProgress,
    );

    // Draw center text
    _drawCenterText(canvas, center);

    // Draw labels
    _drawLabels(canvas, center, radius + strokeWidth / 2);
  }

  void _drawSolidArc(
    Canvas canvas,
    Offset center,
    double radius,
    double startAngle,
    double sweepAngle,
    double strokeWidth,
    Color color, {
    StrokeCap strokeCap = StrokeCap.round,
  }) {
    final rect = Rect.fromCircle(center: center, radius: radius);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = strokeCap;

    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  void _drawEndCap(
    Canvas canvas,
    Offset center,
    double radius,
    double angle,
    double strokeWidth,
  ) {
    final capX = center.dx + radius * math.cos(angle);
    final capY = center.dy + radius * math.sin(angle);
    final capPosition = Offset(capX, capY);

    final capPaint = Paint()
      ..color = const Color(0xFF161F2E)
      ..style = PaintingStyle.fill;

    final barLength = 10.0;
    final barWidth = strokeWidth + 4;

    final barRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: capPosition, width: barWidth, height: barLength),
      const Radius.circular(5),
    );

    canvas.save();
    canvas.translate(capPosition.dx, capPosition.dy);
    canvas.rotate(angle);
    canvas.translate(-capPosition.dx, -capPosition.dy);
    canvas.drawRRect(barRect, capPaint);
    canvas.restore();
  }

  void _drawDots(
    Canvas canvas,
    Offset center,
    double radius,
    double startAngle,
    double sweepAngle,
    double strokeWidth,
    double targetProgress,
    double currentProgress,
  ) {
    final dotCount = 40;
    final dashLength = 6.0;
    final dashThickness = 3.5;

    for (int i = 0; i <= dotCount; i++) {
      final progress = i / dotCount;
      final angle = startAngle + sweepAngle * progress;

      Color dashColor;
      if (progress <= currentProgress) {
        dashColor = const Color(0xFF161F2E);
      } else if (progress <= targetProgress) {
        dashColor = const Color(0xFF6BA4FF);
      } else {
        dashColor = const Color(0xFF2A3648);
      }

      final dashPaint = Paint()
        ..color = dashColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = dashThickness
        ..strokeCap = StrokeCap.round;

      final dotX = center.dx + radius * math.cos(angle);
      final dotY = center.dy + radius * math.sin(angle);

      final perpAngle = angle + math.pi / 2;

      final startX = dotX + (dashLength / 2) * math.cos(perpAngle);
      final startY = dotY + (dashLength / 2) * math.sin(perpAngle);
      final endX = dotX - (dashLength / 2) * math.cos(perpAngle);
      final endY = dotY - (dashLength / 2) * math.sin(perpAngle);

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), dashPaint);
    }
  }

  void _drawHandle(Canvas canvas, Offset center, double radius, double angle) {
    final handleX = center.dx + radius * math.cos(angle);
    final handleY = center.dy + radius * math.sin(angle);
    final handlePosition = Offset(handleX, handleY);

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(handlePosition + const Offset(0, 3), 24, shadowPaint);

    final middleRingPaint = Paint()
      ..color = const Color(0xFF1F2937)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(handlePosition, 20, middleRingPaint);

    final innerCirclePaint = Paint()
      ..color = const Color(0xFF1974FE)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(handlePosition, 8, innerCirclePaint);
  }

  void _drawCenterText(Canvas canvas, Offset center) {
    final targetTextPainter = TextPainter(
      text: TextSpan(
        text: targetValue.toStringAsFixed(0),
        style: const TextStyle(
          color: Color(0xFF1974FE),
          fontSize: 60,
          fontWeight: FontWeight.w500,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    targetTextPainter.layout();
    targetTextPainter.paint(
      canvas,
      Offset(center.dx - targetTextPainter.width / 2, center.dy - 65),
    );

    final targetLabelPainter = TextPainter(
      text: const TextSpan(
        text: 'Target Vacuum',
        style: TextStyle(
          color: Color(0xFF9E9E9E),
          fontSize: 10,
          fontWeight: FontWeight.w400,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    targetLabelPainter.layout();
    targetLabelPainter.paint(
      canvas,
      Offset(center.dx - targetLabelPainter.width / 2, center.dy - 10),
    );

    final currentTextPainter = TextPainter(
      text: TextSpan(
        text: currentValue.toStringAsFixed(1),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 36,
          fontWeight: FontWeight.w500,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    currentTextPainter.layout();
    currentTextPainter.paint(
      canvas,
      Offset(center.dx - currentTextPainter.width / 2, center.dy + 15),
    );

    final currentLabelPainter = TextPainter(
      text: const TextSpan(
        text: 'Actual Vacuum',
        style: TextStyle(
          color: Color(0xFF9E9E9E),
          fontSize: 10,
          fontWeight: FontWeight.w400,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    currentLabelPainter.layout();
    currentLabelPainter.paint(
      canvas,
      Offset(center.dx - currentLabelPainter.width / 2, center.dy + 58),
    );
  }

  void _drawLabels(Canvas canvas, Offset center, double outerRadius) {
    final startAngle = 3 * math.pi / 4;
    final actualEndAngle = math.pi / 4;

    final minLabelPainter = TextPainter(
      text: TextSpan(
        text: 'Minimum (${minValue.toInt()})',
        style: const TextStyle(
          color: Color(0xFF757575),
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    minLabelPainter.layout();

    final minX = center.dx + outerRadius * math.cos(startAngle);
    final minY = center.dy + outerRadius * math.sin(startAngle) + 10;

    minLabelPainter.paint(
      canvas,
      Offset(minX - minLabelPainter.width / 2, minY + 10),
    );

    final maxLabelPainter = TextPainter(
      text: TextSpan(
        text: 'Maximum (${maxValue.toInt()})',
        style: const TextStyle(
          color: Color(0xFF757575),
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    maxLabelPainter.layout();

    final maxX = center.dx + outerRadius * math.cos(actualEndAngle);
    final maxY = center.dy + outerRadius * math.sin(actualEndAngle) + 10;

    maxLabelPainter.paint(
      canvas,
      Offset(maxX - maxLabelPainter.width / 2, maxY + 10),
    );
  }

  @override
  bool shouldRepaint(covariant VacuumGaugePainter oldDelegate) {
    return oldDelegate.currentValue != currentValue ||
        oldDelegate.targetValue != targetValue;
  }
}

// Example usage widget
class VacuumGaugeDemo extends StatefulWidget {
  const VacuumGaugeDemo({Key? key}) : super(key: key);

  @override
  State<VacuumGaugeDemo> createState() => _VacuumGaugeDemoState();
}

class _VacuumGaugeDemoState extends State<VacuumGaugeDemo> {
  double targetValue = 12.0;
  double currentValue = 8.4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            VacuumGaugeSlider(
              minValue: 0,
              maxValue: 20,
              currentValue: currentValue,
              targetValue: targetValue,
              onChanged: (value) {
                setState(() {
                  targetValue = value;
                });
              },
            ),
            const SizedBox(height: 24),
            // Demo buttons to test smooth animation
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      currentValue = (currentValue - 1).clamp(0.0, 20.0);
                    });
                  },
                  child: const Text('- 1'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      currentValue = (currentValue + 1).clamp(0.0, 20.0);
                    });
                  },
                  child: const Text('+ 1'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}