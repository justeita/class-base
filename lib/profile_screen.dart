import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:namer_app/auth_manager.dart';
import 'package:namer_app/theme/app_theme.dart'; // Import for GridPainter

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (AuthManager().isLoggedIn) {
      _refreshUserProfile();
    }
  }

  Future<void> _refreshUserProfile() async {
    final auth = AuthManager();
    if (!auth.isLoggedIn || auth.userId == null) return;

    try {
      final response = await Supabase.instance.client
          .from('app_users')
          .select()
          .eq('id', auth.userId!)
          .maybeSingle();

      if (response != null) {
        await auth.updateProfile(
          fullName: response['full_name'],
          absentNumber: response['absent_number'],
          className: response['class_name'],
          dateOfBirth: response['date_of_birth'],
          gender: response['gender'],
        );
        
        if (mounted) setState(() {});
      }
    } catch (e) {
      debugPrint('Error refreshing profile: $e');
    }
  }

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
    });
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    try {
      final hashedPassword = AuthManager.hashPassword(password);
      
      final response = await Supabase.instance.client
          .from('app_users')
          .select()
          .eq('username', username)
          .eq('password', hashedPassword)
          .maybeSingle();

      if (response != null) {
        if (mounted) {
          Navigator.of(context).pop();
        }

        await AuthManager().login(
          response['id'],
          response['username'],
          response['role'],
          fullName: response['full_name'],
          absentNumber: response['absent_number'],
          className: response['class_name'],
          dateOfBirth: response['date_of_birth'],
          gender: response['gender'],
        );
      } else {
        throw 'AKSES_DITOLAK: KREDENSIAL_TIDAK_VALID';
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString(), style: const TextStyle(fontFamily: 'Courier')),
            backgroundColor: const Color(0xFFFF003C),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signOut() async {
    await AuthManager().logout();
    if (mounted) {
      setState(() {});
    }
  }

  String _calculateAge(String? dateOfBirth) {
    if (dateOfBirth == null) return '-';
    try {
      final dob = DateTime.parse(dateOfBirth);
      final now = DateTime.now();
      int age = now.year - dob.year;
      if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
        age--;
      }
      return age.toString();
    } catch (e) {
      return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthManager();
    final theme = AppTheme.getTheme(auth.currentTheme, gender: auth.gender);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: theme.background,
      body: MediaQuery.removeViewInsets(
        context: context,
        removeBottom: true,
        child: Stack(
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
              child: auth.isLoggedIn
                  ? _buildProfileView(context, auth, theme)
                  : _buildLoginView(context, theme),
            ),
            Positioned(
              top: 0,
              left: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.onSurface.withValues(alpha: 0.24)),
                        borderRadius: theme.isBrutalist ? null : BorderRadius.circular(8),
                        color: theme.surface,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.arrow_back, color: theme.onSurface, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            theme.isBrutalist ? 'KEMBALI' : 'Kembali',
                            style: TextStyle(
                              color: theme.onSurface,
                              fontFamily: theme.fontFamily,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileView(BuildContext context, AuthManager auth, AppTheme theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(color: theme.primary, width: 2),
                borderRadius: theme.isBrutalist ? null : BorderRadius.circular(60),
                color: theme.surface,
              ),
              child: Icon(Icons.person, size: 64, color: theme.primary),
            ),
          ),
          const SizedBox(height: 32),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.surface,
              border: theme.isBrutalist ? Border.all(color: theme.onSurface.withValues(alpha: 0.24)) : null,
              borderRadius: theme.isBrutalist ? null : BorderRadius.circular(16),
              boxShadow: theme.isBrutalist ? null : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  theme.isBrutalist ? 'USERNAME' : 'Username',
                  style: TextStyle(
                    color: theme.onSurface.withValues(alpha: 0.54),
                    fontFamily: theme.fontFamily,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  auth.username.toUpperCase(),
                  style: TextStyle(
                    color: theme.onSurface,
                    fontFamily: theme.fontFamily,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Full Name
                Text(
                  theme.isBrutalist ? 'NAMA LENGKAP' : 'Nama Lengkap',
                  style: TextStyle(
                    color: theme.onSurface.withValues(alpha: 0.54),
                    fontFamily: theme.fontFamily,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  (auth.fullName ?? '-').toUpperCase(),
                  style: TextStyle(
                    color: theme.onSurface,
                    fontFamily: theme.fontFamily,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 16),

                // Gender
                Text(
                  theme.isBrutalist ? 'JENIS KELAMIN' : 'Jenis Kelamin',
                  style: TextStyle(
                    color: theme.onSurface.withValues(alpha: 0.54),
                    fontFamily: theme.fontFamily,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  (auth.gender ?? '-').toUpperCase(),
                  style: TextStyle(
                    color: theme.onSurface,
                    fontFamily: theme.fontFamily,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            theme.isBrutalist ? 'KELAS' : 'Kelas',
                            style: TextStyle(
                              color: theme.onSurface.withValues(alpha: 0.54),
                              fontFamily: theme.fontFamily,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            (auth.className ?? '-').toUpperCase(),
                            style: TextStyle(
                              color: theme.onSurface,
                              fontFamily: theme.fontFamily,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            theme.isBrutalist ? 'NO. ABSEN' : 'No. Absen',
                            style: TextStyle(
                              color: theme.onSurface.withValues(alpha: 0.54),
                              fontFamily: theme.fontFamily,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            auth.absentNumber ?? '-',
                            style: TextStyle(
                              color: theme.onSurface,
                              fontFamily: theme.fontFamily,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            theme.isBrutalist ? 'UMUR' : 'Umur',
                            style: TextStyle(
                              color: theme.onSurface.withValues(alpha: 0.54),
                              fontFamily: theme.fontFamily,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_calculateAge(auth.dateOfBirth)} TAHUN',
                            style: TextStyle(
                              color: theme.onSurface,
                              fontFamily: theme.fontFamily,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                Text(
                  theme.isBrutalist ? 'LEVEL_AKSES' : 'Level Akses',
                  style: TextStyle(
                    color: theme.onSurface.withValues(alpha: 0.54),
                    fontFamily: theme.fontFamily,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  auth.role.toUpperCase(),
                  style: TextStyle(
                    color: auth.role == 'admin' ? theme.tertiary : theme.secondary,
                    fontFamily: theme.fontFamily,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _signOut,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.tertiary,
                foregroundColor: Colors.white,
                shape: theme.isBrutalist ? const BeveledRectangleBorder() : RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 20),
              ),
              child: Text(
                theme.isBrutalist ? 'AKHIRI SESI' : 'Keluar',
                style: TextStyle(
                  fontFamily: theme.fontFamily,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginView(BuildContext context, AppTheme theme) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.lock_outline,
              size: 64,
              color: theme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              theme.isBrutalist ? 'PERMINTAAN AKSES' : 'Masuk',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: theme.fontFamily,
                fontWeight: FontWeight.w900,
                fontSize: 24,
                color: theme.onSurface,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              theme.isBrutalist ? 'MASUKKAN KREDENSIAL UNTUK LANJUT' : 'Masukkan username dan password untuk lanjut',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: theme.fontFamily,
                fontSize: 12,
                color: theme.onSurface.withValues(alpha: 0.54),
              ),
            ),
            const SizedBox(height: 48),
            TextField(
              controller: _usernameController,
              style: TextStyle(color: theme.onSurface, fontFamily: theme.fontFamily),
              decoration: InputDecoration(
                labelText: theme.isBrutalist ? 'USERNAME' : 'Username',
                labelStyle: TextStyle(color: theme.onSurface.withValues(alpha: 0.54), fontFamily: theme.fontFamily),
                prefixIcon: Icon(Icons.person_outline, color: theme.primary),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: theme.onSurface.withValues(alpha: 0.24)),
                  borderRadius: theme.isBrutalist ? BorderRadius.zero : BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: theme.primary),
                  borderRadius: theme.isBrutalist ? BorderRadius.zero : BorderRadius.circular(12),
                ),
                filled: !theme.isBrutalist,
                fillColor: theme.surface,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              style: TextStyle(color: theme.onSurface, fontFamily: theme.fontFamily),
              decoration: InputDecoration(
                labelText: theme.isBrutalist ? 'PASSWORD' : 'Password',
                labelStyle: TextStyle(color: theme.onSurface.withValues(alpha: 0.54), fontFamily: theme.fontFamily),
                prefixIcon: Icon(Icons.lock_outline, color: theme.primary),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: theme.onSurface.withValues(alpha: 0.24)),
                  borderRadius: theme.isBrutalist ? BorderRadius.zero : BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: theme.primary),
                  borderRadius: theme.isBrutalist ? BorderRadius.zero : BorderRadius.circular(12),
                ),
                filled: !theme.isBrutalist,
                fillColor: theme.surface,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 60,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _signIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primary,
                  foregroundColor: theme.isBrutalist ? Colors.black : Colors.white,
                  shape: theme.isBrutalist ? const BeveledRectangleBorder() : RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : Text(
                        theme.isBrutalist ? 'AUTENTIKASI' : 'Masuk',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: theme.fontFamily,
                          letterSpacing: 2,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
