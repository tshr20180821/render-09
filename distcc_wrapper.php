<?php

$data = file_get_contents('php://input');
error_log("data start");
error_log($data);
error_log("data finish");
$data = base64_decode($data);

// exec /usr/bin/distccd --log-level warning --log-file ${DISTCC_LOG} $@
$res = passthru("exec /usr/bin/distccd --log-level warning --log-file /var/www/html/distcc_log.txt ${data}");

echo base64_encode($res);
