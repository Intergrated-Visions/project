<?php
require_once('rabbitMQLib.inc');

// Check if POST data is set
if ($_SERVER["REQUEST_METHOD"] !== "POST") {
  $msg = "NO POST MESSAGE SET/eeeeee";
  http_response_code(400); // Bad Request
  echo json_encode($msg);
  exit(0);
}

// Check if the required fields are present in the POST data
if (!isset($_POST["type"]) || !isset($_POST["uname"]) || !isset($_POST["pword"])) {
  $msg = "Incomplete request data";
  http_response_code(400); // Bad Request
  echo json_encode($msg);
  exit(0);
}

// Database Configuration
$db_host = "192.168.1.100"; // IP of the VM hosting the database
$db_name = "my_database";
$db_user = "database_user";
$db_pass = "database_password";
$charset = 'utf8mb4';

// PDO Database Connection
$dsn = "mysql:host=$db_host;dbname=$db_name;charset=$charset";
$options = [
    PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    PDO::ATTR_EMULATE_PREPARES   => false,
];
try {
    $pdo = new PDO($dsn, $db_user, $db_pass, $options);
} catch (\PDOException $e) {
    error_log($e->getMessage());
    exit('Database connection failed: ' . $e->getMessage());
}

// RabbitMQ Configuration
$BROKER_HOST = "127.0.0.1"; // Default
$hostname = explode("-", gethostname());
if($hostname[2] === "frontend" || $hostname[2] === "dmz"){
    $hostname[2] = "backend";
    $BROKER_HOST = implode("-",$hostname);
    $BROKER_HOST .= ".grouse-hake.ts.net";
}

$connectionConfig = [
    "BROKER_HOST" => "$BROKER_HOST",
    "BROKER_PORT" => 5672,
    "USER" => "test",
    "PASSWORD" => "test",
    "VHOST" => "integratedVisions",
];

$exchangeQueueConfig = [
    "EXCHANGE_TYPE" => "topic",
    "AUTO_DELETE" => true,
    "EXCHANGE" => "authenticationExchange",
    "QUEUE" => "authenticationQueue"
];

$client = new rabbitMQClient($connectionConfig, $exchangeQueueConfig);

$request = array();
$request['type'] = $_POST["type"];

switch ($request['type']) {
  case "login":
  case "register":
    $username = $_POST["uname"];
    $password = $_POST["pword"]; // Ideally, passwords should be hashed and checked accordingly.
    
    // SQL query to check the user credentials
    $stmt = $pdo->prepare("SELECT * FROM users WHERE username = :username AND password = :password");
    $stmt->execute(['username' => $username, 'password' => $password]);
    if ($stmt->fetch()) {
        $response = ["status" => "success", "message" => "Login successful"];
    } else {
        $response = ["status" => "fail", "message" => "Invalid username or password"];
    }
    break;

  case "validate_session":
    $response = ["status" => "success", "message" => "Session is valid"];
    break;
}

echo json_encode($response);

exit(0);
?>
