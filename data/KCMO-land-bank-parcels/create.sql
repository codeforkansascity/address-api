\c address_api

ALTER TABLE city_address_attributes ADD COLUMN land_bank_property SMALLINT DEFAULT 0;
ALTER TABLE city_address_attributes ADD COLUMN active SMALLINT DEFAULT 1;
