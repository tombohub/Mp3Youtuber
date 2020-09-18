<?php

//import accountsa iz accounts.txt u bazu

$dbh = new PDO('mysql:host=localhost;dbname=youtube', 'cika', 'password');
$accounts = file('accounts.txt');

foreach ($accounts as $account) {
	$account = rtrim($account);
	list($username, $password) = array_pad(explode(":", $account, 2), 2, null);
	
	$sql = "INSERT INTO accounts (username, password, free, status) VALUES ('$username','$password', 'yes', 'active')";
	$dbh->exec($sql) or die(print_r($dbh->errorInfo(), true));

}
	
$dbh = null;
