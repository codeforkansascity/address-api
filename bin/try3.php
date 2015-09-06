<?php


$client = new Zend_Http_Client('http://geocoding.geo.census.gov/geocoder/geographies/address');


 $client->setParameterGet(array( 
	'street' => '210 W 19th terrace',
	'city' =>  'Kansas City',
	'state' => 'MO',
	'zip' => '',
	'benchmark' => 4,
	'vintage' => 4,
	'format' => 'json'));

$response = $client->request();

debug($response);

die;


//$result = $client->execute('geocoder/geographies/address', array( 'address' => '210 W 19th terrace, Kansas City, MO'));



http://geocoding.geo.census.gov/geocoder/geographies/address?street=210+w+19th+terrace&city=kansas+city&state=mo&zip=&benchmark=4&vintage=4&format=json
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



