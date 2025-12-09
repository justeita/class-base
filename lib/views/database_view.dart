import 'dart:math';
import 'package:namer_app/views/database/other_classes_view.dart';
import 'package:namer_app/views/database/rules_view.dart';
import 'package:namer_app/views/database/school_view.dart';
import 'package:namer_app/views/database/subject_view.dart';
import 'package:namer_app/widgets/glitch_button.dart';
import 'package:flutter/material.dart';

class DatabaseView extends StatefulWidget {
  const DatabaseView({super.key});

  @override
  State<DatabaseView> createState() => _DatabaseViewState();
}

class _DatabaseViewState extends State<DatabaseView> with TickerProviderStateMixin {
  late AnimationController _noiseController;
  late AnimationController _entranceController;
  
  @override
  void initState() {
    super.initState();
    
    _noiseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Slower, continuous loop
    )..repeat();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _entranceController.forward();
  }

  @override
  void dispose() {
    _noiseController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Layer 1: Animated Acid Background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _noiseController,
              builder: (context, child) {
                return CustomPaint(
                  painter: AcidBackgroundPainter(
                    seed: _noiseController.value,
                  ),
                );
              },
            ),
          ),
          
          // Layer 2: Content
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(width: 2),
                            boxShadow: const [BoxShadow(offset: Offset(4, 4), color: Colors.black)],
                          ),
                          child: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFCCFF00), // Acid Green
                          border: Border.all(width: 2),
                        ),
                        child: const Text(
                          'RESTRICTED AREA',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            fontFamily: 'Courier',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SizedBox(
                    height: 80,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 4,
                          top: 4,
                          child: Text(
                            'DATABASE',
                            style: TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF2D00F7).withValues(alpha: 0.5), // Deep Purple
                              height: 0.9,
                              letterSpacing: -4,
                            ),
                          ),
                        ),
                        const Text(
                          'DATABASE',
                          style: TextStyle(
                            fontSize: 56,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 0.9,
                            letterSpacing: -4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Menu Grid
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      _buildAnimatedItem(
                        0,
                        _buildNeoButton(
                          'SCIEFORSEA',
                          'MAIN_CLASS_DATA',
                          const Color(0xFFFF00FF), // Magenta
                          Icons.science,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SubjectView())),
                          rotate: -0.02,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: _buildAnimatedItem(
                              1,
                              _buildNeoButton(
                                'KELAS LAIN',
                                'OTHER_CLASSES',
                                const Color(0xFF00FFFF), // Cyan
                                Icons.class_,
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const OtherClassesView())),
                                rotate: 0.02,
                                height: 160, // Increased height to prevent overflow
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: _buildAnimatedItem(
                              2,
                              _buildNeoButton(
                                'GURU & STAFF',
                                'FACULTY_MEMBERS',
                                const Color(0xFFFF9900), // Orange
                                Icons.people,
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RulesView())),
                                rotate: -0.02,
                                height: 160, // Increased height to prevent overflow
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildAnimatedItem(
                        3,
                        _buildNeoButton(
                          'SEKOLAH',
                          'SCHOOL_INFO',
                          const Color(0xFFCCFF00), // Acid Green
                          Icons.school,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SchoolView())),
                          textColor: Colors.black,
                          rotate: 0.01,
                        ),
                      ),
                      const SizedBox(height: 40),
                      
                      // Footer Search Bar
                      _buildAnimatedItem(
                        4,
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white),
                            color: Colors.black,
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.search, color: Colors.white),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  style: const TextStyle(color: Colors.white, fontFamily: 'Courier'),
                                  decoration: InputDecoration(
                                    hintText: 'SEARCH_DATABASE...',
                                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontFamily: 'Courier'),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedItem(int index, Widget child) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _entranceController,
        curve: Interval(
          index * 0.1,
          1.0,
          curve: Curves.easeOutBack,
        ),
      )),
      child: FadeTransition(
        opacity: Tween<double>(
          begin: 0,
          end: 1,
        ).animate(CurvedAnimation(
          parent: _entranceController,
          curve: Interval(
            index * 0.1,
            1.0,
            curve: Curves.easeOut,
          ),
        )),
        child: child,
      ),
    );
  }

  Widget _buildNeoButton(String title, String subtitle, Color color, IconData icon, {
    double rotate = 0.0,
    double height = 120,
    Color textColor = Colors.black,
    VoidCallback? onTap,
  }) {
    return Transform.rotate(
      angle: rotate,
      child: GlitchButton(
        onPressed: onTap,
        color: color,
        height: height,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: color, size: 28),
                  Icon(Icons.arrow_outward, color: color, size: 20),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Courier',
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                      color: color,
                      letterSpacing: -1,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Courier',
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: color.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AcidBackgroundPainter extends CustomPainter {
  final double seed;

  AcidBackgroundPainter({required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Dynamic Grid
    paint.color = Colors.white.withValues(alpha: 0.05);
    const gridSize = 40.0;
    
    // Moving Grid Effect
    final offset = seed * gridSize;
    
    for (double x = 0; x < size.width + gridSize; x += gridSize) {
      double drawX = (x + offset) % (size.width + gridSize) - gridSize;
      canvas.drawLine(Offset(drawX, 0), Offset(drawX, size.height), paint);
    }
    for (double y = 0; y < size.height + gridSize; y += gridSize) {
      double drawY = (y + offset) % (size.height + gridSize) - gridSize;
      canvas.drawLine(Offset(0, drawY), Offset(size.width, drawY), paint);
    }

    // Absurd/Aesthetic Shapes
    final random = Random((seed * 100).toInt()); // Jittery random based on time
    
    // Floating Circles/Glitches
    for (int i = 0; i < 5; i++) {
      paint.color = [
        const Color(0xFFFF00FF), 
        const Color(0xFF00FFFF), 
        const Color(0xFFCCFF00)
      ][i % 3].withValues(alpha: 0.3);
      
      // Smooth movement using sine waves based on seed (time)
      final t = seed * 2 * pi;
      final x = size.width * (0.5 + 0.4 * sin(t + i));
      final y = size.height * (0.5 + 0.4 * cos(t * 0.7 + i));
      
      canvas.drawCircle(Offset(x, y), 20 + 10 * sin(t * 2), paint);
    }

    // Random Glitch Lines
    paint.color = const Color(0xFF00FF41).withValues(alpha: 0.4);
    if (random.nextDouble() > 0.7) {
      final y = random.nextDouble() * size.height;
      final h = random.nextDouble() * 50;
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, h), paint..style = PaintingStyle.fill);
    }
  }

  @override
  bool shouldRepaint(covariant AcidBackgroundPainter oldDelegate) {
    return oldDelegate.seed != seed;
  }
}
