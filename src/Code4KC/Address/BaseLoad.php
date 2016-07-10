<?php

namespace Code4KC\Address;

use \PDO as PDO;

/**
 * Class BaseTable
 */
class BaseLoad
{

    var $dbh = null;
    var $row = 0;
    var $totals = array();
    var $rustart = 0;
    var $start_time = 0;

    var $input_file = '';       // CLI Options
    var $input_url = '';
    var $parameters = '';
    var $dry_run = true;
    var $verbose = false;

    var $area_name = "SET area_name";



    /**
     * @param $dbh
     */
    function __construct(&$dbh, $DB_NAME, $debug = false)
    {

        $this->dbh = $dbh;

        $this->rustart = getrusage();   // Lets see how much system resources we use

        $this->start_time = time();     // Lest see wall clock time on this run


    }

    function load() {

    }

    function get_data_curl($source_url, $parameters = '')
    {
        $ch = curl_init();                // create curl resource
        curl_setopt($ch, CURLOPT_URL, $source_url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1); //return the transfer as a string
        if ( !empty( $parameters )) {
            curl_setopt($ch, CURLOPT_POSTFIELDS, $parameters);
        }


        $data = curl_exec($ch); // $output contains the output string
        curl_close($ch); // close curl resource to free up system resources

        return $data;
    }

    function get_data_file($filename)
    {
        $str = file_get_contents($filename);
        $json = json_decode($str, true); // decode the JSON into an associative array
        return $json;
    }

    function end_load() {


        print "\nTotals for " . $this->area_name . "\n";
        print "-------------------------------------------------------------------------------------------------\n";

        printf("%-30.30s %10s %10s %10s %10s %10s %10s \n", 'table', 'insert', 'update', 'inactive', 're-activate', 'N/A', 'ERROR');
        foreach ($this->totals AS $table => $counts) {
            printf("%-30.30s %10d %10d %10d %10d %10d %10d\n", $table, $counts['insert'], $counts['update'], $counts['inactive'], $counts['re-activate'], $counts['N/A'], $counts['error']);
        }
        print "-------------------------------------------------------------------------------------------------\n\n";


        print "Number of lines processed $this->row\n";

// Calcuate how much time this took

        $end_time = time();
        $time_diff = $end_time - $this->start_time;

        if ($time_diff > 0) {
            $time_diff = $this->time_elapsed_A($time_diff);
        } else {
            $time_diff = ' 0 seconds';
        }


        $ru = getrusage();
        $str = "This process used " . $this->rutime($ru, $this->rustart, "utime") .
            " ms for its computations\n";

        print "\n";
        print $str;

        $str = "It spent " . $this->rutime($ru, $this->rustart, "stime") .
            " ms in system calls\n";

        print $str;


// Print end message with time it took
        print "Run time:  $time_diff\n";
    }

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


    function display_cli_options($database_name)
    {

        print "Processing  ";

        if ( !empty( $this->input_file )) {
            print $this->input_file;
        } else {
            print $this->input_url;
        }

        print " ";

        if ($this->dry_run) {
            print " dry-run ";
        } else {
            print " UPDATE ";
        }
        if (!$this->verbose) {
            print " only errors will be reported";
        }
        print "\n";

        print " database " . $database_name . "\n";



    }

    function valid_cli_options()
    {

        $shortopts = "";
        $shortopts .= "f::";  // Optional value
        $shortopts .= "u::";  // Optional value
        $shortopts .= "p::"; // Optional value
        $shortopts .= "d"; // Optional value

        $shortopts .= "U"; // Optional value
        $shortopts .= "v"; // Optional value
        $shortopts .= "h"; // Optional value


        $longopts = array(
            "input-file::",     // Optional value
            "input-url::",
            'param::',
            "dry-run",    // Optional value

            "update",    // Optional value
            "production",    // Optional value
            "help",

        );
        $options = getopt($shortopts, $longopts);

        if (empty($options)
            || array_key_exists('h', $options)
        ) {
            $missing_a_value = true;
        } else {

            $missing_a_value = false;

            foreach ($options AS $opt => $val) {
                switch ($opt) {
                    case 'f':
                    case 'input-file':
                        if ($val === false) {

                        } else {
                            $this->input_file = $val;
                        }
                        break;

                    case 'u':
                    case 'input-url':
                        if ($val === false) {

                        } else {
                            $this->input_url = $val;
                        }
                        break;

                    case 'p':
                    case 'param':
                        $this->parameters = $val;
                        break;

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

            if ( empty($this->input_file) && empty($this->input_url)) {
                $missing_a_value = true;
            }

        }
        return !$missing_a_value;

    }

    /**
     * Display help on CLI usage, if input or output file name a given put them in the example.
     * @param string $input_file
     */
    function help()
    {

        global $argv;

        $input_file = empty($this->input_file) ? 'filename' : $this->input_file;
        $input_url = empty($this->input_url) ? 'http://some.url' : $this->input_url;
        $input_param = empty($this->input_param) ? 'type=json&no-spaces=true' : $this->input_param;


        print $argv[0] . " [--input-file=$input_file | --input-url=$input_url ] [ --input-param=$input_param ] [ --dry-run | --update ] --verbose ]\n";
        print $argv[0] . " [-f=$input_file | -u=$input_url ] [ -p=$input_param ] [ [ -d | -U ] -v ]\n";
    }


}
