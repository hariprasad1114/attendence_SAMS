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
$requiredFields = ['code'];
$missingFields = validateRequiredFields($requiredFields, $input);

if (!empty($missingFields)) {
    sendResponse([
        'success' => false,
        'message' => 'Missing required fields: ' . implode(', ', $missingFields)
    ], 400);
}

$code = sanitizeInput($input['code']);

try {
    // Get attendance code details
    $stmt = $pdo->prepare("
        SELECT id, code, teacher_id, teacher_name, subject, class_name, 
               max_uses, current_uses, expires_at, is_active, created_at
        FROM attendance_codes 
        WHERE code = ? AND is_active = 1
    ");
    $stmt->execute([$code]);
    $attendanceCode = $stmt->fetch();

    if (!$attendanceCode) {
        sendResponse([
            'valid' => false,
            'message' => 'Invalid or inactive attendance code'
        ]);
    }

    // Check if code is expired
    $now = new DateTime();
    $expiresAt = new DateTime($attendanceCode['expires_at']);
    
    if ($now > $expiresAt) {
        // Mark code as inactive
        $updateStmt = $pdo->prepare("UPDATE attendance_codes SET is_active = 0 WHERE id = ?");
        $updateStmt->execute([$attendanceCode['id']]);
        
        sendResponse([
            'valid' => false,
            'message' => 'Attendance code has expired'
        ]);
    }

    // Check if max uses reached
    if ($attendanceCode['max_uses'] && $attendanceCode['current_uses'] >= $attendanceCode['max_uses']) {
        // Mark code as inactive
        $updateStmt = $pdo->prepare("UPDATE attendance_codes SET is_active = 0 WHERE id = ?");
        $updateStmt->execute([$attendanceCode['id']]);
        
        sendResponse([
            'valid' => false,
            'message' => 'Attendance code has reached maximum uses'
        ]);
    }

    sendResponse([
        'valid' => true,
        'message' => 'Attendance code is valid',
        'attendance_code' => $attendanceCode
    ]);

} catch (PDOException $e) {
    sendResponse([
        'valid' => false,
        'message' => 'Database error: ' . $e->getMessage()
    ], 500);
}
?>
