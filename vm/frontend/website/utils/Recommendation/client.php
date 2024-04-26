<?php
require_once('rabbitMQLib.inc');

header('Content-Type: application/json');

// Read the raw POST data from the input stream
$rawData = file_get_contents("php://input");

// Decode the JSON data
$data = json_decode($rawData, true);

// Check if POST data is set
if ($_SERVER["REQUEST_METHOD"] !== "POST") {
  $msg = "NO POST MESSAGE SET/eeeeee";
  http_response_code(400); // Bad Request
  echo json_encode($msg);
  exit(0);
}

// Check if the required fields are present in the POST data
if (!isset($data["type"])) {
  $msg = "Incomplete request data";
  http_response_code(400); // Bad Request
  echo json_encode($data);
  exit(0);
}
  $BROKER_HOST = "127.0.0.1"; // Default
  
  $hostname = explode("-", gethostname());
if($hostname[2] === "frontend" || $hostname[2] === "dmz"){
    $hostname[2] = "backend";
    $BROKER_HOST = implode("-",$hostname);
    $BROKER_HOST = implode("-",$hostname);
    $BROKER_HOST .= ".grouse-hake.ts.net";
}

$connectionConfig = [
    "BROKER_HOST" => "$BROKER_HOST", // ! TO CHANGE
    "BROKER_PORT" => 5672,
    "USER" => "test",  // ! TO CHANGE
    "PASSWORD" => "test",  // ! TO CHANGE
    "VHOST" => "integratedVisions",  // ! TO CHANGE
];

$exchangeQueueConfig = [
    "EXCHANGE_TYPE" => "topic",
    "AUTO_DELETE" => true,
    "EXCHANGE" => "recommendationExchange", // ! TO CHANGE
    "QUEUE" => "recommendationQueue" // ! TO CHANGE
];


$client = new rabbitMQClient($connectionConfig, $exchangeQueueConfig);

$request = $data; 

$response = $client->send_request($request);

echo json_encode($response);

exit(0);
