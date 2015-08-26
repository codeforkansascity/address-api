<?php
// http://api.codeforkc.org/normalize_address/v0000/210%20West%2019th%20terrace/?city=KANSAS%20CITY&state=MO

require '../vendor/autoload.php';
require '../config/config.php';

require '../vendor/Convissor/address/AddressStandardizationSolution.php';

$app = new \Slim\Slim();


$app->get('/error/', function ($id) use ($app) {

});


$app->get('/address-attributes/V0/:address/', function ($id) use ($app) {

    list( $in_address, $x ) = explode("?",$id);

    $in_city = $app->request()->params('city');
    $in_state = $app->request()->params('state');

    $dbh = connect_to_address_database();


$single_line_address =  normalize_address($in_address, $in_city, $in_state); 

    $address_alias = new \Code4KC\Address\AddressAlias($dbh, true);

    if ( $exisiting_address_alias_rec = $address_alias->find_by_single_line_address( $single_line_address ) ) {

        $address_id = $exisiting_address_alias_rec['address_id'];

        $ret =  get_address_attributes( $dbh, $address_id ); 


    } else {

                $ret = array(
                    'code' => 404,
                    'status' => 'error',
                    'message' => 'Address not found',
                    'data' => array()
                );
    }

    $app->response->setStatus($ret['code']);
    echo json_encode($ret);

});


$app->get('/jd_wp/(:id)', function ($id) use ($app) {

  $row = array('not init');
  if (!preg_match('#^[a-zA-Z0-9]+$#', $id)) {
    error_log('BAD ID '.__FILE__.' '.__LINE__);
      $app->notFound();
      $row = array('bad id');
  } else {

      $id = strtoupper($id);

      require '../config/config.php';

      try {

	  $dbh = new PDO("pgsql:dbname=$DB_NAME",$DB_USER,$DB_PASS);

      } catch (PDOException $e) {
          error_log($e->getMessage().' '.__FILE__.' '.__LINE__);
          throw new Exception('Unable to connect to database');
      }


      try {

          $query = $dbh->prepare( "SELECT * FROM jd_wp WHERE county_apn_link = :id LIMIT 1 -- ".  __FILE__.' '.__LINE__);
	  $query->execute(array(':id' => $id));

      } catch(PDOException  $e ){
var_dump($e);
          error_log($e->getMessage().' '.__FILE__.' '.__LINE__);
          throw new Exception('Unable to query database');
      }


      $row = $query->fetch( PDO::FETCH_ASSOC );


  }
  echo json_encode($row);
});

$app->run();



function get_address_attributes( &$dbh, $address_id ) {
        $address = new \Code4KC\Address\Address($dbh, true);
        if ( $address_rec = $address->find_by_id( $address_id ) ) {

            if ( $attributes = $address->get_attributes( $address_id ) ) {

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


function normalize_address($in_address, $in_city, $in_state) {
    $address_converter = new Convissor\address\AddressStandardizationSolution();
    $single_line_address  = $address_converter->AddressLineStandardization($in_address);

    $single_line_address .= ', ' . strtoupper($in_city) . ', ' . strtoupper($in_state);           // We keep unit 'internal'

    return $single_line_address;
}

function connect_to_address_database() {

global $DB_NAME;
global $DB_USER;
global $DB_PASS;
global $DB_HOST;

    try {
        $dbh = new PDO("pgsql:dbname=$DB_NAME", $DB_USER, $DB_PASS);
    } catch (PDOException $e) {
        error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
        throw new Exception('Unable to connect to database');
    }

    return $dbh;
}
