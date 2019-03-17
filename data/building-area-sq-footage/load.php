<?php

require '../../vendor/autoload.php';
require '../../config/config.php';

ini_set("auto_detect_line_endings", true);

/**
 * Class Address
 */
class BuildingArea extends \Code4KC\Address\BaseLoad
{

    var $other_attributes = NULL;

    var $address_error_counts = array();

    /**
     * BuildingArea constructor.                      // Might be one for new
     * @param $DB_NAME
     * @param $DB_USER
     * @param bool $DB_PASS
     * @param bool $debug
     */
    function __construct($DB_NAME, $DB_USER, $DB_PASS, $debug = false)
    {

        if (!$this->valid_cli_options()) {

            $this->help();

        } else {
            try {
                $dbh = new PDO("pgsql:host=localhost; dbname=$DB_NAME", $DB_USER, $DB_PASS);
            } catch (PDOException $e) {
                error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
                return false;
            }

            $this->dbh = $dbh;

            $this->rustart = getrusage();   // Lets see how much system resources we use

            $this->start_time = time();     // Lest see wall clock time on this run

            $this->load();

            $this->end_load();
        }
    }

    function valid_cli_options()
    {

        $shortopts = "";
        $shortopts .= "d"; // Optional value

        $shortopts .= "U"; // Optional value
        $shortopts .= "v"; // Optional value
        $shortopts .= "h"; // Optional value


        $longopts = array(

            "dry-run",    // Optional value

            "update",    // Optional value
            "production",    // Optional value
            "help",

        );
        $options = getopt($shortopts, $longopts);

        if (array_key_exists('h', $options)
        ) {
            $this->help();
            return false;
        } else {

            foreach ($options AS $opt => $val) {
                switch ($opt) {

                    case 'd':
                    case 'dry-run':
                        $this->dry_run = true;
                        break;

                    case 'U':
                    case 'update':
                        $this->dry_run = false;
                        break;

                    case 'v':
                    case 'verbose':
                        $this->verbose = true;
                        break;

                }
            }

        }
        return true;

    }

    /**
     * Display help on CLI usage, if input or output file name a given put them in the example.
     * @param string $input_file
     */
    function help()
    {

        global $argv;

        print $argv[0] . "  [ --dry-run | --update ] --verbose ]\n";
        print $argv[0] . "  [ [ -d | -U ] -v ]\n";
    }

    /**
     * load()
     *
     * Input is for each building on a parcel
     *
     * @return bool
     */
    function load()
    {

        $this->totals['other_attributes'] = array(
            'records' => 0,
            'update' => 0,
            'insert' => 0,
            'inactive' => 0,
            're-activate' => 0,
            'N/A' => 0,
            'error' => 0
        );

        $this->other_attributes = new \Code4KC\Address\OtherAttributes($this->dbh, true);

        $current_other_id = null;

        if ($query = $this->get_building_areas()) {

            while ($building_rec = $query->fetch(PDO::FETCH_ASSOC)) {                        // While we have input records

                $this->totals['other_attributes']['records']++;
                $this->process_current_parcel($building_rec['kivapin'], $building_rec['approximate_building_area_in_feet']);
            }

        }

        return true;
    }

    /**
     * Get the input records
     * @return bool|PDOStatement
     */
    function get_building_areas()
    {

        $sql = "
            select kivapin, sum(cast(bldgsqft AS NUMERIC(10,1))) AS approximate_building_area_in_feet FROM building_area WHERE id <> 'id' AND id IS NOT NULL GROUP BY kivapin
            -- LIMIT 25;

        ";

        print $sql;

        $query = $this->dbh->prepare("$sql  -- " . __FILE__ . ' ' . __LINE__);

        try {
            $query->execute();
        } catch (PDOException  $e) {
            error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
            //throw new Exception('Unable to query database');
            return false;
        }

        return $query;
    }

    /**
     * process_current_parcel
     *
     * Process the current parcel and update the county apn with the delinquent amounts
     *   Update the delinquent amounts in other_attributes
     * or
     *   Add a other_attributes record with the delinquent
     *
     * @param $current_other_id ,   city id of the current
     * @param $amts ,                        yearly ammounts for the current county id
     * @param $current_building_rec              input record for the current county id
     */
    function process_current_parcel($kiva_pin, $approximate_building_area_in_feet)
    {
        $current_building_rec = $this->other_attributes->find_by_id($kiva_pin);
var_dump($current_building_rec);
        if ($current_building_rec) {
print "A";
            if ($current_building_rec['approximate_building_area_in_feet'] != $approximate_building_area_in_feet) {
                $current_building_rec->update($kiva_pin, ['approximate_building_area_in_feet' => $approximate_building_area_in_feet]);
                $this->totals['other_attributes']['update']++;
            } else {
                $this->totals['other_attributes']['N/A']++;
            }
        } else {

            $new_rec = [
                'id' => $kiva_pin,
                'approximate_building_area_in_feet' => $approximate_building_area_in_feet
            ];

            print "B";

            $this->other_attributes->add($new_rec);

            $this->totals['other_attributes']['insert']++;
        }
    }

}


$run = new BuildingArea($DB_NAME, $DB_USER, $DB_PASS);
