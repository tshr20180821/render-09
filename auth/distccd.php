<?php

$pid = getmypid();

error_log(date("Y-m-d H:i:s") . " ${pid} distccd.php start");

$stdin = fopen('php://stdin', 'r');

error_log(date("Y-m-d H:i:s") . " ${pid} distccd.php check point 010");

$data = [];

while(true) {
    $read = array($stdin);
    $write = $except = array();
    $timeout = 5;

    if(stream_select($read, $write, $except, $timeout)) {
        error_log(date("Y-m-d H:i:s") . " ${pid} distccd.php check point 020");
        $data[] = fgets($stdin);
        error_log(date("Y-m-d H:i:s") . " ${pid} distccd.php check point 030");
    } else {
        error_log(date("Y-m-d H:i:s") . " ${pid} distccd.php check point 040");
    }
}

error_log(date("Y-m-d H:i:s") . " ${pid} distccd.php check point 050");

error_log(implode("\r\n", $data));

$socket = socket_create(AF_INET, SOCK_STREAM, SOL_TCP);

error_log(date("Y-m-d H:i:s") . " ${pid} distccd.php check point 060");

socket_connect($socket, '127.0.0.1', 13632);

error_log(date("Y-m-d H:i:s") . " ${pid} distccd.php check point 070");

socket_write($socket, $implode("\r\n", $data));

error_log(date("Y-m-d H:i:s") . " ${pid} distccd.php check point 080");

$res = '';
for (;;) {
    error_log(date("Y-m-d H:i:s") . " ${pid} distccd.php check point 090");
    $buffer = socket_read($socket, 8192);
    if (strlen($buffer) === 0) {
        break;
    }
    $res .= $buffer;
}

error_log(date("Y-m-d H:i:s") . " ${pid} distccd.php check point 100 " . strlen($res));

socket_close($socket);

error_log(date("Y-m-d H:i:s") . " ${pid} distccd.php check point 110");

header('Content-Type: binary/octet-stream');

error_log(date("Y-m-d H:i:s") . " ${pid} distccd.php check point 120");

echo $res;
