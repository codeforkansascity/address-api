<?php

require '../../vendor/autoload.php';
require '../../config/config.php';


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


// ============================================================


$row = 1;

ini_set("auto_detect_line_endings", true);

// Build preparied statement

$names = '';
$values = '';                                                                               // Build it
$sep = '';
$fields = array(
    'kiva_pin' => 'kiva_pin',
    'city_apn' => 'city_apn',
    'addr' => 'addr',
    'fraction' => 'fraction',
    'prefix' => 'prefix',
    'street' => 'street',
    'street_type' => 'street_type',
    'suite' => 'suite'
);

foreach ($fields AS $f => $v) {
    $names .= $sep . $f;
    $values .= $sep . ':' . $f;
    $sep = ', ';
}

$sql = 'INSERT INTO tmp_kcmo_all_addresses (' . $names . ') VALUES (' . $values . ')';
$add_query = $dbh->prepare("$sql  -- " . __FILE__ . ' ' . __LINE__);

if (($handle = fopen("KCMO_Address_11_24_2015.csv", "r")) !== FALSE) {
    $row = 0;
    while (($data = fgetcsv($handle, 1000, ",")) !== FALSE) {
        $row++;

        if ($row == 1) {
            $totals['input']['N/A']++;
            continue;
        }

        $totals['input']['insert']++;

        $data[7] = array_key_exists(7, $data) ? $data[7] : '';
        $new_rec = array();
        $new_rec[':kiva_pin'] = $data[0];
        $new_rec[':city_apn'] = $data[1];
        $new_rec[':addr'] = $data[2];
        $new_rec[':fraction'] = $data[3];
        $new_rec[':prefix'] = $data[4];
        $new_rec[':street'] = $data[5];
        $new_rec[':street_type'] = $data[6];
        $new_rec[':suite'] = $data[7];

        try {
            $ret = $add_query->execute($new_rec);
            if (!$ret) {
                $totals['tmp_kcmo_all_addresses']['error']++;
                print_r($new_rec);
                var_dump($ret);
                print("\nROW=$row\n----------------------------------\n ");
            } else {
                $totals['tmp_kcmo_all_addresses']['insert']++;
            }
        } catch (PDOException  $e) {
            $totals['tmp_kcmo_all_addresses']['error']++;

            if ($totals['tmp_kcmo_all_addresses']['error'] > 20) break;

            die("ROW=$row " . $e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);

        }

    }
}
fclose($handle);

// ============================================================


print "\nTotals\n--------------------------------------------------------------------------\n";

printf("%-30.30s %10s %10s %10s %10s\n", 'table', 'insert', 'update', 'N/A', 'ERROR');
foreach ($totals AS $table => $counts) {
    printf("%-30.30s %10d %10d %10d %10d\n", $table, $counts['insert'], $counts['update'], $counts['N/A'], $counts['error']);
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

print "\n";
print $str;

$str = "It spent " . rutime($ru, $rustart, "stime") .
    " ms in system calls\n";

print $str;


// Print end message with time it took
print "Run time:  $time_diff\n";



