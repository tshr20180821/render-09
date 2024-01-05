<?php

error_log("start distcc_wrapper.php");

$data = file_get_contents('php://input');
error_log("data start");
error_log(strlen($data));
error_log(base64_decode($data));
error_log("data finish");
$data = base64_decode($data);

// exec /usr/bin/distccd --log-level warning --log-file ${DISTCC_LOG} $@
# $res = shell_exec("exec /usr/bin/distccd --log-level warning --log-file /var/www/html/distcc_log.txt ${data}");
$handle = popen("exec /usr/bin/distccd --log-level debug --log-file /var/www/html/distccd_log.txt " . $data, "rb");
$res = '';
while (!feof($handle)) {
    $res .= fread($handle, 8192);
}
pclose($handle);

error_log("res start");
error_log(strlen(base64_encode($res)));
error_log("res finish");

echo base64_encode($res);

error_log("finish distcc_wrapper.php");
