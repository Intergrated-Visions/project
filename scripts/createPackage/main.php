#!/usr/bin/php
<?php
require_once('rabbitMQLib.inc');

if ($argc != 5) {
    echo "Usage: {$argv[0]} <directoryPath> <zipFileName> <remoteVMUsername> <remoteVMHost>\n";
    exit(1);
}

// Assigning passed arguments to variables
$directoryPath = $argv[1];
$zipFileName = $argv[2];
$remoteVMUsername = $argv[3];
$remoteVMHost = $argv[4];

// Setup your connection configuration and message array
$message = [
    'type' => 'packer',
    'directoryPath' => $directoryPath,
    'zipFileName' => $zipFileName,
    'remoteVMUsername' => $remoteVMUsername,
    'remoteVMHost' => $remoteVMHost,
    'timestamp' => date('Y-m-d H:i:s') // Current timestamp
];

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

// Assuming you have a RabbitMQ client setup to send the message
$client = new rabbitMQClient($connectionConfig, $exchangeQueueConfig);

$response = $client->send_request($message);

echo "Response from server: " . print_r($response, true) . "\n";
?>
