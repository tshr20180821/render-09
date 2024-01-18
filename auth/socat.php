<?php

$server = $_POST['server'];
$keyword = $_POST['keyword'];

if (strlen($keyword) != 64) {
    exit;
}

error_log("${server} ${keyword}");

exec('timeout -sKILL 60 | socat "exec:curl -u ' . "${BASIC_USER}:${BASIC_PASSWORD} https://${server}/${keyword}req | base64 -d" . '!!exec:base64 -w0 | curl -u ' . "${BASIC_USER}:${BASIC_PASSWORD} -sST - https://${server}/${keyword}res" . '" tcp:127.0.0.1:13632');
