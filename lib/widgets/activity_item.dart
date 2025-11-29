import 'package:flutter/material.dart';
import 'package:namer_app/auth_manager.dart';
import 'package:namer_app/theme/app_theme.dart';
import 'package:namer_app/schedule_detail_dialog.dart';
import 'package:namer_app/services/schedule_service.dart';

class ActivityItem extends StatelessWidget {
  final Map<String, dynamic> scheduleItem;

  const ActivityItem({
    super.key,
    required this.scheduleItem,
  });

  @override
  Widget build(BuildContext context) {
    final auth = AuthManager();
    final appTheme = AppTheme.getTheme(auth.currentTheme, gender: auth.gender);
    final title = scheduleItem['subject'].toString();
    final teacherName = scheduleItem['teacher']?.toString() ?? '';
    final hasTeacher = teacherName.isNotEmpty && teacherName != '-';
    
    final subtitle = hasTeacher 
        ? '${scheduleItem['start_time']} - ${scheduleItem['end_time']} • $teacherName'
        : '${scheduleItem['start_time']} - ${scheduleItem['end_time']}';
        
    final icon = ScheduleService.getIconForSubject(title);
    final color = ScheduleService.getColorForSubject(title, appTheme);
    final heroTag = 'activity_home_${scheduleItem['id'] ?? scheduleItem.hashCode}';

    return Hero(
      tag: heroTag,
      createRectTween: (begin, end) {
        return MaterialRectCenterArcTween(begin: begin, end: end);
      },
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: hasTeacher ? appTheme.surface : appTheme.surface.withValues(alpha: 0.6),
            border: appTheme.isBrutalist 
                ? Border.all(color: appTheme.onSurface.withValues(alpha: 0.1)) 
                : (appTheme.isManly 
                    ? Border.all(color: appTheme.primary.withValues(alpha: 0.3), width: 1)
                    : null),
            borderRadius: appTheme.isBrutalist 
                ? null 
                : BorderRadius.circular(appTheme.isCute ? 24 : (appTheme.isManly ? 8 : 12)),
            boxShadow: appTheme.isBrutalist ? null : [
              BoxShadow(
                color: appTheme.isCute 
                    ? appTheme.primary.withValues(alpha: 0.1) 
                    : (appTheme.isManly 
                        ? appTheme.primary.withValues(alpha: 0.15) 
                        : Colors.black.withValues(alpha: 0.05)),
                blurRadius: appTheme.isCute ? 12 : (appTheme.isManly ? 4 : 10),
                offset: appTheme.isManly ? const Offset(4, 4) : const Offset(0, 4),
              ),
            ],
          ),
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  opaque: false,
                  barrierDismissible: true,
                  barrierColor: Colors.black54,
                  pageBuilder: (context, animation, secondaryAnimation) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScheduleDetailDialog(
                        schedule: scheduleItem,
                        theme: appTheme,
                        heroTag: heroTag,
                        color: color,
                        icon: icon,
                      ),
                    );
                  },
                ),
              );
            },
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    border: appTheme.isBrutalist 
                        ? Border.all(color: color.withValues(alpha: 0.5)) 
                        : (appTheme.isManly ? Border.all(color: color.withValues(alpha: 0.3)) : null),
                    borderRadius: appTheme.isBrutalist 
                        ? null 
                        : BorderRadius.circular(appTheme.isCute ? 16 : (appTheme.isManly ? 6 : 8)),
                  ),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: appTheme.onSurface,
                          fontFamily: appTheme.fontFamily,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: appTheme.onSurface.withValues(alpha: 0.5),
                          fontSize: 12,
                          fontFamily: appTheme.fontFamily,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: color, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
