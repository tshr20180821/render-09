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
            if ($count_zero++ > 30) {
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

$request_data = implode('', $data);

error_log(date("Y-m-d H:i:s") . " ${pid} send.php check point 060 " . strlen($request_data) . " ${count_zero}");

$mc = new Memcached('pool');
if (count($mc->getServerList()) == 0) {
    $mc->setOption(Memcached::OPT_BINARY_PROTOCOL, true);
    $mc->setSaslAuthData($_ENV['MEMCACHED_USER'], $_ENV['SASL_PASSWORD']);
    $mc->addServer($_ENV['MEMCACHED_SERVER'], $_ENV['MEMCACHED_PORT']);
    $mc->setOption(Memcached::OPT_SERVER_FAILURE_LIMIT, 255);
}

error_log(date("Y-m-d H:i:s") . " ${pid} send.php check point 070 " . substr($request_data, -10));

$distccds = explode(',', getenv('DISTCCD_URLS'));
$target = '';

error_log(date("Y-m-d H:i:s") . " ${pid} send.php check point 080 " . count($distccds));

for (;;) {
    foreach ($distccds as &$distccd) {
        error_log(date("Y-m-d H:i:s") . " ${pid} send.php check point 090 ${distccd}");
        $mc->increment('DISTCCD_URL_' . $distccd, 1, 1, 60 * 5);
        if ($mc->get('DISTCCD_URL_' . $distccd) < 4) {
            $target = $distccd;
            break;
        } else {
            $mc->decrement('DISTCCD_URL_' . $distccd);
            error_log(date("Y-m-d H:i:s") . " ${pid} send.php check point 100 " . $distccd);
        }
    }
    if ($target != '') {
        break;
    }
    sleep(3);
    error_log(date("Y-m-d H:i:s") . " ${pid} send.php check point 110");
}

error_log(date("Y-m-d H:i:s") . " ${pid} send.php check point 120 ${target}");

$ch = curl_init();

error_log(date("Y-m-d H:i:s") . " ${pid} send.php check point 130");

curl_setopt($ch, CURLOPT_URL, $target);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query(['data' => base64_encode($request_data)]));

error_log(date("Y-m-d H:i:s") . " ${pid} send.php check point 140");

curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_USERPWD, getenv('BASIC_USER') . ':' . getenv('BASIC_PASSWORD'));

error_log(date("Y-m-d H:i:s") . " ${pid} send.php check point 150");

$res = curl_exec($ch);

error_log(date("Y-m-d H:i:s") . " ${pid} send.php check point 160 " . strlen($res));

$http_code = (string)curl_getinfo($ch, CURLINFO_HTTP_CODE);

error_log(date("Y-m-d H:i:s") . " ${pid} send.php check point 170 ${http_code}");

curl_close($ch);

error_log(date("Y-m-d H:i:s") . " ${pid} send.php check point 180");

$rc = $mc->decrement('DISTCCD_URL_' . $target);

error_log(date("Y-m-d H:i:s") . " ${pid} send.php check point 190 ${rc}");

$mc->quit();

error_log(date("Y-m-d H:i:s") . " ${pid} send.php check point 200");

echo base64_decode($res);

error_log(date("Y-m-d H:i:s") . " ${pid} send.php check point 210");
