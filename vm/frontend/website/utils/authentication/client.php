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
    "EXCHANGE" => "authenticationExchange", // ! TO CHANGE
    "QUEUE" => "authenticationQueue" // ! TO CHANGE
];


$client = new rabbitMQClient($connectionConfig, $exchangeQueueConfig);

$request = array();
$request['type'] = $_POST["type"];

if(!isset($request['type']))
{
  return "ERROR: unsupported message type";
}

switch ($request['type'])
{
  case "login":
  case "register":
    $request['username'] = $_POST["uname"];
    $request['password'] = $_POST["pword"];
    break;

  case "validate_session":
    break;
}

$response = $client->send_request($request);

echo json_encode($response);

exit(0);
