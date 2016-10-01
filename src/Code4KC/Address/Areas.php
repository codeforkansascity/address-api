<?php

namespace Code4KC\Address;

use PDO as PDO;

/**
 * Class KCMO_Tif
 */
class Areas extends BaseTable
{
    var $dbh;
    var $table_name = 'address_spatial.areas';
    var $primary_key_sequence = 'address_spatial.areas_id_seq';
    var $query = null;
    var $list_query = null;

    var $area_type_id = false;

    var $fields = array(
        'id' => '',
        'area_type_id' => 0,
        'fid' => '',
        'name' => '',
        'geom' => '',
        'ordnum' => '',
        'status' => '',
        'amendment' => '',
        'lastupdate' => '',
        'shape_length' => '',
        'shape_area' => '',
        'active' => ''
    );

    var $field_definitions = array();

    var $id_query = null;
    var $find_all_query = null;
    var $add_query = null;


    var $area_types = array(
        'TIF' => 1,
        'PoliceDivisions' => 2,
        'NeighborhoodCensus' => 3,
        'VacantParcels' => 4,
        'CouncilDistricts' => 5,
        'CouncilDistricts2001' => 6,


    );

    var $fid_query = null;

    function __construct($area_type, &$dbh, $debug = false)
    {

        $this->area_type_id = $this->get_area_type_id( $area_type );

        if ( $this->area_type_id ) {

            $this->dbh = $dbh;

            if ($debug) {
                $this->dbh->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
            }

            return true;

        } else {
            return false;
        }
    }

    function get_area_type_id( $area_type) {
        if ( array_key_exists( $area_type, $this->area_types)) {
            return $this->area_types[ $area_type ];
        } else {
            return false;
        }
    }

    // BASE TABLE START

    /**
     * Add record's fields.  Use default values from $fields
     */
    function add($record)
    {
        if (!$this->add_query) {                                                                // Have we already built the query?
            $names = '';
            $values = '';                                                                               // Build it
            $sep = '';
            foreach ($this->fields AS $f => $v) {
                if ( $f == 'id') continue;
                $names .= $sep . $f;
                $values .= $sep . ':' . $f;
                $sep = ', ';
            }

            $sql = 'INSERT INTO ' . $this->table_name . ' (' . $names . ') VALUES (' . $values . ')';

            $this->add_query = $this->dbh->prepare("$sql  -- " . __FILE__ . ' ' . __LINE__);
        }

        try {                                                                                           // Now we can add thr record
            $new_rec = array();
            foreach ($this->fields AS $f => $v) {
                if ( $f == 'id') continue;
                if (array_key_exists($f, $record)) {
                    $value = $record[$f];
                } else {
                    $value = $v;
                }
                $new_rec[':' . $f] = $value;
            }

            $new_rec[':area_type_id'] = $this->area_type_id;

            $ret = $this->add_query->execute($new_rec);

        } catch (PDOException  $e) {

            error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);

            $this->add_query->debugDumpParams();
            //throw new Exception('Unable to query database');
            return false;
        }


        if ($this->primary_key_sequence) {
            $id = $this->dbh->lastInsertId($this->primary_key_sequence);
        } else {
            $id = null;
        }


        return $id;


    }


    public function git_ids_not_in($ids)
    {

        if ( ! count($ids) ) {
            return array();
        }
        $inQuery = implode(',', $ids);

        $sql = 'SELECT id  AS id FROM ' . $this->table_name .
                ' WHERE  area_type_id = ' . $this->area_type_id . ' AND id  NOT IN (' . $inQuery . ')';

        try {
            $query = $this->dbh->prepare("$sql  -- " . __FILE__ . ' ' . __LINE__);

            $query->execute();

            $result = $query->fetchAll(PDO::FETCH_COLUMN);

        } catch (PDOException  $e) {
            print ($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
            error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
            //throw new Exception('Unable to query database');
            return false;
        }

        return $result;

    }


    /**
     * @param $id
     * @return false or found record
     */
    function find_all()
    {
        if (!$this->find_all_query) {
            $sql = 'SELECT *  FROM ' . $this->table_name .
                    ' WHERE  area_type_id = ' . $this->area_type_id .
                    ' ORDER BY id';
            $this->find_all_query = $this->dbh->prepare("$sql  -- " . __FILE__ . ' ' . __LINE__);
        }

        try {
            $this->find_all_query->execute();
        } catch (PDOException  $e) {
            error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
            //throw new Exception('Unable to query database');
            return false;
        }

        return $this->find_all_query;
    }




    // BASE TABLE END

    function find_name_by_lng_lat( $lng, $lat ) {
        if (!$this->query) {
            $sql = 'SELECT name  FROM ' . $this->table_name .
                    ' WHERE area_type_id = ' . $this->area_type_id .
                    ' AND ST_Intersects( ST_MakePoint( :lng, :lat)::geography::geometry, geom);';
            $this->query = $this->dbh->prepare("$sql  -- " . __FILE__ . ' ' . __LINE__);
        }

        try {
            $this->query->execute(array(':lat' => $lat, ':lng' => $lng));
        } catch (PDOException  $e) {
            error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
            //throw new Exception('Unable to query database');
            return false;
        }

        return $this->query->fetch(PDO::FETCH_ASSOC);
    }



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
                       FROM " . $this->table_name . " As lg
                       INNER JOIN (SELECT fid, name FROM " . $this->table_name . " WHERE  area_type_id = " . $this->area_type_id .") As lp
                           ON lg.fid = lp.fid  WHERE  area_type_id = " . $this->area_type_id .
                            " ORDER BY lg.name) As f )  As fc ;";
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

die ('use find_all()');

    }

    /**
     * @param $id
     * @return false or found record
     */
    function find_by_fid($fid)
    {
        if (!$this->fid_query) {
            $sql = 'SELECT *  FROM ' . $this->table_name . ' WHERE  area_type_id = ' . $this->area_type_id .
                ' AND fid = :fid';
            $this->id_query = $this->dbh->prepare("$sql  -- " . __FILE__ . ' ' . __LINE__);
        }

        try {
            $this->id_query->execute(array(':fid' => $fid));
        } catch (PDOException  $e) {
            error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
            //throw new Exception('Unable to query database');
            return false;
        }

        return $this->id_query->fetch(PDO::FETCH_ASSOC);
    }

}
