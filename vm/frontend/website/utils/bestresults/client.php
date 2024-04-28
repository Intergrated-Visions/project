<?php
require_once('rabbitMQLib.inc');

header('Content-Type: application/json');

// Check if the request is a POST request and contains data
if ($_SERVER["REQUEST_METHOD"] !== "POST") {
    echo json_encode(["error" => "Method not allowed"]);
    http_response_code(405);
    exit(0);
}

// Read the raw POST data from the input stream
//$rawData = file_get_contents("php://input");
//$data = json_decode($rawData, true);

// Validate the data
if (!isset($data["userId"])) {
    echo json_encode(["error" => "Incomplete request data"]);
    http_response_code(400);
    exit(0);
}

// Configuration for the RabbitMQ server
$BROKER_HOST = "127.0.0.1";
$connectionConfig = [
    "BROKER_HOST" => $BROKER_HOST,
    "BROKER_PORT" => 5672,
    "USER" => "test",
    "PASSWORD" => "test",
    "VHOST" => "integratedVisions",
];

$exchangeQueueConfig = [
    "EXCHANGE_TYPE" => "topic",
    "AUTO_DELETE" => false,
    "EXCHANGE" => "bestExchange",
    "QUEUE" => "bestQueue"
];

// Create a new RabbitMQ client
$client = new rabbitMQClient($connectionConfig, $exchangeQueueConfig);

// Construct the request for RabbitMQ
$request = [
    "type" => "getUserProfile",
    "userId" => $data["userId"]
];

// Send the request and wait for the response
$response = $client->send_request($request);

// Output the response
echo json_encode($response);
exit(0);
?>
