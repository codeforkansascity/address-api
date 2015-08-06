<?php


require '../vendor/autoload.php';


$app = new \Slim\Slim();


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
