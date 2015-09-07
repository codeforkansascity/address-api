<?php

require '../../vendor/autoload.php';
require '../../config/config.php';


class CouncilDistricts extends \Code4KC\Address\BaseTable
{

    var $query = null;
    var $table_name = 'address_spatial.mo_kc_city_council_districts_2012';
    var $primary_key_sequence = null;
    var $fields = array(
        'district' => '',
        'geom' => '',
    );

    function find_name_by_lng_lat( $lng, $lat ) {
        if (!$this->query) {
            $sql = 'SELECT district  FROM ' . $this->table_name . ' WHERE ST_Intersects( ST_MakePoint( :lng, :lat), geom);';
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
    'city_address_attributes' => array('insert' => 0, 'update' => 0, 'N/A' => 0, 'error' => 0),
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
$city_address_attributes = new \Code4KC\Address\CityAddressAttributes($dbh, true);
$code4kc = new CouncilDistricts($dbh_code4kc, true);

$sql = 'SELECT a.id, a.longitude, a.latitude, k.city_address_id FROM address a 
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
    $city_address_id = $rec['city_address_id'];

    if ( empty($city_address_id ) ) {
        $totals['input']['N/A']++;
        continue;
    }



    $cc_rec = $code4kc->find_name_by_lng_lat($lng, $lat);

    print_r($cc_rec);


print "\n\n$row, $lng, $lat, $city_address_id\n ";
    $new_rec = array('council_district' => $cc_rec['district']);

    if ( $city_address_attributes_rec = $city_address_attributes->find_by_id( $city_address_id ) ) {
        $city_address_attributes_id = $city_address_attributes_rec[ 'id' ];
        if ( $city_address_attribute_differences = $city_address_attributes->diff($city_address_attributes_rec, $new_rec) ) {
            $city_address_attributes->update( $city_address_attributes_id, $city_address_attribute_differences );
            $totals['city_address_attributes']['update']++;
        } else {
            $totals['city_address_attributes']['N/A']++;
        }
    } else {
//        $city_address_attributes->add( $new_rec );
print "\nEEEE\n";
        $totals['city_address_attributes']['insert']++;
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

