class AttendanceRecord {
  final String id;
  final String studentId;
  final String studentName;
  final String subject;
  final String teacherId;
  final String teacherName;
  final DateTime date;
  final String status; // 'present', 'absent', 'late'
  final String? attendanceCode;
  final String? notes;

  AttendanceRecord({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.subject,
    required this.teacherId,
    required this.teacherName,
    required this.date,
    required this.status,
    this.attendanceCode,
    this.notes,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'] ?? '',
      studentId: json['student_id'] ?? '',
      studentName: json['student_name'] ?? '',
      subject: json['subject'] ?? '',
      teacherId: json['teacher_id'] ?? '',
      teacherName: json['teacher_name'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? 'absent',
      attendanceCode: json['attendance_code'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'student_name': studentName,
      'subject': subject,
      'teacher_id': teacherId,
      'teacher_name': teacherName,
      'date': date.toIso8601String(),
      'status': status,
      'attendance_code': attendanceCode,
      'notes': notes,
    };
  }
}

class AttendanceCode {
  final String id;
  final String code;
  final String teacherId;
  final String teacherName;
  final String subject;
  final String? className;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isActive;
  final int? maxUses;
  final int currentUses;

  AttendanceCode({
    required this.id,
    required this.code,
    required this.teacherId,
    required this.teacherName,
    required this.subject,
    this.className,
    required this.createdAt,
    required this.expiresAt,
    required this.isActive,
    this.maxUses,
    required this.currentUses,
  });

  factory AttendanceCode.fromJson(Map<String, dynamic> json) {
    return AttendanceCode(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      teacherId: json['teacher_id'] ?? '',
      teacherName: json['teacher_name'] ?? '',
      subject: json['subject'] ?? '',
      className: json['class_name'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      expiresAt: DateTime.parse(json['expires_at'] ?? DateTime.now().add(const Duration(hours: 1)).toIso8601String()),
      isActive: json['is_active'] ?? true,
      maxUses: json['max_uses'],
      currentUses: json['current_uses'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'teacher_id': teacherId,
      'teacher_name': teacherName,
      'subject': subject,
      'class_name': className,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
      'is_active': isActive,
      'max_uses': maxUses,
      'current_uses': currentUses,
    };
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isMaxUsesReached => maxUses != null && currentUses >= maxUses!;
  bool get canBeUsed => isActive && !isExpired && !isMaxUsesReached;
}
