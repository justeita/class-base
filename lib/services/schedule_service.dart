import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:namer_app/theme/app_theme.dart';

class ScheduleService {
  static List<Map<String, dynamic>>? _cachedSchedules;
  static DateTime? _lastFetchTime;
  static const Duration _cacheDuration = Duration(minutes: 10);

  static Future<List<Map<String, dynamic>>> fetchScheduleForDay(String day, int dayOfMonth) async {
    try {
      // Use cached all schedules if available, otherwise fetch all
      final allSchedules = await fetchAllSchedules();
      return filterSchedule(allSchedules, day, dayOfMonth);
    } catch (e) {
      debugPrint('Error fetching schedule: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> fetchAllSchedules({bool forceRefresh = false}) async {
    try {
      if (!forceRefresh && _cachedSchedules != null && _lastFetchTime != null) {
        if (DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
          return _cachedSchedules!;
        }
      }

      final response = await Supabase.instance.client
          .from('schedules')
          .select()
          .order('start_time', ascending: true);
      
      final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(response);
      data.sort((a, b) => (a['start_time'] as String).compareTo(b['start_time'] as String));
      
      _cachedSchedules = data;
      _lastFetchTime = DateTime.now();
      
      return data;
    } catch (e) {
      debugPrint('Error fetching all schedules: $e');
      return _cachedSchedules ?? [];
    }
  }

  static List<Map<String, dynamic>> filterSchedule(List<Map<String, dynamic>> allData, String day, int dayOfMonth) {
      final isEven = dayOfMonth % 2 == 0;
      final weekType = isEven ? 'EVEN' : 'ODD';
      return allData.where((item) => 
          item['day'] == day && 
          (item['week_type'] == 'ALL' || item['week_type'] == weekType)
      ).toList();
  }

  static Future<void> addSchedule({
    required String day,
    required String subject,
    required String teacher,
    required String startTime,
    required String endTime,
    required String weekType,
  }) async {
    await Supabase.instance.client.from('schedules').insert({
      'day': day,
      'subject': subject,
      'teacher': teacher,
      'start_time': startTime,
      'end_time': endTime,
      'week_type': weekType,
      'created_at': DateTime.now().toIso8601String(),
    });
    
    // Invalidate cache
    _cachedSchedules = null;
    _lastFetchTime = null;
  }

  static Color getColorForSubject(String subject, AppTheme theme) {
    if (!theme.isBrutalist) {
      switch (subject) {
        case 'MATHEMATICS':
        case 'PHYSICS':
        case 'CHEMISTRY':
          return theme.primary;
        case 'BIOLOGY':
        case 'SPORTS':
          return Colors.green;
        case 'INDONESIAN':
        case 'ENGLISH':
        case 'LOCAL_LANG':
          return theme.tertiary;
        case 'HISTORY':
        case 'CIVICS':
        case 'RELIGION':
          return theme.secondary;
        case 'ARTS':
          return Colors.pink;
        case 'BREAK':
          return Colors.orange;
        default:
          return Colors.grey;
      }
    }

    switch (subject) {
      case 'MATHEMATICS':
      case 'PHYSICS':
      case 'CHEMISTRY':
        return const Color(0xFF00F0FF); // Cyan
      case 'BIOLOGY':
      case 'SPORTS':
        return const Color(0xFFCCFF00); // Acid Green
      case 'INDONESIAN':
      case 'ENGLISH':
      case 'LOCAL_LANG':
        return const Color(0xFFFF003C); // Red
      case 'HISTORY':
      case 'CIVICS':
      case 'RELIGION':
        return const Color(0xFF7000FF); // Purple
      case 'ARTS':
        return const Color(0xFFFF00FF); // Magenta
      case 'BREAK':
        return Colors.white;
      default:
        return Colors.grey;
    }
  }

  static IconData getIconForSubject(String subject) {
    switch (subject) {
      case 'MATHEMATICS':
        return Icons.calculate_outlined;
      case 'PHYSICS':
        return Icons.bolt_outlined;
      case 'CHEMISTRY':
        return Icons.science_outlined;
      case 'BIOLOGY':
        return Icons.biotech_outlined;
      case 'SPORTS':
        return Icons.sports_soccer_outlined;
      case 'INDONESIAN':
      case 'ENGLISH':
      case 'LOCAL_LANG':
        return Icons.menu_book_outlined;
      case 'HISTORY':
        return Icons.history_edu_outlined;
      case 'CIVICS':
        return Icons.gavel_outlined;
      case 'RELIGION':
        return Icons.mosque_outlined;
      case 'ARTS':
        return Icons.palette_outlined;
      case 'BREAK':
        return Icons.restaurant_outlined;
      case 'CEREMONY':
        return Icons.flag_outlined;
      default:
        return Icons.class_outlined;
    }
  }
}
