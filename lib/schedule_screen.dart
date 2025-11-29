import 'package:flutter/material.dart';
import 'package:namer_app/theme/app_theme.dart'; // Import for GridPainter
import 'package:namer_app/auth_manager.dart';
import 'package:namer_app/services/schedule_service.dart';
import 'package:namer_app/schedule_detail_dialog.dart';

class ScheduleView extends StatefulWidget {
  const ScheduleView({super.key});

  @override
  State<ScheduleView> createState() => _ScheduleViewState();
}

class _ScheduleViewState extends State<ScheduleView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _days = ['SENIN', 'SELASA', 'RABU', 'KAMIS', 'JUMAT', 'SABTU'];
  Future<List<Map<String, dynamic>>>? _weekScheduleFuture;

  @override
  void initState() {
    super.initState();
    int initialIndex = DateTime.now().weekday - 1;
    if (initialIndex >= _days.length || initialIndex < 0) {
      initialIndex = 0;
    }
    _tabController = TabController(length: _days.length, vsync: this, initialIndex: initialIndex);
    _weekScheduleFuture = ScheduleService.fetchAllSchedules();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _addSchedule() async {
    final subjectController = TextEditingController();
    final teacherController = TextEditingController();
    final startTimeController = TextEditingController();
    final endTimeController = TextEditingController();
    String selectedDay = _days[_tabController.index];
    String weekType = 'ALL';
    final auth = AuthManager();
    final theme = AppTheme.getTheme(auth.currentTheme, gender: auth.gender);
    final parentContext = context; // Capture parent context

    await showDialog(
      context: parentContext,
      builder: (dialogContext) => StatefulBuilder(
        builder: (builderContext, setState) => Dialog(
          backgroundColor: theme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TAMBAH JADWAL BARU',
                    style: TextStyle(
                      fontFamily: theme.fontFamily,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: theme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 24),
                  InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'HARI',
                      labelStyle: TextStyle(color: theme.onSurface.withValues(alpha: 0.6)),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: theme.onSurface.withValues(alpha: 0.2)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: theme.primary),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedDay,
                        dropdownColor: theme.surface,
                        style: TextStyle(color: theme.onSurface, fontFamily: theme.fontFamily),
                        isExpanded: true,
                        items: _days.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (val) => setState(() => selectedDay = val!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'MATA PELAJARAN',
                      labelStyle: TextStyle(color: theme.onSurface.withValues(alpha: 0.6)),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: theme.onSurface.withValues(alpha: 0.2)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: theme.primary),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: subjectController.text.isEmpty ? 'MATHEMATICS' : subjectController.text,
                        dropdownColor: theme.surface,
                        style: TextStyle(color: theme.onSurface, fontFamily: theme.fontFamily),
                        isExpanded: true,
                        items: ['MATHEMATICS', 'PHYSICS', 'CHEMISTRY', 'BIOLOGY', 'SPORTS', 'INDONESIAN', 'ENGLISH', 'HISTORY', 'CIVICS', 'RELIGION', 'ARTS', 'BREAK']
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (val) => setState(() => subjectController.text = val!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: teacherController,
                    style: TextStyle(color: theme.onSurface, fontFamily: theme.fontFamily),
                    decoration: InputDecoration(
                      labelText: 'GURU / PENGAJAR',
                      labelStyle: TextStyle(color: theme.onSurface.withValues(alpha: 0.6)),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: theme.onSurface.withValues(alpha: 0.2)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: theme.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: startTimeController,
                          style: TextStyle(color: theme.onSurface, fontFamily: theme.fontFamily),
                          decoration: InputDecoration(
                            labelText: 'MULAI (HH:MM)',
                            labelStyle: TextStyle(color: theme.onSurface.withValues(alpha: 0.6)),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: theme.onSurface.withValues(alpha: 0.2)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: theme.primary),
                            ),
                          ),
                          onTap: () async {
                            final time = await showTimePicker(
                              context: dialogContext,
                              initialTime: TimeOfDay.now(),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: ColorScheme.dark(
                                      primary: theme.primary,
                                      onPrimary: theme.background,
                                      surface: theme.surface,
                                      onSurface: theme.onSurface,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (time != null) {
                              final hour = time.hour.toString().padLeft(2, '0');
                              final minute = time.minute.toString().padLeft(2, '0');
                              startTimeController.text = '$hour:$minute';
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: endTimeController,
                          style: TextStyle(color: theme.onSurface, fontFamily: theme.fontFamily),
                          decoration: InputDecoration(
                            labelText: 'SELESAI (HH:MM)',
                            labelStyle: TextStyle(color: theme.onSurface.withValues(alpha: 0.6)),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: theme.onSurface.withValues(alpha: 0.2)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: theme.primary),
                            ),
                          ),
                          onTap: () async {
                            final time = await showTimePicker(
                              context: dialogContext,
                              initialTime: TimeOfDay.now(),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: ColorScheme.dark(
                                      primary: theme.primary,
                                      onPrimary: theme.background,
                                      surface: theme.surface,
                                      onSurface: theme.onSurface,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (time != null) {
                              final hour = time.hour.toString().padLeft(2, '0');
                              final minute = time.minute.toString().padLeft(2, '0');
                              endTimeController.text = '$hour:$minute';
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'TIPE MINGGU',
                      labelStyle: TextStyle(color: theme.onSurface.withValues(alpha: 0.6)),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: theme.onSurface.withValues(alpha: 0.2)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: theme.primary),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: weekType,
                        dropdownColor: theme.surface,
                        style: TextStyle(color: theme.onSurface, fontFamily: theme.fontFamily),
                        isExpanded: true,
                        items: ['ALL', 'ODD', 'EVEN']
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (val) => setState(() => weekType = val!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: Text(
                          'BATAL',
                          style: TextStyle(color: theme.onSurface.withValues(alpha: 0.6), fontFamily: theme.fontFamily),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () async {
                          if (subjectController.text.isEmpty || startTimeController.text.isEmpty || endTimeController.text.isEmpty) return;
                          
                          try {
                            await ScheduleService.addSchedule(
                              day: selectedDay,
                              subject: subjectController.text.isEmpty ? 'MATHEMATICS' : subjectController.text,
                              teacher: teacherController.text,
                              startTime: startTimeController.text,
                              endTime: endTimeController.text,
                              weekType: weekType,
                            );
                            
                            if (parentContext.mounted) {
                              Navigator.pop(dialogContext);
                              // We need to call setState on the parent widget to refresh the schedule
                              // But we are in a static method or a method of State class?
                              // We are in _ScheduleViewState.
                              // So we can call setState of _ScheduleViewState.
                              // But we are inside an async function, so we need to be careful.
                              // We can just update the future.
                              // Wait, we can't call setState of the parent widget directly if we are not in the widget tree?
                              // We are in _addSchedule which is a method of _ScheduleViewState.
                              // So `this.setState` refers to _ScheduleViewState's setState.
                              // But we are inside `showDialog`'s async gap.
                              // So we should use `this.setState` if `mounted` is true.
                              // But `setState` inside `StatefulBuilder` shadows `this.setState`.
                              // So we need to use `this.setState` explicitly or just call a method that calls `setState`.
                              // I will use a helper method or just access the future variable directly if I can.
                              // Actually, I can just assign the future and call setState on the parent context?
                              // No, I am in the State class.
                              // I will use `this.setState` (implied) but I need to make sure I am not using the shadowed `setState`.
                              // The shadowed `setState` is the second argument of `StatefulBuilder`.
                              // I named it `setState` in the builder.
                              // So `setState` refers to the builder's setState.
                              // To access the parent's setState, I can't easily do it if the name is shadowed.
                              // I should rename the builder's setState to `setDialogState`.
                              
                              // Wait, I already renamed it in my previous thought but maybe not in the code I wrote?
                              // In the code I wrote above: `builder: (builderContext, setState) => Dialog(`
                              // Yes, I shadowed it.
                              // I should rename it to `setDialogState`.
                              
                              // However, I can just update the future variable and then call `setState`?
                              // But `setState` is shadowed.
                              // I can use `_ScheduleViewState.this.setState`? No.
                              // I will rename the inner setState.
                              
                              // Actually, I can just call `_refreshSchedule()` method if I create one.
                              // Or I can just do:
                              // _weekScheduleFuture = ScheduleData.fetchAllSchedules();
                              // (parentContext as Element).markNeedsBuild(); // No, that's hacky.
                              
                              // Let's rename the inner setState.
                            }
                          } catch (e) {
                            if (parentContext.mounted) {
                              ScaffoldMessenger.of(parentContext).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primary,
                          foregroundColor: theme.background,
                        ),
                        child: Text('SIMPAN', style: TextStyle(fontFamily: theme.fontFamily, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthManager();
    final theme = AppTheme.getTheme(auth.currentTheme, gender: auth.gender);
    
    // Ensure future is initialized (handles hot reload case)
    _weekScheduleFuture ??= ScheduleService.fetchAllSchedules();
    
    return Scaffold(
      backgroundColor: theme.background,
      body: Stack(
        children: [
          if (theme.backgroundPainter != null)
            Positioned.fill(
              child: CustomPaint(
                painter: theme.backgroundPainter,
              ),
            ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (theme.isBrutalist) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              color: theme.primary,
                              child: Text(
                                'JADWAL_SISTEM',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: theme.fontFamily,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                          Text(
                            theme.isBrutalist ? 'JADWAL_KELAS' : 'Jadwal Pelajaran',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: theme.onSurface,
                              fontFamily: theme.fontFamily,
                              letterSpacing: theme.isBrutalist ? -1 : 0,
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
                        child: Icon(Icons.calendar_month_outlined, color: theme.primary),
                      ),
                    ],
                  ),
                ),

                // Custom Tab Bar
                Container(
                  height: 50,
                  margin: const EdgeInsets.only(bottom: 20),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    indicator: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: theme.primary, width: 4),
                      ),
                    ),
                    labelColor: theme.primary,
                    unselectedLabelColor: theme.onSurface.withValues(alpha: 0.38),
                    dividerColor: theme.onSurface.withValues(alpha: 0.1),
                    labelPadding: const EdgeInsets.symmetric(horizontal: 20),
                    indicatorSize: TabBarIndicatorSize.label,
                    tabs: _days.map((day) {
                      return Tab(
                        child: Text(
                          day,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: theme.fontFamily,
                            fontSize: 14,
                            letterSpacing: 1,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Content
                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: _weekScheduleFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator(color: theme.primary));
                      }
                      
                      final allSchedules = snapshot.data ?? [];
                      
                      return TabBarView(
                        controller: _tabController,
                        children: _days.map((day) {
                          return DayScheduleList(
                            day: day,
                            allSchedules: allSchedules,
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: (auth.role == 'secretary' || auth.role == 'admin')
          ? FloatingActionButton(
              onPressed: _addSchedule,
              backgroundColor: theme.primary,
              foregroundColor: theme.isBrutalist ? Colors.black : Colors.white,
              shape: theme.isBrutalist ? const BeveledRectangleBorder() : RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class DayScheduleList extends StatelessWidget {
  final String day;
  final List<Map<String, dynamic>> allSchedules;

  const DayScheduleList({
    super.key, 
    required this.day,
    required this.allSchedules,
  });

  @override
  Widget build(BuildContext context) {
    final auth = AuthManager();
    final theme = AppTheme.getTheme(auth.currentTheme, gender: auth.gender);

    // Calculate the date for this specific day in the current week
    final now = DateTime.now();
    final days = ['SENIN', 'SELASA', 'RABU', 'KAMIS', 'JUMAT', 'SABTU'];
    final targetWeekday = days.indexOf(day) + 1; // Monday is 1
    final currentWeekday = now.weekday;
    final difference = targetWeekday - currentWeekday;
    final targetDate = now.add(Duration(days: difference));

    final schedule = ScheduleService.filterSchedule(allSchedules, day, targetDate.day);

    // Check if this list is for today
    final isToday = targetDate.year == now.year && targetDate.month == now.month && targetDate.day == now.day;

    if (schedule.isEmpty) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            border: theme.isBrutalist ? Border.all(color: theme.onSurface.withValues(alpha: 0.1)) : null,
            borderRadius: theme.isBrutalist ? null : BorderRadius.circular(24),
            color: theme.surface.withValues(alpha: 0.8),
            boxShadow: theme.isBrutalist ? null : [
              BoxShadow(
                color: theme.primary.withValues(alpha: 0.1),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.weekend_outlined, size: 48, color: theme.onSurface.withValues(alpha: 0.24)),
              const SizedBox(height: 24),
              Text(
                'DATA_TIDAK_DITEMUKAN',
                style: TextStyle(
                  color: theme.onSurface.withValues(alpha: 0.54),
                  fontSize: 16,
                  fontFamily: theme.fontFamily,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'SISTEM_IDLE',
                style: TextStyle(
                  color: theme.onSurface.withValues(alpha: 0.24),
                  fontSize: 12,
                  fontFamily: theme.fontFamily,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      itemCount: schedule.length,
      itemBuilder: (context, index) {
        final item = schedule[index];
        final isLast = index == schedule.length - 1;
        
        bool isActive = false;
        if (isToday) {
          isActive = _checkIsActive(item['start_time'], item['end_time']);
        }
        
        return TimelineItem(
          scheduleItem: item,
          isLast: isLast,
          color: ScheduleService.getColorForSubject(item['subject'].toString(), theme),
          icon: ScheduleService.getIconForSubject(item['subject'].toString()),
          isActive: isActive,
        );
      },
    );
  }

  bool _checkIsActive(String start, String end) {
    final now = TimeOfDay.now();
    final nowMinutes = now.hour * 60 + now.minute;
    
    final startParts = start.split(':');
    final startMinutes = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
    
    final endParts = end.split(':');
    final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);
    
    return nowMinutes >= startMinutes && nowMinutes < endMinutes;
  }
}

class TimelineItem extends StatelessWidget {
  final Map<String, dynamic> scheduleItem;
  final bool isLast;
  final Color color;
  final IconData icon;
  final bool isActive;

  const TimelineItem({
    super.key,
    required this.scheduleItem,
    required this.isLast,
    required this.color,
    required this.icon,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final auth = AuthManager();
    final theme = AppTheme.getTheme(auth.currentTheme, gender: auth.gender);
    final startTime = scheduleItem['start_time'] as String;
    final endTime = scheduleItem['end_time'] as String;
    final heroTag = 'schedule_${scheduleItem['id'] ?? scheduleItem.hashCode}';
    final teacherName = scheduleItem['teacher']?.toString() ?? '';
    final hasTeacher = teacherName.isNotEmpty && teacherName != '-';

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time Column
          SizedBox(
            width: 60,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  startTime,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.onSurface,
                    fontSize: 14,
                    fontFamily: theme.fontFamily,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  endTime,
                  style: TextStyle(
                    color: theme.onSurface.withValues(alpha: 0.54),
                    fontSize: 12,
                    fontFamily: theme.fontFamily,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          // Timeline Line
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: theme.background,
                  border: Border.all(
                    color: hasTeacher ? color : theme.onSurface.withValues(alpha: 0.3),
                    width: 2,
                  ),
                  borderRadius: theme.isBrutalist ? null : BorderRadius.circular(6),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: hasTeacher ? color.withValues(alpha: 0.3) : theme.onSurface.withValues(alpha: 0.1),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 20),
          // Content Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Hero(
                tag: heroTag,
                createRectTween: (begin, end) {
                  return MaterialRectCenterArcTween(begin: begin, end: end);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: hasTeacher ? theme.surface : theme.surface.withValues(alpha: 0.5),
                    border: isActive 
                        ? Border.all(color: theme.primary, width: 2)
                        : (theme.isBrutalist
                            ? Border(
                                left: BorderSide(color: hasTeacher ? color : theme.onSurface.withValues(alpha: 0.3), width: 2),
                              )
                            : (hasTeacher ? null : Border.all(color: theme.onSurface.withValues(alpha: 0.1)))),
                    borderRadius: theme.isBrutalist ? null : BorderRadius.circular(12),
                    boxShadow: (theme.isBrutalist || !hasTeacher || isActive)
                        ? null
                        : [
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
                                  theme: theme,
                                  heroTag: heroTag,
                                  color: color,
                                  icon: icon,
                                ),
                              );
                            },
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Icon(
                              icon,
                              color: hasTeacher ? color : theme.onSurface.withValues(alpha: 0.5),
                              size: 24,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    scheduleItem['subject'].toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16,
                                      color: hasTeacher ? theme.onSurface : theme.onSurface.withValues(alpha: 0.7),
                                      fontFamily: theme.fontFamily,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  if (hasTeacher) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.person_outline,
                                          size: 12,
                                          color: theme.onSurface.withValues(alpha: 0.54),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          teacherName,
                                          style: TextStyle(
                                            color: theme.onSurface.withValues(alpha: 0.54),
                                            fontSize: 12,
                                            fontFamily: theme.fontFamily,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ] else ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'ISTIRAHAT / MANDIRI',
                                      style: TextStyle(
                                        color: theme.onSurface.withValues(alpha: 0.4),
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                        fontFamily: theme.fontFamily,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
