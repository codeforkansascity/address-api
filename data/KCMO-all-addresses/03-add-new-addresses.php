<?php

require '../../vendor/autoload.php';
require '../../config/config.php';
require '../../vendor/Convissor/address/AddressStandardizationSolution.php';

function time_elapsed_A($secs)
{
    $bit = array(
        'y' => $secs / 31556926 % 12,
        'w' => $secs / 604800 % 52,
        'd' => $secs / 86400 % 7,
        'h' => $secs / 3600 % 24,
        'm' => $secs / 60 % 60,
        's' => $secs % 60
    );

    foreach ($bit as $k => $v)
        if ($v > 0) $ret[] = $v . $k;

    return join(' ', $ret);
}

// Print system resources
function rutime($ru, $rus, $index)
{
    return ($ru["ru_$index.tv_sec"] * 1000 + intval($ru["ru_$index.tv_usec"] / 1000))
    - ($rus["ru_$index.tv_sec"] * 1000 + intval($rus["ru_$index.tv_usec"] / 1000));
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
    'address' => array('insert' => 0, 'update' => 0, 'N/A' => 0, 'error' => 0),
    'address_alias' => array('insert' => 0, 'update' => 0, 'N/A' => 0, 'error' => 0),
    'address_keys' => array('insert' => 0, 'update' => 0, 'N/A' => 0, 'error' => 0),
    'tmp_kcmo_all_addresses' => array('insert' => 0, 'update' => 0, 'N/A' => 0, 'error' => 0),
);

print "\n" . $argv[0] . "\n";
for ( $i =0; $i < strlen($argv[0]); $i++) print "-";
print "\n";
print "dbname=$DB_NAME\n";

try {
    $dbh = new PDO("pgsql:host=localhost; dbname=$DB_NAME", $DB_USER, $DB_PASS);
} catch (PDOException $e) {
    error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
    return false;
}

$address_converter = new Convissor\address\AddressStandardizationSolution();
$address = new \Code4KC\Address\Address($dbh, true);
$address_alias = new \Code4KC\Address\AddressAlias($dbh, true);
$address_keys = new \Code4KC\Address\AddressKeys($dbh, true);

$update_query = $dbh->prepare('UPDATE tmp_kcmo_all_addresses SET address_api_id = :address_api_id WHERE id = :id;');


$sql = 'SELECT id, address_api_id, kiva_pin, city_apn, addr, fraction, prefix, street, street_type, suite, city, state, zip
FROM tmp_kcmo_all_addresses';

$query = $dbh->prepare("$sql  -- " . __FILE__ . ' ' . __LINE__);

try {
    $query->execute();
} catch (PDOException  $e) {
    error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
    //throw new Exception('Unable to query database');
    return false;
}


$row = 0;

while ($address_rec = $query->fetch(PDO::FETCH_ASSOC)) {

    $row++;

    // Build address line

    $single_line_address = '';
    $single_line_address .= $address_rec['addr'];
    $single_line_address .= !empty($address_rec['fraction']) ? ' ' . $address_rec['fraction'] : '';
    $single_line_address .= !empty($address_rec['prefix']) ? ' ' . $address_rec['prefix'] : '';
    $single_line_address .= !empty($address_rec['street']) ? ' ' . $address_rec['street'] : '';
    $single_line_address .= !empty($address_rec['street_type']) ? ' ' . $address_rec['street_type'] : '';
    $single_line_address .= !empty($address_rec['suite']) ? ' ' . $address_rec['suite'] : '';
    $single_line_address .= !empty($address_rec['city']) ? ', ' . $address_rec['city'] : '';
    $single_line_address .= !empty($address_rec['state']) ? ', ' . $address_rec['state'] : '';

    $single_line_address = strtoupper($single_line_address);


    // See if it exists, if not then we are going to add it.

    $existing_address_alias_rec = $address_alias->find_by_single_line_address($single_line_address);

    if (!$existing_address_alias_rec) {

        $address_id = 0;


        if ($existing_address_rec = $address->find_by_single_line_address($single_line_address)) {       // Just in case we had a failuer to clean up
            $address_id = $existing_address_rec['id'];
            $totals['address']['N/A']++;

        } else {

            $rec = array();
            $rec['single_line_address'] = $single_line_address;
            $rec['street_number'] = $address_rec['addr'];
            $rec['street_number'] .= !empty($address_rec['fraction']) ? ' ' . $address_rec['fraction'] : '';
            $rec['pre_direction'] = !empty($address_rec['prefix']) ? $address_rec['prefix'] : '';
            $rec['street_name'] = !empty($address_rec['street']) ? $address_rec['street'] : '';
            $rec['street_type'] = !empty($address_rec['street_type']) ? $address_rec['street_type'] : '';
            $rec['internal'] = !empty($address_rec['suite']) ? $address_rec['suite'] : '';
            $rec['city'] = !empty($address_rec['city']) ? $address_rec['city'] : '';
            $rec['state'] = !empty($address_rec['state']) ? $address_rec['state'] : '';
            $rec['zip'] = !empty($address_rec['zip']) ? $address_rec['zip'] : '';

            $address_id = $address->add($rec);
            $totals['address']['insert']++;
        }

        $new_rec = array(
            'single_line_address' => $single_line_address,
            'address_id' => $address_id
        );

        $address_alias->add($new_rec);
        $totals['address_alias']['insert']++;

        // Update temporary table with address ids

        $values = array(
            ':address_api_id' => $address_id,
            ':id' => $address_rec['id']
        );

        try {
            $ret = $update_query->execute($values);
            $totals['tmp_kcmo_all_addresses']['update']++;
        } catch (PDOException  $e) {
            $totals['tmp_kcmo_all_addresses']['error']++;
            print ('UPDATE ERROR: ' . $e->getMessage() . "\n");
        }

        // ADD to address keys

        $new_rec = array('address_id' => $address_id,
            'city_address_id' => $address_rec['kiva_pin'],
            'county_address_id' => $address_rec['city_apn']
        );

        if ($address_keys_rec = $address_keys->find_by_address_id($address_id)) {
            $address_key_id = $address_keys_rec['id'];
            if ($address_key_differences = $address_keys->diff($address_keys_rec, $new_rec)) {
                $address_keys->update($address_key_id, $address_key_differences);
                $totals['address_keys']['update']++;
            } else {
                $totals['address_keys']['N/A']++;
            }
        } else {
            $address_keys->add($new_rec);
            $totals['address_keys']['insert']++;
        }

    } else {
        $totals['tmp_kcmo_all_addresses']['N/A']++;
    }


    // Do we want to add keys records?


}


print "\nTotals\n--------------------------------------------------------------------------\n";

printf("%-30.30s %10s %10s %10s %10s\n", 'table', 'insert', 'update', 'N/A', 'ERROR');
foreach ($totals AS $table => $counts) {
    printf("%-30.30s %10d %10d %10d %10d\n", $table, $counts['insert'], $counts['update'], $counts['N/A'], $counts['error']);
}
print "--------------------------------------------------------------------------\n\n";


print "Number of lines processed $row including header\n";

// Calcuate how much time this took

$end_time = time();
$time_diff = $end_time - $start_time;

if ($time_diff > 0) {
    $time_diff = time_elapsed_A($time_diff);
} else {
    $time_diff = ' 0 seconds';
}


$ru = getrusage();
$str = "This process used " . rutime($ru, $rustart, "utime") .
    " ms for its computations\n";


print $str;

$str = "It spent " . rutime($ru, $rustart, "stime") .
    " ms in system calls\n";

print $str;


// Print end message with time it took
print "Run time:  $time_diff\n";