<?php

namespace Code4KC\Address;

use \PDO as PDO;

/**
 * Class Address
 */
class Address extends BaseTable
{

    var $table_name = 'address';
    var $primary_key_sequence = 'address_id_seq_02';
    var $single_line_address_query = '';
    var $neighbornood_query = '';
    var $metro_area_query = '';
    var $typeahead_query = '';
    var $get_attributes_query = '';
    var $fields = array(
        'single_line_address' => '',
        'street_number' => '',
        'pre_direction' => '',
        'street_name' => '',
        'street_type' => '',
        'post_direction' => '',
        'internal' => '',
        'city' => '',
        'state' => '',
        'zip' => '',
        'zip4' => '',
        'longitude' => '0.0',
        'latitude' => '0.0'
    );

    VAR $base_sql = 'SELECT
                a.id AS address_id,
                a.single_line_address,
                a.city,
                a.state,
                a.zip,
                a.longitude,
                a.latitude,

                k.city_address_id AS city_id,

                c.land_use_code AS city_land_use_code,
                c.land_use AS city_land_use,
                c.classification AS city_classification,
                c.sub_class AS city_sub_class,
                c.neighborhood AS city_nighborhood,
                c.nhood AS city_nhood,
                c.council_district AS city_council_district,
                c.land_bank_property AS city_land_bank_property,

                k.county_address_id AS county_id,
                b.block_2010_name AS census_block_2010_name,
                b.block_2010_id AS census_block_2010_id,
                b.tract_name AS census_track_name,
                b.tract_id AS census_track_id,
                b.zip AS census_zip,
                b.county_id AS census_county_id,
                b.state_id AS census_county_state_id,
                b.longitude AS census_longitude,
                b.latitude AS census_latitude,
                b.tiger_line_id AS census_tiger_line_id,
                b.metro_areas AS census_metro_area,

                j.parcel_number AS county_parcel_number,
                j.name AS county_name,
                j.tif_district AS county_tif_district,
                j.tif_project AS county_tif_project,
                j.neighborhood_code AS county_neighborhood_code,
                j.pca_code AS county_pca_code,
                j.land_use_code AS county_land_use_code,
                j.tca_code AS county_tca_code,
                j.document_number AS county_document_number,
                j.book_number AS county_book_number,
                j.conveyance_area AS county_conveyance_area,
                j.conveyance_designator AS county_conveyance_designator,
                j.legal_description AS county_legal_description,
                j.object_id AS county_object_id,
                j.page_number AS county_page_number,
                cd.situs_address AS county_situs_address,
                cd.situs_city AS county_situs_city,
                cd.situs_state AS county_situs_state,
                cd.situs_zip AS county_situs_zip,
                cd.owner AS county_owner,
                cd.owner_address AS county_owner_address,
                cd.owner_city AS county_owner_city,
                cd.owner_state AS county_owner_state,
                cd.owner_zip AS county_owner_zip,
                cd.stated_area AS county_stated_area,
                cd.tot_sqf_l_area AS county_tot_sqf_l_area,
                cd.year_built AS county_year_built,
                cd.property_area AS county_property_area,
                cd.property_picture AS county_property_picture,
                cd.property_report AS county_property_report,
                cd.market_value AS county_market_value,
                cd.assessed_value AS county_assessed_value,
                cd.assessed_improvement AS county_assessed_improvement,
                cd.assessed_land AS county_assessed_land,
                cd.taxable_value AS county_taxable_value,
                cd.mtg_co AS county_mtg_co,
                cd.mtg_co_address AS county_mtg_co_address,
                cd.mtg_co_city AS county_mtg_co_city,
                cd.mtg_co_state AS county_mtg_co_state,
                cd.mtg_co_zip AS county_mtg_co_zip,
                cd.common_area AS county_common_area,
                cd.floor_designator AS county_floor_designator,
                cd.floor_name_designator AS county_floor_name_designator,
                cd.exempt AS county_exempt,
                cd.complex_name AS county_complex_name,
                cd.cid AS county_cid,
                cd.eff_from_date AS county_eff_from_date,
                cd.eff_to_date AS county_eff_to_date,
                cd.extract_date AS county_extract_date,
                cd.shape_st_area AS county_shape_st_area,
                cd.shape_st_lenght AS county_shape_st_lenght,
                cd.shape_st_area_1 AS county_shape_st_area_1,
                cd.shape_st_length_1 AS county_shape_st_length_1,
                cd.shape_st_legnth_2 AS county_shape_st_legnth_2,
                cd.shape_st_area_2 AS county_shape_st_area_2,
                cd.sim_con_div_type AS county_sim_con_div_type,
                cd.tax_year AS county_tax_year,
                cd.type AS county_type,
                cd.z_designator AS county_z_designator

                FROM city_address_attributes c
                LEFT JOIN address_keys k ON k.city_address_id = c.id
                LEFT JOIN address a on a.id = k.address_id
                LEFT JOIN census_attributes b ON b.city_address_id = k.city_address_id
                LEFT JOIN county_address_attributes j ON j.id = k.county_address_id
                LEFT JOIN county_address_data cd ON cd.id = k.county_address_id
          ';

    /**
     * @param $metro_area
     * @return bool
     */
    function get_metro_area($metro_area)
    {

        if (!$this->metro_area_query) {
            $sql = $this->base_sql . '
                WHERE UPPER(b.metro_areas) = :metro_area
                LIMIT 10000';
            $this->metro_area_query = $this->dbh->prepare("$sql  -- " . __FILE__ . ' ' . __LINE__);
        }

        try {
            $this->metro_area_query->execute(array(':metro_area' => strtoupper($metro_area)));
        } catch (PDOException  $e) {
            error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
            //throw new Exception('Unable to query database');
            return false;
        }

        return $this->metro_area_query->fetchAll(PDO::FETCH_ASSOC);

    }

    /**
     * @param $nighborhood
     * @return bool
     */
    function get_neighborhood($nighborhood)
    {

        if (!$this->neighbornood_query) {
            $sql = $this->base_sql . '
                WHERE UPPER(c.neighborhood) = :nighborhood';
            $this->neighbornood_query = $this->dbh->prepare("$sql  -- " . __FILE__ . ' ' . __LINE__);
        }

        try {
            $this->neighbornood_query->execute(array(':nighborhood' => strtoupper($nighborhood)));
        } catch (PDOException  $e) {
            error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
            //throw new Exception('Unable to query database');
            return false;
        }

        return $this->neighbornood_query->fetchAll(PDO::FETCH_ASSOC);

    }

    /**
     * @param $id
     * @return false or found record
     */
    function typeahead($single_line_address)
    {

        $single_line_address = strtoupper($single_line_address);
        $single_line_address .= '%';

        if (!$this->typeahead_query) {
            $sql = 'SELECT id, single_line_address  FROM ' . $this->table_name . ' WHERE single_line_address LIKE :single_line_address LIMIT 50';
            $this->typeahead_query = $this->dbh->prepare("$sql  -- " . __FILE__ . ' ' . __LINE__);
        }

        try {
            $this->typeahead_query->execute(array(':single_line_address' => $single_line_address));
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
    function find_by_single_line_address($single_line_address)
    {
        if (!$this->single_line_address_query) {
            $sql = 'SELECT *  FROM ' . $this->table_name . ' WHERE single_line_address = :single_line_address';
            $this->single_line_address_query = $this->dbh->prepare("$sql  -- " . __FILE__ . ' ' . __LINE__);
        }

        try {
            $this->single_line_address_query->execute(array(':single_line_address' => $single_line_address));
        } catch (PDOException  $e) {
            error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
            //throw new Exception('Unable to query database');
            return false;
        }

        return $this->single_line_address_query->fetch(PDO::FETCH_ASSOC);
    }

    /**
     * @param $address_id
     * @return bool
     */
    function get_attributes($address_id)
    {

        if (!$this->get_attributes_query) {
            $sql = $this->base_sql . '
                WHERE k.address_id = :address_id';
            $this->get_attributes_query = $this->dbh->prepare("$sql  -- " . __FILE__ . ' ' . __LINE__);
        }

        try {
            $this->get_attributes_query->execute(array(':address_id' => $address_id));
        } catch (PDOException  $e) {
            error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
            //throw new Exception('Unable to query database');
            return false;
        }

        return $this->get_attributes_query->fetch(PDO::FETCH_ASSOC);

    }

}
