import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:namer_app/profile_screen.dart';
import 'package:namer_app/auth_manager.dart';
import 'package:namer_app/events_screen.dart';
import 'package:namer_app/theme/app_theme.dart';
import 'package:namer_app/views/home_view.dart';
import 'package:namer_app/views/tasks_view.dart';
import 'package:namer_app/views/extra_view.dart';
import 'package:namer_app/widgets/featured_card.dart';
import 'package:namer_app/widgets/keep_alive_wrapper.dart';
import 'package:namer_app/widgets/slide_indexed_stack.dart';
import 'package:namer_app/services/notification_service.dart';
import 'dart:ui';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Error loading .env: $e");
  }

  try {
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? '',
      anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
    );
  } catch (e) {
    debugPrint("Error initializing Supabase: $e");
  }

  try {
    await AuthManager().init();
  } catch (e) {
    debugPrint("Error initializing AuthManager: $e");
  }
  
  try {
    // Initialize Notifications
    await NotificationService().init();
    // Schedule daily reminder (fire and forget to not block UI)
    NotificationService().scheduleDailyReminder();
  } catch (e) {
    debugPrint("Error initializing Notifications: $e");
  }

  runApp(const ModernApp());
}

class ModernApp extends StatelessWidget {
  const ModernApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AuthManager(),
      builder: (context, child) {
        final auth = AuthManager();
        final appTheme = AppTheme.getTheme(auth.currentTheme, gender: auth.gender);
        
        return AppThemeScope(
          theme: appTheme,
          child: MaterialApp(
            title: 'School App',
            debugShowCheckedModeBanner: false,
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
                child: child!,
              );
            },
            scrollBehavior: const MaterialScrollBehavior().copyWith(
              physics: const BouncingScrollPhysics(),
              dragDevices: {
                PointerDeviceKind.mouse,
                PointerDeviceKind.touch,
                PointerDeviceKind.stylus,
                PointerDeviceKind.trackpad,
              },
            ),
            themeMode: ThemeMode.dark,
            darkTheme: ThemeData(
              useMaterial3: true,
              pageTransitionsTheme: const PageTransitionsTheme(
                builders: {
                  TargetPlatform.android: ZoomPageTransitionsBuilder(),
                  TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                },
              ),
              colorScheme: ColorScheme.dark(
                primary: appTheme.primary,
                secondary: appTheme.secondary,
                surface: appTheme.surface,
                onSurface: appTheme.onSurface,
                error: appTheme.tertiary,
              ),
              scaffoldBackgroundColor: appTheme.background,
              cardColor: appTheme.surface,
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: false,
              ),
              textTheme: TextTheme(
                headlineMedium: TextStyle(
                  fontFamily: appTheme.fontFamily,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.5,
                  color: appTheme.onSurface,
                ),
                titleLarge: TextStyle(
                  fontFamily: appTheme.fontFamily,
                  fontWeight: FontWeight.bold,
                  color: appTheme.onSurface,
                ),
                bodyLarge: TextStyle(color: appTheme.onSurface.withValues(alpha: 0.7), fontFamily: appTheme.fontFamily),
                bodyMedium: TextStyle(color: appTheme.onSurface.withValues(alpha: 0.6), fontFamily: appTheme.fontFamily),
              ),
            ),
            home: const MainScreen(),
          ),
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AuthManager(),
      builder: (context, child) {
        final auth = AuthManager();
        final userRole = auth.role;
        final appTheme = AppTheme.getTheme(auth.currentTheme, gender: auth.gender);

        if (!auth.isLoggedIn) {
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
                // Decorative Background Elements
                if (appTheme.isCute) ...[
                  // Cute / Kawaii Decoration
                  // Handled by CutePainter now
                ] else if (!appTheme.isManly) ...[
                  Positioned(
                    top: -100,
                    right: -100,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: appTheme.primary.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -50,
                    left: -50,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: appTheme.secondary.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                ] else ...[
                  // Manly / Tech Decoration
                  // Handled by ManlyPainter now
                ],
                
                // Main Content
                SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: appTheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: appTheme.primary.withValues(alpha: 0.2)),
                              ),
                              child: Text(
                                appTheme.isBrutalist ? 'PORTAL AKADEMIK v2.0' : 'Portal Akademik v2.0',
                                style: TextStyle(
                                  color: appTheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  fontFamily: appTheme.fontFamily,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Kelola Kehidupan\nSekolahmu\ndengan Mudah.',
                              style: TextStyle(
                                fontFamily: appTheme.fontFamily,
                                fontWeight: FontWeight.w900,
                                fontSize: 48,
                                height: 1.1,
                                color: appTheme.onSurface,
                                letterSpacing: -1,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Platform all-in-one untuk jadwal, tugas, dan pelacakan akademik.',
                              style: TextStyle(
                                fontFamily: appTheme.fontFamily,
                                fontSize: 16,
                                color: appTheme.onSurface.withValues(alpha: 0.6),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const Spacer(),
                      
                      // Feature Carousel
                      SizedBox(
                        height: 160,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          children: [
                            FeatureCard(
                              theme: appTheme,
                              title: 'Jadwal Pintar',
                              desc: 'Sinkronisasi otomatis dengan kelasmu.',
                              icon: Icons.calendar_month_rounded,
                              color: appTheme.primary,
                            ),
                            const SizedBox(width: 16),
                            FeatureCard(
                              theme: appTheme,
                              title: 'Manajemen Tugas',
                              desc: 'Jangan pernah lewatkan deadline lagi.',
                              icon: Icons.check_circle_outline_rounded,
                              color: appTheme.secondary,
                            ),
                            const SizedBox(width: 16),
                            FeatureCard(
                              theme: appTheme,
                              title: 'Notifikasi',
                              desc: 'Tetap update dengan pemberitahuan.',
                              icon: Icons.notifications_none_rounded,
                              color: appTheme.tertiary,
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Login Button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: SizedBox(
                          width: double.infinity,
                          height: 64,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const ProfileScreen()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: appTheme.onSurface,
                              foregroundColor: appTheme.background,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Mulai Sekarang',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: appTheme.fontFamily,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(Icons.arrow_forward_rounded, color: appTheme.background),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        final tabs = <Widget>[
          const ProfileScreen(),
          const HomeView(),
          TasksView(canEdit: userRole == 'secretary'),
          const EventsView(),
          const ExtraView(),
        ];

        // Ensure index is valid
        if (_selectedIndex >= tabs.length) {
          _selectedIndex = 0;
        }

        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: MediaQuery.removeViewInsets(
            context: context,
            removeBottom: true,
            child: SlideIndexedStack(
              index: _selectedIndex,
              children: tabs.map((tab) => KeepAliveWrapper(child: tab)).toList(),
            ),
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: appTheme.onSurface.withValues(alpha: 0.1))),
              color: appTheme.surface,
            ),
            child: NavigationBar(
              backgroundColor: appTheme.surface,
              indicatorColor: appTheme.primary.withValues(alpha: 0.5),
              selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              destinations: [
                NavigationDestination(
                  icon: Icon(Icons.person_outline, color: appTheme.onSurface.withValues(alpha: 0.5)),
                  selectedIcon: Icon(Icons.person, color: appTheme.onSurface),
                  label: appTheme.isBrutalist ? 'AKUN' : 'Akun',
                ),
                NavigationDestination(
                  icon: Icon(Icons.home_outlined, color: appTheme.onSurface.withValues(alpha: 0.5)),
                  selectedIcon: Icon(Icons.home, color: appTheme.onSurface),
                  label: appTheme.isBrutalist ? 'BERANDA' : 'Beranda',
                ),
                NavigationDestination(
                  icon: Icon(Icons.assignment_outlined, color: appTheme.onSurface.withValues(alpha: 0.5)),
                  selectedIcon: Icon(Icons.assignment, color: appTheme.onSurface),
                  label: appTheme.isBrutalist ? 'TUGAS' : 'Tugas',
                ),
                NavigationDestination(
                  icon: Icon(Icons.event_note_outlined, color: appTheme.onSurface.withValues(alpha: 0.5)),
                  selectedIcon: Icon(Icons.event_note, color: appTheme.onSurface),
                  label: appTheme.isBrutalist ? 'ACARA' : 'Acara',
                ),
                NavigationDestination(
                  icon: Icon(Icons.widgets_outlined, color: appTheme.onSurface.withValues(alpha: 0.5)),
                  selectedIcon: Icon(Icons.widgets, color: appTheme.onSurface),
                  label: appTheme.isBrutalist ? 'EKSTRA' : 'Ekstra',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
