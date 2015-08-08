<?php


require '../vendor/autoload.php';




      $id = strtoupper('JA29620120500000000');

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
print "\n0\n\n";
      } catch(PDOException  $e ){
print "\n1";
          error_log($e->getMessage().' '.__FILE__.' '.__LINE__);
          throw new Exception('Unable to query database');
      }


      $row = $query->fetch( PDO::FETCH_ASSOC );
var_dump($row);


