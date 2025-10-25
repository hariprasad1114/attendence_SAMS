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
$requiredFields = ['student_id', 'attendance_code'];
$missingFields = validateRequiredFields($requiredFields, $input);

if (!empty($missingFields)) {
    sendResponse([
        'success' => false,
        'message' => 'Missing required fields: ' . implode(', ', $missingFields)
    ], 400);
}

$studentId = sanitizeInput($input['student_id']);
$attendanceCode = sanitizeInput($input['attendance_code']);

try {
    // Validate student exists
    $studentStmt = $pdo->prepare("SELECT name FROM users WHERE id = ? AND role = 'student'");
    $studentStmt->execute([$studentId]);
    $student = $studentStmt->fetch();
    
    if (!$student) {
        sendResponse([
            'success' => false,
            'message' => 'Invalid student ID'
        ], 400);
    }
    
    $studentName = $student['name'];

    // Get attendance code details
    $codeStmt = $pdo->prepare("
        SELECT id, code, teacher_id, teacher_name, subject, class_name, 
               max_uses, current_uses, expires_at, is_active
        FROM attendance_codes 
        WHERE code = ? AND is_active = 1
    ");
    $codeStmt->execute([$attendanceCode]);
    $codeData = $codeStmt->fetch();

    if (!$codeData) {
        sendResponse([
            'success' => false,
            'message' => 'Invalid or inactive attendance code'
        ], 400);
    }

    // Check if code is expired
    $now = new DateTime();
    $expiresAt = new DateTime($codeData['expires_at']);
    
    if ($now > $expiresAt) {
        sendResponse([
            'success' => false,
            'message' => 'Attendance code has expired'
        ], 400);
    }

    // Check if max uses reached
    if ($codeData['max_uses'] && $codeData['current_uses'] >= $codeData['max_uses']) {
        sendResponse([
            'success' => false,
            'message' => 'Attendance code has reached maximum uses'
        ], 400);
    }

    // Check if student already marked attendance for this code
    $checkStmt = $pdo->prepare("
        SELECT id FROM attendance 
        WHERE student_id = ? AND attendance_code = ? AND DATE(date) = CURDATE()
    ");
    $checkStmt->execute([$studentId, $attendanceCode]);
    
    if ($checkStmt->fetch()) {
        sendResponse([
            'success' => false,
            'message' => 'Attendance already marked for this session'
        ], 409);
    }

    // Start transaction
    $pdo->beginTransaction();

    try {
        // Insert attendance record
        $attendanceStmt = $pdo->prepare("
            INSERT INTO attendance (
                student_id, student_name, subject, teacher_id, teacher_name, 
                attendance_code, status, date, created_at
            ) VALUES (?, ?, ?, ?, ?, ?, 'present', NOW(), NOW())
        ");
        
        $attendanceResult = $attendanceStmt->execute([
            $studentId,
            $studentName,
            $codeData['subject'],
            $codeData['teacher_id'],
            $codeData['teacher_name'],
            $attendanceCode
        ]);

        if (!$attendanceResult) {
            throw new Exception('Failed to insert attendance record');
        }

        // Update attendance code usage count
        $updateStmt = $pdo->prepare("
            UPDATE attendance_codes 
            SET current_uses = current_uses + 1 
            WHERE id = ?
        ");
        $updateStmt->execute([$codeData['id']]);

        // Check if max uses reached and deactivate if necessary
        if ($codeData['max_uses'] && ($codeData['current_uses'] + 1) >= $codeData['max_uses']) {
            $deactivateStmt = $pdo->prepare("UPDATE attendance_codes SET is_active = 0 WHERE id = ?");
            $deactivateStmt->execute([$codeData['id']]);
        }

        // Commit transaction
        $pdo->commit();

        sendResponse([
            'success' => true,
            'message' => 'Attendance marked successfully'
        ], 201);

    } catch (Exception $e) {
        // Rollback transaction
        $pdo->rollback();
        throw $e;
    }

} catch (PDOException $e) {
    sendResponse([
        'success' => false,
        'message' => 'Database error: ' . $e->getMessage()
    ], 500);
} catch (Exception $e) {
    sendResponse([
        'success' => false,
        'message' => $e->getMessage()
    ], 500);
}
?>
