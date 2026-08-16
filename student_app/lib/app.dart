import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/database/student_database.dart';
import 'package:provider/provider.dart';
import 'features/home/home_page.dart';
import 'features/profile/profile_page.dart';
import 'features/qr_display/student_qr_page.dart';
import 'features/join_class/join_class_page.dart';
import 'features/history/history_page.dart';

class StudentAttendanceApp extends StatelessWidget {
  const StudentAttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Student Attendance',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF1565C0),
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: const Color(0xFF1565C0),
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      routerConfig: _router,
    );
  }
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const _InitialRoute(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfilePage(),
    ),
    GoRoute(
      path: '/qr',
      builder: (context, state) => const StudentQrPage(),
    ),
    GoRoute(
      path: '/join',
      builder: (context, state) => const JoinClassPage(),
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const HistoryPage(),
    ),
  ],
);

class _InitialRoute extends StatelessWidget {
  const _InitialRoute();

  @override
  Widget build(BuildContext context) {
    final db = context.read<StudentDatabase>();

    return StreamBuilder<StudentProfileData?>(
      stream: db.watchProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final profile = snapshot.data;

        if (profile == null) {
          return const ProfilePage();
        }

        return const HomePage();
      },
    );
  }
}
