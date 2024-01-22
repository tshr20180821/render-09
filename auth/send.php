<?php

$pid = getmypid();

error_log(date("Y-m-d H:i:s") . " ${pid} send.php start");

$stdin = fopen('php://stdin', 'r');

error_log(date("Y-m-d H:i:s") . " ${pid} send.php check point 010");

$data = [];
$count_zero = 0;
$line_number = 0;

for (;;) {
    $read = array($stdin);
    $write = $except = array();
    $timeout = 5;
    $line_number++;

    if (stream_select($read, $write, $except, $timeout)) {
        // error_log(date("Y-m-d H:i:s") . " ${pid} ${line_number} send.php check point 020");
        $buffer = fgets($stdin);
        $data[] = $buffer;
        // error_log(date("Y-m-d H:i:s") . " ${pid} ${line_number} send.php check point 030 " . strlen($buffer));
        if (strlen($buffer) == 0) {
            if ($count_zero++ > 50) {
                error_log(date("Y-m-d H:i:s") . " ${pid} send.php check point 040");
                break;
            }
        } else {
            $count_zero = 0;
        }
    } else {
        error_log(date("Y-m-d H:i:s") . " ${pid} ${line_number} send.php check point 050");
        break;
    }
}

error_log(date("Y-m-d H:i:s") . " ${pid} send.php check point 060 " . strlen(implode('', $data)));

$ch = curl_init();

error_log(date("Y-m-d H:i:s") . " ${pid} send.php check point 061");

curl_setopt($ch, CURLOPT_URL, 'https://' . getenv('RENDER_EXTERNAL_HOSTNAME') . '/auth/distccd.php');
error_log(date("Y-m-d H:i:s") . " ${pid} send.php check point 062");
curl_setopt($ch, CURLOPT_POST, true);
error_log(date("Y-m-d H:i:s") . " ${pid} send.php check point 063");
curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query(['data' => base64_encode(implode('', $data))]));
error_log(date("Y-m-d H:i:s") . " ${pid} send.php check point 064");
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
error_log(date("Y-m-d H:i:s") . " ${pid} send.php check point 065");
curl_setopt($ch, CURLOPT_USERPWD, base64_encode(getenv('BASIC_USER') . ':' . getenv('BASIC_PASSWORD')));

error_log(date("Y-m-d H:i:s") . " ${pid} send.php check point 070");

$res = curl_exec($ch);

error_log(date("Y-m-d H:i:s") . " ${pid} send.php check point 080 " . strlen($res));

$http_code = (string)curl_getinfo($ch, CURLINFO_HTTP_CODE);

error_log(date("Y-m-d H:i:s") . " ${pid} send.php check point 090 " . $http_code);

curl_close($ch);

error_log(date("Y-m-d H:i:s") . " ${pid} send.php check point 100");

echo base64_decode($res);

error_log(date("Y-m-d H:i:s") . " ${pid} send.php check point 110");
