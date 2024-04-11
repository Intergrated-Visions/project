#!/usr/bin/php
<?php
require_once('rabbitMQLib.inc');

$BROKER_HOST = "si-developer.grouse-hake.ts.net"; // Default

$connectionConfig = [
    "BROKER_HOST" => $BROKER_HOST, // This should be your RabbitMQ server address
    "BROKER_PORT" => 5672, // The port RabbitMQ is running on
    "USER" => "test", // Your RabbitMQ username
    "PASSWORD" => "test", // Your RabbitMQ password
    "VHOST" => "integratedVisions", // The virtual host in RabbitMQ
];

$exchangeQueueConfig = [
    "EXCHANGE_TYPE" => "topic", // Type of exchange
    "AUTO_DELETE" => false, // Usually false, so the queue persists beyond the connection
    "EXCHANGE" => "createPackageExchange", // The exchange name
    "QUEUE" => "createPackageQueue" // The queue name
];

$client = new rabbitMQClient($connectionConfig, $exchangeQueueConfig);

// Assuming you have packaged the project and have the following information available
$packageName = "my_project_package.zip"; // The package name
$packagePath = "/home/yardley/Desktop/project/packages"; // The absolute path to the package

// Construct the request array with package details
$request = array(
    'type' => 'packer',
    'packageName' => $packageName,
    'packagePath' => $packagePath,
    'timestamp' => date('Y-m-d H:i:s') // Current timestamp, or could be the package's timestamp
);

// Send the package details as a request to the RabbitMQ server
$response = $client->send_request($request);

// Check response from the server
if ($response) {
    echo "Server responded: ", print_r($response, true), "\n";
} else {
    echo "Server did not respond. There might be an error or the server might not be running.\n";
}
?>