import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:namer_app/auth_manager.dart';
import 'package:namer_app/theme/app_theme.dart';
import 'package:namer_app/task_detail_dialog.dart';
import 'package:namer_app/utils/date_helper.dart';

class TasksView extends StatefulWidget {
  final bool canEdit;
  const TasksView({super.key, required this.canEdit});

  @override
  State<TasksView> createState() => _TasksViewState();
}

class _TasksViewState extends State<TasksView> {
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _tasks = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 0;
  final int _pageSize = 20;
  bool _isInitialLoad = true;

  @override
  void initState() {
    super.initState();
    _refreshTasks();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMoreTasks();
    }
  }

  Future<void> _refreshTasks() async {
    setState(() {
      _isLoading = true;
      _tasks = [];
      _page = 0;
      _hasMore = true;
      if (_tasks.isEmpty) _isInitialLoad = true;
    });
    await _loadMoreTasks();
  }

  Future<void> _loadMoreTasks() async {
    if (!_hasMore && !_isInitialLoad) {
        if (_isLoading) setState(() => _isLoading = false);
        return;
    }

    try {
      final from = _page * _pageSize;
      final to = from + _pageSize - 1;
      
      final response = await Supabase.instance.client
          .from('tasks')
          .select('id, title, description, is_completed, created_at, deadline')
          .order('is_completed', ascending: true)
          .order('created_at', ascending: false)
          .range(from, to);
      
      final newTasks = List<Map<String, dynamic>>.from(response);
      
      if (mounted) {
        setState(() {
          _tasks.addAll(newTasks);
          _hasMore = newTasks.length == _pageSize;
          _page++;
          _isLoading = false;
          _isInitialLoad = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isInitialLoad = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading tasks: $e')),
        );
      }
    }
  }

  Future<void> _toggleTask(dynamic id, bool currentStatus) async {
    if (!widget.canEdit) return;
    
    try {
      await Supabase.instance.client
          .from('tasks')
          .update({'is_completed': !currentStatus})
          .eq('id', id);
      
      _refreshTasks();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ERROR: $e')),
        );
      }
    }
  }

  Future<void> _addTask() async {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    DateTime? selectedDate;
    final appTheme = AppTheme.getTheme(AuthManager().currentTheme, gender: AuthManager().gender);
    final parentContext = context;

    await showDialog(
      context: parentContext,
      builder: (dialogContext) => StatefulBuilder(
        builder: (builderContext, setState) {
          Future<void> submit() async {
            if (titleController.text.isEmpty) return;
            
            try {
              await Supabase.instance.client.from('tasks').insert({
                'title': titleController.text,
                'description': descController.text,
                'deadline': selectedDate?.toIso8601String(),
                'is_completed': false,
                'created_at': DateTime.now().toIso8601String(),
              });
              
              if (parentContext.mounted) {
                Navigator.pop(dialogContext);
                _refreshTasks();
                ScaffoldMessenger.of(parentContext).showSnackBar(
                  SnackBar(
                    content: Text('Tugas berhasil ditambahkan', style: TextStyle(fontFamily: appTheme.fontFamily)),
                    backgroundColor: appTheme.primary,
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
          }

          return Dialog(
            backgroundColor: appTheme.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TAMBAH TUGAS BARU',
                    style: TextStyle(
                      fontFamily: appTheme.fontFamily,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: appTheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: titleController,
                    textInputAction: TextInputAction.next,
                    style: TextStyle(color: appTheme.onSurface, fontFamily: appTheme.fontFamily),
                    decoration: InputDecoration(
                      labelText: 'JUDUL TUGAS',
                      labelStyle: TextStyle(color: appTheme.onSurface.withValues(alpha: 0.6)),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: appTheme.onSurface.withValues(alpha: 0.2)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: appTheme.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descController,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => submit(),
                    style: TextStyle(color: appTheme.onSurface, fontFamily: appTheme.fontFamily),
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'DESKRIPSI',
                      labelStyle: TextStyle(color: appTheme.onSurface.withValues(alpha: 0.6)),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: appTheme.onSurface.withValues(alpha: 0.2)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: appTheme.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: dialogContext,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.dark(
                                primary: appTheme.primary,
                                onPrimary: appTheme.background,
                                surface: appTheme.surface,
                                onSurface: appTheme.onSurface,
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
                        border: Border.all(color: appTheme.onSurface.withValues(alpha: 0.2)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedDate == null 
                                ? 'PILIH TENGGAT WAKTU' 
                                : DateHelper.formatToIndonesian(selectedDate!),
                            style: TextStyle(
                              color: appTheme.onSurface.withValues(alpha: selectedDate == null ? 0.6 : 1.0),
                              fontFamily: appTheme.fontFamily,
                            ),
                          ),
                          Icon(Icons.calendar_today, color: appTheme.primary, size: 20),
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
                          'BATAL',
                          style: TextStyle(color: appTheme.onSurface.withValues(alpha: 0.6), fontFamily: appTheme.fontFamily),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: appTheme.primary,
                          foregroundColor: appTheme.background,
                        ),
                        child: Text('SIMPAN', style: TextStyle(fontFamily: appTheme.fontFamily, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = AppTheme.getTheme(AuthManager().currentTheme, gender: AuthManager().gender);

    return Scaffold(
      backgroundColor: appTheme.background,
      body: Stack(
        children: [
          if (appTheme.backgroundPainter != null)
            Positioned.fill(
              child: CustomPaint(
                painter: appTheme.backgroundPainter,
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
                          if (appTheme.isBrutalist) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              color: appTheme.tertiary,
                              child: Text(
                                'DATABASE_TUGAS',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: appTheme.fontFamily,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                          Text(
                            appTheme.isBrutalist ? 'OPERASI_PENDING' : 'Daftar Tugas',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: appTheme.onSurface,
                              fontFamily: appTheme.fontFamily,
                              letterSpacing: appTheme.isBrutalist ? -1 : 0,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: appTheme.onSurface.withValues(alpha: 0.24)),
                          borderRadius: appTheme.isBrutalist ? null : BorderRadius.circular(12),
                          color: appTheme.surface,
                        ),
                        child: Icon(Icons.assignment_outlined, color: appTheme.tertiary),
                      ),
                    ],
                  ),
                ),

                // Task List
                Expanded(
                  child: _isInitialLoad && _tasks.isEmpty
                      ? Center(
                          child: Text(
                            'MEMUAT_DATA...',
                            style: TextStyle(
                              color: appTheme.primary,
                              fontFamily: appTheme.fontFamily,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : _tasks.isEmpty
                          ? Center(
                              child: Container(
                                padding: const EdgeInsets.all(32),
                                decoration: BoxDecoration(
                                  border: appTheme.isBrutalist ? Border.all(color: appTheme.onSurface.withValues(alpha: 0.1)) : null,
                                  borderRadius: appTheme.isBrutalist ? null : BorderRadius.circular(24),
                                  color: appTheme.surface.withValues(alpha: 0.8),
                                  boxShadow: appTheme.isBrutalist ? null : [
                                    BoxShadow(
                                      color: appTheme.primary.withValues(alpha: 0.1),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.folder_off_outlined, size: 48, color: appTheme.onSurface.withValues(alpha: 0.24)),
                                    const SizedBox(height: 24),
                                    Text(
                                      'TUGAS_TIDAK_DITEMUKAN',
                                      style: TextStyle(
                                        color: appTheme.onSurface.withValues(alpha: 0.54),
                                        fontSize: 16,
                                        fontFamily: appTheme.fontFamily,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'SISTEM_IDLE',
                                      style: TextStyle(
                                        color: appTheme.onSurface.withValues(alpha: 0.24),
                                        fontSize: 12,
                                        fontFamily: appTheme.fontFamily,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              itemCount: _tasks.length + (_hasMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == _tasks.length) {
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: CircularProgressIndicator(color: appTheme.primary),
                                    ),
                                  );
                                }
                                return _buildTaskItemWithHeader(index, appTheme);
                              },
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: widget.canEdit
          ? FloatingActionButton(
              heroTag: 'tasks_fab',
              onPressed: _addTask,
              backgroundColor: appTheme.tertiary,
              foregroundColor: appTheme.isBrutalist ? Colors.black : Colors.white,
              shape: appTheme.isBrutalist ? const BeveledRectangleBorder() : RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildSectionHeader(String title, AppTheme theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: theme.fontFamily,
          fontWeight: FontWeight.bold,
          color: theme.onSurface.withValues(alpha: 0.5),
          letterSpacing: 1.2,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildTaskItemWithHeader(int index, AppTheme theme) {
    final task = _tasks[index];
    final isCompleted = task['is_completed'] ?? false;
    final bool showPendingHeader = index == 0 && !isCompleted;
    
    // Show completed header if this is the first completed task
    // This happens if it is completed AND (it's the first task OR the previous task was NOT completed)
    final bool showCompletedHeader = isCompleted && (index == 0 || !(_tasks[index - 1]['is_completed'] ?? false));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showPendingHeader) _buildSectionHeader('MASIH BERJALAN', theme),
        if (showCompletedHeader) ...[
           if (index > 0) const SizedBox(height: 32), // Spacer before completed section if not at top
           _buildSectionHeader('SUDAH SELESAI', theme),
        ],
        _buildTaskItem(task, theme),
      ],
    );
  }

  Widget _buildTaskItem(Map<String, dynamic> task, AppTheme theme) {
    final isCompleted = task['is_completed'] ?? false;
    final heroTag = 'task_list_${task['id']}';
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Hero(
        tag: heroTag,
        createRectTween: (begin, end) {
          return MaterialRectArcTween(begin: begin, end: end);
        },
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: theme.surface,
              border: theme.isBrutalist ? Border(
                left: BorderSide(
                  color: isCompleted ? theme.primary : theme.tertiary,
                  width: 4,
                ),
              ) : null,
              borderRadius: theme.isBrutalist ? null : BorderRadius.circular(12),
              boxShadow: theme.isBrutalist ? null : [
                BoxShadow(
                  color: (isCompleted ? theme.primary : theme.tertiary).withValues(alpha: 0.1),
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
                      barrierColor: Colors.transparent,
                      transitionDuration: const Duration(milliseconds: 500),
                      reverseTransitionDuration: const Duration(milliseconds: 400),
                      pageBuilder: (context, a1, a2) => TaskDetailDialog(task: task, theme: theme, heroTag: heroTag),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        return FadeTransition(
                          opacity: animation, 
                          child: child
                        );
                      },
                    ),
                  );
                },
                borderRadius: theme.isBrutalist ? null : BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task['title'] ?? 'TUGAS_UNKNOWN',
                              style: TextStyle(
                                color: theme.onSurface,
                                fontFamily: theme.fontFamily,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                decoration: isCompleted ? TextDecoration.lineThrough : null,
                                decorationColor: theme.primary,
                                decorationThickness: 2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              task['description'] ?? 'TIDAK_ADA_DATA',
                              style: TextStyle(
                                color: theme.onSurface.withValues(alpha: 0.54),
                                fontFamily: theme.fontFamily,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () => _toggleTask(task['id'], isCompleted),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 32,
                          height: 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isCompleted ? theme.primary : theme.onSurface.withValues(alpha: 0.24),
                              width: 2,
                            ),
                            borderRadius: theme.isBrutalist ? null : BorderRadius.circular(8),
                            color: isCompleted ? theme.primary.withValues(alpha: 0.2) : Colors.transparent,
                          ),
                          child: isCompleted
                              ? Icon(Icons.check, size: 18, color: theme.primary)
                              : null,
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
    );
  }
}
