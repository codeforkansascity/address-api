<?php

require '../../vendor/autoload.php';
require '../../config/config.php';

use \Httpful\Request;


$census = new \Code4KC\Address\Census();

$row = 0;
$out = array();
$names = array();

global $dbh;

$totals = array(
    'address' => array('insert' => 0, 'update' => 0, 'N/A' => 0, 'error' => 0),
    'census_attributes' => array('insert' => 0, 'update' => 0, 'N/A' => 0, 'error' => 0),
);

    try {
        $dbh = new PDO("pgsql:dbname=$DB_NAME", $DB_USER, $DB_PASS);


    } catch (PDOException $e) {
        error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
        throw new Exception('Unable to connect to database');
    }


$address = new \Code4KC\Address\Address($dbh, true);
$census_attributes = new \Code4KC\Address\CensusAttributes($dbh, true);

            $sql = 'SELECT * FROM address';
            $query = $dbh->prepare("$sql  -- " . __FILE__ . ' ' . __LINE__);

        try {
            $query->execute();
        } catch (PDOException  $e) {
            error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
            //throw new Exception('Unable to query database');
            return false;
        }
$row = 0;
        while ( $address_rec =  $query->fetch(PDO::FETCH_ASSOC) ) {
        $row++;

        $street_number = $address_rec['street_number'];
        $pre_direction = $address_rec['pre_direction'];
        $street_name = $address_rec['street_name'];
        $street_type = $address_rec['street_type'];
        $post_direction = $address_rec['post_direction'];
        $internal = $address_rec['internal'];
        $city = $address_rec['city'];
        $state = $address_rec['state'];
        $zip = $address_rec['zip'];

        $street = urlencode(trim(preg_replace('/\s+/', ' ', "$street_number $pre_direction $street_name $street_type $post_direction $internal")));
        $city = urlencode(trim(preg_replace('/\s+/', ' ', "$city")));
        $uri = "http://geocoding.geo.census.gov/geocoder/geographies/address?street=$street&city=$city&state=$state&zip=$zip&benchmark=4&vintage=4&format=json";

$response = Request::get($uri)->send();

print_r($response);

if ( property_exists($response,'body')
&& property_exists($response->body,'result')
&& property_exists($response->body->result,'addressMatches')){

	$c_matches = $response->body->result->addressMatches;

	if ( !empty($c_matches) ) {

		$f_rec = $c_matches['0'] ;

                        $address_id =  $address_rec['id'];
                    $new_rec = array(
                        'id' => $address_id,
                        'zip' => $f_rec->addressComponents->zip
                    );

                    if ( $address_differences = $address->diff($address_rec, $new_rec) ) {
                        $address->update( $address_id, $address_differences );
                        $totals['address']['update']++;
                    } else {
                        $totals['address']['N/A']++;
                    }

        
        $new_rec = array();
		$new_rec['id'] = $address_id;
		$new_rec['county_name'] = $f_rec->geographies->Counties['0']->NAME;
		$new_rec['county_census_id'] = $f_rec->geographies->Counties['0']->COUNTY;
		$new_rec['state_name'] = $f_rec->geographies->States['0']->NAME;
		$new_rec['state_census_id'] = $f_rec->geographies->States['0']->STATE;
        $new_rec['census_tract_name'] = $f_rec->geographies->{'Census Tracts'}['0']->NAME;
        $new_rec['census_tract_id'] = $f_rec->geographies->{'Census Tracts'}['0']->TRACT;
        $new_rec['census_block_2010_name'] = $f_rec->geographies->{'2010 Census Blocks'}['0']->NAME;
        $new_rec['census_block_2010_id'] = $f_rec->geographies->{'2010 Census Blocks'}['0']->BLOCK;
        $new_rec['longitude'] = $f_rec->coordinates->x;
        $new_rec['latitude'] = $f_rec->coordinates->y;
        $new_rec['tiger_line_id'] = $f_rec->tigerLine->tigerLineId;

                    if ( $census_attributes_rec = $census_attributes->find_by_id( $address_id ) ) {
                        $census_attributes_id = $census_attributes_rec[ 'id' ];
                        if ( $city_address_attribute_differences = $census_attributes->diff($census_attributes_rec, $new_rec) ) {
                            $census_attributes->update( $census_attributes_id, $city_address_attribute_differences );
                            $totals['census_attributes']['update']++;
                        } else {
                            $totals['census_attributes']['N/A']++;
                        }
                    } else {
                        $census_attributes->add( $new_rec );
                        $totals['census_attributes']['insert']++;
                    }

	}

}

print "\$zip=$zip\n";
print "\$county_name=$county_name\n";
print "\$county_census_id=$county_census_id\n";
print "\$state_name=$state_name\n";
print "\$state_census_id=$state_census_id\n";
print "\$census_tract_name=$census_tract_name\n";
print "\$census_tract_id=$census_tract_id\n";
print "\$census_block_2010_name=$census_block_2010_name\n";
print "\$census_block_2010_id=$census_block_2010_id\n";



        }

    print "\nTotals\n--------------------------------------------------------------------------\n";

    printf("%-30.30s %10s %10s %10s %10s\n", 'table', 'insert', 'update', 'N/A', 'ERROR');
    foreach ( $totals AS $table => $counts ) {
        printf("%-30.30s %10d %10d %10d %10d\n", $table, $counts['insert'], $counts['update'], $counts['N/A'], $counts['error']);
    }
    print "--------------------------------------------------------------------------\n\n";


    print "Number of lines processed $row\n\n";


