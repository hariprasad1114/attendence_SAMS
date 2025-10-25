import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  AuthService() {
    _loadUserFromStorage();
  }

  Future<void> _loadUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('current_user');
      if (userJson != null) {
        _currentUser = User.fromJson(jsonDecode(userJson));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading user from storage: $e');
    }
  }

  Future<void> _saveUserToStorage(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_user', jsonEncode(user.toJson()));
    } catch (e) {
      debugPrint('Error saving user to storage: $e');
    }
  }

  Future<bool> login(String email, String password, String role) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await ApiService.login(email, password, role);
      
      if (response['success'] == true) {
        _currentUser = User.fromJson(response['user']);
        await _saveUserToStorage(_currentUser!);
        notifyListeners();
        return true;
      } else {
        _setError(response['message'] ?? 'Login failed');
        return false;
      }
    } catch (e) {
      _setError('Network error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_user');
    } catch (e) {
      debugPrint('Error clearing user storage: $e');
    }
    
    _currentUser = null;
    _clearError();
    notifyListeners();
  }

  Future<bool> updateProfile(Map<String, dynamic> updates) async {
    if (_currentUser == null) return false;

    _setLoading(true);
    _clearError();

    try {
      // Update user data
      _currentUser = User(
        id: _currentUser!.id,
        email: updates['email'] ?? _currentUser!.email,
        name: updates['name'] ?? _currentUser!.name,
        role: _currentUser!.role,
        studentId: updates['student_id'] ?? _currentUser!.studentId,
        department: updates['department'] ?? _currentUser!.department,
        phone: updates['phone'] ?? _currentUser!.phone,
        createdAt: _currentUser!.createdAt,
      );

      await _saveUserToStorage(_currentUser!);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update profile: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  // Helper methods for role checking
  bool isStudent() => _currentUser?.role == 'student';
  bool isTeacher() => _currentUser?.role == 'teacher';
  bool isAdmin() => _currentUser?.role == 'admin';
  bool isCounselor() => _currentUser?.role == 'counselor';

  // Get user display name
  String getDisplayName() => _currentUser?.name ?? 'Unknown User';
  
  // Get user role display name
  String getRoleDisplayName() {
    switch (_currentUser?.role) {
      case 'student':
        return 'Student';
      case 'teacher':
        return 'Teacher';
      case 'admin':
        return 'Admin';
      case 'counselor':
        return 'Counselor';
      default:
        return 'Unknown';
    }
  }
}
