<?php
/**
 * SAMS API Test Script
 * This script tests all the API endpoints to ensure they're working correctly
 */

// Configuration
$baseUrl = 'http://localhost/backend_api';
$testResults = [];

// Helper function to make HTTP requests
function makeRequest($url, $method = 'GET', $data = null) {
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_TIMEOUT, 30);
    
    if ($method === 'POST') {
        curl_setopt($ch, CURLOPT_POST, true);
        if ($data) {
            curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
            curl_setopt($ch, CURLOPT_HTTPHEADER, [
                'Content-Type: application/json',
                'Content-Length: ' . strlen(json_encode($data))
            ]);
        }
    }
    
    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);
    
    return [
        'status_code' => $httpCode,
        'response' => json_decode($response, true),
        'raw_response' => $response
    ];
}

// Test function
function testEndpoint($name, $url, $method = 'GET', $data = null, $expectedStatus = 200) {
    global $testResults;
    
    echo "Testing: $name\n";
    echo "URL: $url\n";
    echo "Method: $method\n";
    
    $result = makeRequest($url, $method, $data);
    
    $testResults[] = [
        'name' => $name,
        'url' => $url,
        'method' => $method,
        'status_code' => $result['status_code'],
        'expected_status' => $expectedStatus,
        'success' => $result['status_code'] === $expectedStatus,
        'response' => $result['response']
    ];
    
    if ($result['status_code'] === $expectedStatus) {
        echo "✅ PASS\n";
    } else {
        echo "❌ FAIL - Expected: $expectedStatus, Got: {$result['status_code']}\n";
    }
    
    if ($result['response']) {
        echo "Response: " . json_encode($result['response'], JSON_PRETTY_PRINT) . "\n";
    } else {
        echo "Raw Response: " . $result['raw_response'] . "\n";
    }
    
    echo str_repeat("-", 50) . "\n\n";
}

// Test data
$testUser = [
    'name' => 'Test User',
    'email' => 'test@example.com',
    'password' => 'password123',
    'role' => 'student',
    'student_id' => 'ST001',
    'department' => 'Computer Science'
];

$testLogin = [
    'email' => 'admin@sams.com',
    'password' => 'password',
    'role' => 'admin'
];

$testCode = [
    'teacher_id' => 1,
    'subject' => 'Test Subject',
    'class_name' => 'Test Class',
    'max_uses' => 10
];

echo "🧪 SAMS API Test Suite\n";
echo "====================\n\n";

// Test 1: Database Connection (via login endpoint)
testEndpoint(
    'Database Connection Test',
    "$baseUrl/login.php",
    'POST',
    $testLogin,
    200
);

// Test 2: User Registration
testEndpoint(
    'User Registration',
    "$baseUrl/register_user.php",
    'POST',
    $testUser,
    201
);

// Test 3: Login with valid credentials
testEndpoint(
    'Valid Login',
    "$baseUrl/login.php",
    'POST',
    $testLogin,
    200
);

// Test 4: Login with invalid credentials
testEndpoint(
    'Invalid Login',
    "$baseUrl/login.php",
    'POST',
    [
        'email' => 'invalid@example.com',
        'password' => 'wrongpassword',
        'role' => 'admin'
    ],
    401
);

// Test 5: Generate Attendance Code
testEndpoint(
    'Generate Attendance Code',
    "$baseUrl/generate_code.php",
    'POST',
    $testCode,
    201
);

// Test 6: Validate Attendance Code
testEndpoint(
    'Validate Attendance Code',
    "$baseUrl/validate_code.php",
    'POST',
    ['code' => 'ABC123'],
    200
);

// Test 7: Get Users
testEndpoint(
    'Get Users',
    "$baseUrl/get_users.php",
    'GET',
    null,
    200
);

// Test 8: Get Users by Role
testEndpoint(
    'Get Users by Role',
    "$baseUrl/get_users.php?role=student",
    'GET',
    null,
    200
);

// Test 9: Get Attendance Records
testEndpoint(
    'Get Attendance Records',
    "$baseUrl/get_attendance.php?user_id=1",
    'GET',
    null,
    200
);

// Test 10: Get Low Attendance Students
testEndpoint(
    'Get Low Attendance Students',
    "$baseUrl/get_low_attendance_students.php?threshold=75",
    'GET',
    null,
    200
);

// Test 11: Generate Reports
testEndpoint(
    'Generate Reports',
    "$baseUrl/reports.php?report_type=attendance&user_id=1",
    'GET',
    null,
    200
);

// Test 12: Invalid Endpoint
testEndpoint(
    'Invalid Endpoint',
    "$baseUrl/invalid_endpoint.php",
    'GET',
    null,
    404
);

// Summary
echo "📊 Test Summary\n";
echo "===============\n\n";

$totalTests = count($testResults);
$passedTests = count(array_filter($testResults, function($test) {
    return $test['success'];
}));
$failedTests = $totalTests - $passedTests;

echo "Total Tests: $totalTests\n";
echo "Passed: $passedTests ✅\n";
echo "Failed: $failedTests ❌\n";
echo "Success Rate: " . round(($passedTests / $totalTests) * 100, 2) . "%\n\n";

if ($failedTests > 0) {
    echo "❌ Failed Tests:\n";
    foreach ($testResults as $test) {
        if (!$test['success']) {
            echo "- {$test['name']}: Expected {$test['expected_status']}, Got {$test['status_code']}\n";
        }
    }
    echo "\n";
}

echo "🎉 Test Suite Complete!\n";

// Save results to file
file_put_contents('test_results.json', json_encode($testResults, JSON_PRETTY_PRINT));
echo "📄 Results saved to test_results.json\n";
?>
