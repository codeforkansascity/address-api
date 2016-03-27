<?php

require '../../vendor/autoload.php';
require '../../config/config.php';

require './AddressStandardizationSolution.php';


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
    'input' => array('insert' => 0, 'update' => 0, 'NotJA' => 0, 'NotFound' => 0, 'N/A' => 0, 'error' => 0),
    'tmp_kcmo_all_addresses' => array('insert' => 0, 'update' => 0, 'NotJA' => 0, 'NotFound' => 0, 'N/A' => 0, 'error' => 0),
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


// ============================================================


$address_alias = new \Code4KC\Address\AddressAlias($dbh, true);
$address = new \Code4KC\Address\Address($dbh, true);

$address_converter = new AddressStandardizationSolution();

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

$update_query = $dbh->prepare('UPDATE tmp_kcmo_all_addresses SET address_api_id = :address_api_id , zip = :zip WHERE id = :id;');

$row = 0;
$count = 0;

while ($address_rec = $query->fetch(PDO::FETCH_ASSOC)) {
    $row++;

    if (!empty($address_rec['address_api_id'])) {
        $totals['tmp_kcmo_all_addresses']['error']++;
        continue;
    }
    if (substr($address_rec['city_apn'], 0, 2) != 'JA') {  // skip non jackson county
        $totals['tmp_kcmo_all_addresses']['NotJA']++;
        continue;
    }

    $id = $address_rec['id'];

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

    $exisiting_address_alias_rec = $address_alias->find_by_single_line_address($single_line_address);

    if ($exisiting_address_alias_rec) {
        $address_id = $exisiting_address_alias_rec['address_id'];

        $exisiting_address_rec = $address->find_by_id($address_id);

        $values = array(
            ':address_api_id' => $exisiting_address_rec['id'],
            ':zip' => $exisiting_address_rec['zip'],
            ':id' => $id
        );
        try {
            $ret = $update_query->execute($values);
            $totals['tmp_kcmo_all_addresses']['update']++;
        } catch (PDOException  $e) {
            $totals['tmp_kcmo_all_addresses']['error']++;
            print ('UPDATE ERROR: ' . $e->getMessage() . "\n");
        }

    } else {
        $totals['tmp_kcmo_all_addresses']['NotFound']++;
//        print "ERROR NOT FOUND $single_line_address - " . $address_rec['city_apn'] . "\n";
    }

}

// ============================================================


print "\nTotals\n--------------------------------------------------------------------------\n";

printf("%-30.30s %10s %10s %10s %10s\n", 'table', 'insert', 'update', 'NotJA', 'NotFound', 'N/A', 'error');
foreach ($totals AS $table => $counts) {
    printf("%-30.30s %10d %10d %10d %10d\n", $table, $counts['insert'], $counts['update'], $counts['NotJA'], $counts['NotFound'], $counts['N/A'], $counts['error']);
}
print "--------------------------------------------------------------------------\n\n";


print "Number of lines processed $row\n";

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



