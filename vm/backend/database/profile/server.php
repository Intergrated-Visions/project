#!/usr/bin/php
<?php
require_once('rabbitMQLib.inc');

function getDBConnection() {
    $servername = "localhost"; // Update this to your MySQL server hostname or IP address
    $database = "test123"; // Update this to your MySQL database name
    $username = "Cyrus"; // Update this to your MySQL username
    $password = "Man0nMoon"; // Update this to your MySQL password

    try {
        $conn = new PDO("mysql:host=$servername;dbname=$database", $username, $password);
        // Set the PDO error mode to exception
        $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        return $conn;
    } catch(PDOException $e) {
        echo "Connection failed: " . $e->getMessage();
        exit(0);
    }
}

function doUpdateProfile($request) {
    $conn = getDBConnection();

    // Check for required keys and assign default values if not set
    $userID = $request['userID'] ?? null;
    $fullName = $request['fullName'] ?? '';
    $age = $request['age'] ?? 0; // Assuming age is an integer and you want to default to 0 if not provided
    $aboutMe = $request['about'] ?? '';
    $goals = $request['goals'] ?? '';

    // Convert height and weight to a single float value (e.g., centimeters and kilograms)
    $height = $request['height']['centimeters'] ?? 0; // Default to 0 if not provided
    $weight = $request['weight']['kilograms'] ?? 0; // Default to 0 if not provided

    // Ensure that height and weight are not 'NaN'
    $height = is_numeric($height) ? $height : 0;
    $weight = is_numeric($weight) ? $weight : 0;

    $sql = "INSERT INTO User_profile (UserID, full_name, age, about_me, Height, Weight, Goal) 
            VALUES (?, ?, ?, ?, ?, ?, ?)
            ON DUPLICATE KEY UPDATE
            full_name = VALUES(full_name),
            age = VALUES(age),
            about_me = VALUES(about_me),
            Height = VALUES(Height),
            Weight = VALUES(Weight),
            Goal = VALUES(Goal);";

    $stmt = $conn->prepare($sql);

    try {
        $stmt->execute([$userID, $fullName, $age, $aboutMe, $height, $weight, $goals]);
        return ["returnCode" => '1', 'message' => "Profile updated successfully"];
    } catch (PDOException $e) {
        error_log($e->getMessage());
        return ["returnCode" => '0', 'message' => "Failed to update profile: " . $e->getMessage()];
    }
}


function requestProcessor($request) {
    echo "received request" . PHP_EOL;
    var_dump($request);
    if (!isset($request['type'])) {
        return "ERROR: unsupported message type";
    }
    switch ($request['type']) {
        case "profile":
            return doUpdateProfile($request);
        default:
            return array("returnCode" => '0', 'message' => "Server received request and processed");
    }
}

$connectionConfig = [
    "BROKER_HOST" => "localhost", // Replace with your broker's host
    "BROKER_PORT" => 5672, // Replace with your broker's port
    "USER" => "test", // Replace with your broker's user
    "PASSWORD" => "test", // Replace with your broker's password
    "VHOST" => "integratedVisions", // Replace with your broker's vhost
];

$exchangeQueueConfig = [
    "EXCHANGE_TYPE" => "topic",
    "AUTO_DELETE" => false, // Changed to false if you don't want auto-delete
    "EXCHANGE" => "profileExchange", // Your exchange name
    "QUEUE" => "profileQueue" // Your queue name
];

$server = new rabbitMQServer($connectionConfig, $exchangeQueueConfig);

echo "testRabbitMQServer BEGIN" . PHP_EOL;
$server->process_requests('requestProcessor');
echo "testRabbitMQServer END" . PHP_EOL;
exit();
?>
