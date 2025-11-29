import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:namer_app/auth_manager.dart';
import 'package:namer_app/theme/app_theme.dart';
import 'package:namer_app/task_detail_dialog.dart';
import 'package:namer_app/widgets/featured_card.dart';
import 'package:namer_app/widgets/activity_item.dart';
import 'package:namer_app/widgets/header_section.dart';
import 'package:namer_app/widgets/custom_search_bar.dart';
import 'package:namer_app/utils/date_helper.dart';
import 'package:namer_app/services/schedule_service.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late Future<List<Map<String, dynamic>>> _tasksFuture;
  late Future<List<Map<String, dynamic>>> _scheduleFuture;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    final now = DateTime.now();
    final isTomorrow = now.hour >= 16;
    final scheduleDate = isTomorrow ? now.add(const Duration(days: 1)) : now;
    final dayName = DateHelper.getDayName(scheduleDate.weekday);

    _tasksFuture = Supabase.instance.client
        .from('tasks')
        .select()
        .eq('is_completed', false)
        .order('created_at', ascending: true)
        .limit(5);
        
    _scheduleFuture = ScheduleService.fetchScheduleForDay(dayName, scheduleDate.day);
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = AppTheme.getTheme(AuthManager().currentTheme, gender: AuthManager().gender);
    
    // Schedule Logic
    final now = DateTime.now();
    final isTomorrow = now.hour >= 16;
    final scheduleTitle = isTomorrow 
        ? (appTheme.isBrutalist ? 'JADWAL BESOK' : 'Jadwal Besok')
        : (appTheme.isBrutalist ? 'JADWAL HARI INI' : 'Jadwal Hari Ini');

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: appTheme.background,
      body: Stack(
        children: [
          if (appTheme.backgroundPainter != null)
            Positioned.fill(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: appTheme.backgroundPainter,
                ),
              ),
            ),
          SafeArea(
            child: RepaintBoundary(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const HeaderSection(),
                  const SizedBox(height: 32),
                  CustomSearchBar(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                  ),
                  const SizedBox(height: 40),
                  
                  // TASKS THIS WEEK
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        appTheme.isBrutalist ? 'TUGAS MINGGU INI' : 'Tugas Minggu Ini',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontFamily: appTheme.fontFamily,
                              letterSpacing: appTheme.isBrutalist ? 1.2 : 0,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 180,
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: _tasksFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator(color: appTheme.primary));
                        }
                        
                        final allTasks = snapshot.data ?? [];
                        final tasks = allTasks.where((task) {
                          final title = (task['title'] ?? '').toString().toLowerCase();
                          final desc = (task['description'] ?? '').toString().toLowerCase();
                          return title.contains(_searchQuery) || desc.contains(_searchQuery);
                        }).toList();
                        
                        if (tasks.isEmpty) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: appTheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: appTheme.isBrutalist ? Border.all(color: appTheme.onSurface.withValues(alpha: 0.1)) : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_outline, size: 48, color: appTheme.primary.withValues(alpha: 0.5)),
                                const SizedBox(height: 16),
                                Text(
                                  'SEMUA TUGAS SELESAI',
                                  style: TextStyle(
                                    color: appTheme.onSurface.withValues(alpha: 0.5),
                                    fontFamily: appTheme.fontFamily,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          clipBehavior: Clip.none,
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            String subtitle = 'TENGGAT: -';
                            
                            // Try to parse deadline if it exists
                            if (task['deadline'] != null) {
                               try {
                                 final date = DateTime.parse(task['deadline']);
                                 subtitle = 'TENGGAT ${DateHelper.formatToIndonesian(date, format: 'EEEE').toUpperCase()}';
                               } catch (e) {
                                 subtitle = 'TENGGAT: ?';
                               }
                            }
                            
                            Color cardColor;
                            if (index % 3 == 0) {
                              cardColor = appTheme.secondary;
                            } else if (index % 3 == 1) {
                              cardColor = appTheme.tertiary;
                            } else {
                              cardColor = appTheme.primary;
                            }

                            final heroTag = 'task_home_${task['id']}';
                            return Padding(
                              padding: const EdgeInsets.only(right: 20),
                              child: Hero(
                                tag: heroTag,
                                createRectTween: (begin, end) {
                                  return MaterialRectArcTween(begin: begin, end: end);
                                },
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        PageRouteBuilder(
                                          opaque: false,
                                          barrierDismissible: true,
                                          barrierColor: Colors.transparent,
                                          transitionDuration: const Duration(milliseconds: 500),
                                          reverseTransitionDuration: const Duration(milliseconds: 400),
                                          pageBuilder: (context, a1, a2) => TaskDetailDialog(task: task, theme: appTheme, heroTag: heroTag),
                                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                            return FadeTransition(
                                              opacity: animation, 
                                              child: child
                                            );
                                          },
                                        ),
                                      );
                                    },
                                    child: FeaturedCard(
                                      color: cardColor,
                                      title: (task['title'] ?? 'UNTITLED').toString().toUpperCase(),
                                      subtitle: subtitle,
                                      icon: Icons.assignment_outlined,
                                      index: '0${index + 1}',
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // DYNAMIC SCHEDULE
                  Text(
                    scheduleTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontFamily: appTheme.fontFamily,
                          letterSpacing: 1.2,
                        ),
                  ),
                  const SizedBox(height: 20),
                  
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _scheduleFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator(color: appTheme.primary));
                      }
                      
                      final allSchedule = snapshot.data ?? [];
                      final schedule = allSchedule.where((item) {
                        final subject = (item['subject'] ?? '').toString().toLowerCase();
                        final teacher = (item['teacher'] ?? '').toString().toLowerCase();
                        return subject.contains(_searchQuery) || teacher.contains(_searchQuery);
                      }).toList();

                      if (schedule.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: appTheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: appTheme.isBrutalist ? Border.all(color: appTheme.onSurface.withValues(alpha: 0.1)) : null,
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.weekend, color: appTheme.onSurface.withValues(alpha: 0.5)),
                              const SizedBox(width: 16),
                              Text(
                                'Tidak ada kelas terjadwal.',
                                style: TextStyle(
                                  color: appTheme.onSurface.withValues(alpha: 0.5),
                                  fontFamily: appTheme.fontFamily,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      
                      return Column(
                        children: schedule.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: ActivityItem(
                            scheduleItem: item,
                          ),
                        )).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
