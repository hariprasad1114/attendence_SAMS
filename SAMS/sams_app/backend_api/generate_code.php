<?php
require_once 'db_connect.php';

// Only allow POST requests
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendResponse([
        'success' => false,
        'message' => 'Only POST method allowed'
    ], 405);
}

// Get JSON input
$input = json_decode(file_get_contents('php://input'), true);

if (!$input) {
    sendResponse([
        'success' => false,
        'message' => 'Invalid JSON input'
    ], 400);
}

// Validate required fields
$requiredFields = ['teacher_id', 'subject'];
$missingFields = validateRequiredFields($requiredFields, $input);

if (!empty($missingFields)) {
    sendResponse([
        'success' => false,
        'message' => 'Missing required fields: ' . implode(', ', $missingFields)
    ], 400);
}

$teacherId = sanitizeInput($input['teacher_id']);
$subject = sanitizeInput($input['subject']);
$className = isset($input['class_name']) ? sanitizeInput($input['class_name']) : null;
$maxUses = isset($input['max_uses']) ? (int)$input['max_uses'] : null;
$expiresAt = isset($input['expires_at']) ? $input['expires_at'] : date('Y-m-d H:i:s', strtotime('+1 hour'));

// Validate teacher exists
try {
    $teacherStmt = $pdo->prepare("SELECT name FROM users WHERE id = ? AND role = 'teacher'");
    $teacherStmt->execute([$teacherId]);
    $teacher = $teacherStmt->fetch();
    
    if (!$teacher) {
        sendResponse([
            'success' => false,
            'message' => 'Invalid teacher ID'
        ], 400);
    }
    
    $teacherName = $teacher['name'];
    
} catch (PDOException $e) {
    sendResponse([
        'success' => false,
        'message' => 'Database error: ' . $e->getMessage()
    ], 500);
}

// Generate unique attendance code
$code = generateAttendanceCode(6);

// Ensure code is unique
do {
    $checkStmt = $pdo->prepare("SELECT id FROM attendance_codes WHERE code = ? AND is_active = 1");
    $checkStmt->execute([$code]);
    
    if ($checkStmt->fetch()) {
        $code = generateAttendanceCode(6);
    } else {
        break;
    }
} while (true);

try {
    // Insert attendance code
    $stmt = $pdo->prepare("
        INSERT INTO attendance_codes (
            code, teacher_id, teacher_name, subject, class_name, 
            max_uses, current_uses, expires_at, is_active, created_at
        ) VALUES (?, ?, ?, ?, ?, ?, 0, ?, 1, NOW())
    ");
    
    $result = $stmt->execute([
        $code,
        $teacherId,
        $teacherName,
        $subject,
        $className,
        $maxUses,
        $expiresAt
    ]);

    if ($result) {
        $codeId = $pdo->lastInsertId();
        
        // Get the created attendance code
        $codeStmt = $pdo->prepare("
            SELECT id, code, teacher_id, teacher_name, subject, class_name, 
                   max_uses, current_uses, expires_at, is_active, created_at
            FROM attendance_codes 
            WHERE id = ?
        ");
        $codeStmt->execute([$codeId]);
        $attendanceCode = $codeStmt->fetch();

        sendResponse([
            'success' => true,
            'message' => 'Attendance code generated successfully',
            'attendance_code' => $attendanceCode
        ], 201);
    } else {
        sendResponse([
            'success' => false,
            'message' => 'Failed to generate attendance code'
        ], 500);
    }

} catch (PDOException $e) {
    sendResponse([
        'success' => false,
        'message' => 'Database error: ' . $e->getMessage()
    ], 500);
}
?>
