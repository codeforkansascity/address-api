<?php

namespace Code4KC\Address;

use \PDO as PDO;

/**
 * Class Census
 */
class Census
{

    var $dbh;
    var $single_line_address = '';

    /**
     * @throws Exception
     */
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
    }

    /**
     * @param $address_line
     * @return mixed
     * @throws Exception
     */
    function normalize_address($address_line)
    {
        $this->input_address = strtoupper($address_line);
        try {

            $sql = 'SELECT g.address                   AS street_number,
                           UPPER( g.predirAbbrev )     AS pre_direction,
                           UPPER( g.streetName )       AS street_name,
                           UPPER( g.streetTypeAbbrev ) AS street_type,
                           UPPER( g.postdirAbbrev )    AS post_direction,
                           UPPER( g.internal )         AS internal,
                           UPPER( g.location )         AS city,
                           UPPER( g.stateAbbrev )      AS state,
                           g.zip                       AS zip,
                           g.parsed                    AS parsed
                      FROM normalize_address( :address ) AS g';

            $query = $this->dbh->prepare("$sql  -- " . __FILE__ . ' ' . __LINE__);
            $query->execute(array(':address' => $address_line));

        } catch (PDOException  $e) {
            error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
            throw new Exception('Unable to query database');
        }

        $row = $query->fetch(PDO::FETCH_ASSOC);

        $street_number = $row['street_number'];
        $pre_direction = $row['pre_direction'];
        $street_name = $row['street_name'];
        $street_type = $row['street_type'];
        $post_direction = $row['post_direction'];
        $internal = $row['internal'];
        $city = $row['city'];
        $state = $row['state'];
        $zip = $row['zip'];
        $parsed = $row['parsed'];

        $this->single_line_address = preg_replace('/\s+/', ' ', "$street_number $pre_direction $street_name $street_type $post_direction $internal, $city, $state $zip");
        $this->single_line_address = preg_replace('/\s+,/', ',', $this->single_line_address);

        return $row;

    }

    /**
     * @return string
     */
    function get_single_line_address()
    {
        return $this->single_line_address;
    }

    /**
     * @return mixed
     */
    function get_input_address()
    {
        return $this->input_address;
    }

}
