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
$reportType = isset($_GET['report_type']) ? sanitizeInput($_GET['report_type']) : 'attendance';

try {
    $reportData = [];

    switch ($reportType) {
        case 'attendance':
            $reportData = getAttendanceReport($pdo, $userId, $subject, $startDate, $endDate);
            break;
        case 'users':
            $reportData = getUserReport($pdo);
            break;
        case 'low_attendance':
            $reportData = getLowAttendanceReport($pdo);
            break;
        default:
            sendResponse([
                'success' => false,
                'message' => 'Invalid report type'
            ], 400);
    }

    sendResponse([
        'success' => true,
        'report_type' => $reportType,
        'data' => $reportData,
        'generated_at' => date('Y-m-d H:i:s')
    ]);

} catch (PDOException $e) {
    sendResponse([
        'success' => false,
        'message' => 'Database error: ' . $e->getMessage()
    ], 500);
}

function getAttendanceReport($pdo, $userId, $subject, $startDate, $endDate) {
    $query = "
        SELECT 
            COUNT(*) as total_classes,
            SUM(CASE WHEN status = 'present' THEN 1 ELSE 0 END) as present_classes,
            SUM(CASE WHEN status = 'absent' THEN 1 ELSE 0 END) as absent_classes,
            SUM(CASE WHEN status = 'late' THEN 1 ELSE 0 END) as late_classes,
            ROUND(
                (SUM(CASE WHEN status = 'present' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 2
            ) as attendance_percentage
        FROM attendance 
        WHERE 1=1
    ";
    $params = [];

    if ($userId) {
        $query .= " AND student_id = ?";
        $params[] = $userId;
    }

    if ($subject && $subject !== 'All') {
        $query .= " AND subject = ?";
        $params[] = $subject;
    }

    if ($startDate) {
        $query .= " AND DATE(date) >= ?";
        $params[] = $startDate;
    }

    if ($endDate) {
        $query .= " AND DATE(date) <= ?";
        $params[] = $endDate;
    }

    $stmt = $pdo->prepare($query);
    $stmt->execute($params);
    $summary = $stmt->fetch();

    // Get daily attendance breakdown
    $dailyQuery = "
        SELECT 
            DATE(date) as attendance_date,
            COUNT(*) as total_classes,
            SUM(CASE WHEN status = 'present' THEN 1 ELSE 0 END) as present_classes,
            ROUND(
                (SUM(CASE WHEN status = 'present' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 2
            ) as daily_percentage
        FROM attendance 
        WHERE 1=1
    ";
    
    $dailyParams = [];
    if ($userId) {
        $dailyQuery .= " AND student_id = ?";
        $dailyParams[] = $userId;
    }
    if ($subject && $subject !== 'All') {
        $dailyQuery .= " AND subject = ?";
        $dailyParams[] = $subject;
    }
    if ($startDate) {
        $dailyQuery .= " AND DATE(date) >= ?";
        $dailyParams[] = $startDate;
    }
    if ($endDate) {
        $dailyQuery .= " AND DATE(date) <= ?";
        $dailyParams[] = $endDate;
    }
    
    $dailyQuery .= " GROUP BY DATE(date) ORDER BY attendance_date DESC";
    
    $dailyStmt = $pdo->prepare($dailyQuery);
    $dailyStmt->execute($dailyParams);
    $dailyBreakdown = $dailyStmt->fetchAll();

    return [
        'summary' => $summary,
        'daily_breakdown' => $dailyBreakdown
    ];
}

function getUserReport($pdo) {
    // Get user statistics by role
    $roleQuery = "
        SELECT 
            role,
            COUNT(*) as count
        FROM users 
        GROUP BY role
    ";
    $roleStmt = $pdo->prepare($roleQuery);
    $roleStmt->execute();
    $roleStats = $roleStmt->fetchAll();

    // Get department statistics
    $deptQuery = "
        SELECT 
            department,
            COUNT(*) as count
        FROM users 
        WHERE department IS NOT NULL
        GROUP BY department
        ORDER BY count DESC
    ";
    $deptStmt = $pdo->prepare($deptQuery);
    $deptStmt->execute();
    $deptStats = $deptStmt->fetchAll();

    // Get recent registrations
    $recentQuery = "
        SELECT 
            name, email, role, department, created_at
        FROM users 
        ORDER BY created_at DESC 
        LIMIT 10
    ";
    $recentStmt = $pdo->prepare($recentQuery);
    $recentStmt->execute();
    $recentUsers = $recentStmt->fetchAll();

    return [
        'role_statistics' => $roleStats,
        'department_statistics' => $deptStats,
        'recent_registrations' => $recentUsers
    ];
}

function getLowAttendanceReport($pdo) {
    // Get students with low attendance (< 75%)
    $query = "
        SELECT 
            u.id,
            u.name,
            u.email,
            u.student_id,
            u.department,
            COUNT(a.id) as total_classes,
            SUM(CASE WHEN a.status = 'present' THEN 1 ELSE 0 END) as present_classes,
            ROUND(
                (SUM(CASE WHEN a.status = 'present' THEN 1 ELSE 0 END) * 100.0 / COUNT(a.id)), 2
            ) as attendance_percentage
        FROM users u
        LEFT JOIN attendance a ON u.id = a.student_id
        WHERE u.role = 'student'
        GROUP BY u.id, u.name, u.email, u.student_id, u.department
        HAVING attendance_percentage < 75 OR attendance_percentage IS NULL
        ORDER BY attendance_percentage ASC
    ";
    
    $stmt = $pdo->prepare($query);
    $stmt->execute();
    $lowAttendanceStudents = $stmt->fetchAll();

    return [
        'low_attendance_students' => $lowAttendanceStudents,
        'total_low_attendance' => count($lowAttendanceStudents)
    ];
}
?>
