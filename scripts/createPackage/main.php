<?php
require_once('rabbitMQLib.inc');

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

