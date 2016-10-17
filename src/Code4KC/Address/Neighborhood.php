<?php

namespace Code4KC\Address;

use \PDO as PDO;

/**
 * Class Neighborhood
 */
class Neighborhood extends BaseTable
{
    var $table_name = 'neighborhoods';
    var $primary_key_sequence = null;
    var $list_query = null;
    var $typeahead_query = '';
    var $name_query = '';
    var $fields = array(
        'id' => '',
        'name' => '',
    );



    /**
     * @param $id
     * @return false or found record
     */
    function findallgeo()
    {


        if (!$this->list_query) {
            // From http://www.postgresonline.com/journal/archives/267-Creating-GeoJSON-Feature-Collections-with-JSON-and-PostGIS-functions.html
            $sql = "SELECT row_to_json(fc)
 FROM ( SELECT 'FeatureCollection' As type, array_to_json(array_agg(f)) As features
 FROM (SELECT 'Feature' As type
    , ST_AsGeoJSON(lg.geom)::json As geometry
    , row_to_json(lp) As properties
   FROM address_spatial.mo_kc_city_neighborhoods As lg
         INNER JOIN (SELECT gid, name FROM address_spatial.mo_kc_city_neighborhoods) As lp
       ON lg.gid = lp.gid  ORDER BY lg.name) As f )  As fc;";
            $this->list_query = $this->dbh->prepare("$sql  -- " . __FILE__ . ' ' . __LINE__);
        }

        try {
            $this->list_query->execute();
        } catch (PDOException  $e) {
            error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
            //throw new Exception('Unable to query database');
            return false;
        }
        return $this->list_query->fetchAll(PDO::FETCH_ASSOC);
    }



    /**
     * @param $id
     * @return false or found record
     */
    function findall()
    {


        if (!$this->list_query) {
            $sql = 'SELECT id, name  FROM ' . $this->table_name . ' order by name';
            $this->list_query = $this->dbh->prepare("$sql  -- " . __FILE__ . ' ' . __LINE__);
        }

        try {
            $this->list_query->execute();
        } catch (PDOException  $e) {
            error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
            //throw new Exception('Unable to query database');
            return false;
        }
        return $this->list_query->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * @param $id
     * @return false or found record
     */
    function typeahead($name)
    {

        $name = strtoupper($name);
        $name .= '%';

        if (!$this->typeahead_query) {
            $sql = 'SELECT id, name  FROM ' . $this->table_name . ' WHERE UPPER(name) LIKE :name LIMIT 50';
            $this->typeahead_query = $this->dbh->prepare("$sql  -- " . __FILE__ . ' ' . __LINE__);
        }

        try {
            $this->typeahead_query->execute(array(':name' => $name));
        } catch (PDOException  $e) {
            error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
            //throw new Exception('Unable to query database');
            return false;
        }
        return $this->typeahead_query->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * @param $id
     * @return false or found record
     */
    function find_by_name($name)
    {
        if (!$this->name_query) {
            $sql = 'SELECT *  FROM ' . $this->table_name . ' WHERE name = :name';
            $this->name_query = $this->dbh->prepare("$sql  -- " . __FILE__ . ' ' . __LINE__);
        }

        try {
            $this->name_query->execute(array(':name' => $name));
        } catch (PDOException  $e) {
            error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
            //throw new Exception('Unable to query database');
            return false;
        }

        return $this->name_query->fetch(PDO::FETCH_ASSOC);
    }
}
