import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../screens/login/login_screen.dart';
import '../screens/dashboards/student_dashboard.dart';
import '../screens/dashboards/teacher_dashboard.dart';
import '../screens/dashboards/admin_dashboard.dart';
import '../screens/dashboards/counselor_dashboard.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      // If not authenticated and not on login page, redirect to login
      if (!authService.isAuthenticated && state.uri.toString() != '/login') {
        return '/login';
      }
      
      // If authenticated and on login page, redirect to appropriate dashboard
      if (authService.isAuthenticated && state.uri.toString() == '/login') {
        return _getDashboardRoute(authService.currentUser!.role);
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/student-dashboard',
        builder: (context, state) => const StudentDashboard(),
      ),
      GoRoute(
        path: '/teacher-dashboard',
        builder: (context, state) => const TeacherDashboard(),
      ),
      GoRoute(
        path: '/admin-dashboard',
        builder: (context, state) => const AdminDashboard(),
      ),
      GoRoute(
        path: '/counselor-dashboard',
        builder: (context, state) => const CounselorDashboard(),
      ),
    ],
  );

  static String _getDashboardRoute(String role) {
    switch (role) {
      case 'student':
        return '/student-dashboard';
      case 'teacher':
        return '/teacher-dashboard';
      case 'admin':
        return '/admin-dashboard';
      case 'counselor':
        return '/counselor-dashboard';
      default:
        return '/login';
    }
  }
}
