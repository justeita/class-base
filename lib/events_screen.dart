import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:namer_app/auth_manager.dart';
import 'package:namer_app/theme/app_theme.dart';
import 'package:namer_app/utils/date_helper.dart';

// Top-level function for compute
Map<DateTime, List<dynamic>> _processEvents(List<Map<String, dynamic>> data) {
  final Map<DateTime, List<dynamic>> events = {};

  for (var item in data) {
    final startDateStr = item['event_date'] as String;
    final endDateStr = item['end_date'] as String?;
    
    final startDate = DateTime.parse(startDateStr);
    final endDate = endDateStr != null ? DateTime.parse(endDateStr) : startDate;

    // Normalize to UTC midnight
    final startMidnight = DateTime.utc(startDate.year, startDate.month, startDate.day);
    final endMidnight = DateTime.utc(endDate.year, endDate.month, endDate.day);

    DateTime currentDate = startMidnight;
    
    // Loop through each day in the range
    while (!currentDate.isAfter(endMidnight)) {
      if (events[currentDate] == null) {
        events[currentDate] = [];
      }
      events[currentDate]!.add(item);
      
      currentDate = currentDate.add(const Duration(days: 1));
    }
  }
  return events;
}

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
          .select('id, title, description, event_date, end_date, event_type')
          .order('event_date', ascending: true);

      final data = List<Map<String, dynamic>>.from(response);
      
      // Process events directly (compute removed to fix loading issue)
      final events = _processEvents(data);

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
    final auth = AuthManager();
    final theme = AppTheme.getTheme(auth.currentTheme, gender: auth.gender);
    
    await showDialog(
      context: context,
      builder: (context) => EventStepperDialog(theme: theme, onSave: _loadAllEvents),
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
                            theme: theme,
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
              heroTag: 'events_fab',
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
  final AppTheme theme;

  const EventDetailsPanel({
    super.key, 
    required this.selectedDay,
    required this.events,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = DateHelper.formatToIndonesian(selectedDay);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: theme.isBrutalist 
            ? null 
            : BorderRadius.circular(24),
        border: Border.all(color: theme.onSurface.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dateStr.toUpperCase(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: theme.onSurface,
                  fontFamily: theme.fontFamily,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${events.length} EVENT',
                  style: TextStyle(
                    color: theme.secondary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    fontFamily: theme.fontFamily,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: events.isEmpty
                ? Center(
                    child: Text(
                      'Tidak ada event',
                      style: TextStyle(
                        color: theme.onSurface.withValues(alpha: 0.4),
                        fontFamily: theme.fontFamily,
                        fontSize: 12,
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: events.length,
                    separatorBuilder: (context, index) => Divider(color: theme.onSurface.withValues(alpha: 0.05)),
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return InkWell(
                        onTap: () => _showEventDetail(context, event, theme),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                          child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 4,
                              height: 32,
                              decoration: BoxDecoration(
                                color: theme.secondary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event['title'] ?? 'Event',
                                    style: TextStyle(
                                      color: theme.onSurface,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: theme.fontFamily,
                                    ),
                                  ),
                                  if (event['description'] != null && event['description'].isNotEmpty)
                                    Text(
                                      event['description'],
                                      style: TextStyle(
                                        color: theme.onSurface.withValues(alpha: 0.6),
                                        fontSize: 11,
                                        fontFamily: theme.fontFamily,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                border: Border.all(color: theme.onSurface.withValues(alpha: 0.2)),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                event['event_type'] ?? 'UMUM',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: theme.onSurface.withValues(alpha: 0.6),
                                  fontFamily: theme.fontFamily,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showEventDetail(BuildContext context, Map<String, dynamic> event, AppTheme theme) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: theme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      (event['title'] ?? 'EVENT').toString().toUpperCase(),
                      style: TextStyle(
                        fontFamily: theme.fontFamily,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: theme.onSurface,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: theme.onSurface),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  event['event_type'] ?? 'UMUM',
                  style: TextStyle(
                    color: theme.secondary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: theme.fontFamily,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                event['description'] ?? 'Tidak ada deskripsi',
                style: TextStyle(
                  color: theme.onSurface.withValues(alpha: 0.8),
                  fontFamily: theme.fontFamily,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: theme.onSurface.withValues(alpha: 0.5)),
                  const SizedBox(width: 8),
                  Text(
                    DateHelper.formatToIndonesian(DateTime.parse(event['event_date'])),
                    style: TextStyle(
                      color: theme.onSurface.withValues(alpha: 0.6),
                      fontFamily: theme.fontFamily,
                      fontSize: 12,
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

class EventStepperDialog extends StatefulWidget {
  final AppTheme theme;
  final VoidCallback onSave;

  const EventStepperDialog({super.key, required this.theme, required this.onSave});

  @override
  State<EventStepperDialog> createState() => _EventStepperDialogState();
}

class _EventStepperDialogState extends State<EventStepperDialog> {
  int _currentStep = 0;
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _eventType = 'UMUM';
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDateRange = DateTimeRange(start: now, end: now);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: widget.theme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.theme.isBrutalist ? 'TAMBAH EVENT BARU' : 'Tambah Event Baru',
              style: TextStyle(
                fontFamily: widget.theme.fontFamily,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: widget.theme.onSurface,
              ),
            ),
            const SizedBox(height: 24),
            
            // Stepper Content
            Flexible(
              child: _buildStepContent(),
            ),
            
            const SizedBox(height: 24),
            
            // Navigation Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentStep > 0)
                  TextButton(
                    onPressed: () => setState(() => _currentStep--),
                    child: Text(
                      'KEMBALI',
                      style: TextStyle(color: widget.theme.onSurface.withValues(alpha: 0.6), fontFamily: widget.theme.fontFamily),
                    ),
                  )
                else
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'BATAL',
                      style: TextStyle(color: widget.theme.onSurface.withValues(alpha: 0.6), fontFamily: widget.theme.fontFamily),
                    ),
                  ),
                  
                ElevatedButton(
                  onPressed: _handleNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.theme.secondary,
                    foregroundColor: widget.theme.background,
                  ),
                  child: Text(
                    _currentStep == 2 ? (widget.theme.isBrutalist ? 'SIMPAN' : 'Simpan') : 'LANJUT',
                    style: TextStyle(fontFamily: widget.theme.fontFamily, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              textInputAction: TextInputAction.next,
              style: TextStyle(color: widget.theme.onSurface, fontFamily: widget.theme.fontFamily),
              decoration: InputDecoration(
                labelText: widget.theme.isBrutalist ? 'JUDUL EVENT' : 'Judul Event',
                labelStyle: TextStyle(color: widget.theme.onSurface.withValues(alpha: 0.6)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: widget.theme.onSurface.withValues(alpha: 0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: widget.theme.secondary),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _handleNext(),
              style: TextStyle(color: widget.theme.onSurface, fontFamily: widget.theme.fontFamily),
              maxLines: 3,
              decoration: InputDecoration(
                labelText: widget.theme.isBrutalist ? 'DESKRIPSI' : 'Deskripsi',
                labelStyle: TextStyle(color: widget.theme.onSurface.withValues(alpha: 0.6)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: widget.theme.onSurface.withValues(alpha: 0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: widget.theme.secondary),
                ),
              ),
            ),
          ],
        );
      case 1:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Pilih Tipe Event',
              style: TextStyle(color: widget.theme.onSurface, fontFamily: widget.theme.fontFamily),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['UMUM', 'LIBUR', 'UJIAN', 'RAPAT', 'LAINNYA'].map((type) {
                final isSelected = _eventType == type;
                return ChoiceChip(
                  label: Text(type),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _eventType = type);
                  },
                  selectedColor: widget.theme.secondary,
                  labelStyle: TextStyle(
                    color: isSelected ? widget.theme.background : widget.theme.onSurface,
                    fontFamily: widget.theme.fontFamily,
                  ),
                  backgroundColor: widget.theme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: widget.theme.onSurface.withValues(alpha: 0.2)),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      case 2:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Pilih Tanggal & Durasi',
              style: TextStyle(color: widget.theme.onSurface, fontFamily: widget.theme.fontFamily),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  initialDateRange: _selectedDateRange,
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.dark(
                          primary: widget.theme.secondary,
                          onPrimary: widget.theme.background,
                          surface: widget.theme.surface,
                          onSurface: widget.theme.onSurface,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  setState(() => _selectedDateRange = picked);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: widget.theme.onSurface.withValues(alpha: 0.2)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DARI',
                            style: TextStyle(
                              fontSize: 10,
                              color: widget.theme.onSurface.withValues(alpha: 0.5),
                              fontFamily: widget.theme.fontFamily,
                            ),
                          ),
                          Text(
                            DateHelper.formatToIndonesian(_selectedDateRange!.start),
                            style: TextStyle(
                              color: widget.theme.onSurface,
                              fontFamily: widget.theme.fontFamily,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Icon(Icons.arrow_forward, color: widget.theme.secondary),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'SAMPAI',
                            style: TextStyle(
                              fontSize: 10,
                              color: widget.theme.onSurface.withValues(alpha: 0.5),
                              fontFamily: widget.theme.fontFamily,
                            ),
                          ),
                          Text(
                            DateHelper.formatToIndonesian(_selectedDateRange!.end),
                            style: TextStyle(
                              color: widget.theme.onSurface,
                              fontFamily: widget.theme.fontFamily,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _handleNext() async {
    if (_currentStep == 0) {
      if (_titleController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Judul tidak boleh kosong')),
        );
        return;
      }
      setState(() => _currentStep++);
    } else if (_currentStep == 1) {
      setState(() => _currentStep++);
    } else {
      // Save
      try {
        await Supabase.instance.client.from('events').insert({
          'title': _titleController.text,
          'description': _descController.text,
          'event_date': _selectedDateRange!.start.toIso8601String(),
          'end_date': _selectedDateRange!.end.toIso8601String(),
          'event_type': _eventType,
          'created_at': DateTime.now().toIso8601String(),
        });
        
        if (mounted) {
          Navigator.pop(context);
          widget.onSave();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Event berhasil ditambahkan', style: TextStyle(fontFamily: widget.theme.fontFamily)),
              backgroundColor: widget.theme.secondary,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }
}
