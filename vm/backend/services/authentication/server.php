#!/usr/bin/php
<?php
require_once('rabbitMQLib.inc');

function doLogin($username,$password)
{
  
  // Database connection parameters love 
  $servername = "localhost"; // Update this to your MySQL server hostname or IP address
  $database = "test123"; // Update this to your MySQL database name
  // Create a new mysqli connection
  $conn = new mysqli($servername, "Cyrus", "Man0nMoon", $database);
  if ($conn->connect_error) {
      $msg = "failed: " . $conn->connect_error;
      http_response_code(400); // Internal Server Error
      echo json_encode($msg);
      exit(0);
  }

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
      $randomNumber = rand(1, 1000); // Generates a random number between 1 and 100 (inclusive);
      $_sessionId = strval($randomNumber);
      $dateTimestamp = strtotime("tomorrow");
      $expired_at = date('Y-m-d H:i:s', $dateTimestamp);

      $stmt = $conn->prepare("INSERT INTO  user_sessions (session_id, username, expired_at) VALUES (?, ?, ?)");
      $stmt->bind_param("sss", $_sessionId, $password, $expired_at);
      
      try {
        // Attempt to execute the prepared statement
        if ($stmt->execute()) {
            return array("returnCode" => 200, 'message' => "User Logged in successfully!", "session" => $_sessionId, "expired_at" => $expired_at);
        } else {
            return array("returnCode" => 500, 'message' => "Error Logging in user");
        }
      } catch (Exception $e) {
          return array("returnCode" => 500, "message" => "Error executing query: " . $e->getMessage());
      }
    } else {
      return array("returnCode" => 400, 'message'=>$username . " " . $password);
    }
  } catch (Exception $e) {
    return array("returnCode" => 500, "message" => "Error executing query: " . $e->getMessage());
  }

  
}
function doRegistation($username,$password){
  // Database connection parameters
  $servername = "localhost"; // Update this to your MySQL server hostname or IP address
  $database = "test123"; // Update this to your MySQL database name
  // Create a new mysqli connection
  $conn = new mysqli($servername, "Cyrus", "Man0nMoon", $database);
  if ($conn->connect_error) {
      $msg = "failed: " . $conn->connect_error;
      http_response_code(400); // Internal Server Error
      echo json_encode($msg);
      exit(0);
  }
  // Prepare SQL statement to insert user data into the database
  $stmt = $conn->prepare("INSERT INTO users (username, password_hash) VALUES (?, ?)");
  $stmt->bind_param("ss", $username, $password);
try {
    // Attempt to execute the prepared statement
    if ($stmt->execute()) {
        return array("returnCode" => 200, 'message' => "User registered successfully!");
    } else {
        return array("returnCode" => 500, 'message' => "Error registering user");
    }
} catch (Exception $e) {
    return array("returnCode" => 500, "message" => "Error executing query: " . $e->getMessage());
}

// close the connection
}

function requestProcessor($request)
{
  echo "received request".PHP_EOL;
  var_dump($request);
  if(!isset($request['type']))
  {
    return "ERROR: unsupported message type";
  }
  switch ($request['type'])
  {
    case "login":
      return doLogin($request['username'],$request['password']);
    case "register":
      return doRegistation($request['username'],$request['password']);
    case "validate_session":
      return doValidate($request['sessionId']);
  }
  return array("returnCode" => '0', 'message'=>"Server received request and processed");
}

$connectionConfig = [
  "BROKER_HOST" => "localhost", // ! TO CHANGE
  "BROKER_PORT" => 5672,
  "USER" => "test",  // ! TO CHANGE
  "PASSWORD" => "test",  // ! TO CHANGE
  "VHOST" => "integratedVisions",  // ! TO CHANGE
];

$exchangeQueueConfig = [
  "EXCHANGE_TYPE" => "topic",
  "AUTO_DELETE" => true,
  "EXCHANGE" => "authenticationExchange", // ! TO CHANGE
  "QUEUE" => "authenticationQueue" // ! TO CHANGE
];

$server = new rabbitMQServer($connectionConfig, $exchangeQueueConfig);

echo "testRabbitMQServer BEGIN".PHP_EOL;
$server->process_requests('requestProcessor');
echo "testRabbitMQServer END".PHP_EOL;
exit();
?>
