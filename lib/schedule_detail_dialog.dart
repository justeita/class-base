import 'package:flutter/material.dart';
import 'package:namer_app/theme/app_theme.dart';

class ScheduleDetailDialog extends StatelessWidget {
  final Map<String, dynamic> schedule;
  final AppTheme theme;
  final String heroTag;
  final Color color;
  final IconData icon;

  const ScheduleDetailDialog({
    super.key,
    required this.schedule,
    required this.theme,
    required this.heroTag,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.5),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Hero(
            tag: heroTag,
            createRectTween: (begin, end) {
              return MaterialRectCenterArcTween(begin: begin, end: end);
            },
            child: Material(
              color: theme.surface,
              borderRadius: theme.isBrutalist 
                  ? BorderRadius.zero 
                  : BorderRadius.circular(theme.isCute ? 32 : (theme.isManly ? 8 : 24)),
              elevation: 8,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.close, color: theme.onSurface),
                            onPressed: () => Navigator.pop(context),
                          ),
                          Expanded(
                            child: Text(
                              theme.isBrutalist ? 'DETAIL JADWAL' : 'Detail Jadwal',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: theme.fontFamily,
                                fontWeight: FontWeight.bold,
                                color: theme.onSurface.withValues(alpha: 0.5),
                                fontSize: 14,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.1),
                                    borderRadius: theme.isBrutalist 
                                        ? BorderRadius.zero 
                                        : BorderRadius.circular(theme.isCute ? 24 : (theme.isManly ? 8 : 16)),
                                    border: Border.all(color: color.withValues(alpha: 0.3)),
                                  ),
                                  child: Icon(icon, color: color, size: 32),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    (schedule['subject'] ?? 'UNKNOWN').toString().toUpperCase(),
                                    style: TextStyle(
                                      fontFamily: theme.fontFamily,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 24,
                                      color: theme.onSurface,
                                      height: 1.2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: theme.background,
                                borderRadius: theme.isBrutalist 
                                    ? BorderRadius.zero 
                                    : BorderRadius.circular(theme.isCute ? 24 : (theme.isManly ? 8 : 16)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildDetailRow(theme.isBrutalist ? 'WAKTU' : 'Waktu', '${schedule['start_time']} - ${schedule['end_time']}', theme),
                                  const SizedBox(height: 16),
                                  _buildDetailRow(theme.isBrutalist ? 'PENGAJAR' : 'Pengajar', schedule['teacher'] ?? '-', theme),
                                  const SizedBox(height: 16),
                                  _buildDetailRow(theme.isBrutalist ? 'HARI' : 'Hari', schedule['day'] ?? '-', theme),
                                  const SizedBox(height: 16),
                                  const Divider(),
                                  const SizedBox(height: 16),
                                  _buildDetailRow(theme.isBrutalist ? 'TIPE MINGGU' : 'Tipe Minggu', schedule['week_type'] == 'ALL' ? (theme.isBrutalist ? 'SEMUA MINGGU' : 'Semua Minggu') : (schedule['week_type'] == 'ODD' ? (theme.isBrutalist ? 'MINGGU GANJIL' : 'Minggu Ganjil') : (theme.isBrutalist ? 'MINGGU GENAP' : 'Minggu Genap')), theme),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, AppTheme theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: theme.fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: theme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontFamily: theme.fontFamily,
              fontWeight: FontWeight.bold,
              color: theme.onSurface,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
