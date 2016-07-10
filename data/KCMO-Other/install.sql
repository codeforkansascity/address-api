DROP TABLE IF EXISTS address_spatial.areasf ;
DROP SEQUENCE IF EXISTS address_spatial.areasf_id_seq;
DROP TABLE IF EXISTS address_spatial.areas ;
DROP SEQUENCE IF EXISTS address_spatial.areas_id_seq;



CREATE SEQUENCE address_spatial.areas_id_seq
    START WITH 2001
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE address_spatial.areas_id_seq OWNER TO c4kc;

SET default_tablespace = '';

SET default_with_oids = false;


DROP TABLE address_spatial.areas ;
CREATE TABLE address_spatial.areas (
   id integer DEFAULT nextval('address_spatial.areas_id_seq'::regclass) NOT NULL,
   area_type_id integer DEFAULT 0,
   fid integer,
   geom geometry,
   name varchar,
   ordnum varchar,
   status varchar,
   amendment varchar,
   lastupdate varchar,
   shape_length double precision,
   shape_area double precision ,
   active integer DEFAULT 1,
   added timestamp without time zone DEFAULT now(),
   changed timestamp without time zone DEFAULT now(),
  CONSTRAINT pk_kcmo_nhood_fid PRIMARY KEY (id)
);

ALTER TABLE address_spatial.areas ALTER COLUMN geom  TYPE geometry(MultiPolygon, 4326) USING ST_Transform(geom, 4326);

CREATE INDEX idx_areas ON
  address_spatial.areas
USING gist(geom);

ALTER TABLE address_spatial.areas OWNER TO c4kc;

\d address_spatial.areas

\c address_api

ALTER TABLE  city_address_attributes ADD COLUMN tif varchar;
ALTER TABLE  city_address_attributes ADD COLUMN police_division varchar;
ALTER TABLE  city_address_attributes ADD COLUMN neighborhood_census varchar;
ALTER TABLE  city_address_attributes ADD COLUMN vacant_parcel integer DEFAULT 0;





