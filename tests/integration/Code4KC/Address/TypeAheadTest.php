<?php
/**
 * Created by PhpStorm.
 * User: james
 * Date: 4/24/2016
 * Time: 4:09 PM
 */


//require '../../../vendor/Convissor/address/AddressStandardizationSolution.php';

class TypeAheadTest extends PHPUnit_Framework_TestCase
{
    // ...

    public function testTypeAhead()
    {
        require 'config/config.php';
        try {
            $dbh = new PDO("pgsql:dbname=$DB_NAME", $DB_USER, $DB_PASS);
        } catch (PDOException $e) {
            error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
            throw new Exception('Unable to connect to database');
        }
        $address = new \Code4KC\Address\Address($dbh, true);

        $result = $address->typeahead("210 w 19th TER FL 1");
        //var_dump($result);
        $this->assertEquals(200567, $result[0]["id"]);
        $this->assertEquals("210 W 19TH TER FL 1, KANSAS CITY, MO", $result[0]["single_line_address"]);


        $neighborhood = new \Code4KC\Address\Neighborhood($dbh, true);

        $result = $neighborhood->typeahead("East Meyer");

        $this->assertEquals(29, $result[0]["id"]);
        $this->assertEquals("East Meyer", $result[0]["name"]);


        $result = $neighborhood->find_by_name("210 w 19th TER FL 1");
        var_dump($result);

    }
}
