#!/usr/bin/php
<?php
require_once('rabbitMQLib.inc');


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
    case "packer":
      return array('returnCode' => '0', 'message'=>'Sever recieved request and processed');
    
  }
  return array("returnCode" => '0', 'message'=>"Server received request and processed");
}
 $BROKER_HOST = "si-developer.grouse-hake.ts.net"; // Default

$connectionConfig = [
  "BROKER_HOST" => $BROKER_HOST, // ! TO CHANGE
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

$server = new rabbitMQServer($connectionConfig, $exchangeQueueConfig);

echo "testRabbitMQServer BEGIN".PHP_EOL;
$server->process_requests('requestProcessor');
echo "testRabbitMQServer END".PHP_EOL;
exit();
?>
