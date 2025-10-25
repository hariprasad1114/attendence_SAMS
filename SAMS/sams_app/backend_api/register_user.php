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
$requiredFields = ['name', 'email', 'password', 'role'];
$missingFields = validateRequiredFields($requiredFields, $input);

if (!empty($missingFields)) {
    sendResponse([
        'success' => false,
        'message' => 'Missing required fields: ' . implode(', ', $missingFields)
    ], 400);
}

$name = sanitizeInput($input['name']);
$email = sanitizeInput($input['email']);
$password = $input['password'];
$role = sanitizeInput($input['role']);
$studentId = isset($input['student_id']) ? sanitizeInput($input['student_id']) : null;
$department = isset($input['department']) ? sanitizeInput($input['department']) : null;
$phone = isset($input['phone']) ? sanitizeInput($input['phone']) : null;

// Validate email format
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    sendResponse([
        'success' => false,
        'message' => 'Invalid email format'
    ], 400);
}

// Validate password strength
if (strlen($password) < 6) {
    sendResponse([
        'success' => false,
        'message' => 'Password must be at least 6 characters long'
    ], 400);
}

// Validate role
$validRoles = ['student', 'teacher', 'admin', 'counselor'];
if (!in_array($role, $validRoles)) {
    sendResponse([
        'success' => false,
        'message' => 'Invalid role. Must be one of: ' . implode(', ', $validRoles)
    ], 400);
}

try {
    // Check if email already exists
    $checkStmt = $pdo->prepare("SELECT id FROM users WHERE email = ?");
    $checkStmt->execute([$email]);
    
    if ($checkStmt->fetch()) {
        sendResponse([
            'success' => false,
            'message' => 'Email already exists'
        ], 409);
    }

    // Check if student_id already exists (for students)
    if ($role === 'student' && $studentId) {
        $checkStudentStmt = $pdo->prepare("SELECT id FROM users WHERE student_id = ?");
        $checkStudentStmt->execute([$studentId]);
        
        if ($checkStudentStmt->fetch()) {
            sendResponse([
                'success' => false,
                'message' => 'Student ID already exists'
            ], 409);
        }
    }

    // Hash password
    $hashedPassword = hashPassword($password);

    // Insert new user
    $stmt = $pdo->prepare("
        INSERT INTO users (name, email, password, role, student_id, department, phone, created_at) 
        VALUES (?, ?, ?, ?, ?, ?, ?, NOW())
    ");
    
    $result = $stmt->execute([
        $name, 
        $email, 
        $hashedPassword, 
        $role, 
        $studentId, 
        $department, 
        $phone
    ]);

    if ($result) {
        $userId = $pdo->lastInsertId();
        
        // Get the created user (without password)
        $userStmt = $pdo->prepare("
            SELECT id, name, email, role, student_id, department, phone, created_at 
            FROM users 
            WHERE id = ?
        ");
        $userStmt->execute([$userId]);
        $user = $userStmt->fetch();

        sendResponse([
            'success' => true,
            'message' => 'User registered successfully',
            'user' => $user
        ], 201);
    } else {
        sendResponse([
            'success' => false,
            'message' => 'Failed to register user'
        ], 500);
    }

} catch (PDOException $e) {
    sendResponse([
        'success' => false,
        'message' => 'Database error: ' . $e->getMessage()
    ], 500);
}
?>
