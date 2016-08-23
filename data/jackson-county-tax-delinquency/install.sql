
\c address_api
CREATE EXTENSION postgres_fdw;
CREATE EXTENSION ogr_fdw;

ALTER TABLE  county_address_attributes ADD COLUMN delinquent_tax_2010 NUMERIC(10,2) DEFAULT 0;
ALTER TABLE  county_address_attributes ADD COLUMN delinquent_tax_2011 NUMERIC(10,2) DEFAULT 0;
ALTER TABLE  county_address_attributes ADD COLUMN delinquent_tax_2012 NUMERIC(10,2) DEFAULT 0;
ALTER TABLE  county_address_attributes ADD COLUMN delinquent_tax_2013 NUMERIC(10,2) DEFAULT 0;
ALTER TABLE  county_address_attributes ADD COLUMN delinquent_tax_2014 NUMERIC(10,2) DEFAULT 0;
ALTER TABLE  county_address_attributes ADD COLUMN delinquent_tax_2015 NUMERIC(10,2) DEFAULT 0;
ALTER TABLE  county_address_attributes ADD COLUMN added timestamp  DEFAULT now();
ALTER TABLE  county_address_attributes ADD COLUMN changed timestamp  DEFAULT now();

CREATE INDEX ON county_address_attributes (id);
CREATE INDEX ON county_address_attributes (parcel_number);

