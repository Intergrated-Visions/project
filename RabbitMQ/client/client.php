#!/usr/bin/php
<?php
require_once('rabbitMQLib.inc');

$connectionConfig = [
    "BROKER_HOST" => "rabbitmq.grouse-hake.ts.net", // ! TO CHANGE
    "BROKER_PORT" => 5672,
    "USER" => "test",  // ! TO CHANGE
    "PASSWORD" => "test",  // ! TO CHANGE
    "VHOST" => "",  // ! TO CHANGE
];

$exchangeQueueConfig = [
    "EXCHANGE_TYPE" => "topic",
    "AUTO_DELETE" => true,
    "EXCHANGE" => "", // ! TO CHANGE
    "QUEUE" => "" // ! TO CHANGE
];

$client = new rabbitMQClient($connectionConfig, $exchangeQueueConfig);
if (isset($argv[1]))
{
  $msg = $argv[1];
}
else
{
  $msg = "test message";
}

$request = array();
$request['type'] = "Login";
$request['username'] = "steve";
$request['password'] = "password";
$request['message'] = $msg;
$response = $client->send_request($request);
//$response = $client->publish($request);

echo "client received response: ".PHP_EOL;
print_r($response);
echo "\n\n";

echo $argv[0]." END".PHP_EOL;
