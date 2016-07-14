<?php

namespace Code4KC\Address;

use PDO as PDO;

/**
 * Class BaseTable
 */
class AreaLoad extends BaseLoad
{

    var $active_spatial_ids = array();
    var $inactive_spatial_ids = array();

    var $have_spatial_changes = false;          // Flag to see if we need to update all of the addresses
    //  set to TRUE if we add or change a spatial record

    var $totals = array(
        'spatial' => array('insert' => 0, 'update' => 0, 'inactive' => 0, 're-activate' => 0, 'N/A' => 0, 'error' => 0),
        'city_address_attributes' => array('insert' => 0, 'update' => 0, 'inactive' => 0, 're-activate' => 0, 'N/A' => 0, 'error' => 0),
    );

    /**
     * @param $dbh
     *
     * Connect to both the address and spatial database
     */
    function __construct($DB_NAME, $DB_USER, $DB_PASS, $DB_CODE4KC_NAME, $DB_CODE4KC_USER, $DB_CODE4KC_PASS, $debug = false)
    {

        if (!$this->valid_cli_options()) {

            print "\nBAD\n";
            $this->help();
        } else {
            try {
                $dbh = new PDO("pgsql:host=localhost; dbname=$DB_NAME", $DB_USER, $DB_PASS);
            } catch (PDOException $e) {
                error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
                return false;
            }

            try {
                $spatial_dbh = new PDO("pgsql:host=localhost; dbname=$DB_CODE4KC_NAME", $DB_CODE4KC_USER, $DB_CODE4KC_PASS);
            } catch (PDOException $e) {
                error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
                return false;
            }


            $this->dbh = $dbh;
            $this->spatial_dbh = $spatial_dbh;

            $this->rustart = getrusage();   // Lets see how much system resources we use

            $this->start_time = time();     // Lest see wall clock time on this run

            $this->Areas = new \Code4KC\Address\Areas($this->area_name, $this->spatial_dbh, true);

            if ($this->Areas === false) {
                die('Unable to find area');
            } else {
                $this->load_spatial();
                if ($this->have_spatial_changes) {
                    $this->load();
                }
                $this->end_load();
            }

        }


    }

    function load_spatial()
    {

    }

    function get_spatial_records( $sql ) {


        $this->list_query = $this->spatial_dbh->prepare("$sql  -- " . __FILE__ . ' ' . __LINE__);

        try {
            $this->list_query->execute();
        } catch (PDOException  $e) {
            error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
            print "ERROR " . $e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__;
            //throw new Exception('Unable to query database');
            return false;
        }
        $records = $this->list_query->fetchAll(PDO::FETCH_ASSOC);

        return $records;
    }

    function load()
    {

    }


}
