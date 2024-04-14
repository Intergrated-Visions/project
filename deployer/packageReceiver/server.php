#!/usr/bin/php
<?php
require_once('rabbitMQLib.inc');

function requestProcessor($request)
{
    echo "received request".PHP_EOL;
    var_dump($request);

    if (!isset($request['type'])) {
        return ['returnCode' => '1', 'message' => "ERROR: unsupported message type"];
    }

    switch ($request['type']) {
        case "packer":
            $packageName = $request['packageName'] ?? null;
            $remotePackagePath = $request['packagePath'] ?? null;
            $timestamp = $request['timestamp'] ?? date('Y-m-d H:i:s');

            if (!$packageName || !$remotePackagePath) {
                return ['returnCode' => '1', 'message' => 'Missing package name or path'];
            }

            // Details of the remote VM
            $remoteVMUsername = "yardley";
            $remoteVMHost = "100.68.84.125";

            // Local directory to copy the package to
            $localPath = "/home/ubuntu/Desktop/project/deployer/packageReceiver/copyfile";

            // Find the newest file in the remote directory
            $findNewestFileCommand = "ssh {$remoteVMUsername}@{$remoteVMHost} 'cd {$remotePackagePath} && ls -t | head -n1'";
            exec($findNewestFileCommand, $output, $returnVar);

            if ($returnVar !== 0 || empty($output)) {
                error_log("Failed to find the newest file. Command: $findNewestFileCommand");
                return ['returnCode' => '1', 'message' => "Failed to find the newest file."];
            }

            $newestFileName = trim($output[0]);
            $remoteFilePath = rtrim($remotePackagePath, '/') . '/' . $newestFileName;

            // Ensure the local directory exists
            if (!file_exists($localPath) && !mkdir($localPath, 0755, true)) {
                return ['returnCode' => '1', 'message' => "Failed to create local directory."];
            }

            // Copy the newest file from the remote directory
            $scpCommand = "scp {$remoteVMUsername}@{$remoteVMHost}:\"{$remoteFilePath}\" \"{$localPath}/\"";
            exec($scpCommand, $output, $returnVar);

            if ($returnVar !== 0) {
                error_log("Failed to scp file from remote VM. Command: $scpCommand");
                return ['returnCode' => '1', 'message' => "Failed to copy file from remote VM."];
            }

            $localPackagePath = $localPath . '/' . $newestFileName;
            echo "Newest package $newestFileName copied successfully to $localPackagePath.\n";

            // ... rest of your logic ...

            return ['returnCode' => '0', 'message' => 'Newest package received and processed.'];
        default:
            return ["returnCode" => '0', 'message' => "Server received request and processed"];
    }
}

// RabbitMQ server configuration...
$BROKER_HOST = "si-developer.grouse-hake.ts.net"; // Set your broker host
$connectionConfig = [
    "BROKER_HOST" => $BROKER_HOST,
    "BROKER_PORT" => 5672,
    "USER" => "test", // Set your user
    "PASSWORD" => "test", // Set your password
    "VHOST" => "integratedVisions", // Set your vhost
];
$exchangeQueueConfig = [
    "EXCHANGE_TYPE" => "topic",
    "AUTO_DELETE" => true,
    "EXCHANGE" => "createPackageExchange",
    "QUEUE" => "createPackageQueue"
];

$server = new rabbitMQServer($connectionConfig, $exchangeQueueConfig);

echo "testRabbitMQServer BEGIN".PHP_EOL;
$server->process_requests('requestProcessor');
echo "testRabbitMQServer END".PHP_EOL;
?>
