import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:namer_app/auth_manager.dart';
import 'package:namer_app/theme/app_theme.dart';
import 'package:namer_app/utils/date_helper.dart';

class EventsView extends StatefulWidget {
  const EventsView({super.key});

  @override
  State<EventsView> createState() => _EventsViewState();
}

class _EventsViewState extends State<EventsView> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<dynamic>> _events = {};

  @override
  void initState() {
    super.initState();
    // _selectedDay = _focusedDay; // Removed to keep initial selection empty
    _loadAllEvents();
  }

  Future<void> _loadAllEvents() async {
    try {
      // Fetch all events ordered by date
      final response = await Supabase.instance.client
          .from('events')
          .select()
          .order('event_date', ascending: true);

      final data = List<Map<String, dynamic>>.from(response);
      final Map<DateTime, List<dynamic>> events = {};

      for (var item in data) {
        final dateStr = item['event_date'] as String;
        final date = DateTime.parse(dateStr);
        // Normalize to UTC midnight to match TableCalendar's day
        final key = DateTime.utc(date.year, date.month, date.day);

        if (events[key] == null) {
          events[key] = [];
        }
        events[key]!.add(item);
      }

      if (mounted) {
        setState(() {
          _events = events;
        });
      }
    } catch (e) {
      debugPrint('Error loading events for markers: $e');
    }
  }

  Future<void> _addEvent() async {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final typeController = TextEditingController(text: 'UMUM');
    DateTime? selectedDate = _selectedDay ?? DateTime.now();
    final auth = AuthManager();
    final theme = AppTheme.getTheme(auth.currentTheme, gender: auth.gender);
    final parentContext = context; // Capture parent context

    await showDialog(
      context: parentContext,
      builder: (dialogContext) => StatefulBuilder(
        builder: (builderContext, setState) => Dialog(
          backgroundColor: theme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  theme.isBrutalist ? 'TAMBAH EVENT BARU' : 'Tambah Event Baru',
                  style: TextStyle(
                    fontFamily: theme.fontFamily,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: theme.onSurface,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: titleController,
                  style: TextStyle(color: theme.onSurface, fontFamily: theme.fontFamily),
                  decoration: InputDecoration(
                    labelText: theme.isBrutalist ? 'JUDUL EVENT' : 'Judul Event',
                    labelStyle: TextStyle(color: theme.onSurface.withValues(alpha: 0.6)),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: theme.onSurface.withValues(alpha: 0.2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: theme.secondary),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  style: TextStyle(color: theme.onSurface, fontFamily: theme.fontFamily),
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: theme.isBrutalist ? 'DESKRIPSI' : 'Deskripsi',
                    labelStyle: TextStyle(color: theme.onSurface.withValues(alpha: 0.6)),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: theme.onSurface.withValues(alpha: 0.2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: theme.secondary),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                InputDecorator(
                  decoration: InputDecoration(
                    labelText: theme.isBrutalist ? 'TIPE EVENT' : 'Tipe Event',
                    labelStyle: TextStyle(color: theme.onSurface.withValues(alpha: 0.6)),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: theme.onSurface.withValues(alpha: 0.2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: theme.secondary),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: typeController.text,
                      dropdownColor: theme.surface,
                      style: TextStyle(color: theme.onSurface, fontFamily: theme.fontFamily),
                      isExpanded: true,
                      items: ['UMUM', 'LIBUR', 'UJIAN', 'RAPAT', 'LAINNYA']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (val) => setState(() => typeController.text = val!),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: dialogContext,
                      initialDate: selectedDate!,
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.dark(
                              primary: theme.secondary,
                              onPrimary: theme.background,
                              surface: theme.surface,
                              onSurface: theme.onSurface,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (date != null) {
                      setState(() => selectedDate = date);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.onSurface.withValues(alpha: 0.2)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateHelper.formatToIndonesian(selectedDate!),
                          style: TextStyle(
                            color: theme.onSurface,
                            fontFamily: theme.fontFamily,
                          ),
                        ),
                        Icon(Icons.calendar_today, color: theme.secondary, size: 20),
                      ],
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
                        theme.isBrutalist ? 'BATAL' : 'Batal',
                        style: TextStyle(color: theme.onSurface.withValues(alpha: 0.6), fontFamily: theme.fontFamily),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () async {
                        if (titleController.text.isEmpty) return;
                        
                        try {
                          await Supabase.instance.client.from('events').insert({
                            'title': titleController.text,
                            'description': descController.text,
                            'event_date': selectedDate!.toIso8601String(),
                            'event_type': typeController.text,
                            'created_at': DateTime.now().toIso8601String(),
                          });
                          
                          if (parentContext.mounted) {
                            Navigator.pop(dialogContext);
                            _loadAllEvents();
                            ScaffoldMessenger.of(parentContext).showSnackBar(
                              SnackBar(
                                content: Text('Event berhasil ditambahkan', style: TextStyle(fontFamily: theme.fontFamily)),
                                backgroundColor: theme.secondary,
                              ),
                            );
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
                        backgroundColor: theme.secondary,
                        foregroundColor: theme.background,
                      ),
                      child: Text(theme.isBrutalist ? 'SIMPAN' : 'Simpan', style: TextStyle(fontFamily: theme.fontFamily, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
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
                          const SizedBox(height: 8),
                          Text(
                            theme.isBrutalist ? 'KALENDER' : 'Kalender',
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
                        child: Icon(Icons.event_note_outlined, color: theme.secondary),
                      ),
                    ],
                  ),
                ),
                
                // Content Area (Split View)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Calendar Section
                        Container(
                          decoration: BoxDecoration(
                            color: theme.surface,
                            borderRadius: theme.isBrutalist 
                                ? null 
                                : BorderRadius.circular(theme.isCute ? 32 : (theme.isManly ? 8 : 24)),
                            border: theme.isBrutalist 
                                ? Border.all(color: theme.onSurface.withValues(alpha: 0.1)) 
                                : (theme.isManly ? Border.all(color: theme.primary.withValues(alpha: 0.3)) : null),
                            boxShadow: theme.isBrutalist ? null : [
                              BoxShadow(
                                color: theme.isCute 
                                    ? theme.primary.withValues(alpha: 0.1) 
                                    : (theme.isManly 
                                        ? theme.primary.withValues(alpha: 0.15) 
                                        : Colors.black.withValues(alpha: 0.05)),
                                blurRadius: theme.isCute ? 20 : (theme.isManly ? 4 : 20),
                                offset: theme.isManly ? const Offset(4, 4) : const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: TableCalendar(
                            firstDay: DateTime.utc(2023, 7, 17),
                            lastDay: DateTime.utc(2026, 5, 5),
                            focusedDay: _focusedDay,
                            calendarFormat: _calendarFormat,
                            eventLoader: (day) {
                              return _events[DateTime.utc(day.year, day.month, day.day)] ?? [];
                            },
                            selectedDayPredicate: (day) {
                              return isSameDay(_selectedDay, day);
                            },
                            onDaySelected: (selectedDay, focusedDay) {
                              if (!isSameDay(_selectedDay, selectedDay)) {
                                setState(() {
                                  _selectedDay = selectedDay;
                                  _focusedDay = focusedDay;
                                });
                              } else {
                                // Deselect if tapping the same day
                                setState(() {
                                  _selectedDay = null;
                                });
                              }
                            },
                            onFormatChanged: (format) {
                              if (_calendarFormat != format) {
                                setState(() {
                                  _calendarFormat = format;
                                });
                              }
                            },
                            onPageChanged: (focusedDay) {
                              _focusedDay = focusedDay;
                            },
                            onHeaderTapped: (focusedDay) {
                              showGeneralDialog(
                                context: context,
                                barrierDismissible: true,
                                barrierLabel: 'Dismiss',
                                barrierColor: Colors.black54,
                                transitionDuration: const Duration(milliseconds: 300),
                                pageBuilder: (context, animation, secondaryAnimation) {
                                  return Center(
                                    child: Material(
                                      color: Colors.transparent,
                                      child: Container(
                                        width: 320,
                                        padding: const EdgeInsets.all(24),
                                        decoration: BoxDecoration(
                                          color: theme.surface,
                                          borderRadius: BorderRadius.circular(24),
                                          border: Border.all(color: theme.onSurface.withValues(alpha: 0.1)),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.2),
                                              blurRadius: 20,
                                              offset: const Offset(0, 10),
                                            )
                                          ],
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              "PILIH TAHUN AJARAN",
                                              style: TextStyle(
                                                fontFamily: theme.fontFamily,
                                                fontWeight: FontWeight.bold,
                                                color: theme.secondary,
                                                letterSpacing: 1.5,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 24),
                                            ...[2023, 2024, 2025, 2026].map((year) {
                                              final isSelected = focusedDay.year == year;
                                              return InkWell(
                                                onTap: () {
                                                  Navigator.pop(context, year);
                                                },
                                                borderRadius: BorderRadius.circular(12),
                                                child: Container(
                                                  margin: const EdgeInsets.only(bottom: 12),
                                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                                  decoration: BoxDecoration(
                                                    color: isSelected ? theme.secondary.withValues(alpha: 0.1) : Colors.transparent,
                                                    borderRadius: BorderRadius.circular(12),
                                                    border: isSelected ? Border.all(color: theme.secondary.withValues(alpha: 0.5)) : null,
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Expanded(
                                                        child: year == 2023 
                                                          ? Text(
                                                              "awal masuk ---", 
                                                              textAlign: TextAlign.end,
                                                              style: TextStyle(
                                                                fontFamily: theme.fontFamily,
                                                                fontSize: 12,
                                                                color: theme.onSurface.withValues(alpha: 0.5),
                                                              ),
                                                            )
                                                          : const SizedBox(),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Text(
                                                        "$year",
                                                        style: TextStyle(
                                                          fontFamily: theme.fontFamily,
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 18,
                                                          color: isSelected ? theme.secondary : theme.onSurface,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Expanded(
                                                        child: year == 2026 
                                                          ? Text(
                                                              "--- akhir masuk", 
                                                              textAlign: TextAlign.start,
                                                              style: TextStyle(
                                                                fontFamily: theme.fontFamily,
                                                                fontSize: 12,
                                                                color: theme.onSurface.withValues(alpha: 0.5),
                                                              ),
                                                            )
                                                          : const SizedBox(),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                transitionBuilder: (context, animation, secondaryAnimation, child) {
                                  return ScaleTransition(
                                    scale: CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeOutBack,
                                    ),
                                    child: FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    ),
                                  );
                                },
                              ).then((selectedYear) {
                                if (selectedYear != null && selectedYear is int) {
                                  setState(() {
                                    int newMonth = _focusedDay.month;
                                    int newDay = _focusedDay.day;
                                    
                                    if (selectedYear == 2023) {
                                       if (newMonth < 7) { newMonth = 7; newDay = 17; }
                                       else if (newMonth == 7 && newDay < 17) { newDay = 17; }
                                    } else if (selectedYear == 2026) {
                                       if (newMonth > 5) { newMonth = 5; newDay = 5; }
                                       else if (newMonth == 5 && newDay > 5) { newDay = 5; }
                                    }
                                    
                                    _focusedDay = DateTime.utc(selectedYear, newMonth, newDay);
                                  });
                                }
                              });
                            },
                            calendarStyle: CalendarStyle(
                              defaultTextStyle: TextStyle(color: theme.onSurface, fontFamily: theme.fontFamily),
                              weekendTextStyle: TextStyle(color: theme.tertiary, fontFamily: theme.fontFamily),
                              outsideTextStyle: TextStyle(color: theme.onSurface.withValues(alpha: 0.3), fontFamily: theme.fontFamily),
                              selectedDecoration: BoxDecoration(
                                color: theme.secondary,
                                shape: theme.isBrutalist ? BoxShape.rectangle : BoxShape.circle,
                              ),
                              todayDecoration: BoxDecoration(
                                color: theme.secondary.withValues(alpha: 0.3),
                                shape: theme.isBrutalist ? BoxShape.rectangle : BoxShape.circle,
                              ),
                              todayTextStyle: TextStyle(color: theme.secondary, fontWeight: FontWeight.bold, fontFamily: theme.fontFamily),
                              markerDecoration: BoxDecoration(
                                color: theme.tertiary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            headerStyle: HeaderStyle(
                              titleCentered: true,
                              formatButtonVisible: false,
                              titleTextStyle: TextStyle(
                                color: theme.onSurface,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: theme.fontFamily,
                              ),
                              leftChevronIcon: Icon(Icons.chevron_left, color: theme.onSurface),
                              rightChevronIcon: Icon(Icons.chevron_right, color: theme.onSurface),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),

                        // Details Panel
                        Expanded(
                          child: EventDetailsPanel(
                            selectedDay: _selectedDay ?? DateTime.now(),
                            events: _events[DateTime.utc(
                              (_selectedDay ?? DateTime.now()).year,
                              (_selectedDay ?? DateTime.now()).month,
                              (_selectedDay ?? DateTime.now()).day,
                            )] ?? [],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: (auth.role == 'secretary' || auth.role == 'admin')
          ? FloatingActionButton(
              onPressed: _addEvent,
              backgroundColor: theme.secondary,
              foregroundColor: theme.isBrutalist ? Colors.black : Colors.white,
              shape: theme.isBrutalist ? const BeveledRectangleBorder() : RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class EventDetailsPanel extends StatelessWidget {
  final DateTime selectedDay;
  final List<dynamic> events;

  const EventDetailsPanel({
    super.key, 
    required this.selectedDay,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    final auth = AuthManager();
    final theme = AppTheme.getTheme(auth.currentTheme, gender: auth.gender);
    final dateStr = DateHelper.formatToIndonesian(selectedDay);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: theme.isBrutalist 
            ? null 
            : BorderRadius.circular(theme.isCute ? 32 : (theme.isManly ? 8 : 24)),
        border: theme.isBrutalist 
            ? Border.all(color: theme.onSurface.withValues(alpha: 0.1)) 
            : (theme.isManly ? Border.all(color: theme.primary.withValues(alpha: 0.3)) : null),
        boxShadow: theme.isBrutalist ? null : [
          BoxShadow(
            color: theme.isCute 
                ? theme.primary.withValues(alpha: 0.1) 
                : (theme.isManly 
                    ? theme.primary.withValues(alpha: 0.15) 
                    : Colors.black.withValues(alpha: 0.05)),
            blurRadius: theme.isCute ? 20 : (theme.isManly ? 4 : 20),
            offset: theme.isManly ? const Offset(4, 4) : const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            theme.isBrutalist ? 'TANGGAL_TERPILIH' : 'Tanggal Terpilih',
            style: TextStyle(
              color: theme.secondary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              fontFamily: theme.fontFamily,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            dateStr.toUpperCase(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: theme.onSurface,
              fontFamily: theme.fontFamily,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: events.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.event_busy_outlined, size: 48, color: theme.onSurface.withValues(alpha: 0.2)),
                        const SizedBox(height: 16),
                        Text(
                          'Tidak ada event ditemukan',
                          style: TextStyle(
                            color: theme.onSurface.withValues(alpha: 0.5),
                            fontFamily: theme.fontFamily,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.background,
                          border: Border(left: BorderSide(color: theme.secondary, width: 4)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  event['event_type'] ?? 'UMUM',
                                  style: TextStyle(
                                    color: theme.secondary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: theme.fontFamily,
                                  ),
                                ),
                                Icon(Icons.more_horiz, size: 16, color: theme.onSurface.withValues(alpha: 0.3)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              event['title'] ?? 'Event Tanpa Judul',
                              style: TextStyle(
                                color: theme.onSurface,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: theme.fontFamily,
                              ),
                            ),
                            if (event['description'] != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                event['description'],
                                style: TextStyle(
                                  color: theme.onSurface.withValues(alpha: 0.6),
                                  fontSize: 12,
                                  fontFamily: theme.fontFamily,
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
