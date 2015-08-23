<?php
// http://api.codeforkc.org/normalize_address/v0000/210%20West%2019th%20terrace/?city=KANSAS%20CITY&state=MO

require '../vendor/autoload.php';
require '../config/config.php';

require '../vendor/Convissor/address/AddressStandardizationSolution.php';

$app = new \Slim\Slim();


$app->get('/normalize_address/v0000/:address/', function ($id) use ($app) {

    list( $in_address, $x ) = explode("?",$id);

    $in_city = $app->request()->params('city');
    $in_state = $app->request()->params('state');

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

    $address_converter = new Convissor\address\AddressStandardizationSolution();
    $address = new \Code4KC\Address\Address($dbh, true);
    $address_alias = new \Code4KC\Address\AddressAlias($dbh, true);
    $address_keys = new \Code4KC\Address\AddressKeys($dbh, true);
    $city_address_attributes = new \Code4KC\Address\CityAddressAttributes($dbh, true);


    $single_line_address  = $address_converter->AddressLineStandardization($in_address);

    $single_line_address .= ', ' . strtoupper($in_city) . ', ' . strtoupper($in_state);           // We keep unit 'internal'

    $census = new \Code4KC\Address\Census();
    $normalized_address = $census->normalize_address($single_line_address);                // Strips off unit 'internal' 

    if ( $exisiting_address_alias_rec = $address_alias->find_by_single_line_address( $single_line_address ) ) {

print "<h1>hit</h1><pre>";
    print_r($normalized_address);
    print_r($exisiting_address_alias_rec);
print "</pre>";

        $address_id = $exisiting_address_alias_rec['address_id'];
        if ( $address_rec = $address->find_by_id( $address_id ) ) {

print "<pre>";
print_r($address_rec);
print "</pre>";

            if ( $attributes = $address->get_attributes( $address_id ) ) {

print "<pre>";
print_r($attributes);
print "</pre>";

                $rec = array_merge($address_rec, $attributes);

print "<pre>";
print_r($rec);
print "</pre>";

            }
        }

    } else {
echo "MISS";
    }
    print_r($normalized_address);

echo "END";

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
