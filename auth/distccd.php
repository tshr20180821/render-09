<?php

$pid = getmypid();

error_log(date("Y-m-d H:i:s") . " ${pid} distccd.php start");

if (php_sapi_name() === 'cli' || defined('STDIN'))
{
    $stdin = fopen('php://stdin', 'r');
    error_log(date("Y-m-d H:i:s") . " ${pid} distccd.php check point 010 CLI");
} else {
    $stdin = fopen('php://input', 'r');
    error_log(date("Y-m-d H:i:s") . " ${pid} distccd.php check point 010 NON-CLI");
}

$data = [];
$count_zero = 0;
$line_number = 0;

while (true) {
    $read = array($stdin);
    $write = $except = array();
    $timeout = 5;
    $line_number++;

    if (stream_select($read, $write, $except, $timeout)) {
        error_log(date("Y-m-d H:i:s") . " ${pid} ${line_number} distccd.php check point 020");
        $buffer = fgets($stdin);
        $data[] = $buffer;
        error_log(date("Y-m-d H:i:s") . " ${pid} ${line_number} distccd.php check point 030 " . strlen($buffer));
        if (strlen($buffer) == 0) {
            if ($count_zero++ > 50) {
                break;
            }
        } else {
            $count_zero = 0;
        }
    } else {
        error_log(date("Y-m-d H:i:s") . " ${pid} ${line_number} distccd.php check point 040");
        break;
    }
}

error_log(date("Y-m-d H:i:s") . " ${pid} ${line_number} distccd.php check point 050 " . strlen(implode('', $data)));

// error_log(strlen(implode("\r\n", $data)));

$socket = socket_create(AF_INET, SOCK_STREAM, SOL_TCP);

error_log(date("Y-m-d H:i:s") . " ${pid} distccd.php check point 060");

$rc = socket_connect($socket, '127.0.0.1', 13632);

error_log(date("Y-m-d H:i:s") . " ${pid} distccd.php check point 070 " . $rc);

$rc = socket_write($socket, implode('', $data));

error_log(date("Y-m-d H:i:s") . " ${pid} distccd.php check point 080 " . $rc);

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
