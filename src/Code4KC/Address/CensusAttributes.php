<?php

namespace Code4KC\Address;

use \PDO as PDO;

/**
 * Class Address
 */
class CensusAttributes extends BaseTable
{

    var $table_name = 'census_attributes';                                                    
    var $primary_key_sequence = '';
    var $fields = array(                                                            
        'block_2010_name' => '',
        'block_2010_id' => '',
        'tract_name' => '',
        'tract_id' => '',
        'zip' => '',
        'county_id' => '',
        'state_id' => '',
        'longitude' => '',
        'latitude' => '',
        'tiger_line_id' => '',
    );

}
