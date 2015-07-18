<?php


require '../vendor/autoload.php';


$app = new \Slim\Slim();


$app->get('/hello/:name', function ($name) {
    echo "Hello, $name";
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
          $mysqli = new mysqli($DB_HOST, $DB_USER, $DB_PASS, $DB_NAME);
      } catch (mysqli_sql_exception $e) {
          error_log($e->getMessage().' '.__FILE__.' '.__LINE__);
          throw new Exception('Unable to connect to database');
      }

      $mysqli->real_query(
        "SELECT * FROM jd_wp WHERE county_apn_link = '$id'  LIMIT 1 -- ".
        __FILE__.' '.__LINE__
    );
      if ($mysqli->error) {
          error_log($mysqli->error.' '.__FILE__.' '.__LINE__);
          throw new Exception('Unable to execute database query:');
      }

      $res = $mysqli->use_result();

      $row = $res->fetch_assoc();

  }
  echo json_encode($row);
});

$app->run();
