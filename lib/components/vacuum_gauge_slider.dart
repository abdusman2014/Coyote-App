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
//   Widget build(BuildContext context) {
//     return Container(
//       width: 300,
//       height: 300,
//       child: GestureDetector(
//         onPanUpdate: (details) {
//           _updateTargetFromTouch(details.localPosition);
//         },
//         onPanDown: (details) {
//           _updateTargetFromTouch(details.localPosition);
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

//   void _updateTargetFromTouch(Offset position) {
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
//         // Ensure target value cannot go below current value
//         _targetValue = newValue.clamp(widget.minValue, widget.maxValue);
//       });

//       widget.onChanged?.call(_targetValue);
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

//     // Arc parameters - rotated 90 degrees anticlockwise
//     // Original start: 225° (5π/4), after 90° anticlockwise rotation: 135° (3π/4)
//     final startAngle = 3 * math.pi / 4;
//     final sweepAngle = 3 * math.pi / 2;

//     // Calculate progress
//     final targetProgress = (targetValue - minValue) / (maxValue - minValue);
//     final currentProgress = (currentValue - minValue) / (maxValue - minValue);

//     // Draw the complete background arc (remaining gauge - #161F2E)
//     _drawSolidArc(
//       canvas,
//       center,
//       radius,
//       startAngle,
//       sweepAngle,
//       strokeWidth,
//       const Color(0xFF161F2E),
//     );

//     // Draw target value arc (#1974FE) FIRST
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

//     // Draw current value arc (actual vacuum - #FFF6BC) ON TOP with custom caps
//     if (currentProgress > 0) {
//       // Draw arc with butt cap (flat on both ends)
//       final rect = Rect.fromCircle(center: center, radius: radius);

//       final arcPaint = Paint()
//         ..color = const Color(0xFFFFF6BC)
//         ..style = PaintingStyle.stroke
//         ..strokeWidth = strokeWidth
//         ..strokeCap = StrokeCap.butt; // Flat ends

//       canvas.drawArc(
//         rect,
//         startAngle,
//         sweepAngle * currentProgress,
//         false,
//         arcPaint,
//       );

//       // Draw fully rounded start cap
//       _drawFullyRoundedStartCap(
//         canvas,
//         center,
//         radius,
//         startAngle,
//         strokeWidth,
//       );

//       // Draw custom rounded end cap with radius 5
//       _drawCustomEndCap(
//         canvas,
//         center,
//         radius,
//         startAngle + sweepAngle * currentProgress,
//         strokeWidth,
//       );
//     }

//     // Draw dashes BEFORE the black bar
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

//     // Draw black bar at the end of actual vacuum AFTER dashes (so it's on top)
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

//   void _drawGradientArc(
//     Canvas canvas,
//     Offset center,
//     double radius,
//     double startAngle,
//     double sweepAngle,
//     double strokeWidth,
//     List<Color> colors, {
//     bool isBackground = false,
//   }) {
//     final rect = Rect.fromCircle(center: center, radius: radius);

//     final gradient = ui.Gradient.sweep(
//       center,
//       colors,
//       null,
//       TileMode.clamp,
//       startAngle,
//       startAngle + sweepAngle,
//     );

//     final paint = Paint()
//       ..shader = gradient
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = strokeWidth
//       ..strokeCap = StrokeCap.round;

//     canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
//   }

//   void _drawSolidArc(
//     Canvas canvas,
//     Offset center,
//     double radius,
//     double startAngle,
//     double sweepAngle,
//     double strokeWidth,
//     Color color,
//   ) {
//     final rect = Rect.fromCircle(center: center, radius: radius);

//     final paint = Paint()
//       ..color = color
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = strokeWidth
//       ..strokeCap = StrokeCap.round;

//     canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
//   }

//   void _drawEndCap(
//     Canvas canvas,
//     Offset center,
//     double radius,
//     double angle,
//     double strokeWidth,
//   ) {
//     // Calculate position at the end of actual vacuum arc
//     final capX = center.dx + radius * math.cos(angle);
//     final capY = center.dy + radius * math.sin(angle);
//     final capPosition = Offset(capX, capY);

//     // Draw rounded bar with color #161F2E
//     final capPaint = Paint()
//       ..color = const Color(0xFF161F2E)
//       ..style = PaintingStyle.fill;

//     // The bar should be perpendicular to the arc direction
//     final barLength = 10.0; // Thickness perpendicular to arc
//     final barWidth = strokeWidth + 4; // Width along the arc stroke

//     // Create a rounded rectangle
//     final barRect = RRect.fromRectAndRadius(
//       Rect.fromCenter(center: capPosition, width: barWidth, height: barLength),
//       const Radius.circular(5),
//     );

//     // Rotate the canvas to align the bar along the arc stroke
//     canvas.save();
//     canvas.translate(capPosition.dx, capPosition.dy);
//     canvas.rotate(angle); // Align with the arc tangent
//     canvas.translate(-capPosition.dx, -capPosition.dy);

//     canvas.drawRRect(barRect, capPaint);

//     canvas.restore();
//   }

//   void _drawFullyRoundedStartCap(
//     Canvas canvas,
//     Offset center,
//     double radius,
//     double angle,
//     double strokeWidth,
//   ) {
//     // Calculate position at the start of actual vacuum arc
//     final capX = center.dx + radius * math.cos(angle);
//     final capY = center.dy + radius * math.sin(angle);
//     final capPosition = Offset(capX, capY);

//     // Draw fully rounded circle (semicircle effect)
//     final capPaint = Paint()
//       ..color = const Color(0xFFFFF6BC)
//       ..style = PaintingStyle.fill;

//     canvas.drawCircle(capPosition, strokeWidth / 2, capPaint);
//   }

//   void _drawCustomEndCap(
//     Canvas canvas,
//     Offset center,
//     double radius,
//     double angle,
//     double strokeWidth,
//   ) {
//     // Calculate position at the end of actual vacuum arc
//     final capX = center.dx + radius * math.cos(angle);
//     final capY = center.dy + radius * math.sin(angle);
//     final capPosition = Offset(capX, capY);

//     // Draw rounded end cap with radius 5
//     final capPaint = Paint()
//       ..color = const Color(0xFFFFF6BC)
//       ..style = PaintingStyle.fill;

//     final capWidth = 10.0;
//     final capHeight = strokeWidth;

//     final capRect = RRect.fromRectAndRadius(
//       Rect.fromCenter(center: capPosition, width: capWidth, height: capHeight),
//       const Radius.circular(5), // Change this value to adjust the corner radius
//     );

//     // Rotate to align with arc
//     canvas.save();
//     canvas.translate(capPosition.dx, capPosition.dy);
//     canvas.rotate(angle);
//     canvas.translate(-capPosition.dx, -capPosition.dy);

//     canvas.drawRRect(capRect, capPaint);

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
//         // Dark dashes for actual vacuum
//         dashColor = const Color(0xFF161F2E);
//       } else if (progress <= targetProgress) {
//         // Light blue dashes for target vacuum
//         dashColor = const Color(0xFF6BA4FF);
//       } else {
//         // Dark dashes for remaining
//         dashColor = const Color(0xFF2A3648);
//       }

//       final dashPaint = Paint()
//         ..color = dashColor
//         ..style = PaintingStyle.stroke
//         ..strokeWidth = dashThickness
//         ..strokeCap = StrokeCap.round;

//       // Calculate position on the arc centerline
//       final dotX = center.dx + radius * math.cos(angle);
//       final dotY = center.dy + radius * math.sin(angle);

//       // Draw dash perpendicular to the arc
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

//     // Handle shadow
//     final shadowPaint = Paint()
//       ..color = Colors.black.withOpacity(0.4)
//       ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
//     canvas.drawCircle(handlePosition + const Offset(0, 3), 24, shadowPaint);

//     // Outer ring (#1974FE)
//     final outerRingPaint = Paint()
//       ..color = const Color(0xFF1974FE)
//       ..style = PaintingStyle.fill;
//     canvas.drawCircle(handlePosition, 20, outerRingPaint);

//     // Middle ring (dark)
//     final middleRingPaint = Paint()
//       ..color = const Color(0xFF1F2937)
//       ..style = PaintingStyle.fill;
//     canvas.drawCircle(handlePosition, 20, middleRingPaint);

//     // Inner solid blue circle (#1974FE)
//     final innerCirclePaint = Paint()
//       ..color = const Color(0xFF1974FE)
//       ..style = PaintingStyle.fill;
//     canvas.drawCircle(handlePosition, 8, innerCirclePaint);
//   }

//   void _drawCenterText(Canvas canvas, Offset center) {
//     // Draw target value (large blue number)
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

//     // Draw "Target Vacuum" label
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

//     // Draw current value (white number)
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

//     // Draw "Actual Vacuum" label
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
//     // Calculate positions based on the rotated gauge
//     // Start angle: 135° (3π/4) - top left
//     // End angle: 45° (π/4) - top right

//     final startAngle = 3 * math.pi / 4; // 135° - where gauge starts
//     final actualEndAngle = math.pi / 4; // 45° - where gauge ends

//     // Draw "Minimum (0)" label below the start position
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

//     // Draw "Maximum (20)" label below the end position
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
import 'dart:ui' as ui;
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

class _VacuumGaugeSliderState extends State<VacuumGaugeSlider> {
  late double _targetValue;

  @override
  void initState() {
    super.initState();
    _targetValue = widget.targetValue;
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
        child: CustomPaint(
          painter: VacuumGaugePainter(
            minValue: widget.minValue,
            maxValue: widget.maxValue,
            currentValue: widget.currentValue,
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

    // Start at 135° (3π/4) after 90° anticlockwise rotation and go 270° clockwise
    final startAngle = 3 * math.pi / 4;
    final totalSweep = 3 * math.pi / 2;

    // Calculate angle relative to start
    double relativeAngle = angle - startAngle;
    if (relativeAngle < 0) relativeAngle += 2 * math.pi;

    // Only update if within the arc range
    if (relativeAngle <= totalSweep) {
      final progress = relativeAngle / totalSweep;
      final newValue =
          widget.minValue + (widget.maxValue - widget.minValue) * progress;

      setState(() {
        // Ensure target value cannot go below current value
        _targetValue = newValue.clamp(widget.minValue, widget.maxValue);
      });

      widget.onChanged?.call(_targetValue);
    }
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

    // Arc parameters - rotated 90 degrees anticlockwise
    // Original start: 225° (5π/4), after 90° anticlockwise rotation: 135° (3π/4)
    final startAngle = 3 * math.pi / 4;
    final sweepAngle = 3 * math.pi / 2;

    // Calculate progress
    final targetProgress = (targetValue - minValue) / (maxValue - minValue);
    final currentProgress = (currentValue - minValue) / (maxValue - minValue);

    // Draw the complete background arc (remaining gauge - #161F2E)
    _drawSolidArc(
      canvas,
      center,
      radius,
      startAngle,
      sweepAngle,
      strokeWidth,
      const Color(0xFF161F2E),
    );

    // Draw target value arc (#1974FE) FIRST
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

    // Draw current value arc (actual vacuum - #FFF6BC) ON TOP
    if (currentProgress > 0) {
      _drawSolidArc(
        canvas,
        center,
        radius,
        startAngle,
        sweepAngle * currentProgress,
        strokeWidth,
        const Color(0xFFFFF6BC),
      );
    }

    // Draw dashes BEFORE the black bar
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

    // Draw black bar at the end of actual vacuum AFTER dashes (so it's on top)
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

  void _drawGradientArc(
    Canvas canvas,
    Offset center,
    double radius,
    double startAngle,
    double sweepAngle,
    double strokeWidth,
    List<Color> colors, {
    bool isBackground = false,
  }) {
    final rect = Rect.fromCircle(center: center, radius: radius);

    final gradient = ui.Gradient.sweep(
      center,
      colors,
      null,
      TileMode.clamp,
      startAngle,
      startAngle + sweepAngle,
    );

    final paint = Paint()
      ..shader = gradient
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  void _drawSolidArc(
    Canvas canvas,
    Offset center,
    double radius,
    double startAngle,
    double sweepAngle,
    double strokeWidth,
    Color color,
  ) {
    final rect = Rect.fromCircle(center: center, radius: radius);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  void _drawEndCap(
    Canvas canvas,
    Offset center,
    double radius,
    double angle,
    double strokeWidth,
  ) {
    // Calculate position at the end of actual vacuum arc
    final capX = center.dx + radius * math.cos(angle);
    final capY = center.dy + radius * math.sin(angle);
    final capPosition = Offset(capX, capY);

    // Draw rounded bar with color #161F2E
    final capPaint = Paint()
      ..color = const Color(0xFF161F2E)
      ..style = PaintingStyle.fill;

    // The bar should be perpendicular to the arc direction
    final barLength = 10.0; // Thickness perpendicular to arc
    final barWidth = strokeWidth + 4; // Width along the arc stroke

    // Create a rounded rectangle
    final barRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: capPosition, width: barWidth, height: barLength),
      const Radius.circular(5),
    );

    // Rotate the canvas to align the bar along the arc stroke
    canvas.save();
    canvas.translate(capPosition.dx, capPosition.dy);
    canvas.rotate(angle); // Align with the arc tangent
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
        // Dark dashes for actual vacuum
        dashColor = const Color(0xFF161F2E);
      } else if (progress <= targetProgress) {
        // Light blue dashes for target vacuum
        dashColor = const Color(0xFF6BA4FF);
      } else {
        // Dark dashes for remaining
        dashColor = const Color(0xFF2A3648);
      }

      final dashPaint = Paint()
        ..color = dashColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = dashThickness
        ..strokeCap = StrokeCap.round;

      // Calculate position on the arc centerline
      final dotX = center.dx + radius * math.cos(angle);
      final dotY = center.dy + radius * math.sin(angle);

      // Draw dash perpendicular to the arc
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

    // Handle shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(handlePosition + const Offset(0, 3), 24, shadowPaint);

    // Outer ring (#1974FE)
    final outerRingPaint = Paint()
      ..color = const Color(0xFF1974FE)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(handlePosition, 20, outerRingPaint);

    // Middle ring (dark)
    final middleRingPaint = Paint()
      ..color = const Color(0xFF1F2937)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(handlePosition, 20, middleRingPaint);

    // Inner solid blue circle (#1974FE)
    final innerCirclePaint = Paint()
      ..color = const Color(0xFF1974FE)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(handlePosition, 8, innerCirclePaint);
  }

  void _drawCenterText(Canvas canvas, Offset center) {
    // Draw target value (large blue number)
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

    // Draw "Target Vacuum" label
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

    // Draw current value (white number)
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

    // Draw "Actual Vacuum" label
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
    // Calculate positions based on the rotated gauge
    // Start angle: 135° (3π/4) - top left
    // End angle: 45° (π/4) - top right

    final startAngle = 3 * math.pi / 4; // 135° - where gauge starts
    final actualEndAngle = math.pi / 4; // 45° - where gauge ends

    // Draw "Minimum (0)" label below the start position
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

    // Draw "Maximum (20)" label below the end position
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: VacuumGaugeSlider(
          minValue: 0,
          maxValue: 20,
          currentValue: 8.4,
          targetValue: targetValue,
          onChanged: (value) {
            setState(() {
              targetValue = value;
            });
          },
        ),
      ),
    );
  }
}
