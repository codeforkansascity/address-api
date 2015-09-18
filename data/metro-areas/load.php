<?php

require '../../vendor/autoload.php';
require '../../config/config.php';


class Spatial extends \Code4KC\Address\BaseTable
{

    var $query = null;
    var $table_name = 'address_spatial.census_metro_areas';
    var $primary_key_sequence = null;
    var $fields = array(
        'name' => '',
        'geom' => '',
    );

    function find_name_by_lng_lat( $lng, $lat ) {
        if (!$this->query) {
            $sql = 'SELECT name  FROM ' . $this->table_name . ' WHERE ST_Intersects( ST_MakePoint( :lng, :lat), geom);';
            $this->query = $this->dbh->prepare("$sql  -- " . __FILE__ . ' ' . __LINE__);
        }

        try {
            $this->query->execute(array(':lat' => $lat, ':lng' => $lng));
        } catch (PDOException  $e) {
            error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
            //throw new Exception('Unable to query database');
            return false;
        }

        return $this->query->fetch(PDO::FETCH_ASSOC);
    }

}


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


$row = 0;
$out = array();
$names = array();

global $dbh;

$totals = array(
    'input' => array('insert' => 0, 'update' => 0, 'N/A' => 0, 'error' => 0),
    'census_attributes' => array('insert' => 0, 'update' => 0, 'N/A' => 0, 'error' => 0),
);

try {
    $dbh = new PDO("pgsql:dbname=$DB_NAME", $DB_USER, $DB_PASS);
} catch (PDOException $e) {
    error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
    throw new Exception('Unable to connect to database');
}

try {
    $dbh_code4kc = new PDO("pgsql:dbname=$DB_CODE4KC_NAME", $DB_CODE4KC_USER, $DB_CODE4KC_PASS);
} catch (PDOException $e) {
    error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
    throw new Exception('Unable to connect to database');
}

$address = new \Code4KC\Address\Address($dbh, true);
$census_attributes = new \Code4KC\Address\CityAddressAttributes($dbh, true);
$census_attributes = new \Code4KC\Address\CensusAttributes($dbh, true);
$code4kc = new Spatial($dbh_code4kc, true);

$sql = 'SELECT a.id, a.longitude, a.latitude, k.city_address_id 
FROM address a 
LEFT JOIN address_keys k ON ( k.address_id = a.id) 
LEFT JOIN census_attributes c ON ( k.city_address_id = c.city_address_id) ';

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
while ($rec = $query->fetch(PDO::FETCH_ASSOC)) {

    $row++;

    $lng = $rec['longitude'];
    $lat = $rec['latitude'];
    $address_id = $rec['id'];

    if ( empty($address_id ) ) {
        $totals['input']['N/A']++;
        continue;
    }



    $cc_rec = $code4kc->find_name_by_lng_lat($lng, $lat);



    $new_rec = array('metro_areas' => $cc_rec['name']);
    if ( $census_attributes_rec = $census_attributes->find_by_id( $address_id ) ) {
        $census_attributes_id = $census_attributes_rec[ 'id' ];
        if ( $city_address_attribute_differences = $census_attributes->diff($census_attributes_rec, $new_rec) ) {
            $census_attributes->update( $census_attributes_id, $city_address_attribute_differences );
            $totals['census_attributes']['update']++;
            print "$row, $lng, $lat, $address_id " . $cc_rec['name'] . "\n";
        } else {
            $totals['census_attributes']['N/A']++;
        }
    } else {
//        $census_attributes->add( $new_rec );
print "\nEEEE\n";
        $totals['census_attributes']['insert']++;
    }
    
}

print "\nTotals\n--------------------------------------------------------------------------\n";

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

