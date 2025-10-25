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
$role = isset($_GET['role']) ? sanitizeInput($_GET['role']) : null;
$department = isset($_GET['department']) ? sanitizeInput($_GET['department']) : null;

try {
    // Build query
    $query = "
        SELECT id, name, email, role, student_id, department, phone, 
               created_at, last_login
        FROM users 
        WHERE 1=1
    ";
    $params = [];

    // Add filters
    if ($role) {
        $query .= " AND role = ?";
        $params[] = $role;
    }

    if ($department) {
        $query .= " AND department = ?";
        $params[] = $department;
    }

    // Order by created_at descending
    $query .= " ORDER BY created_at DESC";

    // Execute query
    $stmt = $pdo->prepare($query);
    $stmt->execute($params);
    $users = $stmt->fetchAll();

    // Format the response
    $formattedUsers = [];
    foreach ($users as $user) {
        $formattedUsers[] = [
            'id' => $user['id'],
            'name' => $user['name'],
            'email' => $user['email'],
            'role' => $user['role'],
            'student_id' => $user['student_id'],
            'department' => $user['department'],
            'phone' => $user['phone'],
            'created_at' => $user['created_at'],
            'last_login' => $user['last_login']
        ];
    }

    sendResponse([
        'success' => true,
        'users' => $formattedUsers,
        'total_users' => count($formattedUsers)
    ]);

} catch (PDOException $e) {
    sendResponse([
        'success' => false,
        'message' => 'Database error: ' . $e->getMessage()
    ], 500);
}
?>
