<?php

$server = $_POST['server'];
$keyword = $_POST['keyword'];

if (strlen($keyword) != 64) {
    exit;
}

error_log("${server} ${keyword}");

exec('timeout -sKILL 60 socat "' . "exec:server=${server} keyword=${keyword} /usr/src/app/receive.sh!!server=${server} keyword=${keyword} /usr/src/app/send.sh" . '" tcp:127.0.0.1:13632');
