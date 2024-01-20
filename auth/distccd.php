<?php

error_log(date("Y-m-d H:i:s") . ' distccd.php start');

$stdin = fopen('php://stdin', 'r');

error_log("distccd.php check point 010");

$data = [];

while(true) {
    $read = array($stdin);
    $write = $except = array();
    $timeout = 20;

    if(stream_select($read, $write, $except, $timeout)) {
        error_log("distccd.php check point 020");
        $data[] = fgets($stdin);
        error_log("distccd.php check point 030");
    } else {
        error_log("distccd.php check point 040");
    }
}
error_log(implode("\r\n", $data));

$socket = socket_create(AF_INET, SOCK_STREAM, SOL_TCP);

error_log(date("Y-m-d H:i:s") . ' distccd.php check point 020');

socket_connect($socket, '127.0.0.1', 13632);

error_log(date("Y-m-d H:i:s") . ' distccd.php check point 030');

socket_write($socket, $implode("\r\n", $data));

error_log(date("Y-m-d H:i:s") . ' distccd.php check point 040');

$res = '';
for (;;) {
    error_log(date("Y-m-d H:i:s") . ' distccd.php check point 050');
    $buffer = socket_read($socket, 8192);
    if (strlen($buffer) === 0) {
        break;
    }
    $res .= $buffer;
}

error_log(date("Y-m-d H:i:s") . ' distccd.php check point 060 ' . strlen($res));

socket_close($socket);

error_log(date("Y-m-d H:i:s") . ' distccd.php check point 070');

header('Content-Type: binary/octet-stream');

error_log(date("Y-m-d H:i:s") . ' distccd.php check point 080');

echo $res;
