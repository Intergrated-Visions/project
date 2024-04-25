#!/usr/bin/php
<?php
require_once('rabbitMQLib.inc');

function requestProcessor($request)
{
    echo "Received request:\n";
    var_dump($request);

    if (!isset($request['type'])) {
        return ['returnCode' => '1', 'message' => "ERROR: unsupported message type"];
    }

    switch ($request['type']) {
        case "packer":
            // Validate necessary data is present
            if (empty($request['zipFileName']) || empty($request['directoryPath'])) {
                return ['returnCode' => '1', 'message' => 'Missing necessary information about the package.'];
            }

            $packageName = $request['zipFileName'];
            $remotePackagePath = $request['directoryPath'];
            $remoteVMUsername = $request['remoteVMUsername'] ?? 'defaultUsername'; // Default if not provided
            $remoteVMHost = $request['remoteVMHost'] ?? 'defaultHost'; // Default if not provided

            echo "Preparing to handle package: $packageName from $remoteVMHost\n";

            // Local directory to copy the package to
            $localPath = "/home/ubuntu/Desktop/project/deployer/packageReceiver/copyfile";

            // Ensure the local directory exists
            if (!file_exists($localPath) && !mkdir($localPath, 0755, true)) {
                return ['returnCode' => '1', 'message' => "Failed to create local directory $localPath."];
            }

            // Define full path for remote and local files
            $remoteFilePath = rtrim($remotePackagePath, '/') . '/' . $packageName;
            $localFilePath = $localPath . '/' . $packageName;

            // Command to copy the file from the remote server
            $scpCommand = "scp {$remoteVMUsername}@{$remoteVMHost}:\"{$remoteFilePath}\" \"{$localFilePath}\"";
            exec($scpCommand, $output, $returnVar);

            if ($returnVar !== 0) {
                error_log("Failed to scp file: $scpCommand");
                return ['returnCode' => '1', 'message' => "Failed to copy file from remote VM."];
            }

            echo "Package $packageName copied successfully to $localFilePath.\n";

            // Additional processing can be done here

            return ['returnCode' => '0', 'message' => 'Package received and processed successfully.'];

        default:
            return ["returnCode" => '0', 'message' => "Server received request and processed"];
    }
}

// Configuration for RabbitMQ connection
$BROKER_HOST = "si-developer.grouse-hake.ts.net";
$connectionConfig = [
    "BROKER_HOST" => $BROKER_HOST,
    "BROKER_PORT" => 5672,
    "USER" => "test",
    "PASSWORD" => "test",
    "VHOST" => "integratedVisions",
];
$exchangeQueueConfig = [
    "EXCHANGE_TYPE" => "topic",
    "AUTO_DELETE" => true,
    "EXCHANGE" => "createPackageExchange",
    "QUEUE" => "createPackageQueue"
];

$server = new rabbitMQServer($connectionConfig, $exchangeQueueConfig);

echo "testRabbitMQServer BEGIN\n";
$server->process_requests('requestProcessor');
echo "testRabbitMQServer END\n";
?>
