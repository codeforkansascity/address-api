<?php


require '../vendor/autoload.php';

// From https://github.com/fguillot/JsonRPC

use JsonRPC\Client;

$client = new Client('http://geocoding.geo.census.gov/geocoder/geographies');


$client->debug = true;

$result = $client->execute( 'address', array( 
	'street' => '210 W 19th terrace',
	'city' =>  'Kansas City',
	'state' => 'MO',
	'zip' => '',
	'benchmark' => 4,
	'vintage' => 4,
	'format' => 'json'));

var_dump($result);



