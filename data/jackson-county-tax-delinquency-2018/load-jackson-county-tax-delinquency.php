<?php

require '../../vendor/autoload.php';
require '../../config/config.php';

ini_set("auto_detect_line_endings", true);

/**
 * Class Address
 */
class JacksonCountyTaxDeliquency extends \Code4KC\Address\BaseLoad
{

    var $empty_amts = array(
        'delinquent_tax_2016' => 0,
        'delinquent_tax_2017' => 0
    );
    var $address_error_counts = array();

    /**
     * JacksonCountyTaxDeliquency constructor.                      // Might be one for new
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
     * Input is a record for each year of a parcel
     *
     *       county_address_id   tax_year balance_amt
     *       JA12640060100000000     2015     1438.90
     *                                                  <-- control break, process the current one JA12640060100000000
     *                                                  <-- setup the new parcel as current JA12640060900000000
     *       JA12640060900000000     2012      177.82
     *       JA12640060900000000     2013       64.77
     *       JA12640060900000000     2014       57.17
     *       JA12640060900000000     2015       44.89
     *                                                  <-- control break, process the current one JA12640060900000000
     *                                                  <-- setup the new parcel as current JA12640061200000000
     *       JA12640061200000000     2014       90.32
     *       JA12640061200000000     2015       89.86
     *
     *       JA12640061400000000     2014      477.47
     *       JA12640061400000000     2015      475.00
     *
     *
     * @return bool
     */
    function load()
    {
        $amts = $this->empty_amts;

        $this->totals['county_address_attributes'] = array(
            'records' => 0,
            'update' => 0,
            'insert' => 0,
            'inactive' => 0,
            're-activate' => 0,
            'N/A' => 0,
            'error' => 0
        );

        $this->county_address_attributes = new \Code4KC\Address\CountyAddressAttributes($this->dbh, true);
        $this->address_keys = new \Code4KC\Address\AddressKeys($this->dbh, true);

        $current_county_address_id = null;
        $current_tax_rec = array();

        if ($query = $this->get_delinquencies()) {

            while ($tax_rec = $query->fetch(PDO::FETCH_ASSOC)) {                        // While we have input records

                $this->totals['county_address_attributes']['records']++;

                $county_address_id = trim($tax_rec['county_address_id']);

                if ($current_county_address_id != $county_address_id) {                 // New parcel was just read

                    if ($current_county_address_id != null) {                           // if not the first parcel
                        $this->process_current_parcel($current_county_address_id,       // Process the current parcel
                                                 $amts, $current_tax_rec);
                    }

                    $current_county_address_id = $county_address_id;                    // setup a new  parcel as current
                    $current_tax_rec = $tax_rec;
                    $amts = $this->empty_amts;

                }

                $year = $tax_rec['tax_year'];
                $amt = $tax_rec['balance_amt'];
                $amts['delinquent_tax_' . $year] = $amt;                                // For each year remember its amount

            }

            if ($current_county_address_id != null) {                                   // and not the first one, ie no input
                $this->process_current_parcel($current_county_address_id, $amts, $current_tax_rec);
            }

            if ( count($this->address_error_counts)) {
                print "\nAddress that were not found: ";
                print_r($this->address_error_counts);

                print "\n";
            }
        }
                                                                                        // Process the last county parcel

        return true;


    }

    /**
     * Get the input records
     * @return bool|PDOStatement
     */
    function get_delinquencies()
    {

        $sql = "
            SELECT CONCAT('JA' , REPLACE(parcel_number,'-','')) AS county_address_id,
                    parcel_number,
                    situs_address,
                    situs_city,
                    delq_yr AS tax_year,
                    base_delq_amt AS balance_amt
            FROM jackson_county_delinquent_tax_parcels
            WHERE TRIM(situs_city) = 'KANSAS CITY'
            ORDER BY parcel_number, tax_year
            -- LIMIT 9;

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
     *   Update the delinquent amounts in county_address_attributes
     * or
     *   Add a county_address_attributes record with the delinquent
     *
     * @param $current_county_address_id,   county id of the current
     * @param $amts,                        yearly ammounts for the current county id
     * @param $current_tax_rec              input record for the current county id
     */
    function process_current_parcel($current_county_address_id, $amts, $current_tax_rec)
    {

        $address_keys = $this->address_keys->find_by_county_address_id($current_county_address_id);

        if ($address_keys) {

            $county_address_attributes_rec = $this->county_address_attributes->find_by_id($current_county_address_id);

            if ($county_address_attributes_rec) {
                $this->update_county($current_county_address_id, $county_address_attributes_rec, $amts);
            } else {

                $current_parcel_number = $current_tax_rec['parcel_number'];

                $new_rec = $amts;
                $new_rec['id'] = $current_county_address_id;
                $new_rec['parcel_number'] = $current_parcel_number;

                $this->county_address_attributes->add($new_rec);

                $this->totals['county_address_attributes']['insert']++;
            }

        } else {
            // We are not adding new addresses,

            // TOTAL BAD APN by situs_address

            $situs_address = $current_tax_rec['situs_address'];
            array_key_exists($situs_address, $this->address_error_counts) ? $this->address_error_counts[$situs_address]++ : $this->address_error_counts[$situs_address] = 1;


            $this->totals['county_address_attributes']['error']++;
        }

    }

    function update_county($county_address_attributes_id, $county_address_attributes_rec, $new_rec)
    {
        if ($county_address_attribute_differences = $this->county_address_attributes->diff($county_address_attributes_rec, $new_rec)) {
            if (!$this->dry_run) {
                $this->county_address_attributes->update($county_address_attributes_id, $county_address_attribute_differences);
            }
            $this->totals['county_address_attributes']['update']++;
        } else {
            $this->totals['county_address_attributes']['N/A']++;
        }
    }

    function display_record($line_number, $msg, $data)
    {
        printf("%10s: %5d %16.16s %s \n", $msg, $line_number, $data['land_use_code'], $data['land_use_description']);
    }

    function display_rejected_record($line_number, $data, $data_errors)
    {
        printf("\nERROR: %5d %16.16s %s \n", $line_number, $data['land_use_code'], $data['land_use_description']);
        $last_field = '.';
        foreach ($data_errors AS $field => $msgs) {
            foreach ($msgs AS $msg) {

                if ($last_field != $field) {
                    $dsp_field = $field . ':';
                    $last_field = $field;
                } else {
                    $dsp_field = '';
                }

                printf("         %20.20s %-s\n", $dsp_field, $msg);
            }
        }
    }


}


$run = new JacksonCountyTaxDeliquency($DB_NAME, $DB_USER, $DB_PASS);
