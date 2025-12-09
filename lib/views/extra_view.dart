import 'package:flutter/material.dart';
import 'package:namer_app/auth_manager.dart';
import 'package:namer_app/theme/app_theme.dart';
import 'package:namer_app/views/database_view.dart';

class ExtraView extends StatelessWidget {
  const ExtraView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthManager();
    final theme = AppTheme.getTheme(auth.currentTheme, gender: auth.gender);

    final menuItems = [
      {
        'title': 'Database',
        'subtitle': 'Akses Data Sekolah',
        'icon': Icons.storage_rounded,
        'color': const Color(0xFF4CAF50),
        'route': 'database',
      },
      {
        'title': 'Tatib',
        'subtitle': 'Buktikan kamu benar',
        'icon': Icons.gavel_rounded,
        'color': const Color(0xFFF44336),
      },
      {
        'title': 'Kas',
        'subtitle': 'Ada tidaknya korupsi',
        'icon': Icons.attach_money_rounded,
        'color': const Color(0xFFFFC107),
      },
      {
        'title': 'Map Sekolah',
        'subtitle': 'Kerja keras Pak Anwar',
        'icon': Icons.map_rounded,
        'color': const Color(0xFF2196F3),
      },
      {
        'title': 'LAPOR BK',
        'subtitle': 'Semoga didengar',
        'icon': Icons.report_problem_rounded,
        'color': const Color(0xFF9C27B0),
      },
    ];

    return Scaffold(
      backgroundColor: theme.background,
      body: Stack(
        children: [
          if (theme.backgroundPainter != null)
            Positioned.fill(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: theme.backgroundPainter,
                ),
              ),
            ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            theme.isBrutalist ? 'EKSTRA' : 'Ekstra',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: theme.onSurface,
                              fontFamily: theme.fontFamily,
                              letterSpacing: -1,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: theme.onSurface.withValues(alpha: 0.24)),
                          borderRadius: theme.isBrutalist ? null : BorderRadius.circular(12),
                          color: theme.surface,
                        ),
                        child: Icon(Icons.widgets_outlined, color: theme.primary),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(24),
                    itemCount: menuItems.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final item = menuItems[index];
                      final color = item['color'] as Color;
                      
                      return Container(
                        decoration: BoxDecoration(
                          color: theme.surface,
                          borderRadius: theme.isBrutalist ? null : BorderRadius.circular(16),
                          border: theme.isBrutalist 
                              ? Border.all(color: theme.onSurface.withValues(alpha: 0.1))
                              : null,
                          boxShadow: theme.isBrutalist ? null : [
                            BoxShadow(
                              color: color.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              if (item['route'] == 'database') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const DatabaseView()),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Fitur ${item['title']} belum tersedia'),
                                    backgroundColor: theme.surface,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                            borderRadius: theme.isBrutalist ? null : BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      item['icon'] as IconData,
                                      color: color,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          (item['title'] as String).toUpperCase(),
                                          style: TextStyle(
                                            fontFamily: theme.fontFamily,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: theme.onSurface,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          item['subtitle'] as String,
                                          style: TextStyle(
                                            fontFamily: theme.fontFamily,
                                            fontSize: 12,
                                            color: theme.onSurface.withValues(alpha: 0.6),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 16,
                                    color: theme.onSurface.withValues(alpha: 0.3),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
