import 'dart:math';
import 'package:flutter/material.dart';
import 'package:namer_app/widgets/glitch_button.dart';

class SubjectView extends StatefulWidget {
  const SubjectView({super.key});

  @override
  State<SubjectView> createState() => _SubjectViewState();
}

class _SubjectViewState extends State<SubjectView> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFFF00FF); // Magenta

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('SCIEFORSEA_DATA', style: TextStyle(fontFamily: 'Courier', color: primaryColor, fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: [
          // Animated Background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: DataStreamPainter(offset: _controller.value),
                );
              },
            ),
          ),
          
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    border: Border.all(color: primaryColor, width: 2),
                    color: Colors.black.withValues(alpha: 0.8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CLASS_PROFILE',
                        style: TextStyle(
                          fontFamily: 'Courier',
                          color: primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'SCIEFORSEA',
                        style: TextStyle(
                          fontFamily: 'Courier',
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildInfoRow('WALI KELAS', 'Mr. John Doe, M.Pd'),
                      const SizedBox(height: 12),
                      _buildInfoRow('KETUA KELAS', 'Ahmad Fulan'),
                      const SizedBox(height: 12),
                      _buildInfoRow('WAKIL KETUA', 'Siti Fulana'),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: GlitchButton(
                        color: const Color(0xFF00FFFF),
                        height: 60,
                        onPressed: () {},
                        child: const Text(
                          'INFO SISWA',
                          style: TextStyle(
                            fontFamily: 'Courier',
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00FFFF),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GlitchButton(
                        color: const Color(0xFFCCFF00),
                        height: 60,
                        onPressed: () {},
                        child: const Text(
                          'GALERI FOTO',
                          style: TextStyle(
                            fontFamily: 'Courier',
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFCCFF00),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),
                
                const Text(
                  'CLASS_OFFICERS',
                  style: TextStyle(
                    fontFamily: 'Courier',
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                _buildOfficerCard('SEKRETARIS 1', 'Budi Santoso', const Color(0xFFFF9900)),
                _buildOfficerCard('SEKRETARIS 2', 'Ani Wijaya', const Color(0xFFFF9900)),
                _buildOfficerCard('BENDAHARA 1', 'Citra Lestari', const Color(0xFF00FF41)),
                _buildOfficerCard('BENDAHARA 2', 'Dewi Sartika', const Color(0xFF00FF41)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Courier',
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value.toUpperCase(),
            style: const TextStyle(
              fontFamily: 'Courier',
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOfficerCard(String role, String name, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: color, width: 4)),
        color: Colors.white.withValues(alpha: 0.05),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                role,
                style: TextStyle(
                  fontFamily: 'Courier',
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                name.toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'Courier',
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Icon(Icons.person_outline, color: color.withValues(alpha: 0.5)),
        ],
      ),
    );
  }
}

class DataStreamPainter extends CustomPainter {
  final double offset;

  DataStreamPainter({required this.offset});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFF00FF).withValues(alpha: 0.1)
      ..strokeWidth = 1;

    final random = Random(42);
    
    for (int i = 0; i < 20; i++) {
      final x = random.nextDouble() * size.width;
      final speed = random.nextDouble() * 2 + 1;
      final y = (offset * size.height * speed + random.nextDouble() * size.height) % size.height;
      
      final charHeight = random.nextDouble() * 20 + 10;
      canvas.drawLine(Offset(x, y), Offset(x, y + charHeight), paint);
    }
  }

  @override
  bool shouldRepaint(covariant DataStreamPainter oldDelegate) => oldDelegate.offset != offset;
}
