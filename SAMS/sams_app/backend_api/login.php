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
$requiredFields = ['email', 'password', 'role'];
$missingFields = validateRequiredFields($requiredFields, $input);

if (!empty($missingFields)) {
    sendResponse([
        'success' => false,
        'message' => 'Missing required fields: ' . implode(', ', $missingFields)
    ], 400);
}

$email = sanitizeInput($input['email']);
$password = $input['password'];
$role = sanitizeInput($input['role']);

try {
    // Query to get user by email and role
    $stmt = $pdo->prepare("
        SELECT id, name, email, role, student_id, department, phone, password, created_at 
        FROM users 
        WHERE email = ? AND role = ?
    ");
    $stmt->execute([$email, $role]);
    $user = $stmt->fetch();

    if (!$user) {
        sendResponse([
            'success' => false,
            'message' => 'Invalid email or role'
        ], 401);
    }

    // Verify password
    if (!verifyPassword($password, $user['password'])) {
        sendResponse([
            'success' => false,
            'message' => 'Invalid password'
        ], 401);
    }

    // Remove password from response
    unset($user['password']);

    // Update last login
    $updateStmt = $pdo->prepare("UPDATE users SET last_login = NOW() WHERE id = ?");
    $updateStmt->execute([$user['id']]);

    sendResponse([
        'success' => true,
        'message' => 'Login successful',
        'user' => $user
    ]);

} catch (PDOException $e) {
    sendResponse([
        'success' => false,
        'message' => 'Database error: ' . $e->getMessage()
    ], 500);
}
?>
