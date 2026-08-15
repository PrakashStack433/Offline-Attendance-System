import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'features/classes/class_list_page.dart';
import 'features/classes/class_form_page.dart';
import 'features/classes/class_detail_page.dart';
import 'features/students/student_form_page.dart';
import 'features/attendance/take_attendance_page.dart';
import 'features/attendance/attendance_history_page.dart';
import 'features/export/export_page.dart';

class AttendanceApp extends StatelessWidget {
  const AttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Offline Attendance',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF1B5E20),
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: const Color(0xFF1B5E20),
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
      builder: (context, state) => const ClassListPage(),
    ),
    GoRoute(
      path: '/class/new',
      builder: (context, state) => ClassFormPage(
        existingClassId: state.uri.queryParameters['edit'],
      ),
    ),
    GoRoute(
      path: '/class/:id',
      builder: (context, state) => ClassDetailPage(
        classId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/class/:classId/student/new',
      builder: (context, state) => StudentFormPage(
        classId: state.pathParameters['classId']!,
      ),
    ),
    GoRoute(
      path: '/class/:classId/student/:studentId/edit',
      builder: (context, state) => StudentFormPage(
        classId: state.pathParameters['classId']!,
        studentId: state.pathParameters['studentId'],
      ),
    ),
    GoRoute(
      path: '/class/:classId/attendance',
      builder: (context, state) => TakeAttendancePage(
        classId: state.pathParameters['classId']!,
      ),
    ),
    GoRoute(
      path: '/class/:classId/history',
      builder: (context, state) => AttendanceHistoryPage(
        classId: state.pathParameters['classId']!,
      ),
    ),
    GoRoute(
      path: '/export',
      builder: (context, state) => const ExportPage(),
    ),
  ],
);
