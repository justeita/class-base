import 'package:flutter/material.dart';

class GridPainter extends CustomPainter {
  const GridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF222222)
      ..strokeWidth = 1;

    const double spacing = 40;

    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CutePainter extends CustomPainter {
  const CutePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Helper to draw a bubble
    void drawBubble(double x, double y, double radius, Color color) {
      // Main body
      paint.color = color.withValues(alpha: 0.15);
      canvas.drawCircle(Offset(x, y), radius, paint);
      
      // Highlight (reflection)
      final highlightPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.4)
        ..style = PaintingStyle.fill;
      canvas.drawOval(
        Rect.fromLTWH(x - radius * 0.5, y - radius * 0.6, radius * 0.3, radius * 0.2), 
        highlightPaint
      );
      
      // Border
      final borderPaint = Paint()
        ..color = color.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(Offset(x, y), radius, borderPaint);
    }

    // Helper to draw a sparkle (diamond shape)
    void drawSparkle(double x, double y, double scale, Color color) {
      final path = Path();
      path.moveTo(x, y - 10 * scale); // Top
      path.quadraticBezierTo(x + 2 * scale, y - 2 * scale, x + 10 * scale, y); // Right
      path.quadraticBezierTo(x + 2 * scale, y + 2 * scale, x, y + 10 * scale); // Bottom
      path.quadraticBezierTo(x - 2 * scale, y + 2 * scale, x - 10 * scale, y); // Left
      path.close();
      paint.color = color;
      canvas.drawPath(path, paint);
    }

    // Bubbles
    drawBubble(size.width * 0.1, size.height * 0.1, 60, const Color(0xFFFF9AA2));
    drawBubble(size.width * 0.9, size.height * 0.25, 80, const Color(0xFFC7CEEA));
    drawBubble(size.width * 0.5, size.height * 0.5, 100, const Color(0xFFFFDAC1));
    drawBubble(size.width * 0.2, size.height * 0.8, 50, const Color(0xFFE2F0CB));
    drawBubble(size.width * 0.8, size.height * 0.9, 70, const Color(0xFFFFB7B2));

    // Sparkles
    drawSparkle(size.width * 0.3, size.height * 0.2, 1.5, const Color(0xFFE2F0CB).withValues(alpha: 0.5));
    drawSparkle(size.width * 0.7, size.height * 0.6, 2.0, const Color(0xFFC7CEEA).withValues(alpha: 0.5));
    drawSparkle(size.width * 0.1, size.height * 0.7, 1.0, const Color(0xFFFFDAC1).withValues(alpha: 0.5));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ManlyPainter extends CustomPainter {
  const ManlyPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF334155).withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = const Color(0xFF1E293B).withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw a few large decorative hexagons
    void drawHexagon(double x, double y, double radius) {
      final path = Path();
      
      path.moveTo(x + radius * 0.866, y + radius * 0.5);
      path.lineTo(x, y + radius);
      path.lineTo(x - radius * 0.866, y + radius * 0.5);
      path.lineTo(x - radius * 0.866, y - radius * 0.5);
      path.lineTo(x, y - radius);
      path.lineTo(x + radius * 0.866, y - radius * 0.5);
      path.close();
      
      canvas.drawPath(path, paint);
      canvas.drawPath(path, strokePaint);
    }

    drawHexagon(size.width * 0.1, size.height * 0.2, 80);
    drawHexagon(size.width * 0.9, size.height * 0.5, 120);
    drawHexagon(size.width * 0.5, size.height * 0.8, 100);
    drawHexagon(size.width * 0.2, size.height * 0.9, 60);
    drawHexagon(size.width * 0.8, size.height * 0.1, 50);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AppTheme {
  final Color primary;
  final Color secondary;
  final Color tertiary;
  final Color background;
  final Color surface;
  final Color onSurface;
  final String fontFamily;
  final CustomPainter? backgroundPainter;
  final bool isBrutalist;
  final bool isManly;
  final bool isCute;

  AppTheme({
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.background,
    required this.surface,
    required this.onSurface,
    required this.fontFamily,
    this.backgroundPainter,
    this.isBrutalist = false,
    this.isManly = false,
    this.isCute = false,
  });

  static AppTheme getTheme(String role, {String? gender}) {
    switch (role) {
      case 'secretary':
        return AppTheme(
          primary: const Color(0xFFD4AF37), // Gold
          secondary: const Color(0xFF000080), // Navy
          tertiary: const Color(0xFF8B0000), // Dark Red
          background: const Color(0xFFF9F9F0), // Soft Beige
          surface: const Color(0xFFFFFFFF),
          onSurface: const Color(0xFF1A1A1A),
          fontFamily: 'Times New Roman', // Serif
          isBrutalist: false,
        );
      case 'admin':
        return AppTheme(
          primary: const Color(0xFFCCFF00), // Acid Green
          secondary: const Color(0xFF7000FF), // Electric Purple
          tertiary: const Color(0xFFFF003C), // Cyber Red
          background: const Color(0xFF000000), // Black
          surface: const Color(0xFF1E1E1E),
          onSurface: const Color(0xFFFFFFFF),
          fontFamily: 'Courier', // Monospace
          backgroundPainter: const GridPainter(),
          isBrutalist: true,
        );
      case 'user':
      default:
        if (gender == 'Perempuan') {
          // Cute / Soft Theme (Kawaii)
          return AppTheme(
            primary: const Color(0xFFFF9AA2), // Pastel Pink (Strawberry)
            secondary: const Color(0xFFB5EAD7), // Pastel Mint
            tertiary: const Color(0xFFFFDAC1), // Pastel Peach
            background: const Color(0xFFFFF0F5), // Lavender Blush (Very light pink)
            surface: const Color(0xFFFFFFFF),
            onSurface: const Color(0xFF6D4C41), // Soft Brown (Chocolate)
            fontFamily: 'Roboto',
            isBrutalist: false,
            isCute: true,
            backgroundPainter: const CutePainter(),
          );
        } else {
          // Default / Male (Manly / Slate Theme)
          return AppTheme(
            primary: const Color(0xFF0F172A), // Slate 900 (Very Dark Blue)
            secondary: const Color(0xFF334155), // Slate 700
            tertiary: const Color(0xFF0EA5E9), // Sky 500 (Brighter Blue for contrast)
            background: const Color(0xFFF1F5F9), // Slate 100 (Lighter background for contrast)
            surface: const Color(0xFFFFFFFF),
            onSurface: const Color(0xFF020617), // Slate 950
            fontFamily: 'Roboto', // Sans-serif
            isBrutalist: false,
            isManly: true,
            backgroundPainter: const ManlyPainter(),
          );
        }
    }
  }
}
