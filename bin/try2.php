<?php

require '../vendor/autoload.php';

use \Httpful\Request;

$uri = "http://geocoding.geo.census.gov/geocoder/geographies/address?street=219+w+19th+terrace&city=kansas+city&state=mo&zip=&benchmark=4&vintage=4&format=json";
$response = Request::get($uri)->send();

print_r($response);



