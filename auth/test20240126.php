<?php

$pdo = new PDO($_ENV['PDO_PGSQL_DSN']);

$statement_select = $pdo->prepare('SELECT version() VERSION');

$rc = $statement_select->execute();
$results = $statement_select->fetchAll();

foreach ($results as $row) {
    error_log($row['VERSION']);
}

$pdo = null;
