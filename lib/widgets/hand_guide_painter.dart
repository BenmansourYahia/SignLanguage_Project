import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

// Custom painter for hand positioning guide
class HandGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.warmAccent.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final fillPaint = Paint()
      ..color = AppColors.warmAccent.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    // Calculate center rectangle (60% of screen)
    final centerWidth = size.width * 0.6;
    final centerHeight = size.height * 0.5;
    final left = (size.width - centerWidth) / 2;
    final top = (size.height - centerHeight) / 2;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, centerWidth, centerHeight),
      const Radius.circular(20),
    );

    // Draw filled rectangle
    canvas.drawRRect(rect, fillPaint);
    
    // Draw border
    canvas.drawRRect(rect, paint);

    // Draw corner markers
    final cornerPaint = Paint()
      ..color = AppColors.warmAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final cornerLength = 30.0;

    // Top-left corner
    canvas.drawLine(
      Offset(left, top + cornerLength),
      Offset(left, top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left, top),
      Offset(left + cornerLength, top),
      cornerPaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(left + centerWidth - cornerLength, top),
      Offset(left + centerWidth, top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left + centerWidth, top),
      Offset(left + centerWidth, top + cornerLength),
      cornerPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(left, top + centerHeight - cornerLength),
      Offset(left, top + centerHeight),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left, top + centerHeight),
      Offset(left + cornerLength, top + centerHeight),
      cornerPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(left + centerWidth - cornerLength, top + centerHeight),
      Offset(left + centerWidth, top + centerHeight),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left + centerWidth, top + centerHeight - cornerLength),
      Offset(left + centerWidth, top + centerHeight),
      cornerPaint,
    );

    // Draw hand icon in center
    final textPainter = TextPainter(
      text: TextSpan(
        text: '✋',
        style: TextStyle(
          fontSize: 40,
          color: AppColors.warmAccent.withOpacity(0.6),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        size.width / 2 - textPainter.width / 2,
        size.height / 2 - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
