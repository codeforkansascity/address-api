<?php
// http://api.codeforkc.org/normalize_address/v0000/210%20West%2019th%20terrace/?city=KANSAS%20CITY&state=MO

require '../vendor/autoload.php';
require '../config/config.php';

require '../vendor/Convissor/address/AddressStandardizationSolution.php';

$app = new \Slim\Slim();


/**
 * Example of a URL argument but no parameter.  Must specify a
 * fake parameter
 */
$app->get('/test/V0(/:id)', function ($id = 0) use ($app) {
    $in_state = strtoupper($app->request()->params('state'));

    var_dump($in_state);

});

$app->get('/police_divisions/V0/', function () use ($app) {
    return find_all_areas($app, 'PoliceDivisions');
});
$app->get('/kcmo_tifs/V0/', function () use ($app) {
    return find_all_areas($app, 'TIF');
});
$app->get('/neighborhood_census/V0/', function () use ($app) {
    return find_all_areas($app, 'NeighborhoodCensus');
});


$app->get('/metro-areas/V0/', function () use ($app) {


    if ($dbh = connect_to_spatial_database()) {

        $address = new \Code4KC\Address\MetroArea($dbh, true);

        if ($address_recs = $address->findallgeo()) {

            $ret = array(
                'code' => 200,
                'status' => 'sucess',
                'message' => '',
                'data' => $address_recs
            );

        } else {
            $ret = array(
                'code' => 404,
                'status' => 'error',
                'message' => 'Address not found',
                'data' => array()
            );
        }

    } else {

        $ret = array(
            'code' => 500,
            'status' => 'failed',
            'message' => 'Unable to connect to database.',
            'data' => array()
        );
    }


    $app->response->setStatus($ret['code']);

    if ($ret['code'] == 200) {
        echo $address_recs[0]['row_to_json'];
    } else {
        echo json_encode($ret);
    }
});


$app->get('/address-by-metro-area/V0/:metro_area', function ($metro_area) use ($app) {
    list($metro_area, $x) = explode("?", $metro_area);


    $in_city = strtoupper($app->request()->params('city'));
    $in_state = strtoupper($app->request()->params('state'));

    if (!empty($metro_area)) {
        if (city_state_valid($in_city, $in_state)) {

            if ($dbh = connect_to_address_database()) {

                $address = new \Code4KC\Address\Address($dbh, true);
                $ret = $address->get_metro_area($metro_area);

                $ret = array(
                    'code' => 200,
                    'status' => 'sucess',
                    'message' => '',
                    'data' => $ret
                );
            } else {
                $ret = array(
                    'code' => 404,
                    'status' => 'error',
                    'message' => 'Neighborhood not found',
                    'data' => array()
                );
            }
        } else {
            $ret = array(
                'code' => 500,
                'status' => 'failed',
                'message' => 'Unable to connect to database.',
                'data' => array()
            );
        }
    } else {
        $ret = array(
            'code' => 404,
            'status' => 'error',
            'message' => 'City ID was not valid..',
            'data' => array()
        );
    }

    $app->response->setStatus($ret['code']);
    echo json_encode($ret);
});

$app->get('/address-by-neighborhood/V0/:nighborhood', function ($nighborhood) use ($app) {
    list($nighborhood, $x) = explode("?", $nighborhood);


    $in_city = strtoupper($app->request()->params('city'));
    $in_state = strtoupper($app->request()->params('state'));

    if (!empty($nighborhood)) {
        if (city_state_valid($in_city, $in_state)) {

            if ($dbh = connect_to_address_database()) {

                $address = new \Code4KC\Address\Address($dbh, true);
                $ret = $address->get_neighborhood($nighborhood);

                $ret = array(
                    'code' => 200,
                    'status' => 'sucess',
                    'message' => '',
                    'data' => $ret
                );
            } else {
                $ret = array(
                    'code' => 404,
                    'status' => 'error',
                    'message' => 'Neighborhood not found',
                    'data' => array()
                );
            }
        } else {
            $ret = array(
                'code' => 500,
                'status' => 'failed',
                'message' => 'Unable to connect to database.',
                'data' => array()
            );
        }
    } else {
        $ret = array(
            'code' => 404,
            'status' => 'error',
            'message' => 'City ID was not valid..',
            'data' => array()
        );
    }

    $app->response->setStatus($ret['code']);
    echo json_encode($ret);
});

$app->get('/neighborhoods-geo/V0/:id/', function ($id) use ($app) {


    $in_city = strtoupper($app->request()->params('city'));
    $in_state = strtoupper($app->request()->params('state'));

    if (city_state_valid($in_city, $in_state)) {

        if ($dbh = connect_to_spatial_database()) {

            $address = new \Code4KC\Address\Neighborhood($dbh, true);

            if ($address_recs = $address->findallgeo()) {

                $ret = array(
                    'code' => 200,
                    'status' => 'sucess',
                    'message' => '',
                    'data' => $address_recs
                );

            } else {
                $ret = array(
                    'code' => 404,
                    'status' => 'error',
                    'message' => 'Address not found',
                    'data' => array()
                );
            }

        } else {

            $ret = array(
                'code' => 500,
                'status' => 'failed',
                'message' => 'Unable to connect to database.',
                'data' => array()
            );
        }

    } else {
        $ret = array(
            'code' => 404,
            'status' => 'error',
            'message' => 'State or City was not valid.',
            'data' => array()
        );
    }


    $app->response->setStatus($ret['code']);

    if ($ret['code'] == 200) {
        echo $address_recs[0]['row_to_json'];
    } else {
        echo json_encode($ret);
    }
});


$app->get('/neighborhoods/V0/:id/', function ($id) use ($app) {


    $ret = array(
        'code' => 404,
        'status' => 'error',
        'message' => 'was not valid.',
        'data' => array()
    );


    $in_city = strtoupper($app->request()->params('city'));
    $in_state = strtoupper($app->request()->params('state'));

    if (city_state_valid($in_city, $in_state)) {

        if ($dbh = connect_to_address_database()) {

            $address = new \Code4KC\Address\Neighborhood($dbh, true);

            if ($address_recs = $address->findall()) {

                $ret = array(
                    'code' => 200,
                    'status' => 'sucess',
                    'message' => '',
                    'data' => $address_recs
                );

            } else {
                $ret = array(
                    'code' => 404,
                    'status' => 'error',
                    'message' => 'Address not found',
                    'data' => array()
                );
            }

        } else {

            $ret = array(
                'code' => 500,
                'status' => 'failed',
                'message' => 'Unable to connect to database.',
                'data' => array()
            );
        }

    } else {
        $ret = array(
            'code' => 404,
            'status' => 'error',
            'message' => 'State or City was not valid.',
            'data' => array()
        );
    }


    $app->response->setStatus($ret['code']);
    echo json_encode($ret);
});


$app->get('/address-typeahead/V0/:address/', function ($in_address) use ($app) {

    $in_address = addslashes($in_address);


    if ($dbh = connect_to_address_database()) {

        $address = new \Code4KC\Address\Address($dbh, true);
        if ($address_recs = $address->typeahead($in_address)) {

            $ret = array(
                'code' => 200,
                'status' => 'sucess',
                'message' => '',
                'data' => $address_recs
            );

        } else {
            $ret = array(
                'code' => 404,
                'status' => 'error',
                'message' => 'Address not found',
                'data' => array()
            );
        }
    } else {
        $ret = array(
            'code' => 404,
            'status' => 'error',
            'message' => 'State or City was not valid.',
            'data' => array()
        );
    }

    if ($address_recs == false) {
        echo json_encode($address_recs);
    } else {
        $app->response->setStatus($ret['code']);
        echo json_encode($ret);
    }
});

/**
 * address_spatial.mo_kc_city_neighborhoods
 */
$app->get('/neighborhood-typeahead/V0/:neighborhood/', function ($in_neighborhood) use ($app) {

    $in_neighborhood = addslashes($in_neighborhood);


    if ($dbh = connect_to_address_database()) {

        $neighborhood = new \Code4KC\Address\Neighborhood($dbh, true);
        if ($neighborhood_recs = $neighborhood->typeahead($in_neighborhood)) {

            $ret = array(
                'code' => 200,
                'status' => 'sucess',
                'message' => '',
                'data' => $neighborhood_recs
            );

        } else {
            $ret = array(
                'code' => 404,
                'status' => 'error',
                'message' => 'Address not found',
                'data' => array()
            );
        }
    } else {
        $ret = array(
            'code' => 404,
            'status' => 'error',
            'message' => 'State or City was not valid.',
            'data' => array()
        );
    }

    if ($neighborhood_recs == false) {
        echo json_encode($neighborhood_recs);
    } else {
        $app->response->setStatus($ret['code']);
        echo json_encode($ret);
    }
});

$app->get('/neighborhood-attributes/V0/:neighborhood/', function ($name) use ($app) {

    list($in_neighborhood, $x) = explode("?", $name);
    $in_neighborhood = addslashes($in_neighborhood);

    $in_city = strtoupper($app->request()->params('city'));
    $in_state = strtoupper($app->request()->params('state'));

    if (city_state_valid($in_city, $in_state)) {

        if ($dbh = connect_to_address_database()) {

            $neighborhood = new \Code4KC\Address\Neighborhood($dbh, true);

            if ($neighborhood_rec = $neighborhood->find_by_name($in_neighborhood)) {

                $ret = array(
                    'code' => 202,
                    'status' => 'sucess',
                    'message' => '',
                    'data' => $neighborhood_rec
                );

            } else {
                $ret = array(
                    'code' => 404,
                    'status' => 'error',
                    'message' => 'Neighborhood not found' . $in_neighborhood,
                    'data' => array()
                );
            }
        } else {
            $ret = array(
                'code' => 404,
                'status' => 'error',
                'message' => 'State or City was not valid.',
                'data' => array()
            );
        }
    } else {
        $ret = array(
            'code' => 500,
            'status' => 'failed',
            'message' => 'Unable to connect to database.',
            'data' => array()
        );
    }

    $app->response->setStatus($ret['code']);
    echo json_encode($ret);

});


$app->get('/address-attributes-id/V0/:id/', function ($id) use ($app) {
    list($county_id, $x) = explode("?", $id);

    $id = intval($id);

    $in_city = strtoupper($app->request()->params('city'));
    $in_state = strtoupper($app->request()->params('state'));

    if (!empty($id)) {
        if (city_state_valid($in_city, $in_state)) {

            if ($dbh = connect_to_address_database()) {

                $ret = get_address_attributes($dbh, $id);

            } else {
                $ret = array(
                    'code' => 404,
                    'status' => 'error',
                    'message' => 'Address not found',
                    'data' => array()
                );
            }
        } else {
            $ret = array(
                'code' => 500,
                'status' => 'failed',
                'message' => 'Unable to connect to database.',
                'data' => array()
            );
        }
    } else {
        $ret = array(
            'code' => 404,
            'status' => 'error',
            'message' => 'City ID was not valid..',
            'data' => array()
        );
    }

    $app->response->setStatus($ret['code']);
    echo json_encode($ret);
});

$app->get('/address-attributes-county-id/V0/:id/', function ($id) use ($app) {

    list($county_id, $x) = explode("?", $id);   // FIX we do not do this in other that have a numeric id.....

    $county_id = addslashes($county_id);

    $in_city = strtoupper($app->request()->params('city'));
    $in_state = strtoupper($app->request()->params('state'));

    if (!empty($county_id)) {
        if (city_state_valid($in_city, $in_state)) {

            if ($dbh = connect_to_address_database()) {

                $address_keys = new \Code4KC\Address\AddressKeys($dbh, true);

                if ($exisiting_address_alias_rec = $address_keys->find_by_county_address_id($county_id)) {

                    $address_id = $exisiting_address_alias_rec['address_id'];
                    $ret = get_address_attributes($dbh, $address_id);

                } else {

                    $ret = array(
                        'code' => 404,
                        'status' => 'error',
                        'message' => 'Address not found',
                        'data' => array()
                    );
                }
            } else {
                $ret = array(
                    'code' => 404,
                    'status' => 'error',
                    'message' => 'State or City was not valid.',
                    'data' => array()
                );
            }
        } else {
            $ret = array(
                'code' => 500,
                'status' => 'failed',
                'message' => 'Unable to connect to database.',
                'data' => array()
            );
        }
    } else {
        $ret = array(
            'code' => 404,
            'status' => 'error',
            'message' => 'City ID was not valid..',
            'data' => array()
        );
    }

    $app->response->setStatus($ret['code']);
    echo json_encode($ret);
});


$app->get('/address-attributes-city-id/V0/:id/', function ($id) use ($app) {

    list($city_id, $x) = explode("?", $id);

    $in_city = strtoupper($app->request()->params('city'));
    $in_state = strtoupper($app->request()->params('state'));

    $city_id = intval($city_id);
    if ($city_id) {
        if (city_state_valid($in_city, $in_state)) {

            if ($dbh = connect_to_address_database()) {

                $address_keys = new \Code4KC\Address\AddressKeys($dbh, true);
                if ($exisiting_address_alias_rec = $address_keys->find_by_city_address_id($city_id)) {

                    $address_id = $exisiting_address_alias_rec['address_id'];
                    $ret = get_address_attributes($dbh, $address_id);

                } else {
                    $ret = array(
                        'code' => 404,
                        'status' => 'error',
                        'message' => 'Address not found',
                        'data' => array()
                    );
                }
            } else {
                $ret = array(
                    'code' => 404,
                    'status' => 'error',
                    'message' => 'State or City was not valid.',
                    'data' => array()
                );
            }
        } else {
            $ret = array(
                'code' => 500,
                'status' => 'failed',
                'message' => 'Unable to connect to database.',
                'data' => array()
            );
        }
    } else {
        $ret = array(
            'code' => 404,
            'status' => 'error',
            'message' => 'City ID was not valid..',
            'data' => array()
        );
    }

    $app->response->setStatus($ret['code']);
    echo json_encode($ret);

});

$app->get('/address-attributes/V0/:address/', function ($id) use ($app) {

    list($in_address, $x) = explode("?", $id);
    $in_address = addslashes($in_address);

    $in_city = strtoupper($app->request()->params('city'));
    $in_state = strtoupper($app->request()->params('state'));

    if (city_state_valid($in_city, $in_state)) {

        if ($dbh = connect_to_address_database()) {

            $single_line_address = normalize_address($in_address, $in_city, $in_state);

            $address_alias = new \Code4KC\Address\AddressAlias($dbh, true);

            if ($exisiting_address_alias_rec = $address_alias->find_by_single_line_address($single_line_address)) {

                $address_id = $exisiting_address_alias_rec['address_id'];

                $ret = get_address_attributes($dbh, $address_id);

            } else {
                $ret = array(
                    'code' => 404,
                    'status' => 'error',
                    'message' => 'Address not found',
                    'data' => array()
                );
            }
        } else {
            $ret = array(
                'code' => 404,
                'status' => 'error',
                'message' => 'State or City was not valid.',
                'data' => array()
            );
        }
    } else {
        $ret = array(
            'code' => 500,
            'status' => 'failed',
            'message' => 'Unable to connect to database.',
            'data' => array()
        );
    }

    $app->response->setStatus($ret['code']);
    echo json_encode($ret);

});

$app->get('/all/V0/', function () use ($app) {


    $ret = array(
        'code' => 404,
        'status' => 'error',
        'message' => 'was not valid.',
        'data' => array()
    );


    if ($dbh = connect_to_address_database()) {

        $address = new \Code4KC\Address\Address($dbh, true);

        if ($address_recs = $address->findall()) {

            $ret = array(
                'code' => 200,
                'status' => 'sucess',
                'message' => '',
                'data' => $address_recs
            );

        } else {
            $ret = array(
                'code' => 404,
                'status' => 'error',
                'message' => 'Address not found',
                'data' => array()
            );
        }

    } else {

        $ret = array(
            'code' => 500,
            'status' => 'failed',
            'message' => 'Unable to connect to database.',
            'data' => array()
        );
    }


    $app->response->setStatus($ret['code']);
    echo json_encode($ret);
});


$app->get('/jd_wp/(:id)', function ($id) use ($app) {

    $row = array('not init');
    if (!preg_match('#^[a-zA-Z0-9]+$#', $id)) {
        error_log('BAD ID ' . __FILE__ . ' ' . __LINE__);
        $app->notFound();
        $row = array('bad id');
    } else {

        $id = strtoupper($id);

        require '../config/config.php';

        try {

            $dbh = new PDO("pgsql:dbname=$DB_NAME", $DB_USER, $DB_PASS);

        } catch (PDOException $e) {
            error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
            throw new Exception('Unable to connect to database');
        }


        try {

            $query = $dbh->prepare("SELECT * FROM jd_wp WHERE county_apn_link = :id LIMIT 1 -- " . __FILE__ . ' ' . __LINE__);
            $query->execute(array(':id' => $id));

        } catch (PDOException  $e) {
            var_dump($e);
            error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
            throw new Exception('Unable to query database');
        }


        $row = $query->fetch(PDO::FETCH_ASSOC);


    }
    echo json_encode($row);
});

$app->run();

function find_all_areas(&$app, $area)
{
    if ($dbh = connect_to_spatial_database()) {

        $address = new \Code4KC\Address\Areas($area, $dbh, true);

        if ($address_recs = $address->findallgeo()) {

            $ret = array(
                'code' => 200,
                'status' => 'sucess',
                'message' => '',
                'data' => $address_recs
            );

        } else {
            $ret = array(
                'code' => 404,
                'status' => 'error',
                'message' => 'Area type not found',
                'data' => array()
            );
        }

    } else {

        $ret = array(
            'code' => 500,
            'status' => 'failed',
            'message' => 'Unable to connect to database.',
            'data' => array()
        );
    }


    $app->response->setStatus($ret['code']);

    if ($ret['code'] == 200) {
        echo $address_recs[0]['row_to_json'];
    } else {
        echo json_encode($ret);
    }
}


/**
 * @param $dbh
 * @param $address_id
 * @return array
 */
function get_address_attributes(&$dbh, $address_id)
{
    $address = new \Code4KC\Address\Address($dbh, true);
    if ($address_rec = $address->find_by_id($address_id)) {
        if ($attributes = $address->get_attributes($address_id)) {

            $data = array_merge($address_rec, $attributes);
            $ret = array(
                'code' => 200,
                'status' => 'success',
                'message' => '',
                'data' => $data
            );

        } else {
            $data = $address_rec;
            $ret = array(
                'code' => 200,
                'status' => 'success',
                'message' => 'Unable to provide address attributes',
                'data' => $data
            );
        }
    } else {

        $data = $address_rec;
        $ret = array(
            'code' => 402,
            'status' => 'error',
            'message' => 'Internal error, address alias found, but address record is missing',
            'data' => $data
        );
    }
    return $ret;
}

/**
 * @param $in_address
 * @param $in_city
 * @param $in_state
 * @return string
 */

function normalize_address($in_address, $in_city, $in_state)
{
    $address_converter = new Convissor\address\AddressStandardizationSolution();
    $single_line_address = $address_converter->AddressLineStandardization($in_address);

    $single_line_address .= ', ' . strtoupper($in_city) . ', ' . strtoupper($in_state);           // We keep unit 'internal'

    return $single_line_address;
}

/**
 * Verify that City and State are valid.
 * This is stub code till we figure out a better way.
 * @param $city
 * @param $state
 * @return bool
 */
function city_state_valid($city, $state)
{
    if (
        ($city == "" || $city == "KANSAS CITY")
        && ($state == "" || $state == "MO")
    ) {
        return true;
    } else {
        return false;
    }
}

/**
 * @return PDO
 * @throws Exception
 */
function connect_to_address_database()
{

    global $DB_NAME;
    global $DB_USER;
    global $DB_PASS;
    global $DB_HOST;

    try {
        $dbh = new PDO("pgsql:dbname=$DB_NAME", $DB_USER, $DB_PASS);
    } catch (PDOException $e) {
        error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
        return false;
    }

    return $dbh;
}


/**
 * @return PDO
 * @throws Exception
 */
function connect_to_spatial_database()
{

    global $DB_CODE4KC_NAME;
    global $DB_CODE4KC_USER;
    global $DB_CODE4KC_PASS;
    global $DB_CODE4KC_HOST;

    try {
        $dbh = new PDO("pgsql:dbname=$DB_CODE4KC_NAME", $DB_CODE4KC_USER, $DB_CODE4KC_PASS);
    } catch (PDOException $e) {
        error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
        return false;
    }

    return $dbh;
}
