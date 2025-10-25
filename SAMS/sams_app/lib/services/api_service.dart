import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/attendance.dart';

class ApiService {
  static const String baseUrl = 'http://localhost/backend_api';
  
  // Headers
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Authentication
  static Future<Map<String, dynamic>> login(String email, String password, String role) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login.php'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'password': password,
          'role': role,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Login failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // User Management
  static Future<List<User>> getUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_users.php'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return (data['users'] as List)
              .map((user) => User.fromJson(user))
              .toList();
        }
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch users: $e');
    }
  }

  static Future<bool> addUser(User user, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register_user.php'),
        headers: _headers,
        body: jsonEncode({
          ...user.toJson(),
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      throw Exception('Failed to add user: $e');
    }
  }

  // Attendance Management
  static Future<List<AttendanceRecord>> getAttendanceRecords(String userId, {String? subject, DateTime? startDate, DateTime? endDate}) async {
    try {
      final queryParams = <String, String>{
        'user_id': userId,
        if (subject != null) 'subject': subject,
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
      };

      final uri = Uri.parse('$baseUrl/get_attendance.php').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return (data['attendance'] as List)
              .map((record) => AttendanceRecord.fromJson(record))
              .toList();
        }
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch attendance records: $e');
    }
  }

  static Future<bool> markAttendance(String studentId, String attendanceCode) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/mark_attendance.php'),
        headers: _headers,
        body: jsonEncode({
          'student_id': studentId,
          'attendance_code': attendanceCode,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      throw Exception('Failed to mark attendance: $e');
    }
  }

  // Attendance Code Management
  static Future<AttendanceCode> generateAttendanceCode(String teacherId, String subject, {String? className, int? maxUses, Duration? validity}) async {
    try {
      final validityDuration = validity ?? const Duration(hours: 1);
      final expiresAt = DateTime.now().add(validityDuration);

      final response = await http.post(
        Uri.parse('$baseUrl/generate_code.php'),
        headers: _headers,
        body: jsonEncode({
          'teacher_id': teacherId,
          'subject': subject,
          'class_name': className,
          'max_uses': maxUses,
          'expires_at': expiresAt.toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return AttendanceCode.fromJson(data['attendance_code']);
        }
      }
      throw Exception('Failed to generate attendance code');
    } catch (e) {
      throw Exception('Failed to generate attendance code: $e');
    }
  }

  static Future<bool> validateAttendanceCode(String code) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/validate_code.php'),
        headers: _headers,
        body: jsonEncode({'code': code}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['valid'] ?? false;
      }
      return false;
    } catch (e) {
      throw Exception('Failed to validate attendance code: $e');
    }
  }

  // Reports
  static Future<Map<String, dynamic>> getAttendanceReport(String userId, {String? subject, DateTime? startDate, DateTime? endDate}) async {
    try {
      final queryParams = <String, String>{
        'user_id': userId,
        if (subject != null) 'subject': subject,
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
      };

      final uri = Uri.parse('$baseUrl/reports.php').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Failed to fetch attendance report');
    } catch (e) {
      throw Exception('Failed to fetch attendance report: $e');
    }
  }

  static Future<List<User>> getLowAttendanceStudents(double threshold) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_low_attendance_students.php?threshold=$threshold'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return (data['students'] as List)
              .map((student) => User.fromJson(student))
              .toList();
        }
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch low attendance students: $e');
    }
  }
}
