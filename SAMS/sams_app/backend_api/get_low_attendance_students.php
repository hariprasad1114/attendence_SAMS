<?php
require_once 'db_connect.php';

// Only allow GET requests
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendResponse([
        'success' => false,
        'message' => 'Only GET method allowed'
    ], 405);
}

// Get query parameters
$threshold = isset($_GET['threshold']) ? (float)$_GET['threshold'] : 75.0;

try {
    // Get students with attendance below threshold
    $query = "
        SELECT 
            u.id,
            u.name,
            u.email,
            u.student_id,
            u.department,
            u.phone,
            COUNT(a.id) as total_classes,
            SUM(CASE WHEN a.status = 'present' THEN 1 ELSE 0 END) as present_classes,
            ROUND(
                (SUM(CASE WHEN a.status = 'present' THEN 1 ELSE 0 END) * 100.0 / COUNT(a.id)), 2
            ) as attendance_percentage
        FROM users u
        LEFT JOIN attendance a ON u.id = a.student_id
        WHERE u.role = 'student'
        GROUP BY u.id, u.name, u.email, u.student_id, u.department, u.phone
        HAVING attendance_percentage < ? OR attendance_percentage IS NULL
        ORDER BY attendance_percentage ASC
    ";
    
    $stmt = $pdo->prepare($query);
    $stmt->execute([$threshold]);
    $lowAttendanceStudents = $stmt->fetchAll();

    // Format the response
    $formattedStudents = [];
    foreach ($lowAttendanceStudents as $student) {
        $formattedStudents[] = [
            'id' => $student['id'],
            'name' => $student['name'],
            'email' => $student['email'],
            'student_id' => $student['student_id'],
            'department' => $student['department'],
            'phone' => $student['phone'],
            'total_classes' => (int)$student['total_classes'],
            'present_classes' => (int)$student['present_classes'],
            'attendance_percentage' => $student['attendance_percentage'] ? (float)$student['attendance_percentage'] : 0.0
        ];
    }

    sendResponse([
        'success' => true,
        'students' => $formattedStudents,
        'total_count' => count($formattedStudents),
        'threshold' => $threshold
    ]);

} catch (PDOException $e) {
    sendResponse([
        'success' => false,
        'message' => 'Database error: ' . $e->getMessage()
    ], 500);
}
?>
