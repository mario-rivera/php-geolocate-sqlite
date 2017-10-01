<?php 
require_once __DIR__.'/../vendor/autoload.php';

use mrivera\ip2location\IpLocator;

$locator = new IpLocator( new SQLite3(IP2LOCATION_DB3) );

// '46.244.106.52'
// '122.208.118.194'
// '222.10.43.121'
// '58.90.228.8'
$result = $locator->locate( '222.10.43.121' );
var_dump( $result );
