<?php

error_log(date("Y-m-d H:i:s"));

$data = file_get_contents("php://input");

error_log($data);

$socket = socket_create(AF_INET, SOCK_STREAM, SOL_TCP);
socket_connect($socket, '127.0.0.1', 13632);

socket_write($socket, $data);

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
