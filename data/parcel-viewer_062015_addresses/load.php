<?php

require '../../vendor/autoload.php';
require '../../config/config.php';

class Census
{

    var $dbh;

    function __construct()
    {
    global $DB_CENSUS_NAME;
    global $DB_CENSUS_USER;
    global $DB_CENSUS_PASS;
    global $DB_CENSUS_HOST;

        try {

            $this->dbh = new PDO("pgsql:dbname=$DB_CENSUS_NAME", $DB_CENSUS_USER, $DB_CENSUS_PASS);

        } catch (PDOException $e) {
            error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
            throw new Exception('Unable to connect to database');
        }
        print "In BaseClass constructor\n";
    }
    
    function normalize_address( $address_line ) {
        try {

            $sql = 'SELECT g.address                   AS address,
                           UPPER( g.predirAbbrev )     AS predirAbbrev,
                           UPPER( g.streetName )       AS streetName,
                           UPPER( g.streetTypeAbbrev ) AS streetTypeAbbrev,
                           UPPER( g.postdirAbbrev )    AS postdirAbbrev,
                           UPPER( g.internal )         AS internal,
                           UPPER( g.location )         AS city,
                           UPPER( g.stateAbbrev )      AS state,
                           g.zip                       AS zip,
                           g.parsed                    AS parsed
                      FROM normalize_address( :address ) AS g';

            $query = $this->dbh->prepare("$sql  -- " . __FILE__ . ' ' . __LINE__);
            $query->execute(array(':address' => $address_line ));

        } catch (PDOException  $e) {
            error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
            throw new Exception('Unable to query database');
        }

        $row = $query->fetch(PDO::FETCH_ASSOC);

        print_r($row);

        return $row;

    }

}


    $census = new Census();

    $normalized_address = $census->normalize_address( '210 west oak st, greenwood, mo 64106' );

die('end');

$id = 'JA29620120500000000';

try {

    $dbh = new PDO("pgsql:dbname=$DB_NAME", $DB_USER, $DB_PASS);

} catch (PDOException $e) {
    error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
    throw new Exception('Unable to connect to database');
}


try {

    $query = $dbh->prepare("SELECT * FROM jd_wp WHERE county_apn_link = :id LIMIT 1 -- " . __FILE__ . ' ' . __LINE__);
    $query->execute(array(':id' => $id));

} catch (PDOException  $e) {
    error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
    throw new Exception('Unable to query database');
}


$row = $query->fetch(PDO::FETCH_ASSOC);

var_dump($row);
print_r($row);
