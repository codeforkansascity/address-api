
\c address_api
CREATE EXTENSION postgres_fdw;
CREATE EXTENSION ogr_fdw;

ALTER TABLE  county_address_attributes ADD COLUMN delinquent_tax_2016 NUMERIC(10,2) DEFAULT 0;
ALTER TABLE  county_address_attributes ADD COLUMN delinquent_tax_2017 NUMERIC(10,2) DEFAULT 0;

