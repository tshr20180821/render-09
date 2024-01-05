<?php

$data = base64_decode(file_get_contents('php://input'));

// exec /usr/bin/distccd --log-level warning --log-file ${DISTCC_LOG} $@
$res = passthru("exec /usr/bin/distccd --log-level warning --log-file /var/www/html/distcc_log.txt ${data}");

echo base64_encode($res);
