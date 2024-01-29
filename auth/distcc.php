<?php

$pid = getmypid();

error_log(date("Y-m-d H:i:s") . " ${pid} distcc.php start");

$stdin = fopen('php://stdin', 'r');

error_log(date("Y-m-d H:i:s") . " ${pid} distcc.php check point 010");

$data = [];
$line_number = 0;
$write = $except = null;
$timeout = 3;

for (;;) {
    $read = array($stdin);
    $line_number++;

    if (stream_select($read, $write, $except, $timeout)) {
        $buffer = fgets($stdin);
        $data[] = $buffer;
    } else {
        error_log(date("Y-m-d H:i:s") . " ${pid} distcc.php check point 020 ${line_number}");
        break;
    }
}

$request_data = implode('', $data);

error_log(date("Y-m-d H:i:s") . " ${pid} distcc.php check point 030 " . strlen($request_data));

$mc = new Memcached('pool');
if (count($mc->getServerList()) == 0) {
    $mc->setOption(Memcached::OPT_BINARY_PROTOCOL, true);
    $mc->setSaslAuthData($_ENV['MEMCACHED_USER'], $_ENV['SASL_PASSWORD']);
    $mc->addServer($_ENV['MEMCACHED_SERVER'], $_ENV['MEMCACHED_PORT']);
    $mc->setOption(Memcached::OPT_SERVER_FAILURE_LIMIT, 255);
}

error_log(date("Y-m-d H:i:s") . " ${pid} distcc.php check point 040");

$distccds = explode(',', getenv('DISTCCD_URLS'));
$target = '';

error_log(date("Y-m-d H:i:s") . " ${pid} distcc.php check point 050 " . count($distccds));

for (;;) {
    foreach ($distccds as &$distccd) {
        error_log(date("Y-m-d H:i:s") . " ${pid} distcc.php check point 060 ${distccd}");
        $mc->increment("DISTCCD_URL_${distccd}", 1, 1, 60 * 5);
        if ($mc->get("DISTCCD_URL_${distccd}") < 4) {
            $target = $distccd;
            break;
        } else {
            $mc->decrement("DISTCCD_URL_${distccd}");
            error_log(date("Y-m-d H:i:s") . " ${pid} distcc.php check point 070 ${distccd}");
        }
    }
    if ($target != '') {
        break;
    }
    sleep(3);
    error_log(date("Y-m-d H:i:s") . " ${pid} distcc.php check point 080");
}

error_log(date("Y-m-d H:i:s") . " ${pid} distcc.php check point 090 ${target}");

$ch = curl_init();

error_log(date("Y-m-d H:i:s") . " ${pid} distcc.php check point 100");

curl_setopt($ch, CURLOPT_URL, $target);
curl_setopt($ch, CURLOPT_POST, true);
// curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query(['data' => base64_encode(gzencode($request_data))]));
curl_setopt($ch, CURLOPT_POSTFIELDS, gzencode($request_data));

error_log(date("Y-m-d H:i:s") . " ${pid} distcc.php check point 110");

curl_setopt($ch, CURLOPT_ENCODING, '');
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_USERPWD, getenv('BASIC_USER') . ':' . getenv('BASIC_PASSWORD'));

error_log(date("Y-m-d H:i:s") . " ${pid} distcc.php check point 120");

$res = curl_exec($ch);

error_log(date("Y-m-d H:i:s") . " ${pid} distcc.php check point 130 " . strlen($res));

$http_code = (string)curl_getinfo($ch, CURLINFO_HTTP_CODE);

error_log(date("Y-m-d H:i:s") . " ${pid} distcc.php check point 140 ${http_code}");

curl_close($ch);

error_log(date("Y-m-d H:i:s") . " ${pid} distcc.php check point 150");

$rc = $mc->decrement('DISTCCD_URL_' . $target);

error_log(date("Y-m-d H:i:s") . " ${pid} distcc.php check point 160 ${rc} ${target}");

$mc->quit();

error_log(date("Y-m-d H:i:s") . " ${pid} distcc.php check point 170");

echo base64_decode($res);

error_log(date("Y-m-d H:i:s") . " ${pid} distcc.php check point 180");
