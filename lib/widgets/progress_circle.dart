import 'package:flutter/material.dart';
import 'dart:math' as math;

class ProgressCircle extends StatelessWidget {
  final double progress;
  final double size;
  final Color backgroundColor;
  final Color progressColor;
  final double strokeWidth;

  const ProgressCircle({
    Key? key,
    required this.progress,
    this.size = 192.0,
    this.backgroundColor = const Color(0xFFE5E7EB),
    this.progressColor = const Color(0xFF4F46E5),
    this.strokeWidth = 8.72727,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine status text based on progress
    String statusText = 'Analyzing';
    if (progress >= 1.0) {
      statusText = 'Complete';
    } else if (progress >= 0.75) {
      statusText = 'Almost done';
    }

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: ProgressCirclePainter(
              progress: progress,
              backgroundColor: backgroundColor,
              progressColor: progressColor,
              strokeWidth: strokeWidth,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: size * 0.1875, // 36px for size 192
                  fontWeight: FontWeight.w700,
                  color: progressColor,
                  height: 1.0,
                ),
                semanticsLabel: '${(progress * 100).toInt()} percent complete',
              ),
              SizedBox(height: size * 0.04167), // 8px for size 192
              Text(
                statusText,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: size * 0.07292, // 14px for size 192
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ProgressCirclePainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;
  final double strokeWidth;

  ProgressCirclePainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw background circle
    final backgroundPaint =
        Paint()
          ..color = backgroundColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw progress arc
    final progressPaint =
        Paint()
          ..color = progressColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius);
    const startAngle = -math.pi / 2; // Start from top
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(rect, startAngle, sweepAngle, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant ProgressCirclePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
