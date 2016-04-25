<?php

namespace Code4KC\Address;

use \PDO as PDO;

/**
 * Class Address
 */
class CityAddressAttributes extends BaseTable
{

    var $table_name = 'city_address_attributes';
    var $primary_key_sequence = null;
    var $fields = array(
        'id' => '',
        'land_use_code' => '',
        'land_use' => '',
        'classification' => '',
        'sub_class' => '',
        'neighborhood' => '',
        'nhood' => '',
        'council_district' => '',
        'land_bank_property' => 0,
    );

    var $field_definitions = array(
        'land_use_code' => array('size' => 10, 'type' => 'char'),
        'land_bank_property' => array('size' => false, 'type' => 'int')

    );

}
