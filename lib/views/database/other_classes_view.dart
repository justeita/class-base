import 'package:flutter/material.dart';

class OtherClassesView extends StatefulWidget {
  const OtherClassesView({super.key});

  @override
  State<OtherClassesView> createState() => _OtherClassesViewState();
}

class _OtherClassesViewState extends State<OtherClassesView> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<String> classes = const [
    'MIPA 1', 'MIPA 2', 'MIPA 3',
    'BIC 1', 'BIC 2',
    'IPS 1', 'IPS 2', 'IPS 3', 'IPS 4',
    'Bahasa',
    'PK 1', 'PK 2',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00FFFF)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('OTHER_CLASSES', style: TextStyle(fontFamily: 'Courier', color: Color(0xFF00FFFF), fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: [
          // Background Grid Animation
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: GridPainter(offset: _controller.value),
                );
              },
            ),
          ),
          ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: classes.length,
            itemBuilder: (context, index) {
              return _buildClassItem(index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildClassItem(int index) {
    final color = [
      const Color(0xFF00FFFF),
      const Color(0xFFFF00FF),
      const Color(0xFFCCFF00),
    ][index % 3];

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 24),
              height: 80,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Shadow/Glitch Effect
                  Positioned(
                    top: 4,
                    left: 4,
                    right: -4,
                    bottom: -4,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: color.withValues(alpha: 0.3)),
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                  // Main Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      border: Border.all(color: color, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.1),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {},
                        splashColor: color.withValues(alpha: 0.2),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                classes[index],
                                style: TextStyle(
                                  fontFamily: 'Courier',
                                  color: color,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2,
                                ),
                              ),
                              Row(
                                children: [
                                  // Decorative bits
                                  Container(
                                    width: 8,
                                    height: 8,
                                    color: color,
                                  ),
                                  const SizedBox(width: 4),
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: color),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Icon(Icons.arrow_forward, color: color),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class GridPainter extends CustomPainter {
  final double offset;

  GridPainter({required this.offset});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00FFFF).withValues(alpha: 0.05)
      ..strokeWidth = 1;

    const spacing = 40.0;
    final yOffset = offset * spacing;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = -spacing; y < size.height + spacing; y += spacing) {
      canvas.drawLine(
        Offset(0, y + yOffset),
        Offset(size.width, y + yOffset),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant GridPainter oldDelegate) => oldDelegate.offset != offset;
}
