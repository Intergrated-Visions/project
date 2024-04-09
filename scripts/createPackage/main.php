#!/usr/bin/php
<?php
require_once('rabbitMQLib.inc');
  
$BROKER_HOST = "si-developer.grouse-hake.ts.net"; // Default

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
    "EXCHANGE" => "createPackageExchange", // ! TO CHANGE
    "QUEUE" => "createPackageQueue" // ! TO CHANGE
];

$client = new rabbitMQClient($connectionConfig, $exchangeQueueConfig);

$request = array();
$request['type'] = 'packer';





$response = $client->send_request($request);
