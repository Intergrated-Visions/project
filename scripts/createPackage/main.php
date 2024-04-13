#!/usr/bin/php
<?php
require_once('rabbitMQLib.inc');

// Ensure the script has the correct number of command-line arguments
if ($argc != 3) {
    echo "Usage: {$argv[0]} <directoryPath> <zipFileName>\n";
    exit(1);
}

$zipSaveDir = $argv[1]; // The directory where the zip file is saved
$zipFileName = $argv[2]; // The name of the zip file

$BROKER_HOST = "si-developer.grouse-hake.ts.net"; // This should be your RabbitMQ server address

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
    "EXCHANGE" => "createPackageExchange",
    "QUEUE" => "createPackageQueue"
];

$client = new rabbitMQClient($connectionConfig, $exchangeQueueConfig);

// Construct the request array with package details
$request = [
    'type' => 'packer',
    'packageName' => $zipFileName,
    'packagePath' => $zipSaveDir,
    'timestamp' => date('Y-m-d H:i:s') // Current timestamp, or could be the package's timestamp
];

// Send the package details as a request to the RabbitMQ server
$response = $client->send_request($request);

// Check response from the server
if ($response) {
    echo "Server responded: ", print_r($response, true), "\n";
} else {
    echo "Server did not respond. There might be an error or the server might not be running.\n";
}
?>
