<?php
error_reporting(E_ALL ^ E_NOTICE);
require_once 'excel_reader2.php';

$header_map["1"] = "jrd_1";   // JRD_1
$header_map["2"] = "jrd_sheet";   // JRD_Sheet
$header_map["3"] = "order";   // Order
$header_map["4"] = "st_num";   // St_Num
$header_map["5"] = "street";   // Street
$header_map["6"] = "jrd_block";   // JRD_Block
$header_map["7"] = "jrd_address";   // JRD_Address
$header_map["8"] = "short_own";   // Short_Own
$header_map["9"] = "absentee_owner";   // AbsenteeOwner
$header_map["10"] = "kiva_pin";   // KIVA_Pin
$header_map["11"] = "county_apn_link";   // County_APN_Link
$header_map["12"] = "sub_division";   // Subdivision
$header_map["13"] = "block";   // Block
$header_map["14"] = "lot";   // Lot
$header_map["15"] = "owner";   // Owner
$header_map["16"] = "owner_2";   // Owner2
$header_map["17"] = "owner_address";   // OwnerAddress
$header_map["18"] = "owner_city_zip";   // OwnerCityZip
$header_map["19"] = "site_address";   // SiteAddress
$header_map["20"] = "zip_code";   // ZipCode
$header_map["21"] = "council_district";   // CouncilDistrict
$header_map["22"] = "trash_day";   // TrashDay
$header_map["23"] = "school_distrct";   // SchoolDistrct
$header_map["24"] = "census_neigh_borhood";   // CensusNeighborhood
$header_map["25"] = "park_region";   // ParkRegion
$header_map["26"] = "pw_maintenance_district";   // PWMaintenanceDistrict
$header_map["27"] = "zoning";   // Zoning
$header_map["28"] = "land_use";   // LandUse
$header_map["29"] = "blvd_front_footage";   // BlvdFrontFootage
$header_map["30"] = "effective_date";   // EffectiveDate
$header_map["31"] = "assessed_land";   // AssessedLand
$header_map["32"] = "assessed_improve";   // AssessedImprove
$header_map["33"] = "exempt_land";   // ExemptLand
$header_map["34"] = "exempt_improve";   // ExemptImprove
$header_map["35"] = "square_feet";   // SquareFeet
$header_map["36"] = "acres";   // Acres
$header_map["37"] = "perimeter";   // Perimeter
$header_map["38"] = "year_built";   // YearBuilt
$header_map["39"] = "living_area";   // LivingArea
$header_map["40"] = "tax_neighborhood_code";   // TaxNeighborhoodCode
$header_map["41"] = "parcel_area_sf";   // ParcelAreaSF
$header_map["42"] = "propert_class_pca_code";   // PropertClassPCACode
$header_map["43"] = "landuse_type";   // LandUseType
$header_map["44"] = "market_value";   // MarketValue
$header_map["45"] = "taxabl_evalue";   // TaxableValue
$header_map["46"] = "assessed_value";   // AssessedValue
$header_map["47"] = "tax_status";   // TaxStatus
$header_map["48"] = "legal_description";   // LegalDescription

$s = "INSERT INTO jd_wp (";
$sep = '';
for ( $i = 1; $i < 49; $i++) {
     $s .= "$sep`" . $header_map[$i] . "`";
     $sep = ", ";
}

$s .= ") VALUES (";

$sep = '';
for ( $i = 1; $i < 49; $i++) {
     $s .= "$sep?";
     $sep = ", ";
}

$s .= ")";

print "|$s|\n";



$sep = '';
$types = '';
$vars = '';
for ( $i = 1; $i < 49; $i++) {
     $types .= 's';
     $vars .= $sep."\$v[$i]";
     $sep = ', ';
     $v[$i] = '';

}


$bind_stmt = "\$stmt->bind_param('$types', $vars);\n";

print "\n\n\n";
print $bind_stmt;



$mysqli = new mysqli("localhost", "address_api", "address_api", "address_api");
if ($mysqli->connect_errno) {
    echo "Failed to connect to MySQL: (" . $mysqli->connect_errno . ") " . $mysqli->connect_error;
}

if (!$mysqli->query("DELETE FROM jd_wp")) {
    die ("Table delete failed: (" . $mysqli->errno . ") " . $mysqli->error);
}

/* Prepared statement, stage 1: prepare */
if (!($stmt = $mysqli->prepare("INSERT INTO jd_wp (`jrd_1`, `jrd_sheet`, `order`, `st_num`, `street`, `jrd_block`, `jrd_address`, `short_own`, `absentee_owner`, `kiva_pin`, `county_apn_link`, `sub_division`, `block`, `lot`, `owner`, `owner_2`, `owner_address`, `owner_city_zip`, `site_address`, `zip_code`, `council_district`, `trash_day`, `school_distrct`, `census_neigh_borhood`, `park_region`, `pw_maintenance_district`, `zoning`, `land_use`, `blvd_front_footage`, `effective_date`, `assessed_land`, `assessed_improve`, `exempt_land`, `exempt_improve`, `square_feet`, `acres`, `perimeter`, `year_built`, `living_area`, `tax_neighborhood_code`, `parcel_area_sf`, `propert_class_pca_code`, `landuse_type`, `market_value`, `taxabl_evalue`, `assessed_value`, `tax_status`, `legal_description`) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"))) {
     die( "Prepare failed: (" . $mysqli->errno . ") " . $mysqli->error);
}


if (!$stmt->bind_param('ssssssssssssssssssssssssssssssssssssssssssssssss', $v[1], $v[2], $v[3], $v[4], $v[5], $v[6], $v[7], $v[8], $v[9], $v[10], $v[11], $v[12], $v[13], $v[14], $v[15], $v[16], $v[17], $v[18], $v[19], $v[20], $v[21], $v[22], $v[23], $v[24], $v[25], $v[26], $v[27], $v[28], $v[29], $v[30], $v[31], $v[32], $v[33], $v[34], $v[35], $v[36], $v[37], $v[38], $v[39], $v[40], $v[41], $v[42], $v[43], $v[44], $v[45], $v[46], $v[47], $v[48])) {
    die( "Binding parameters failed: (" . $stmt->errno . ") " . $stmt->error);
}



$data = new Spreadsheet_Excel_Reader("wp.xls");

$num_rows = $data->rowcount($sheet_index=0);
$num_cols = $data->colcount($sheet_index=0);

print "$num_rows,$num_cols\n\n";

$types = '';
$vars = '';
for ($r = 2; $r < $num_rows; $r++) {
print "row=$r \n";
	for ($i = 1; $i < $num_cols; $i++) {
		$v[$i] = $data->val($r,$i);


print "\$v[$i] = |" . $v[$i] . "|\n";
	}
$v[48] = substr($v[48],0,200);
$v[28] = substr($v[28],0,5);
if (!$stmt->execute()) {
    die( "Execute failed: (" . $stmt->errno . ") " . $stmt->error);
}

	
}







