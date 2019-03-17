<?php

namespace Code4KC\Address;

use \PDO as PDO;

/**
 * Class Address
 */
class OtherAttributes extends BaseTable
{

    var $table_name = 'other_attributes';
    var $id_auto_increment = false;
    var $primary_key_sequence = null;
    var $fields = array(
        'id' => '1',
        'approximate_building_area_in_feet' => '',
    );

}
