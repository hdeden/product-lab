import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth/auth_page.dart';
import 'config.dart';
import 'home_page.dart';
import 'attendance_page.dart';
import 'profile_page.dart';
import 'main_shell.dart';
import 'payslip/payslip_detail_page.dart';
import 'payslip/payslip_page.dart';
import 'requests/leave_request_page.dart';
import 'requests/late_early_request_page.dart';
import 'requests/overtime_request_page.dart';
import 'requests/request_status_page.dart';
import 'requests/requests_page.dart';
import 'attendance/attendance_clock_page.dart';
import 'attendance/attendance_history_page.dart';
import 'ui/hris_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: hrisBlue,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: hrisGray50,
      useMaterial3: true,
    );

    return MaterialApp(
      title: 'HRIS',
      theme: baseTheme.copyWith(
        textTheme: GoogleFonts.spaceGroteskTextTheme(baseTheme.textTheme),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: const Color(0xFF1E2A32),
          elevation: 0,
          titleTextStyle: GoogleFonts.spaceGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E2A32),
          ),
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF0E9E1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: baseTheme.colorScheme.primary,
              width: 1.4,
            ),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
      home: const AuthGate(),
      routes: {
        '/login': (context) => const AuthPage(),
        ProfilePage.routeName: (context) => const ProfilePage(),
        AttendancePage.routeName: (context) => const AttendancePage(),
        RequestsPage.routeName: (context) => const RequestsPage(),
        LeaveRequestPage.routeName: (context) => const LeaveRequestPage(),
        OvertimeRequestPage.routeName: (context) => const OvertimeRequestPage(),
        LateEarlyRequestPage.routeName: (context) =>
            const LateEarlyRequestPage(),
        RequestStatusPage.routeName: (context) => const RequestStatusPage(),
        PayslipPage.routeName: (context) => const PayslipPage(),
        AttendanceHistoryPage.routeName: (context) =>
            const AttendanceHistoryPage(),
        AttendanceClockPage.routeName: (context) => const AttendanceClockPage(),
      },
      onGenerateRoute: (settings) {
        final name = settings.name ?? '';
        if (name.startsWith(PayslipDetailPage.routePrefix)) {
          final payslipId =
              name.substring(PayslipDetailPage.routePrefix.length);
          return MaterialPageRoute(
            builder: (_) => PayslipDetailPage(payslipId: payslipId),
          );
        }
        return null;
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.data?.session;
        if (session == null) {
          //return const AuthPage();
          return const MainShell();
        }
        return const MainShell();
      },
    );
  }
}
