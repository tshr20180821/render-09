<?php

$pid = getmypid();

$data = file_get_contents("php://input");

echo $data;
