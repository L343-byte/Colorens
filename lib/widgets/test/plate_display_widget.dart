import 'package:flutter/material.dart';
import 'package:colorlens/models/ishihara_plate_model.dart';

/// Displays an Ishihara test plate with authentic image or dots.
class PlateDisplayWidget extends StatelessWidget {
  final List<DotData> dots;
  final String? imagePath;
  final double size;

  const PlateDisplayWidget({
    super.key,
    required this.dots,
    this.imagePath,
    this.size = 280,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: size,
        height: size,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipOval(
          child: imagePath != null
              ? Image.asset(
                  imagePath!,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (context, error, stackTrace) => CustomPaint(
                    size: Size(size, size),
                    painter: IshiharaPlatePainter(dots: dots),
                  ),
                )
              : CustomPaint(
                  size: Size(size, size),
                  painter: IshiharaPlatePainter(dots: dots),
                ),
        ),
      ),
    );
  }
}

/// Custom painter for rendering the Ishihara dots.
class IshiharaPlatePainter extends CustomPainter {
  final List<DotData> dots;

  IshiharaPlatePainter({required this.dots});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw background circle
    paint.color = Colors.grey.shade300;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      paint,
    );

    // Draw dots
    for (final dot in dots) {
      paint.color = dot.color;
      canvas.drawCircle(
        Offset(dot.x * size.width, dot.y * size.height),
        dot.radius * size.width,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant IshiharaPlatePainter oldDelegate) {
    return oldDelegate.dots != dots;
  }
}
