<?php

require '../../vendor/autoload.php';
require '../../config/config.php';

use \Httpful\Request;

    function time_elapsed_A($secs){
        $bit = array(
            'y' => $secs / 31556926 % 12,
            'w' => $secs / 604800 % 52,
            'd' => $secs / 86400 % 7,
            'h' => $secs / 3600 % 24,
            'm' => $secs / 60 % 60,
            's' => $secs % 60
        );

        foreach($bit as $k => $v)
            if($v > 0)$ret[] = $v . $k;

        return join(' ', $ret);
    }

    // Print system resources
    function rutime($ru, $rus, $index) {
        return ($ru["ru_$index.tv_sec"]*1000 + intval($ru["ru_$index.tv_usec"]/1000))
       -  ($rus["ru_$index.tv_sec"]*1000 + intval($rus["ru_$index.tv_usec"]/1000));
    }

    // Lets see how much system resources we use
    $rustart = getrusage();

    // Lest see wall clock time on this run

    $start_time = time();

$census = new \Code4KC\Address\Census();

$row = 0;
$out = array();
$names = array();

global $dbh;

$totals = array(
    'input' => array('insert' => 0, 'update' => 0, 'N/A' => 0, 'error' => 0),
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

$sql = 'SELECT a.id, a.street_number, a.pre_direction, a.street_name, a.street_type, a.post_direction, a.internal, a.city, a.state, a.zip, k.city_address_id, k.county_address_id, c.city_address_id AS census_city_address_id FROM address a 
LEFT JOIN address_keys k ON ( k.address_id = a.id) 
LEFT JOIN census_attributes c ON ( k.city_address_id = c.city_address_id) 
ORDER BY a.id DESC';

$query = $dbh->prepare("$sql  -- " . __FILE__ . ' ' . __LINE__);

try {
    $query->execute();
} catch (PDOException  $e) {
    error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
    //throw new Exception('Unable to query database');
    return false;
}
$row = 0;
$count = 0;
while ($address_rec = $query->fetch(PDO::FETCH_ASSOC)) {
    $row++;
    $census_city_address_id = $address_rec['census_city_address_id'];

    if ( !empty($census_city_address_id ) ) {
        $totals['input']['N/A']++;
        continue;
    }

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

    // http://geocoding.geo.census.gov/geocoder/geographies/onelineaddress?address=210+west+oak+st%2C+greenwood+mo&benchmark=4&vintage=4
    //   Benchmark: Public_AR_Current
    //   Vintage:   Curent_Curent

    $uri = "http://geocoding.geo.census.gov/geocoder/geographies/address?street=$street&city=$city&state=$state&zip=$zip&benchmark=4&vintage=4&format=json";

    $response = Request::get($uri)->send();

    sleep(1);

    if (property_exists($response, 'body')
        && property_exists($response->body, 'result')
        && property_exists($response->body->result, 'addressMatches')
    ) {
        $address_id = $address_rec['id'];
//print "\n$address_id:";
        $c_matches = $response->body->result->addressMatches;

        if (!empty($c_matches)) {

            $f_rec = $c_matches['0'];
//print "---------------------------------------------\n";
//print_r($address_rec);
//print_r($f_rec);
            $zip = $f_rec->addressComponents->zip;

            $new_rec = array(
                'id' => $address_id,
                'zip' => $zip,
            );

            if ($address_differences = $address->diff($address_rec, $new_rec)) {
                $address->update($address_id, $address_differences);
                $totals['address']['update']++;
//print 'u';
            } else {
                $totals['address']['N/A']++;
            }

            $new_rec = array();
            $new_rec['id'] = $address_id;
            if ( property_exists( $f_rec->geographies->{'2010 Census Blocks'}['0'], 'NAME' ))  $new_rec['block_2010_name'] = $f_rec->geographies->{'2010 Census Blocks'}['0']->NAME;
            if ( property_exists( $f_rec->geographies->{'2010 Census Blocks'}['0'], 'BLOCK' )) $new_rec['block_2010_id'] = $f_rec->geographies->{'2010 Census Blocks'}['0']->BLOCK;
            if ( property_exists( $f_rec->geographies->{'Census Tracts'}['0'], 'NAME' )) $new_rec['tract_name'] = $f_rec->geographies->{'Census Tracts'}['0']->NAME;
            if ( property_exists( $f_rec->geographies->{'Census Tracts'}['0'], 'BLOCK' )) $new_rec['tract_id'] = $f_rec->geographies->{'Census Tracts'}['0']->TRACT;
            $new_rec['zip'] = $zip;
            if ( property_exists( $f_rec->geographies->Counties['0'], 'COUNTY' )) $new_rec['county_id'] = $f_rec->geographies->Counties['0']->COUNTY;
            if ( property_exists( $f_rec->geographies->States['0'], 'STATE' )) $new_rec['state_id'] =  $f_rec->geographies->States['0']->STATE;
            $new_rec['longitude'] = $f_rec->coordinates->x;
            $new_rec['latitude'] = $f_rec->coordinates->y;
            $new_rec['tiger_line_id'] = $f_rec->tigerLine->tigerLineId;
            $new_rec['city_address_id'] = $address_rec['city_address_id'];
            $new_rec['county_address_id'] = $address_rec['county_address_id'];



            if ($census_attributes_rec = $census_attributes->find_by_id($address_id)) {
                $census_attributes_id = $census_attributes_rec['id'];
                if ($city_address_attribute_differences = $census_attributes->diff($census_attributes_rec, $new_rec)) {
                    $census_attributes->update($census_attributes_id, $city_address_attribute_differences);
                    $totals['census_attributes']['update']++;
//print "U";
                } else {
                    $totals['census_attributes']['N/A']++;
                }
            } else {
//print_r($new_rec);
                $census_attributes->add($new_rec);
//print "A";
                $totals['census_attributes']['insert']++;
            }

        } else {
            // Census did not find a matching address.
//print "No match found for $street $city, $state, $zip";

        }

    } else {
//print "Census returned bad results for $street $city, $state, $zip";
    }



}

print "\n\nTotals\n--------------------------------------------------------------------------\n";

printf("%-30.30s %10s %10s %10s %10s\n", 'table', 'insert', 'update', 'N/A', 'ERROR');
foreach ($totals AS $table => $counts) {
    printf("%-30.30s %10d %10d %10d %10d\n", $table, $counts['insert'], $counts['update'], $counts['N/A'], $counts['error']);
}
print "--------------------------------------------------------------------------\n\n";


print "Number of lines processed $row\n\n";

    // Calcuate how much time this took

    $end_time = time();
    $time_diff = $end_time - $start_time ;

    if ( $time_diff > 0 ) {
        $time_diff = time_elapsed_A( $time_diff );
    } else {
        $time_diff = ' 0 seconds';
    }


    $ru = getrusage();
    $str =  "This process used " . rutime($ru, $rustart, "utime") .
        " ms for its computations\n";

    print "\n";
    print $str;

    $str = "It spent " . rutime($ru, $rustart, "stime") .
        " ms in system calls\n";

    print $str;


    // Print end message with time it took
    print "Run time:  $time_diff\n";

    print "\n\n";

