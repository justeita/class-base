import 'package:flutter/material.dart';
import 'package:namer_app/theme/app_theme.dart';
import 'package:namer_app/utils/date_helper.dart';

class TaskDetailDialog extends StatelessWidget {
  final Map<String, dynamic> task;
  final AppTheme theme;
  final String heroTag;

  const TaskDetailDialog({super.key, required this.task, required this.theme, required this.heroTag});

  @override
  Widget build(BuildContext context) {
    final isCompleted = task['is_completed'] ?? false;
    String deadline = 'Tidak ada tenggat';
    
    if (task['deadline'] != null) {
      try {
        deadline = DateHelper.formatToIndonesian(DateTime.parse(task['deadline']));
      } catch (e) {
        deadline = task['deadline'].toString();
      }
    }

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
                constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
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
                              theme.isBrutalist ? 'DETAIL TUGAS' : 'Detail Tugas',
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
                            Text(
                              (task['title'] ?? 'UNTITLED').toString().toUpperCase(),
                              style: TextStyle(
                                fontFamily: theme.fontFamily,
                                fontWeight: FontWeight.w900,
                                fontSize: 32,
                                color: theme.onSurface,
                              ),
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
                                  _buildDetailRow(theme.isBrutalist ? 'STATUS' : 'Status', isCompleted ? (theme.isBrutalist ? 'SELESAI' : 'Selesai') : (theme.isBrutalist ? 'DALAM PROSES' : 'Dalam Proses'), theme),
                                  const SizedBox(height: 16),
                                  _buildDetailRow(theme.isBrutalist ? 'TENGGAT' : 'Tenggat', deadline, theme),
                                  const SizedBox(height: 16),
                                  const Divider(),
                                  const SizedBox(height: 16),
                                  Text(
                                    task['description'] ?? 'Tidak ada deskripsi',
                                    style: TextStyle(
                                      fontFamily: theme.fontFamily,
                                      color: theme.onSurface,
                                      height: 1.6,
                                      fontSize: 16,
                                    ),
                                  ),
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
