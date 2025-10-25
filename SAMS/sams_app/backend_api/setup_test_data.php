<?php
/**
 * SAMS Test Data Setup Script
 * This script creates test users and data for testing purposes
 */

require_once 'db_connect.php';

echo "🔧 SAMS Test Data Setup\n";
echo "=======================\n\n";

try {
    // Create test teacher
    $teacherData = [
        'name' => 'Dr. John Smith',
        'email' => 'teacher@test.com',
        'password' => 'password123',
        'role' => 'teacher',
        'department' => 'Mathematics'
    ];
    
    $teacherStmt = $pdo->prepare("
        INSERT INTO users (name, email, password, role, department, created_at) 
        VALUES (?, ?, ?, ?, ?, NOW())
    ");
    
    $teacherResult = $teacherStmt->execute([
        $teacherData['name'],
        $teacherData['email'],
        hashPassword($teacherData['password']),
        $teacherData['role'],
        $teacherData['department']
    ]);
    
    if ($teacherResult) {
        $teacherId = $pdo->lastInsertId();
        echo "✅ Test teacher created with ID: $teacherId\n";
    } else {
        echo "⚠️  Teacher might already exist\n";
        // Get existing teacher ID
        $existingTeacherStmt = $pdo->prepare("SELECT id FROM users WHERE email = ? AND role = 'teacher'");
        $existingTeacherStmt->execute([$teacherData['email']]);
        $teacher = $existingTeacherStmt->fetch();
        if ($teacher) {
            $teacherId = $teacher['id'];
            echo "✅ Using existing teacher ID: $teacherId\n";
        }
    }
    
    // Create test students
    $students = [
        [
            'name' => 'Alice Johnson',
            'email' => 'alice@student.com',
            'student_id' => 'ST001',
            'department' => 'Computer Science'
        ],
        [
            'name' => 'Bob Wilson',
            'email' => 'bob@student.com',
            'student_id' => 'ST002',
            'department' => 'Mathematics'
        ],
        [
            'name' => 'Carol Davis',
            'email' => 'carol@student.com',
            'student_id' => 'ST003',
            'department' => 'Physics'
        ]
    ];
    
    foreach ($students as $student) {
        $studentStmt = $pdo->prepare("
            INSERT INTO users (name, email, password, role, student_id, department, created_at) 
            VALUES (?, ?, ?, 'student', ?, ?, NOW())
        ");
        
        $studentResult = $studentStmt->execute([
            $student['name'],
            $student['email'],
            hashPassword('password123'),
            $student['student_id'],
            $student['department']
        ]);
        
        if ($studentResult) {
            echo "✅ Test student created: {$student['name']}\n";
        } else {
            echo "⚠️  Student might already exist: {$student['name']}\n";
        }
    }
    
    // Create test attendance codes
    if (isset($teacherId)) {
        $codes = [
            [
                'code' => 'MATH101',
                'subject' => 'Calculus',
                'class_name' => 'Class 10A',
                'max_uses' => 30
            ],
            [
                'code' => 'CS201',
                'subject' => 'Data Structures',
                'class_name' => 'Class 11B',
                'max_uses' => 25
            ]
        ];
        
        foreach ($codes as $codeData) {
            $codeStmt = $pdo->prepare("
                INSERT INTO attendance_codes (
                    code, teacher_id, teacher_name, subject, class_name, 
                    max_uses, current_uses, expires_at, is_active, created_at
                ) VALUES (?, ?, ?, ?, ?, ?, 0, DATE_ADD(NOW(), INTERVAL 2 HOUR), 1, NOW())
            ");
            
            $codeResult = $codeStmt->execute([
                $codeData['code'],
                $teacherId,
                'Dr. John Smith',
                $codeData['subject'],
                $codeData['class_name'],
                $codeData['max_uses']
            ]);
            
            if ($codeResult) {
                echo "✅ Test attendance code created: {$codeData['code']}\n";
            } else {
                echo "⚠️  Attendance code might already exist: {$codeData['code']}\n";
            }
        }
    }
    
    // Create some test attendance records
    $attendanceStmt = $pdo->prepare("
        INSERT INTO attendance (
            student_id, student_name, subject, teacher_id, teacher_name, 
            attendance_code, status, date, created_at
        ) VALUES (?, ?, ?, ?, ?, ?, 'present', DATE_SUB(NOW(), INTERVAL 1 DAY), NOW())
    ");
    
    // Get student IDs
    $studentStmt = $pdo->prepare("SELECT id, name FROM users WHERE role = 'student' LIMIT 3");
    $studentStmt->execute();
    $students = $studentStmt->fetchAll();
    
    foreach ($students as $student) {
        $attendanceResult = $attendanceStmt->execute([
            $student['id'],
            $student['name'],
            'Calculus',
            isset($teacherId) ? $teacherId : 1,
            'Dr. John Smith',
            'MATH101'
        ]);
        
        if ($attendanceResult) {
            echo "✅ Test attendance record created for: {$student['name']}\n";
        }
    }
    
    echo "\n🎉 Test data setup complete!\n";
    echo "\nTest Credentials:\n";
    echo "Teacher: teacher@test.com / password123\n";
    echo "Students: alice@student.com, bob@student.com, carol@student.com / password123\n";
    echo "Admin: admin@sams.com / password\n";
    
} catch (PDOException $e) {
    echo "❌ Database error: " . $e->getMessage() . "\n";
}
?>
