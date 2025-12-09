import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart' as flutter_timezone;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    try {
      tz.initializeTimeZones();
      final timeZoneNameObj = await flutter_timezone.FlutterTimezone.getLocalTimezone();
      String timeZoneName = timeZoneNameObj.toString();
      
      // Fix for Linux/some platforms returning complex string like "TimezoneInfo(Asia/Jakarta, ...)"
      if (timeZoneName.startsWith('TimezoneInfo(')) {
        final parts = timeZoneName.split(',');
        if (parts.isNotEmpty) {
          timeZoneName = parts[0].replaceAll('TimezoneInfo(', '').trim();
        }
      }

      try {
        tz.setLocalLocation(tz.getLocation(timeZoneName));
      } catch (e) {
        debugPrint("Error setting local location: $e. Fallback to UTC.");
        tz.setLocalLocation(tz.getLocation('UTC'));
      }

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      final DarwinInitializationSettings initializationSettingsDarwin =
          const DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      final InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
      );

      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) {
          // Handle notification tap
        },
      );
      
      // Request permissions for Android 13+
      final androidImplementation = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
              
      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
        await androidImplementation.requestExactAlarmsPermission();
      }
    } catch (e) {
      debugPrint("Error initializing NotificationService: $e");
    }
  }

  // ---------------------------------------------------------------------------
  // KONFIGURASI KATA-KATA NOTIFIKASI HARIAN
  // ---------------------------------------------------------------------------
  // Format:
  // DateTime.monday (1) -> Pesan untuk notifikasi hari Senin (target Selasa)
  // DateTime.saturday (6) -> Pesan untuk notifikasi hari Sabtu (target Minggu)
  //
  // 'has_tasks': Pesan jika ada tugas/event
  // 'no_tasks': Pesan jika TIDAK ada tugas/event
  
  static const Map<int, Map<String, String>> dailyMessages = {
    DateTime.monday: {
      'has_tasks': 'Seninnya semangaatt yaa~ 🥺💕 Ada tugas/event besok nih, jangan lupa dikerjain yaa sayang~',
      'no_tasks': 'Besok aman koook~ tapi belajar dikit yaa buat materi Selasa, aku percaya sama kamu! 🌸',
    },
    DateTime.tuesday: {
      'has_tasks': 'Selasanya fighting yaa beb! 💪✨ Tugas/event besok harus selesai nih, kamu pasti bisaaa~',
      'no_tasks': 'Rabu besok tenang kok sayaang~ review materi bentar aja yaa biar makin pinteeer 🥰',
    },
    DateTime.wednesday: {
      'has_tasks': 'Udah Rabu niih~ 🌈 Yuk kerjain tugas/event buat besok, aku temenin kamu kok hehe 💕',
      'no_tasks': 'Kamis besok gada PR lohh! 🎀 Tapi tetep belajar bentar yaa, good job today btw! ✨',
    },
    DateTime.thursday: {
      'has_tasks': 'Kamis ceriaa~ 🌟 Besok Jumat tapi ada deadline nih, semangat yaa sayangkuu! uwu',
      'no_tasks': 'Jumat berkah besok! ✨🤲 Gada tugas, weekendnya tinggal 1 hari lagi hehe~',
    },
    DateTime.friday: {
      'has_tasks': 'Jumat baiikk~ 💝 Selesaiin tugas/event dulu yaa biar weekend beneran happy! u got this beb!',
      'no_tasks': 'Yaaay weekend vibes! 🎉 Besok Sabtu masih sekolah sih, tapi tetep semangaatt yaa! 🥺💕',
    },
    DateTime.saturday: {
      'has_tasks': 'Sabtu masih sekolah huhu 🥺 tapi ada tugas/event besok nih, fighting yaa sayang! ✨',
      'no_tasks': 'Sabtu masih sekolah tp besok Minggu libuuur! 🌸 Gada tugas, kamu kerenn bangett! 💕',
    },
    DateTime.sunday: {
      'has_tasks': 'Minggu santai tapi... besok Senin ada deadline loh beb! 🥺 Yuk dikerjain, aku yakin kamu bisa! 💪✨',
      'no_tasks': 'Minggu healing dulu yaa~ 🌈 Besok Senin siapin mental sama tas sekolah, semangaatt sayangg! 💕',
    },
  };

  String _generateNotificationMessage(
    List<Map<String, dynamic>> tasks, 
    List<Map<String, dynamic>> events,
    DateTime notificationDate, // Tanggal notifikasi muncul (bukan target)
  ) {
    final hasItems = tasks.isNotEmpty || events.isNotEmpty;
    final dayOfWeek = notificationDate.weekday;
    
    // Ambil template pesan berdasarkan hari notifikasi muncul
    final templates = dailyMessages[dayOfWeek] ?? dailyMessages[DateTime.monday]!;
    
    String baseMessage = hasItems 
        ? templates['has_tasks']! 
        : templates['no_tasks']!;

    // Tambahkan detail jumlah jika ada
    if (hasItems) {
      List<String> details = [];
      if (tasks.isNotEmpty) details.add("${tasks.length} tugas");
      if (events.isNotEmpty) details.add("${events.length} event");
      
      return "$baseMessage (${details.join(', ')})";
    }

    return baseMessage;
  }
  // ---------------------------------------------------------------------------

  Future<void> scheduleDailyReminder() async {
    // 1. Tentukan waktu notifikasi (Hari ini jam 18:00)
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 18, 00);

    // Jika sudah lewat jam 18:00, jadwalkan untuk besok
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    try {
      // 4. Jadwalkan Notifikasi (Tanpa pengulangan otomatis agar konten tetap update)
      // Kita akan menjadwalkan untuk 3 hari ke depan setiap kali aplikasi dibuka
      // agar jika user tidak membuka aplikasi besok, notifikasi lusa tetap ada.
      
      for (int i = 0; i < 3; i++) {
        final nextScheduleDate = scheduledDate.add(Duration(days: i));
        final nextTargetDate = nextScheduleDate.add(const Duration(days: 1));
        
        // Fetch data untuk hari target tersebut
        final nextStartOfDay = DateTime(nextTargetDate.year, nextTargetDate.month, nextTargetDate.day);
        final nextEndOfDay = nextStartOfDay.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));
        
        // Fetch Tasks
        final nextTasksResponse = await Supabase.instance.client
            .from('tasks')
            .select()
            .eq('is_completed', false)
            .gte('deadline', nextStartOfDay.toIso8601String())
            .lte('deadline', nextEndOfDay.toIso8601String());

        // Fetch Events (Gantikan Schedule)
        final nextEventsResponse = await Supabase.instance.client
            .from('events')
            .select()
            .gte('event_date', nextStartOfDay.toIso8601String())
            .lte('event_date', nextEndOfDay.toIso8601String());

        final String nextBody = _generateNotificationMessage(
          List<Map<String, dynamic>>.from(nextTasksResponse), 
          List<Map<String, dynamic>>.from(nextEventsResponse),
          nextScheduleDate, // Pass tanggal notifikasi untuk penentuan pesan
        );

        await flutterLocalNotificationsPlugin.zonedSchedule(
          i, // ID berbeda untuk setiap hari (0, 1, 2)
          'Pengingat Besok',
          nextBody,
          nextScheduleDate,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'daily_reminder_channel',
              'Daily Reminder',
              channelDescription: 'Notifikasi harian untuk jadwal dan tugas besok',
              importance: Importance.max,
              priority: Priority.high,
            ),
            iOS: DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
        
        debugPrint("Jadwal notifikasi ID $i: $nextScheduleDate -> $nextBody");
      }

    } catch (e) {
      debugPrint("Gagal menjadwalkan notifikasi: $e");
    }
  }
  
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
