#!/usr/bin/php
<?php
require_once('rabbitMQLib.inc');

function requestProcessor($request)
{
  echo "received request".PHP_EOL;
  var_dump($request);

  if(!isset($request['type']))
  {
    return array('returnCode' => '1', 'message'=>"ERROR: unsupported message type");
  }

  switch ($request['type'])
  {
    case "packer":
      // Extract package details from the request
      $packageName = $request['packageName'] ?? null;
      $packagePath = $request['packagePath'] ?? null;
      $timestamp = $request['timestamp'] ?? date('Y-m-d H:i:s'); // Use the current timestamp if not provided
      
      // Validate package details
      if (!$packageName || !$packagePath) {
        return array('returnCode' => '1', 'message'=>'Missing package name or path');
      }

      // Database connection parameters
      $servername = "localhost"; // Update this to your MySQL server hostname or IP address
      $database = "packageDB"; // Update this to your MySQL database name
      $username = "Cyrus"; // Update this to your MySQL username
      $password = "Man0nMoon"; // Update this to your MySQL password

      // Create a new mysqli connection
      $conn = new mysqli($servername, $username, $password, $database);

      // Check for a connection error
      if ($conn->connect_error) {
        return array('returnCode' => '1', 'message'=>"Database connection error: " . $conn->connect_error);
      }

      // Prepare the INSERT statement
     // Insert the package data into the database
try {
  // Ensure you're using $conn, which is your mysqli connection object
  $stmt = $conn->prepare("INSERT INTO packages (name, path, created_at) VALUES (?, ?, ?)");
  if ($stmt === false) {
    // Handle prepare error
    return array('returnCode' => '1', 'message' => "Prepare failed: " . $conn->error);
  }
  
  $stmt->bind_param("sss", $packageName, $packagePath, $timestamp);
  if (!$stmt->execute()) {
    // Handle execute error
    return array('returnCode' => '1', 'message' => "Execute failed: " . $stmt->error);
  }
  
  // Success
  $stmt->close();
  return array('returnCode' => '0', 'message' => 'Server received package and stored in database');
  
} catch (Exception $e) {
  // Catch any other exceptions and return an error message
  return array('returnCode' => '1', 'message' => "Database error: " . $e->getMessage());
}

      
    default:
      // Return a default response for other message types
      return array("returnCode" => '0', 'message'=>"Server received request and processed");
  }
}

$BROKER_HOST = "si-developer.grouse-hake.ts.net"; // Set your broker host

$connectionConfig = [
  "BROKER_HOST" => $BROKER_HOST,
  "BROKER_PORT" => 5672,
  "USER" => "test", // Set your user
  "PASSWORD" => "test", // Set your password
  "VHOST" => "integratedVisions", // Set your vhost
];

$exchangeQueueConfig = [
  "EXCHANGE_TYPE" => "topic",
  "AUTO_DELETE" => true,
  "EXCHANGE" => "createPackageExchange",
  "QUEUE" => "createPackageQueue"
];

$server = new rabbitMQServer($connectionConfig, $exchangeQueueConfig);

echo "testRabbitMQServer BEGIN".PHP_EOL;
$server->process_requests('requestProcessor');
echo "testRabbitMQServer END".PHP_EOL;
exit();
?>
