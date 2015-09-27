<?php

require '../../../vendor/autoload.php';
require '../../../config/config.php';
require '../../../vendor/Convissor/address/AddressStandardizationSolution.php';

function convert2city_parcel_number($parcel_number) {
    $p = str_replace('-', '', $parcel_number);                  // Strip off the hypens 
    $p = "JA$p";                                                // Append the JA KCMO uses
    return $p;
}

class JacksonCountySpatial extends \Code4KC\Address\BaseTable
{

    var $query = null;
    var $table_name = 'address_spatial.jackson_county_mo_tax_neighborhoods';
    var $primary_key_sequence = null;
    var $fields = array(
        'gid' => '',
        'name' => '',
        'situs_address' => '',
        'situs_city' => '',
        'situs_state' => '',
        'situs_zip' => '',
        'parcel_number' => '',
        'owner' => '',
        'owner_address' => '',
        'owner_city' => '',
        'owner_state' => '',
        'owner_zip' => '',
        'stated_area' => '',
        'tot_sqf_l_area' => '',
        'year_built' => '',
        'property_area' => '',
        'property_picture' => '',
        'property_report' => '',
        'market_value' => '',
        'assessed_value' => '',
        'assessed_improvement' => '',
        'assessed_land' => '',
        'taxable_value' => '',
        'mtg_co' => '',
        'mtg_co_address' => '',
        'mtg_co_city' => '',
        'mtg_co_state' => '',
        'mtg_co_zip' => '',
        'common_area' => '',
        'floor_designator' => '',
        'floor_name_designator' => '',
        'exempt' => '',
        'complex_name' => '',
        'cid' => '',
        'tif_district' => '',
        'tif_project' => '',
        'neighborhood_code' => '',
        'pca_code' => '',
        'land_use_code' => '',
        'tca_code' => '',
        'document_number' => '',
        'book_number' => '',
        'conveyance_area' => '',
        'conveyance_designator' => '',
        'eff_from_date' => '',
        'eff_to_date' => '',
        'extract_date' => '',
        'legal_description' => '',
        'object_id' => '',
        'page_number' => '',
        'shape_st_area' => '',
        'shape_st_lenght' => '',
        'shape_st_area_1' => '',
        'shape_st_length_1' => '',
        'shape_st_legnth_2' => '',
        'shape_st_area_2' => '',
        'sim_con_div_type' => '',
        'tax_year' => '',
        'type' => '',
        'z_designator' => '',
    );

}

$census = new \Code4KC\Address\Census();

$row = 0;
$out = array();
$names = array();

global $dbh;
global $dbh_code4kc;

$totals = array(
    'input' => array('insert' => 0, 'update' => 0, 'N/A' => 0, 'error' => 0),
    'address' => array('insert' => 0, 'update' => 0, 'N/A' => 0, 'error' => 0),
    'address_alias' => array('insert' => 0, 'update' => 0, 'N/A' => 0, 'error' => 0),
    'address_keys' => array('insert' => 0, 'update' => 0, 'N/A' => 0, 'error' => 0),
    'county_address_attributes' => array('insert' => 0, 'update' => 0, 'N/A' => 0, 'error' => 0),
    'county_address_data' => array('insert' => 0, 'update' => 0, 'N/A' => 0, 'error' => 0),
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


$address_converter = new Convissor\address\AddressStandardizationSolution();
$address = new \Code4KC\Address\Address($dbh, true);
$address_alias = new \Code4KC\Address\AddressAlias($dbh, true);
$address_keys = new \Code4KC\Address\AddressKeys($dbh, true);
$county_address_attributes = new \Code4KC\Address\CountyAddressAttributes($dbh, true);
$county_address_data = new \Code4KC\Address\CountyAddressData($dbh, true);


$sql = "SELECT * FROM address_spatial.jackson_county_mo_tax_neighborhoods WHERE situs_city = 'KANSAS CITY' LIMIT 20 ";

$query = $dbh_code4kc->prepare("$sql  -- " . __FILE__ . ' ' . __LINE__);

try {
    $query->execute();
} catch (PDOException  $e) {
    error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
    //throw new Exception('Unable to query database');
    return false;
}

while ($data = $query->fetch(PDO::FETCH_ASSOC)) {
    $num = count($data);
    $row++;
    $parcel_number = $data['parcel_number'];
    $city_parcel_number = convert2city_parcel_number($parcel_number);


            $single_line_address = $address_converter->AddressLineStandardization($data['situs_address']);

            $single_line_address .= ', ' . strtoupper($data['situs_city']) . ', ' . strtoupper($data['situs_state']);                    // We keep unit 'internal'
                $normalized_address = $census->normalize_address($single_line_address);                // Strips off unit 'internal'

    print "$parcel_number $city_parcel_number $single_line_address\n";

            $data['id'] = $city_parcel_number;                      // FIX THIS IN V2

            $address_id = 0;
            if ($exisiting_address_alias_rec = $address_alias->find_by_single_line_address($single_line_address)) {
                $totals['address_alias']['N/A']++;
                $address_id = $exisiting_address_alias_rec['address_id'];


               if ($address_key_rec = $address_keys->find_by_county_address_id($city_parcel_number)) {
                    print_r($address_key_rec);
                    if ($county_address_rec = $county_address_attributes->find_by_id($city_parcel_number)) {
                    $totals['county_address_attributes']['N/A']++;
                    } else {
                    $county_address_attributes->add($data);
                    $totals['county_address_attributes']['insert']++;
                    }

                    if ($county_address_rec = $county_address_data->find_by_id($city_parcel_number)) {
                    $totals['county_address_data']['N/A']++;
                    } else {
                    $county_address_data->add($data);
                    $totals['county_address_data']['insert']++;
                    }
                } else {

                }
            } else {

            }    
}

print "\nTotals\n--------------------------------------------------------------------------\n";

printf("%-30.30s %10s %10s %10s %10s\n", 'table', 'insert', 'update', 'N/A', 'ERROR');
foreach ($totals AS $table => $counts) {
    printf("%-30.30s %10d %10d %10d %10d\n", $table, $counts['insert'], $counts['update'], $counts['N/A'], $counts['error']);
}
print "--------------------------------------------------------------------------\n\n";


print "Number of lines processed $row including header\n\n";
