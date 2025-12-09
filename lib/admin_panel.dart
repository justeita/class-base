import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:namer_app/auth_manager.dart';
import 'package:namer_app/theme/app_theme.dart'; // Import for GridPainter

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _absentNumberController = TextEditingController();
  final _classNameController = TextEditingController();
  final _dobController = TextEditingController();
  
  String _selectedRole = 'user';
  String _selectedGender = 'Pria';
  bool _isSubmitting = false;
  
  // Pagination state
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 0;
  final int _pageSize = 20;
  bool _isInitialLoad = true;

  @override
  void initState() {
    super.initState();
    _refreshUsers();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _absentNumberController.dispose();
    _classNameController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMoreUsers();
    }
  }

  Future<void> _refreshUsers() async {
    setState(() {
      _isLoading = true;
      _users = [];
      _page = 0;
      _hasMore = true;
      if (_users.isEmpty) _isInitialLoad = true;
    });
    await _loadMoreUsers();
  }

  Future<void> _loadMoreUsers() async {
    if (!_hasMore && !_isInitialLoad) {
        if (_isLoading) setState(() => _isLoading = false);
        return;
    }

    try {
      final from = _page * _pageSize;
      final to = from + _pageSize - 1;

      final response = await Supabase.instance.client
          .from('app_users')
          .select('id, username, role, created_at')
          .order('created_at')
          .range(from, to);
      
      final newUsers = List<Map<String, dynamic>>.from(response);

      if (mounted) {
        setState(() {
          _users.addAll(newUsers);
          _hasMore = newUsers.length == _pageSize;
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
          SnackBar(content: Text('ERROR: $e', style: const TextStyle(fontFamily: 'Courier')), backgroundColor: const Color(0xFFFF003C)),
        );
      }
    }
  }

  Future<void> _addUser() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('INPUT_DIBUTUHKAN', style: TextStyle(fontFamily: 'Courier')),
          backgroundColor: Color(0xFFFF003C),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final username = _usernameController.text.trim();
      final password = _passwordController.text.trim();
      final hashedPassword = AuthManager.hashPassword(password);

      await Supabase.instance.client.from('app_users').insert({
        'username': username,
        'password': hashedPassword,
        'role': _selectedRole,
        'full_name': _fullNameController.text.isEmpty ? null : _fullNameController.text.trim(),
        'absent_number': _absentNumberController.text.isEmpty ? null : _absentNumberController.text.trim(),
        'class_name': _classNameController.text.isEmpty ? null : _classNameController.text.trim(),
        'date_of_birth': _dobController.text.isEmpty ? null : _dobController.text.trim(),
        'gender': _selectedGender,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('USER_TERDAFTAR', style: TextStyle(fontFamily: 'Courier', color: Colors.black)),
            backgroundColor: Color(0xFFCCFF00),
          ),
        );
        Navigator.pop(context); // Tutup dialog
        _refreshUsers(); // Refresh list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ERROR: $e', style: const TextStyle(fontFamily: 'Courier')), backgroundColor: const Color(0xFFFF003C)),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showAddUserDialog() {
    _usernameController.clear();
    _passwordController.clear();
    _fullNameController.clear();
    _absentNumberController.clear();
    _classNameController.clear();
    _dobController.clear();
    _selectedRole = 'user';
    _selectedGender = 'Pria';

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: const Color(0xFFCCFF00), width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFCCFF00).withValues(alpha: 0.2),
                blurRadius: 20,
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ENTRI_USER_BARU',
                  style: TextStyle(
                    color: Color(0xFFCCFF00),
                    fontFamily: 'Courier',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _usernameController,
                  style: const TextStyle(color: Colors.white, fontFamily: 'Courier'),
                  decoration: const InputDecoration(
                    labelText: 'USERNAME *',
                    labelStyle: TextStyle(color: Colors.white54, fontFamily: 'Courier'),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                      borderRadius: BorderRadius.zero,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFCCFF00)),
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white, fontFamily: 'Courier'),
                  decoration: const InputDecoration(
                    labelText: 'PASSWORD *',
                    labelStyle: TextStyle(color: Colors.white54, fontFamily: 'Courier'),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                      borderRadius: BorderRadius.zero,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFCCFF00)),
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _fullNameController,
                  style: const TextStyle(color: Colors.white, fontFamily: 'Courier'),
                  decoration: const InputDecoration(
                    labelText: 'NAMA LENGKAP',
                    labelStyle: TextStyle(color: Colors.white54, fontFamily: 'Courier'),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                      borderRadius: BorderRadius.zero,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFCCFF00)),
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _classNameController,
                        style: const TextStyle(color: Colors.white, fontFamily: 'Courier'),
                        decoration: const InputDecoration(
                          labelText: 'KELAS',
                          labelStyle: TextStyle(color: Colors.white54, fontFamily: 'Courier'),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white24),
                            borderRadius: BorderRadius.zero,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFCCFF00)),
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _absentNumberController,
                        style: const TextStyle(color: Colors.white, fontFamily: 'Courier'),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'NO. ABSEN',
                          labelStyle: TextStyle(color: Colors.white54, fontFamily: 'Courier'),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white24),
                            borderRadius: BorderRadius.zero,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFCCFF00)),
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _dobController,
                  style: const TextStyle(color: Colors.white, fontFamily: 'Courier'),
                  decoration: const InputDecoration(
                    labelText: 'TGL LAHIR (YYYY-MM-DD)',
                    labelStyle: TextStyle(color: Colors.white54, fontFamily: 'Courier'),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                      borderRadius: BorderRadius.zero,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFCCFF00)),
                      borderRadius: BorderRadius.zero,
                    ),
                    hintText: '2005-08-17',
                    hintStyle: TextStyle(color: Colors.white24, fontFamily: 'Courier'),
                  ),
                  onTap: () async {
                    FocusScope.of(context).requestFocus(FocusNode());
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().subtract(const Duration(days: 365 * 15)),
                      firstDate: DateTime(1990),
                      lastDate: DateTime.now(),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: Color(0xFFCCFF00),
                              onPrimary: Colors.black,
                              surface: Colors.black,
                              onSurface: Colors.white,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (date != null) {
                      _dobController.text = date.toIso8601String().split('T')[0];
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedGender,
                  dropdownColor: const Color(0xFF1E1E1E),
                  style: const TextStyle(color: Colors.white, fontFamily: 'Courier'),
                  decoration: const InputDecoration(
                    labelText: 'JENIS KELAMIN',
                    labelStyle: TextStyle(color: Colors.white54, fontFamily: 'Courier'),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                      borderRadius: BorderRadius.zero,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFCCFF00)),
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Pria', child: Text('PRIA')),
                    DropdownMenuItem(value: 'Perempuan', child: Text('PEREMPUAN')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      _selectedGender = value;
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedRole,
                  dropdownColor: const Color(0xFF1E1E1E),
                  style: const TextStyle(color: Colors.white, fontFamily: 'Courier'),
                  decoration: const InputDecoration(
                    labelText: 'LEVEL_AKSES',
                    labelStyle: TextStyle(color: Colors.white54, fontFamily: 'Courier'),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                      borderRadius: BorderRadius.zero,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFCCFF00)),
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'user', child: Text('SISWA (USER)')),
                    DropdownMenuItem(value: 'secretary', child: Text('SEKRETARIS')),
                    DropdownMenuItem(value: 'admin', child: Text('ADMINISTRATOR')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      _selectedRole = value;
                    }
                  },
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'BATALKAN',
                        style: TextStyle(color: Colors.white54, fontFamily: 'Courier', fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _addUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCCFF00),
                        foregroundColor: Colors.black,
                        shape: const BeveledRectangleBorder(),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                          : const Text('EKSEKUSI', style: TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold)),
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

  Widget _buildThemeButton(String label, String role, Color color) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          AuthManager().setThemeOverride(role);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('MODE_VISUAL: $label', style: const TextStyle(fontFamily: 'Courier', color: Colors.black)),
              backgroundColor: color,
              duration: const Duration(seconds: 1),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withValues(alpha: 0.2),
          foregroundColor: color,
          side: BorderSide(color: color),
          shape: const BeveledRectangleBorder(),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Courier',
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          const Positioned.fill(
            child: CustomPaint(
              painter: GridPainter(),
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
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            color: const Color(0xFF7000FF),
                            child: const Text(
                              'KONSOL_ADMIN',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Courier',
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'MANAJEMEN_USER',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              fontFamily: 'Courier',
                              letterSpacing: -1,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Icon(Icons.admin_panel_settings_outlined, color: Color(0xFF7000FF)),
                      ),
                    ],
                  ),
                ),

                // Theme Preview Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'MODE_PREVIEW_TEMA',
                        style: TextStyle(
                          color: Colors.white54,
                          fontFamily: 'Courier',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _buildThemeButton('SISWA', 'user', const Color(0xFF00F0FF)),
                          const SizedBox(width: 10),
                          _buildThemeButton('SEKRETARIS', 'secretary', const Color(0xFFD4AF37)),
                          const SizedBox(width: 10),
                          _buildThemeButton('ADMIN', 'admin', const Color(0xFFCCFF00)),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white10, height: 32),

                // User List
                Expanded(
                  child: _isInitialLoad && _users.isEmpty
                      ? const Center(
                          child: Text(
                            'MENGAMBIL_DATA...',
                            style: TextStyle(color: Color(0xFFCCFF00), fontFamily: 'Courier'),
                          ),
                        )
                      : _users.isEmpty
                          ? const Center(child: Text('TIDAK_ADA_USER', style: TextStyle(color: Colors.white54, fontFamily: 'Courier')))
                          : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              itemCount: _users.length + (_hasMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == _users.length) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: CircularProgressIndicator(color: Color(0xFFCCFF00)),
                                    ),
                                  );
                                }
                                
                                final user = _users[index];
                                final role = user['role'] as String;
                                Color roleColor;
                                switch (role) {
                                  case 'admin':
                                    roleColor = const Color(0xFFFF003C);
                                  case 'secretary':
                                    roleColor = const Color(0xFFCCFF00);
                                  default:
                                    roleColor = const Color(0xFF00F0FF);
                                }

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E1E1E),
                                    border: Border(
                                      left: BorderSide(color: roleColor, width: 4),
                                    ),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    title: Text(
                                      user['username'] ?? 'UNKNOWN',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Courier',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'AKSES: ${role.toUpperCase()}',
                                      style: TextStyle(
                                        color: roleColor,
                                        fontFamily: 'Courier',
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.white24),
                                      onPressed: () async {
                                        try {
                                          await Supabase.instance.client.from('app_users').delete().eq('id', user['id']);
                                          if (context.mounted) {
                                            _refreshUsers();
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('USER_DIHAPUS', style: TextStyle(fontFamily: 'Courier', color: Colors.black)),
                                                backgroundColor: Color(0xFFCCFF00),
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('GAGAL: $e', style: const TextStyle(fontFamily: 'Courier')), backgroundColor: const Color(0xFFFF003C)),
                                            );
                                          }
                                        }
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddUserDialog,
        backgroundColor: const Color(0xFFCCFF00),
        foregroundColor: Colors.black,
        shape: const BeveledRectangleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
