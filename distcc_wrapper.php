<?php

error_log("start distcc_wrapper.php");

$data = file_get_contents('php://input');
// error_log("data start");
// error_log($data);
// error_log("data finish");
$data = base64_decode($data);

// exec /usr/bin/distccd --log-level warning --log-file ${DISTCC_LOG} $@
$res = shell_exec("exec /usr/bin/distccd --log-level warning --log-file /var/www/html/distcc_log.txt ${data}");

error_log("res start");
error_log(strlen(base64_encode($res)));
error_log("res finish");

echo base64_encode($res);

error_log("finish distcc_wrapper.php");
