class User {
  final String id;
  final String email;
  final String name;
  final String role;
  final String? studentId;
  final String? department;
  final String? phone;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.studentId,
    this.department,
    this.phone,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      studentId: json['student_id'],
      department: json['department'],
      phone: json['phone'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'student_id': studentId,
      'department': department,
      'phone': phone,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

enum UserRole {
  student,
  teacher,
  admin,
  counselor,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.student:
        return 'Student';
      case UserRole.teacher:
        return 'Teacher';
      case UserRole.admin:
        return 'Admin';
      case UserRole.counselor:
        return 'Counselor';
    }
  }

  String get value {
    switch (this) {
      case UserRole.student:
        return 'student';
      case UserRole.teacher:
        return 'teacher';
      case UserRole.admin:
        return 'admin';
      case UserRole.counselor:
        return 'counselor';
    }
  }
}
