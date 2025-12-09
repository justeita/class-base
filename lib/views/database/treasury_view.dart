import 'dart:math';
import 'package:flutter/material.dart';

class TreasuryView extends StatelessWidget {
  const TreasuryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFFD700)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('TREASURY_LOGS', style: TextStyle(fontFamily: 'Courier', color: Color(0xFFFFD700), fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFFFD700), width: 2),
                color: const Color(0xFFFFD700).withValues(alpha: 0.05),
              ),
              child: CustomPaint(
                painter: ChartPainter(),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'TRANSACTION_HISTORY',
              style: TextStyle(
                fontFamily: 'Courier',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFD700),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) {
                  final isIncome = index % 3 != 0;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(left: BorderSide(color: isIncome ? Colors.green : Colors.red, width: 4)),
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isIncome ? 'CONTRIBUTION #00$index' : 'EXPENSE #00$index',
                              style: const TextStyle(
                                fontFamily: 'Courier',
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '2025-12-0${index + 1} 10:00:00',
                              style: TextStyle(
                                fontFamily: 'Courier',
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          isIncome ? '+ IDR 50.000' : '- IDR 120.000',
                          style: TextStyle(
                            fontFamily: 'Courier',
                            color: isIncome ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFD700)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final random = Random(42);
    
    double x = 0;
    double y = size.height / 2;
    path.moveTo(x, y);

    final points = <Offset>[Offset(x, y)];

    while (x < size.width) {
      x += size.width / 10;
      y = size.height / 2 + (random.nextDouble() - 0.5) * size.height * 0.8;
      path.lineTo(x, y);
      points.add(Offset(x, y));
    }

    canvas.drawPath(path, paint);

    // Draw points
    paint.style = PaintingStyle.fill;
    for (final point in points) {
      canvas.drawCircle(point, 4, paint);
      canvas.drawCircle(point, 8, paint..color = const Color(0xFFFFD700).withValues(alpha: 0.2));
      paint.color = const Color(0xFFFFD700); // Reset color
    }
    
    // Draw Grid
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..strokeWidth = 1;
      
    for (double i = 0; i <= size.height; i += 40) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
