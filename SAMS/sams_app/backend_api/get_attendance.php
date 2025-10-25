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
$userId = isset($_GET['user_id']) ? sanitizeInput($_GET['user_id']) : null;
$subject = isset($_GET['subject']) ? sanitizeInput($_GET['subject']) : null;
$startDate = isset($_GET['start_date']) ? $_GET['start_date'] : null;
$endDate = isset($_GET['end_date']) ? $_GET['end_date'] : null;

if (!$userId) {
    sendResponse([
        'success' => false,
        'message' => 'User ID is required'
    ], 400);
}

try {
    // Validate user exists
    $userStmt = $pdo->prepare("SELECT role FROM users WHERE id = ?");
    $userStmt->execute([$userId]);
    $user = $userStmt->fetch();
    
    if (!$user) {
        sendResponse([
            'success' => false,
            'message' => 'Invalid user ID'
        ], 400);
    }

    $userRole = $user['role'];

    // Build query based on user role
    if ($userRole === 'student') {
        // For students, get their attendance records
        $query = "
            SELECT a.id, a.student_id, a.student_name, a.subject, 
                   a.teacher_id, a.teacher_name, a.status, a.attendance_code, 
                   a.date, a.created_at
            FROM attendance a
            WHERE a.student_id = ?
        ";
        $params = [$userId];
    } else if ($userRole === 'teacher') {
        // For teachers, get attendance records for their classes
        $query = "
            SELECT a.id, a.student_id, a.student_name, a.subject, 
                   a.teacher_id, a.teacher_name, a.status, a.attendance_code, 
                   a.date, a.created_at
            FROM attendance a
            WHERE a.teacher_id = ?
        ";
        $params = [$userId];
    } else {
        // For admin/counselor, get all attendance records
        $query = "
            SELECT a.id, a.student_id, a.student_name, a.subject, 
                   a.teacher_id, a.teacher_name, a.status, a.attendance_code, 
                   a.date, a.created_at
            FROM attendance a
            WHERE 1=1
        ";
        $params = [];
    }

    // Add filters
    if ($subject && $subject !== 'All') {
        $query .= " AND a.subject = ?";
        $params[] = $subject;
    }

    if ($startDate) {
        $query .= " AND DATE(a.date) >= ?";
        $params[] = $startDate;
    }

    if ($endDate) {
        $query .= " AND DATE(a.date) <= ?";
        $params[] = $endDate;
    }

    // Order by date descending
    $query .= " ORDER BY a.date DESC";

    // Execute query
    $stmt = $pdo->prepare($query);
    $stmt->execute($params);
    $attendanceRecords = $stmt->fetchAll();

    // Format the response
    $formattedRecords = [];
    foreach ($attendanceRecords as $record) {
        $formattedRecords[] = [
            'id' => $record['id'],
            'student_id' => $record['student_id'],
            'student_name' => $record['student_name'],
            'subject' => $record['subject'],
            'teacher_id' => $record['teacher_id'],
            'teacher_name' => $record['teacher_name'],
            'status' => $record['status'],
            'attendance_code' => $record['attendance_code'],
            'date' => $record['date'],
            'created_at' => $record['created_at']
        ];
    }

    sendResponse([
        'success' => true,
        'attendance' => $formattedRecords,
        'total_records' => count($formattedRecords)
    ]);

} catch (PDOException $e) {
    sendResponse([
        'success' => false,
        'message' => 'Database error: ' . $e->getMessage()
    ], 500);
}
?>
