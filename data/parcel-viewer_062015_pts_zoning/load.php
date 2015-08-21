<?php

require '../../vendor/autoload.php';
require '../../config/config.php';

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
    'address_keys' => array('insert' => 0, 'update' => 0, 'N/A' => 0, 'error' => 0),
    'city_address_attributes' => array('insert' => 0, 'update' => 0, 'N/A' => 0, 'error' => 0),
);

if (($handle = fopen("KCMO_06152015_Parcel_PTs_Zoning.csv", "r")) !== FALSE) {
    try {
        $dbh = new PDO("pgsql:dbname=$DB_NAME", $DB_USER, $DB_PASS);
    } catch (PDOException $e) {
        error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
        throw new Exception('Unable to connect to database');
    }

    $address = new \Code4KC\Address\Address($dbh, true);
    $address_keys = new \Code4KC\Address\AddressKeys($dbh, true);
    $city_address_attributes = new \Code4KC\Address\CityAddressAttributes($dbh, true);

    $names = array(
	'id', 'longitude', 'latitude', 'land_use_code', 'classification', 'land_use', 'sub_class'
    );

    
    while (($data = fgetcsv($handle, 1000, ",")) !== FALSE) {
        $num = count($data);
        $row++;
        print "$row\n";

        if ($row == 1) {

        } else {
            $rec = array();
            for ($c = 0; $c < $num; $c++) {
                $rec [$names [$c]] = $data[$c];
            }
            $city_address_id = $rec['id'];

if ( empty($city_address_id ) ) {
    print "EROOR: empty city id on line $row\n";
    $totals['input']['error']++;
    continue;

}
            if ( $address_keys_rec = $address_keys->find_by_city_address_id( $city_address_id ) ) {
                $address_id = $address_keys_rec[ 'address_id' ];
                if ( $address_rec = $address->find_by_id( $address_id )) {
                    $new_rec = array(
                        'id' => $address_id,
                        'longitude' => $rec['longitude'],
                        'latitude' => $rec['latitude']
                    );

                    if ( $address_differences = $address->diff($address_rec, $new_rec) ) {
                        $address->update( $address_id, $address_differences );
                        $totals['address']['update']++;
                    } else {
                        $totals['address']['N/A']++;
                    }

                    $new_rec = array(
                        'id' => $city_address_id,
                        'land_use_code' => $rec['land_use_code'],
                        'classification' => $rec['classification'],
                        'land_use' => $rec['land_use'],
                        'sub_class' => $rec['sub_class']
                    );

                    if ( $city_address_attributes_rec = $city_address_attributes->find_by_id( $city_address_id ) ) {
                        $city_address_attributes_id = $city_address_attributes_rec[ 'id' ];
                        if ( $city_address_attribute_differences = $city_address_attributes->diff($city_address_attributes_rec, $new_rec) ) {
                            $city_address_attributes->update( $city_address_attributes_id, $city_address_attribute_differences );
                            $totals['city_address_attributes']['update']++;
                        } else {
                            $totals['city_address_attributes']['N/A']++;
                        }
                    } else {
                        $city_address_attributes->add( $new_rec );
                        $totals['city_address_attributes']['insert']++;
                    }
                    
                } else {
                    print "ERROR address id $address_id not found, line $row\n";
                    $totals['address']['error']++;
                }
            } else {
                print "ERROR address_keys for city id $city_address_id not found, line $row\n";
                $totals['address_keys']['error']++;
            }

        }
    }
    fclose($handle);

    print "\nTotals\n--------------------------------------------------------------------------\n";

    printf("%-30.30s %10s %10s %10s %10s\n", 'table', 'insert', 'update', 'N/A', 'ERROR');
    foreach ( $totals AS $table => $counts ) {
        printf("%-30.30s %10d %10d %10d %10d\n", $table, $counts['insert'], $counts['update'], $counts['N/A'], $counts['error']);
    }
    print "--------------------------------------------------------------------------\n\n";
    
}
    print "NOTE: We should not be inserting records\n";
    print "Number of lines processed $row including header\n\n";


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

