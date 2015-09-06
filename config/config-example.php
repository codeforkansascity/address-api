<?php

global $DB_NAME;
global $DB_USER;
global $DB_PASS;
global $DB_HOST;

if ( !empty( $_SERVER["DB_HOST"] )) { $DB_HOST = $_SERVER["DB_HOST"]; } else { $DB_HOST = 'localhost'; }
if ( !empty( $_SERVER["DB_USER"] )) { $DB_USER = $_SERVER["DB_USER"]; } else { $DB_USER = 'address_api'; }
if ( !empty( $_SERVER["DB_PASS"] )) { $DB_PASS = $_SERVER["DB_PASS"]; } else { $DB_PASS = 'address_api'; }
if ( !empty( $_SERVER["DB_NAME"] )) { $DB_NAME = $_SERVER["DB_NAME"]; } else { $DB_NAME = 'address_api'; }
