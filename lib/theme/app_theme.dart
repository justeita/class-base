import 'package:flutter/material.dart';

class GridPainter extends CustomPainter {
  static final Paint _paint = Paint()
    ..color = const Color(0xFF222222)
    ..strokeWidth = 1;

  const GridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const double spacing = 40;

    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), _paint);
    }

    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), _paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CutePainter extends CustomPainter {
  static final Paint _mainPaint = Paint()..style = PaintingStyle.fill;
  static final Paint _highlightPaint = Paint()
    ..color = Colors.white.withValues(alpha: 0.4)
    ..style = PaintingStyle.fill;
  static final Paint _borderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;

  const CutePainter();

  @override
  void paint(Canvas canvas, Size size) {
    // Helper to draw a bubble
    void drawBubble(double x, double y, double radius, Color color) {
      // Main body
      _mainPaint.color = color.withValues(alpha: 0.15);
      canvas.drawCircle(Offset(x, y), radius, _mainPaint);
      
      // Highlight (reflection)
      canvas.drawOval(
        Rect.fromLTWH(x - radius * 0.5, y - radius * 0.6, radius * 0.3, radius * 0.2), 
        _highlightPaint
      );
      
      // Border
      _borderPaint.color = color.withValues(alpha: 0.3);
      canvas.drawCircle(Offset(x, y), radius, _borderPaint);
    }

    // Helper to draw a sparkle (diamond shape)
    void drawSparkle(double x, double y, double scale, Color color) {
      final path = Path();
      path.moveTo(x, y - 10 * scale); // Top
      path.quadraticBezierTo(x + 2 * scale, y - 2 * scale, x + 10 * scale, y); // Right
      path.quadraticBezierTo(x + 2 * scale, y + 2 * scale, x, y + 10 * scale); // Bottom
      path.quadraticBezierTo(x - 2 * scale, y + 2 * scale, x - 10 * scale, y); // Left
      path.close();
      _mainPaint.color = color;
      canvas.drawPath(path, _mainPaint);
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
  static final Paint _fillPaint = Paint()
    ..color = const Color(0xFF334155).withValues(alpha: 0.05)
    ..style = PaintingStyle.fill;

  static final Paint _strokePaint = Paint()
    ..color = const Color(0xFF1E293B).withValues(alpha: 0.05)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;

  const ManlyPainter();

  @override
  void paint(Canvas canvas, Size size) {
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
      
      canvas.drawPath(path, _fillPaint);
      canvas.drawPath(path, _strokePaint);
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

class AppThemeScope extends InheritedWidget {
  final AppTheme theme;

  const AppThemeScope({
    super.key,
    required this.theme,
    required super.child,
  });

  static AppTheme of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppThemeScope>();
    assert(scope != null, 'No AppThemeScope found in context');
    return scope!.theme;
  }

  @override
  bool updateShouldNotify(AppThemeScope oldWidget) => theme != oldWidget.theme;
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

  static final Map<String, AppTheme> _cache = {};

  static AppTheme getTheme(String role, {String? gender}) {
    final key = '$role-${gender ?? ''}';
    if (_cache.containsKey(key)) {
      return _cache[key]!;
    }

    AppTheme theme;
    switch (role) {
      case 'admin':
        theme = AppTheme(
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
      case 'secretary':
      case 'user':
      default:
        if (gender == 'Perempuan') {
          // Cute / Soft Theme (Kawaii)
          theme = AppTheme(
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
          theme = AppTheme(
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
    
    _cache[key] = theme;
    return theme;
  }
}
