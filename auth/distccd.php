<?php

error_log("Y-m-d H:i:s");

$data = file_get_contents("php://input");

error_log($data);

$socket = stream_socket_client('tcp://127.0.0.1:13632');

socket_write($socket, $data, strlen($data));

$res = '';
for (;;) {
    $buffer = socket_read($socket, 1024);
    if (strlen($buffer) === 0) {
        break;
    }
    $res .= $buffer;
}

socket_close($socket);

header('Content-Type: binary/octet-stream');

echo $res;
