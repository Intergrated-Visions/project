<?php
// Check if POST data is set
if ($_SERVER["REQUEST_METHOD"] !== "POST") {
    $msg = "NO POST MESSAGE SET";
    http_response_code(500); // Bad Request
    echo json_encode($msg);
    exit(0);
}

// Check if the required fields are present in the POST data
if (!isset($_POST["type"]) || !isset($_POST["uname"]) || !isset($_POST["pword"])) {
    $msg = "Incomplete request data";
    http_response_code(500); // Bad Request
    echo json_encode($msg);
    exit(0);
}

// Database connection parameters
$servername = "192.168.1.221:3306"; // Update this to your MySQL server hostname or IP address
$username = "Cyrus"; // Update this to your MySQL username
$password = "Man0nMoon"; // Update this to your MySQL password
$database = "test123"; // Update this to your MySQL database name

// Create a new mysqli connection
$conn = new mysqli($servername, $username, $password, $database);
if ($conn->connect_error) {
    $msg = "failed: " . $conn->connect_error;
    http_response_code(400); // Internal Server Error
    echo json_encode($msg);
    exit(0);
}

// Sanitize input data (optional, since we'll use prepared statements)
$type = $_POST["type"];
$username = $_POST["uname"];
$password = $_POST["pword"];

// Prepare SQL statement to query the database for user authentication
$stmt = $conn->prepare("SELECT * FROM users WHERE username=? AND password_hash=?");
$stmt->bind_param("ss", $username, $password);

try {
    // Attempt to execute the prepared statement
    $stmt->execute();
    
    // Get result
    $result = $stmt->get_result();
    
    // Check if any rows are returned, indicating successful authentication
    if ($result->num_rows > 0) {
        $response = "login, successful";
    } else {
        // If user isn't in the database, redirect to register.html page
        header("Location: register.html");
        exit;
    }
} catch (Exception $e) {
    // Log the error to a file or output it for debugging
    error_log('Error executing SQL query: ' . $e->getMessage());
    
    // Return an error response
    http_response_code(500); // Internal Server Error
    $response = "e";
}

// Close the database connection
$stmt->close();
$conn->close();
// Return JSON response
echo json_encode($response);
exit(0);
?>