CREATE SCHEMA "public";

CREATE SEQUENCE address_id_seq START WITH 1;

CREATE SEQUENCE address_id_seq_02 START WITH 1;

CREATE SEQUENCE address_key_id_seq START WITH 1;

CREATE SEQUENCE address_string_alias_id_seq START WITH 1;

CREATE SEQUENCE jd_wp_id_seq START WITH 1;

CREATE SEQUENCE land_use_codes_id_seq START WITH 1;

CREATE SEQUENCE neighborhoods_id_seq START WITH 1;

CREATE SEQUENCE tmp_kcmo_all_addresses_id_seq START WITH 1;

CREATE TABLE address ( 
	id                   serial  NOT NULL,
	single_line_address  varchar(240) DEFAULT NULL::character varying ,
	street_number        varchar(10)  ,
	pre_direction        varchar(120) DEFAULT NULL::character varying ,
	street_name          varchar(100) DEFAULT NULL::character varying ,
	street_type          varchar(24) DEFAULT NULL::character varying ,
	post_direction       varchar(10) DEFAULT NULL::character varying ,
	internal             char(10)  ,
	city                 varchar(120) DEFAULT NULL::character varying ,
	"state"              varchar(2) DEFAULT NULL::character varying ,
	zip                  varchar(5) DEFAULT NULL::character varying ,
	zip4                 varchar(4) DEFAULT NULL::character varying ,
	longitude            numeric(13,10)  ,
	latitude             numeric(13,10)  ,
	added                timestamp DEFAULT now() ,
	changed              timestamp DEFAULT now() ,
	street_address       varchar  ,
	CONSTRAINT address_pkey PRIMARY KEY ( id ),
	CONSTRAINT pk_address UNIQUE ( single_line_address ) 
 );

COMMENT ON TABLE address IS 'Currently address fields are base off of tiger Geocode normalize_address values.';

COMMENT ON COLUMN address.pre_direction IS 'Directional prefix of road such as N, S, E, W etc.  These are controlled using the direction_lookup table.';

COMMENT ON COLUMN address.street_type IS 'abbreviated version of street type: e.g. St, Ave, Cir. These are controlled using the street_type_lookup table.

';

COMMENT ON COLUMN address.post_direction IS 'abbreviated directional suffice of road N, S, E, W etc. These are controlled using the direction_lookup table.';

COMMENT ON COLUMN address.internal IS 'internal address such as an apartment or suite number.';

COMMENT ON COLUMN address."state" IS 'two character US State. e.g MA, NY, MI. These are controlled by the state_lookup table.';

COMMENT ON COLUMN address.zip IS '5-digit zipcode. e.g. 02109.';

COMMENT ON COLUMN address.longitude IS 'From City';

COMMENT ON COLUMN address.latitude IS 'From City';

COMMENT ON COLUMN address.added IS 'Date/Time Added';

COMMENT ON COLUMN address.changed IS 'Date/Time last changed';

CREATE TABLE address_alias ( 
	single_line_address  varchar(240) DEFAULT NULL::character varying NOT NULL,
	address_id           integer  ,
	CONSTRAINT pk_address_string_alias PRIMARY KEY ( single_line_address ),
	CONSTRAINT fk_address_string_alias FOREIGN KEY ( address_id ) REFERENCES address( id )    
 );

CREATE INDEX idx_address_string_alias ON address_alias ( address_id );

CREATE TABLE address_keys ( 
	id                   serial  NOT NULL,
	address_id           integer  NOT NULL,
	city_address_id      integer  NOT NULL,
	county_address_id    varchar(25)  NOT NULL,
	added                timestamp DEFAULT now() ,
	changed              timestamp DEFAULT now() ,
	CONSTRAINT pk_address_keys PRIMARY KEY ( id ),
	CONSTRAINT fk_address_keys FOREIGN KEY ( address_id ) REFERENCES address( id )    
 );

CREATE INDEX idx_address_keys ON address_keys ( address_id );

CREATE INDEX idx_address_keys_0 ON address_keys ( city_address_id );

CREATE INDEX idx_address_keys_1 ON address_keys ( county_address_id );

COMMENT ON COLUMN address_keys.city_address_id IS 'KIVA pin for KCMO';

COMMENT ON COLUMN address_keys.county_address_id IS 'APN for Jackson County';

CREATE TABLE census_attributes ( 
	id                   integer  NOT NULL,
	block_2010_name      varchar(24)  ,
	block_2010_id        varchar(10)  ,
	tract_name           varchar(24)  ,
	tract_id             varchar(10)  ,
	zip                  varchar(5)  ,
	county_id            varchar(10)  ,
	state_id             varchar(10)  ,
	added                timestamp DEFAULT now() ,
	changed              timestamp DEFAULT now() ,
	longitude            varchar(10)  ,
	latitude             varchar(10)  ,
	tiger_line_id        numeric(10,0)  ,
	city_address_id      integer  ,
	county_address_id    varchar(25)  ,
	metro_areas          varchar(62)  ,
	CONSTRAINT fk_census_attributes FOREIGN KEY ( id ) REFERENCES address( id )    
 );

CREATE INDEX idx_census_attributes ON census_attributes ( id );

CREATE TABLE city_address_attributes ( 
	id                   integer  NOT NULL,
	land_use_code        varchar(124)  ,
	land_use             varchar(42)  ,
	classification       varchar(42)  ,
	sub_class            varchar(42)  ,
	neighborhood         varchar(42)  ,
	added                timestamp DEFAULT now() ,
	changed              timestamp DEFAULT now() ,
	council_district     varchar(5)  ,
	nhood                varchar(62)  ,
	land_bank_property   smallint DEFAULT 0 ,
	tif                  varchar  ,
	police_division      varchar  ,
	neighborhood_census  varchar  ,
	vacant_parcel        integer DEFAULT 0 ,
	CONSTRAINT idx_city_attributes UNIQUE ( id ) 
 );

COMMENT ON COLUMN city_address_attributes.id IS 'KIVA pin for KCMO';

COMMENT ON COLUMN city_address_attributes.land_use_code IS 'From parcel-viewer';

COMMENT ON COLUMN city_address_attributes.land_use IS 'From parcel-viewer';

COMMENT ON COLUMN city_address_attributes.classification IS 'From parcel-viewer';

COMMENT ON COLUMN city_address_attributes.sub_class IS 'From parcel-viewer';

CREATE TABLE county_address_attributes ( 
	id                   varchar(30)  ,
	gid                  integer  NOT NULL,
	parcel_number        varchar(30)  ,
	name                 varchar(50)  ,
	tif_district         varchar(40)  ,
	tif_project          varchar(60)  ,
	neighborhood_code    varchar(5)  ,
	pca_code             varchar(10)  ,
	land_use_code        varchar(5)  ,
	tca_code             varchar(10)  ,
	document_number      varchar(15)  ,
	book_number          varchar(8)  ,
	conveyance_area      varchar(12)  ,
	conveyance_designator varchar(20)  ,
	legal_description    varchar(200)  ,
	object_id            numeric(10,0)  ,
	page_number          varchar(80)  ,
	delinquent_tax_2010  numeric(10,2) DEFAULT 0 ,
	delinquent_tax_2011  numeric(10,2) DEFAULT 0 ,
	delinquent_tax_2012  numeric(10,2) DEFAULT 0 ,
	delinquent_tax_2013  numeric(10,2) DEFAULT 0 ,
	delinquent_tax_2014  numeric(10,2) DEFAULT 0 ,
	delinquent_tax_2015  numeric(10,2) DEFAULT 0 ,
	added                timestamp DEFAULT now() ,
	changed              timestamp DEFAULT now() 
 );

CREATE INDEX county_address_attributes_id_idx ON county_address_attributes ( id );

CREATE INDEX county_address_attributes_parcel_number_idx ON county_address_attributes ( parcel_number );

CREATE TABLE county_address_data ( 
	id                   varchar(30)  ,
	situs_address        varchar(80)  ,
	situs_city           varchar(80)  ,
	situs_state          varchar(80)  ,
	situs_zip            varchar(80)  ,
	"owner"              varchar(40)  ,
	owner_address        varchar(50)  ,
	owner_city           varchar(40)  ,
	owner_state          varchar(10)  ,
	owner_zip            varchar(10)  ,
	stated_area          varchar(50)  ,
	tot_sqf_l_area       numeric(10,0)  ,
	year_built           numeric(10,0)  ,
	property_area        numeric(-9999999,0)  ,
	property_picture     varchar(255)  ,
	property_report      varchar(255)  ,
	market_value         numeric(10,0)  ,
	assessed_value       numeric(10,0)  ,
	assessed_improvement varchar(10)  ,
	assessed_land        varchar(10)  ,
	taxable_value        numeric(10,0)  ,
	mtg_co               varchar(40)  ,
	mtg_co_address       varchar(50)  ,
	mtg_co_city          varchar(40)  ,
	mtg_co_state         varchar(10)  ,
	mtg_co_zip           varchar(10)  ,
	common_area          varchar(1)  ,
	floor_designator     varchar(80)  ,
	floor_name_designator varchar(25)  ,
	exempt               varchar(5)  ,
	complex_name         varchar(100)  ,
	cid                  varchar(100)  ,
	eff_from_date        varchar(80)  ,
	eff_to_date          varchar(80)  ,
	extract_date         varchar(80)  ,
	shape_st_area        numeric(-9999999,0)  ,
	shape_st_lenght      numeric(-9999999,0)  ,
	shape_st_area_1      numeric(-9999999,0)  ,
	shape_st_length_1    numeric(-9999999,0)  ,
	shape_st_legnth_2    numeric(-9999999,0)  ,
	shape_st_area_2      numeric(-9999999,0)  ,
	sim_con_div_type     varchar(10)  ,
	tax_year             numeric(10,0)  ,
	"type"               numeric(10,0)  ,
	z_designator         varchar(20)  
 );

CREATE TABLE jd_wp ( 
	id                   serial  NOT NULL,
	jrd_1                varchar(24) DEFAULT ''::character varying NOT NULL,
	jrd_sheet            varchar(24) DEFAULT ''::character varying NOT NULL,
	"order"              varchar(24) DEFAULT ''::character varying NOT NULL,
	st_num               varchar(24) DEFAULT ''::character varying NOT NULL,
	street               varchar(24) DEFAULT ''::character varying NOT NULL,
	jrd_block            varchar(24) DEFAULT ''::character varying NOT NULL,
	jrd_address          varchar(24) DEFAULT ''::character varying NOT NULL,
	short_own            varchar(24) DEFAULT ''::character varying NOT NULL,
	absentee_owner       varchar(24) DEFAULT ''::character varying NOT NULL,
	kiva_pin             varchar(24) DEFAULT ''::character varying NOT NULL,
	county_apn_link      varchar(24) DEFAULT ''::character varying NOT NULL,
	sub_division         varchar(42) DEFAULT ''::character varying NOT NULL,
	block                varchar(24) DEFAULT ''::character varying NOT NULL,
	lot                  varchar(24) DEFAULT ''::character varying NOT NULL,
	"owner"              varchar(64) DEFAULT ''::character varying NOT NULL,
	owner_2              varchar(64) DEFAULT ''::character varying NOT NULL,
	owner_address        varchar(42) DEFAULT ''::character varying NOT NULL,
	owner_city_zip       varchar(44) DEFAULT ''::character varying NOT NULL,
	site_address         varchar(42) DEFAULT ''::character varying NOT NULL,
	zip_code             varchar(24) DEFAULT ''::character varying NOT NULL,
	council_district     varchar(24) DEFAULT ''::character varying NOT NULL,
	trash_day            varchar(24) DEFAULT ''::character varying NOT NULL,
	school_distrct       varchar(24) DEFAULT ''::character varying NOT NULL,
	census_neigh_borhood varchar(24) DEFAULT ''::character varying NOT NULL,
	park_region          varchar(10) DEFAULT ''::character varying NOT NULL,
	pw_maintenance_district varchar(4) DEFAULT ''::character varying NOT NULL,
	zoning               varchar(20) DEFAULT ''::character varying NOT NULL,
	land_use             varchar(120) DEFAULT ''::character varying NOT NULL,
	blvd_front_footage   varchar(24) DEFAULT ''::character varying NOT NULL,
	effective_date       varchar(24) DEFAULT ''::character varying NOT NULL,
	assessed_land        varchar(24) DEFAULT ''::character varying NOT NULL,
	assessed_improve     varchar(24) DEFAULT ''::character varying NOT NULL,
	exempt_land          varchar(24) DEFAULT ''::character varying NOT NULL,
	exempt_improve       varchar(24) DEFAULT ''::character varying NOT NULL,
	square_feet          varchar(24) DEFAULT ''::character varying NOT NULL,
	acres                varchar(24) DEFAULT ''::character varying NOT NULL,
	perimeter            varchar(24) DEFAULT ''::character varying NOT NULL,
	year_built           varchar(24) DEFAULT ''::character varying NOT NULL,
	living_area          varchar(24) DEFAULT ''::character varying NOT NULL,
	tax_neighborhood_code varchar(24) DEFAULT ''::character varying NOT NULL,
	parcel_area_sf       varchar(24) DEFAULT ''::character varying NOT NULL,
	propert_class_pca_code varchar(24) DEFAULT ''::character varying NOT NULL,
	landuse_type         varchar(24) DEFAULT ''::character varying NOT NULL,
	market_value         varchar(24) DEFAULT ''::character varying NOT NULL,
	taxabl_evalue        varchar(24) DEFAULT ''::character varying NOT NULL,
	assessed_value       varchar(24) DEFAULT ''::character varying NOT NULL,
	tax_status           varchar(42) DEFAULT ''::character varying NOT NULL,
	legal_description    varchar(255) DEFAULT ''::character varying NOT NULL,
	CONSTRAINT jd_wp_pkey PRIMARY KEY ( id )
 );

CREATE TABLE land_use_codes ( 
	id                   serial  NOT NULL,
	land_use_code        varchar(10) DEFAULT NULL::character varying ,
	land_use_description varchar(80) DEFAULT NULL::character varying ,
	active               integer DEFAULT 1 ,
	added                timestamp DEFAULT now() ,
	changed              timestamp DEFAULT now() 
 );

CREATE TABLE neighborhoods ( 
	id                   serial  NOT NULL,
	name                 varchar(42)  ,
	CONSTRAINT neighborhoods_pkey PRIMARY KEY ( id )
 );

CREATE TABLE spatial_ref_sys ( 
	srid                 integer  NOT NULL,
	auth_name            varchar(256)  ,
	auth_srid            integer  ,
	srtext               varchar(2048)  ,
	proj4text            varchar(2048)  ,
	CONSTRAINT spatial_ref_sys_pkey PRIMARY KEY ( srid )
 );

ALTER TABLE spatial_ref_sys ADD CONSTRAINT spatial_ref_sys_srid_check CHECK ( (srid > 0) AND (srid <= 998999) );

CREATE TABLE tmp_kcmo_all_addresses ( 
	id                   serial  NOT NULL,
	address_api_id       integer  ,
	kiva_pin             integer  ,
	city_apn             varchar(30) DEFAULT NULL::character varying ,
	addr                 varchar(20) DEFAULT NULL::character varying ,
	fraction             varchar(20) DEFAULT NULL::character varying ,
	"prefix"             varchar(20) DEFAULT NULL::character varying ,
	street               varchar(50) DEFAULT NULL::character varying ,
	street_type          varchar(10) DEFAULT NULL::character varying ,
	suite                varchar(20) DEFAULT NULL::character varying ,
	city                 varchar(20) DEFAULT 'KANSAS CITY'::character varying ,
	"state"              varchar(20) DEFAULT 'MO'::character varying ,
	zip                  varchar(20) DEFAULT NULL::character varying ,
	added                timestamp DEFAULT now() ,
	changed              timestamp DEFAULT now() 
 );

CREATE OR REPLACE FUNCTION public._st_asgeojson(integer, geometry, integer, integer)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT ST_AsGeoJson($2::geometry, $3::int4, $4::int4); $function$
CREATE OR REPLACE FUNCTION public._st_asgeojson(integer, geography, integer, integer)
 RETURNS text
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$geography_as_geojson$function$

CREATE OR REPLACE FUNCTION public._st_asgml(integer, geometry, integer, integer, text, text)
 RETURNS text
 LANGUAGE c
 IMMUTABLE
AS '$libdir/postgis-2.2', $function$LWGEOM_asGML$function$
CREATE OR REPLACE FUNCTION public._st_asgml(integer, geography, integer, integer, text, text)
 RETURNS text
 LANGUAGE c
 IMMUTABLE
AS '$libdir/postgis-2.2', $function$geography_as_gml$function$

CREATE OR REPLACE FUNCTION public._st_askml(integer, geometry, integer, text)
 RETURNS text
 LANGUAGE c
 IMMUTABLE
AS '$libdir/postgis-2.2', $function$LWGEOM_asKML$function$
CREATE OR REPLACE FUNCTION public._st_askml(integer, geography, integer, text)
 RETURNS text
 LANGUAGE c
 IMMUTABLE
AS '$libdir/postgis-2.2', $function$geography_as_kml$function$

CREATE OR REPLACE FUNCTION public._st_bestsrid(geography)
 RETURNS integer
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT _ST_BestSRID($1,$1)$function$
CREATE OR REPLACE FUNCTION public._st_bestsrid(geography, geography)
 RETURNS integer
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$geography_bestsrid$function$

CREATE OR REPLACE FUNCTION public._st_contains(geom1 geometry, geom2 geometry)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT COST 100
AS '$libdir/postgis-2.2', $function$contains$function$
CREATE OR REPLACE FUNCTION public._st_contains(rast1 raster, nband1 integer, rast2 raster, nband2 integer)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT COST 1000
AS '$libdir/rtpostgis-2.2', $function$RASTER_contains$function$

CREATE OR REPLACE FUNCTION public._st_containsproperly(geom1 geometry, geom2 geometry)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT COST 100
AS '$libdir/postgis-2.2', $function$containsproperly$function$
CREATE OR REPLACE FUNCTION public._st_containsproperly(rast1 raster, nband1 integer, rast2 raster, nband2 integer)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT COST 1000
AS '$libdir/rtpostgis-2.2', $function$RASTER_containsProperly$function$

CREATE OR REPLACE FUNCTION public._st_count(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 1)
 RETURNS bigint
 LANGUAGE plpgsql
 IMMUTABLE STRICT
AS $function$
	DECLARE
		rtn bigint;
	BEGIN
		IF exclude_nodata_value IS FALSE THEN
			SELECT width * height INTO rtn FROM ST_Metadata(rast);
		ELSE
			SELECT count INTO rtn FROM _st_summarystats($1, $2, $3, $4);
		END IF;
		RETURN rtn;
	END;
	$function$
CREATE OR REPLACE FUNCTION public._st_count(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 1)
 RETURNS bigint
 LANGUAGE plpgsql
 STABLE STRICT
AS $function$
	DECLARE
		count bigint;
	BEGIN
		EXECUTE 'SELECT ST_CountAgg('
			|| quote_ident($2) || ', '
			|| $3 || ', '
			|| $4 || ', '
			|| $5 || ') '
			|| 'FROM ' || quote_ident($1)
	 	INTO count;
		RETURN count;
	END;
 	$function$

CREATE OR REPLACE FUNCTION public._st_countagg_transfn(agg agg_count, rast raster, exclude_nodata_value boolean)
 RETURNS agg_count
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
	DECLARE
		rtn_agg agg_count;
	BEGIN
		rtn_agg := __st_countagg_transfn(
			agg,
			rast,
			1, exclude_nodata_value,
			1
		);
		RETURN rtn_agg;
	END;
	$function$
CREATE OR REPLACE FUNCTION public._st_countagg_transfn(agg agg_count, rast raster, nband integer, exclude_nodata_value boolean)
 RETURNS agg_count
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
	DECLARE
		rtn_agg agg_count;
	BEGIN
		rtn_agg := __st_countagg_transfn(
			agg,
			rast,
			nband, exclude_nodata_value,
			1
		);
		RETURN rtn_agg;
	END;
	$function$
CREATE OR REPLACE FUNCTION public._st_countagg_transfn(agg agg_count, rast raster, nband integer, exclude_nodata_value boolean, sample_percent double precision)
 RETURNS agg_count
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
	DECLARE
		rtn_agg agg_count;
	BEGIN
		rtn_agg := __st_countagg_transfn(
			agg,
			rast,
			nband, exclude_nodata_value,
			sample_percent
		);
		RETURN rtn_agg;
	END;
	$function$

CREATE OR REPLACE FUNCTION public._st_countagg_transfn(agg agg_count, rast raster, exclude_nodata_value boolean)
 RETURNS agg_count
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
	DECLARE
		rtn_agg agg_count;
	BEGIN
		rtn_agg := __st_countagg_transfn(
			agg,
			rast,
			1, exclude_nodata_value,
			1
		);
		RETURN rtn_agg;
	END;
	$function$
CREATE OR REPLACE FUNCTION public._st_countagg_transfn(agg agg_count, rast raster, nband integer, exclude_nodata_value boolean)
 RETURNS agg_count
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
	DECLARE
		rtn_agg agg_count;
	BEGIN
		rtn_agg := __st_countagg_transfn(
			agg,
			rast,
			nband, exclude_nodata_value,
			1
		);
		RETURN rtn_agg;
	END;
	$function$
CREATE OR REPLACE FUNCTION public._st_countagg_transfn(agg agg_count, rast raster, nband integer, exclude_nodata_value boolean, sample_percent double precision)
 RETURNS agg_count
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
	DECLARE
		rtn_agg agg_count;
	BEGIN
		rtn_agg := __st_countagg_transfn(
			agg,
			rast,
			nband, exclude_nodata_value,
			sample_percent
		);
		RETURN rtn_agg;
	END;
	$function$

CREATE OR REPLACE FUNCTION public._st_coveredby(geom1 geometry, geom2 geometry)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT COST 100
AS '$libdir/postgis-2.2', $function$coveredby$function$
CREATE OR REPLACE FUNCTION public._st_coveredby(rast1 raster, nband1 integer, rast2 raster, nband2 integer)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT COST 1000
AS '$libdir/rtpostgis-2.2', $function$RASTER_coveredby$function$

CREATE OR REPLACE FUNCTION public._st_covers(geom1 geometry, geom2 geometry)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT COST 100
AS '$libdir/postgis-2.2', $function$covers$function$
CREATE OR REPLACE FUNCTION public._st_covers(geography, geography)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT COST 100
AS '$libdir/postgis-2.2', $function$geography_covers$function$
CREATE OR REPLACE FUNCTION public._st_covers(rast1 raster, nband1 integer, rast2 raster, nband2 integer)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT COST 1000
AS '$libdir/rtpostgis-2.2', $function$RASTER_covers$function$

CREATE OR REPLACE FUNCTION public._st_covers(geom1 geometry, geom2 geometry)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT COST 100
AS '$libdir/postgis-2.2', $function$covers$function$
CREATE OR REPLACE FUNCTION public._st_covers(geography, geography)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT COST 100
AS '$libdir/postgis-2.2', $function$geography_covers$function$
CREATE OR REPLACE FUNCTION public._st_covers(rast1 raster, nband1 integer, rast2 raster, nband2 integer)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT COST 1000
AS '$libdir/rtpostgis-2.2', $function$RASTER_covers$function$

CREATE OR REPLACE FUNCTION public._st_dfullywithin(geom1 geometry, geom2 geometry, double precision)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_dfullywithin$function$
CREATE OR REPLACE FUNCTION public._st_dfullywithin(rast1 raster, nband1 integer, rast2 raster, nband2 integer, distance double precision)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT COST 1000
AS '$libdir/rtpostgis-2.2', $function$RASTER_dfullywithin$function$

CREATE OR REPLACE FUNCTION public._st_distancetree(geography, geography)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT _ST_DistanceTree($1, $2, 0.0, true)$function$
CREATE OR REPLACE FUNCTION public._st_distancetree(geography, geography, double precision, boolean)
 RETURNS double precision
 LANGUAGE c
 IMMUTABLE STRICT COST 100
AS '$libdir/postgis-2.2', $function$geography_distance_tree$function$

CREATE OR REPLACE FUNCTION public._st_distanceuncached(geography, geography)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT _ST_DistanceUnCached($1, $2, 0.0, true)$function$
CREATE OR REPLACE FUNCTION public._st_distanceuncached(geography, geography, boolean)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT _ST_DistanceUnCached($1, $2, 0.0, $3)$function$
CREATE OR REPLACE FUNCTION public._st_distanceuncached(geography, geography, double precision, boolean)
 RETURNS double precision
 LANGUAGE c
 IMMUTABLE STRICT COST 100
AS '$libdir/postgis-2.2', $function$geography_distance_uncached$function$

CREATE OR REPLACE FUNCTION public._st_distanceuncached(geography, geography)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT _ST_DistanceUnCached($1, $2, 0.0, true)$function$
CREATE OR REPLACE FUNCTION public._st_distanceuncached(geography, geography, boolean)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT _ST_DistanceUnCached($1, $2, 0.0, $3)$function$
CREATE OR REPLACE FUNCTION public._st_distanceuncached(geography, geography, double precision, boolean)
 RETURNS double precision
 LANGUAGE c
 IMMUTABLE STRICT COST 100
AS '$libdir/postgis-2.2', $function$geography_distance_uncached$function$

CREATE OR REPLACE FUNCTION public._st_dwithin(geom1 geometry, geom2 geometry, double precision)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT COST 100
AS '$libdir/postgis-2.2', $function$LWGEOM_dwithin$function$
CREATE OR REPLACE FUNCTION public._st_dwithin(geography, geography, double precision, boolean)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT COST 100
AS '$libdir/postgis-2.2', $function$geography_dwithin$function$
CREATE OR REPLACE FUNCTION public._st_dwithin(rast1 raster, nband1 integer, rast2 raster, nband2 integer, distance double precision)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT COST 1000
AS '$libdir/rtpostgis-2.2', $function$RASTER_dwithin$function$

CREATE OR REPLACE FUNCTION public._st_dwithin(geom1 geometry, geom2 geometry, double precision)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT COST 100
AS '$libdir/postgis-2.2', $function$LWGEOM_dwithin$function$
CREATE OR REPLACE FUNCTION public._st_dwithin(geography, geography, double precision, boolean)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT COST 100
AS '$libdir/postgis-2.2', $function$geography_dwithin$function$
CREATE OR REPLACE FUNCTION public._st_dwithin(rast1 raster, nband1 integer, rast2 raster, nband2 integer, distance double precision)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT COST 1000
AS '$libdir/rtpostgis-2.2', $function$RASTER_dwithin$function$

CREATE OR REPLACE FUNCTION public._st_dwithinuncached(geography, geography, double precision)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$SELECT $1 && _ST_Expand($2,$3) AND $2 && _ST_Expand($1,$3) AND _ST_DWithinUnCached($1, $2, $3, true)$function$
CREATE OR REPLACE FUNCTION public._st_dwithinuncached(geography, geography, double precision, boolean)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT COST 100
AS '$libdir/postgis-2.2', $function$geography_dwithin_uncached$function$

CREATE OR REPLACE FUNCTION public._st_histogram(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 1, bins integer DEFAULT 0, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE c
 IMMUTABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_histogramCoverage$function$
CREATE OR REPLACE FUNCTION public._st_histogram(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 1, bins integer DEFAULT 0, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, min double precision DEFAULT NULL::double precision, max double precision DEFAULT NULL::double precision, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE c
 IMMUTABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_histogram$function$

CREATE OR REPLACE FUNCTION public._st_intersects(geom1 geometry, geom2 geometry)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT COST 100
AS '$libdir/postgis-2.2', $function$intersects$function$
CREATE OR REPLACE FUNCTION public._st_intersects(geom geometry, rast raster, nband integer DEFAULT NULL::integer)
 RETURNS boolean
 LANGUAGE plpgsql
 IMMUTABLE COST 1000
AS $function$
	DECLARE
		hasnodata boolean := TRUE;
		_geom geometry;
	BEGIN
		IF ST_SRID(rast) != ST_SRID(geom) THEN
			RAISE EXCEPTION 'Raster and geometry do not have the same SRID';
		END IF;
		_geom := ST_ConvexHull(rast);
		IF nband IS NOT NULL THEN
			SELECT CASE WHEN bmd.nodatavalue IS NULL THEN FALSE ELSE NULL END INTO hasnodata FROM ST_BandMetaData(rast, nband) AS bmd;
		END IF;
		IF ST_Intersects(geom, _geom) IS NOT TRUE THEN
			RETURN FALSE;
		ELSEIF nband IS NULL OR hasnodata IS FALSE THEN
			RETURN TRUE;
		END IF;
		SELECT ST_Collect(t.geom) INTO _geom FROM ST_PixelAsPolygons(rast, nband) AS t;
		RETURN ST_Intersects(geom, _geom);
	END;
	$function$
CREATE OR REPLACE FUNCTION public._st_intersects(rast1 raster, nband1 integer, rast2 raster, nband2 integer)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT COST 1000
AS '$libdir/rtpostgis-2.2', $function$RASTER_intersects$function$

CREATE OR REPLACE FUNCTION public._st_intersects(geom1 geometry, geom2 geometry)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT COST 100
AS '$libdir/postgis-2.2', $function$intersects$function$
CREATE OR REPLACE FUNCTION public._st_intersects(geom geometry, rast raster, nband integer DEFAULT NULL::integer)
 RETURNS boolean
 LANGUAGE plpgsql
 IMMUTABLE COST 1000
AS $function$
	DECLARE
		hasnodata boolean := TRUE;
		_geom geometry;
	BEGIN
		IF ST_SRID(rast) != ST_SRID(geom) THEN
			RAISE EXCEPTION 'Raster and geometry do not have the same SRID';
		END IF;
		_geom := ST_ConvexHull(rast);
		IF nband IS NOT NULL THEN
			SELECT CASE WHEN bmd.nodatavalue IS NULL THEN FALSE ELSE NULL END INTO hasnodata FROM ST_BandMetaData(rast, nband) AS bmd;
		END IF;
		IF ST_Intersects(geom, _geom) IS NOT TRUE THEN
			RETURN FALSE;
		ELSEIF nband IS NULL OR hasnodata IS FALSE THEN
			RETURN TRUE;
		END IF;
		SELECT ST_Collect(t.geom) INTO _geom FROM ST_PixelAsPolygons(rast, nband) AS t;
		RETURN ST_Intersects(geom, _geom);
	END;
	$function$
CREATE OR REPLACE FUNCTION public._st_intersects(rast1 raster, nband1 integer, rast2 raster, nband2 integer)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT COST 1000
AS '$libdir/rtpostgis-2.2', $function$RASTER_intersects$function$

CREATE OR REPLACE FUNCTION public._st_mapalgebra(rastbandargset rastbandarg[], expression text, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'INTERSECTION'::text, nodata1expr text DEFAULT NULL::text, nodata2expr text DEFAULT NULL::text, nodatanodataval double precision DEFAULT NULL::double precision)
 RETURNS raster
 LANGUAGE c
 STABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_nMapAlgebraExpr$function$
CREATE OR REPLACE FUNCTION public._st_mapalgebra(rastbandargset rastbandarg[], callbackfunc regprocedure, pixeltype text DEFAULT NULL::text, distancex integer DEFAULT 0, distancey integer DEFAULT 0, extenttype text DEFAULT 'INTERSECTION'::text, customextent raster DEFAULT NULL::raster, mask double precision[] DEFAULT NULL::double precision[], weighted boolean DEFAULT NULL::boolean, VARIADIC userargs text[] DEFAULT NULL::text[])
 RETURNS raster
 LANGUAGE c
 STABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_nMapAlgebra$function$

CREATE OR REPLACE FUNCTION public._st_overlaps(geom1 geometry, geom2 geometry)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT COST 100
AS '$libdir/postgis-2.2', $function$overlaps$function$
CREATE OR REPLACE FUNCTION public._st_overlaps(rast1 raster, nband1 integer, rast2 raster, nband2 integer)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT COST 1000
AS '$libdir/rtpostgis-2.2', $function$RASTER_overlaps$function$

CREATE OR REPLACE FUNCTION public._st_quantile(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 1, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE c
 IMMUTABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_quantile$function$
CREATE OR REPLACE FUNCTION public._st_quantile(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 1, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE c
 STABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_quantileCoverage$function$

CREATE OR REPLACE FUNCTION public._st_summarystats(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 1)
 RETURNS summarystats
 LANGUAGE c
 IMMUTABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_summaryStats$function$
CREATE OR REPLACE FUNCTION public._st_summarystats(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 1)
 RETURNS summarystats
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$ 
	DECLARE
		stats summarystats;
	BEGIN
		EXECUTE 'SELECT (stats).* FROM (SELECT ST_SummaryStatsAgg('
			|| quote_ident($2) || ', '
			|| $3 || ', '
			|| $4 || ', '
			|| $5 || ') AS stats '
			|| 'FROM ' || quote_ident($1)
			|| ') foo'
			INTO stats;
		RETURN stats;
	END;
	$function$

CREATE OR REPLACE FUNCTION public._st_summarystats_transfn(internal, raster, boolean, double precision)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_summaryStats_transfn$function$
CREATE OR REPLACE FUNCTION public._st_summarystats_transfn(internal, raster, integer, boolean)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_summaryStats_transfn$function$
CREATE OR REPLACE FUNCTION public._st_summarystats_transfn(internal, raster, integer, boolean, double precision)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_summaryStats_transfn$function$

CREATE OR REPLACE FUNCTION public._st_summarystats_transfn(internal, raster, boolean, double precision)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_summaryStats_transfn$function$
CREATE OR REPLACE FUNCTION public._st_summarystats_transfn(internal, raster, integer, boolean)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_summaryStats_transfn$function$
CREATE OR REPLACE FUNCTION public._st_summarystats_transfn(internal, raster, integer, boolean, double precision)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_summaryStats_transfn$function$

CREATE OR REPLACE FUNCTION public._st_touches(geom1 geometry, geom2 geometry)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT COST 100
AS '$libdir/postgis-2.2', $function$touches$function$
CREATE OR REPLACE FUNCTION public._st_touches(rast1 raster, nband1 integer, rast2 raster, nband2 integer)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT COST 1000
AS '$libdir/rtpostgis-2.2', $function$RASTER_touches$function$

CREATE OR REPLACE FUNCTION public._st_union_transfn(internal, raster)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_union_transfn$function$
CREATE OR REPLACE FUNCTION public._st_union_transfn(internal, raster, integer)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_union_transfn$function$
CREATE OR REPLACE FUNCTION public._st_union_transfn(internal, raster, text)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_union_transfn$function$
CREATE OR REPLACE FUNCTION public._st_union_transfn(internal, raster, unionarg[])
 RETURNS internal
 LANGUAGE c
 IMMUTABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_union_transfn$function$
CREATE OR REPLACE FUNCTION public._st_union_transfn(internal, raster, integer, text)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_union_transfn$function$

CREATE OR REPLACE FUNCTION public._st_union_transfn(internal, raster)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_union_transfn$function$
CREATE OR REPLACE FUNCTION public._st_union_transfn(internal, raster, integer)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_union_transfn$function$
CREATE OR REPLACE FUNCTION public._st_union_transfn(internal, raster, text)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_union_transfn$function$
CREATE OR REPLACE FUNCTION public._st_union_transfn(internal, raster, unionarg[])
 RETURNS internal
 LANGUAGE c
 IMMUTABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_union_transfn$function$
CREATE OR REPLACE FUNCTION public._st_union_transfn(internal, raster, integer, text)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_union_transfn$function$

CREATE OR REPLACE FUNCTION public._st_union_transfn(internal, raster)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_union_transfn$function$
CREATE OR REPLACE FUNCTION public._st_union_transfn(internal, raster, integer)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_union_transfn$function$
CREATE OR REPLACE FUNCTION public._st_union_transfn(internal, raster, text)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_union_transfn$function$
CREATE OR REPLACE FUNCTION public._st_union_transfn(internal, raster, unionarg[])
 RETURNS internal
 LANGUAGE c
 IMMUTABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_union_transfn$function$
CREATE OR REPLACE FUNCTION public._st_union_transfn(internal, raster, integer, text)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_union_transfn$function$

CREATE OR REPLACE FUNCTION public._st_union_transfn(internal, raster)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_union_transfn$function$
CREATE OR REPLACE FUNCTION public._st_union_transfn(internal, raster, integer)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_union_transfn$function$
CREATE OR REPLACE FUNCTION public._st_union_transfn(internal, raster, text)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_union_transfn$function$
CREATE OR REPLACE FUNCTION public._st_union_transfn(internal, raster, unionarg[])
 RETURNS internal
 LANGUAGE c
 IMMUTABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_union_transfn$function$
CREATE OR REPLACE FUNCTION public._st_union_transfn(internal, raster, integer, text)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_union_transfn$function$

CREATE OR REPLACE FUNCTION public._st_valuecount(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, searchvalues double precision[] DEFAULT NULL::double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE c
 IMMUTABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_valueCount$function$
CREATE OR REPLACE FUNCTION public._st_valuecount(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, searchvalues double precision[] DEFAULT NULL::double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE c
 STABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_valueCountCoverage$function$

CREATE OR REPLACE FUNCTION public._st_within(geom1 geometry, geom2 geometry)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$SELECT _ST_Contains($2,$1)$function$
CREATE OR REPLACE FUNCTION public._st_within(rast1 raster, nband1 integer, rast2 raster, nband2 integer)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT _st_contains($3, $4, $1, $2) $function$

CREATE OR REPLACE FUNCTION public.addgeometrycolumn(table_name character varying, column_name character varying, new_srid integer, new_type character varying, new_dim integer, use_typmod boolean DEFAULT true)
 RETURNS text
 LANGUAGE plpgsql
 STRICT
AS $function$
DECLARE
	ret  text;
BEGIN
	SELECT AddGeometryColumn('','',$1,$2,$3,$4,$5, $6) into ret;
	RETURN ret;
END;
$function$
CREATE OR REPLACE FUNCTION public.addgeometrycolumn(schema_name character varying, table_name character varying, column_name character varying, new_srid integer, new_type character varying, new_dim integer, use_typmod boolean DEFAULT true)
 RETURNS text
 LANGUAGE plpgsql
 STABLE STRICT
AS $function$
DECLARE
	ret  text;
BEGIN
	SELECT AddGeometryColumn('',$1,$2,$3,$4,$5,$6,$7) into ret;
	RETURN ret;
END;
$function$
CREATE OR REPLACE FUNCTION public.addgeometrycolumn(catalog_name character varying, schema_name character varying, table_name character varying, column_name character varying, new_srid_in integer, new_type character varying, new_dim integer, use_typmod boolean DEFAULT true)
 RETURNS text
 LANGUAGE plpgsql
 STRICT
AS $function$
DECLARE
	rec RECORD;
	sr varchar;
	real_schema name;
	sql text;
	new_srid integer;
BEGIN
	-- Verify geometry type
	IF (postgis_type_name(new_type,new_dim) IS NULL )
	THEN
		RAISE EXCEPTION 'Invalid type name "%(%)" - valid ones are:
	POINT, MULTIPOINT,
	LINESTRING, MULTILINESTRING,
	POLYGON, MULTIPOLYGON,
	CIRCULARSTRING, COMPOUNDCURVE, MULTICURVE,
	CURVEPOLYGON, MULTISURFACE,
	GEOMETRY, GEOMETRYCOLLECTION,
	POINTM, MULTIPOINTM,
	LINESTRINGM, MULTILINESTRINGM,
	POLYGONM, MULTIPOLYGONM,
	CIRCULARSTRINGM, COMPOUNDCURVEM, MULTICURVEM
	CURVEPOLYGONM, MULTISURFACEM, TRIANGLE, TRIANGLEM,
	POLYHEDRALSURFACE, POLYHEDRALSURFACEM, TIN, TINM
	or GEOMETRYCOLLECTIONM', new_type, new_dim;
		RETURN 'fail';
	END IF;

	-- Verify dimension
	IF ( (new_dim >4) OR (new_dim <2) ) THEN
		RAISE EXCEPTION 'invalid dimension';
		RETURN 'fail';
	END IF;
	IF ( (new_type LIKE '%M') AND (new_dim!=3) ) THEN
		RAISE EXCEPTION 'TypeM needs 3 dimensions';
		RETURN 'fail';
	END IF;

	-- Verify SRID
	IF ( new_srid_in > 0 ) THEN
		IF new_srid_in > 998999 THEN
			RAISE EXCEPTION 'AddGeometryColumn() - SRID must be <= %', 998999;
		END IF;
		new_srid := new_srid_in;
		SELECT SRID INTO sr FROM spatial_ref_sys WHERE SRID = new_srid;
		IF NOT FOUND THEN
			RAISE EXCEPTION 'AddGeometryColumn() - invalid SRID';
			RETURN 'fail';
		END IF;
	ELSE
		new_srid := ST_SRID('POINT EMPTY'::geometry);
		IF ( new_srid_in != new_srid ) THEN
			RAISE NOTICE 'SRID value % converted to the officially unknown SRID value %', new_srid_in, new_srid;
		END IF;
	END IF;

	-- Verify schema
	IF ( schema_name IS NOT NULL AND schema_name != '' ) THEN
		sql := 'SELECT nspname FROM pg_namespace ' ||
			'WHERE text(nspname) = ' || quote_literal(schema_name) ||
			'LIMIT 1';
		RAISE DEBUG '%', sql;
		EXECUTE sql INTO real_schema;
		IF ( real_schema IS NULL ) THEN
			RAISE EXCEPTION 'Schema % is not a valid schemaname', quote_literal(schema_name);
			RETURN 'fail';
		END IF;
	END IF;
	IF ( real_schema IS NULL ) THEN
		RAISE DEBUG 'Detecting schema';
		sql := 'SELECT n.nspname AS schemaname ' ||
			'FROM pg_catalog.pg_class c ' ||
			  'JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace ' ||
			'WHERE c.relkind = ' || quote_literal('r') ||
			' AND n.nspname NOT IN (' || quote_literal('pg_catalog') || ', ' || quote_literal('pg_toast') || ')' ||
			' AND pg_catalog.pg_table_is_visible(c.oid)' ||
			' AND c.relname = ' || quote_literal(table_name);
		RAISE DEBUG '%', sql;
		EXECUTE sql INTO real_schema;
		IF ( real_schema IS NULL ) THEN
			RAISE EXCEPTION 'Table % does not occur in the search_path', quote_literal(table_name);
			RETURN 'fail';
		END IF;
	END IF;

	-- Add geometry column to table
	IF use_typmod THEN
	     sql := 'ALTER TABLE ' ||
            quote_ident(real_schema) || '.' || quote_ident(table_name)
            || ' ADD COLUMN ' || quote_ident(column_name) ||
            ' geometry(' || postgis_type_name(new_type, new_dim) || ', ' || new_srid::text || ')';
        RAISE DEBUG '%', sql;
	ELSE
        sql := 'ALTER TABLE ' ||
            quote_ident(real_schema) || '.' || quote_ident(table_name)
            || ' ADD COLUMN ' || quote_ident(column_name) ||
            ' geometry ';
        RAISE DEBUG '%', sql;
    END IF;
	EXECUTE sql;
	IF NOT use_typmod THEN
        -- Add table CHECKs
        sql := 'ALTER TABLE ' ||
            quote_ident(real_schema) || '.' || quote_ident(table_name)
            || ' ADD CONSTRAINT '
            || quote_ident('enforce_srid_' || column_name)
            || ' CHECK (st_srid(' || quote_ident(column_name) ||
            ') = ' || new_srid::text || ')' ;
        RAISE DEBUG '%', sql;
        EXECUTE sql;
    
        sql := 'ALTER TABLE ' ||
            quote_ident(real_schema) || '.' || quote_ident(table_name)
            || ' ADD CONSTRAINT '
            || quote_ident('enforce_dims_' || column_name)
            || ' CHECK (st_ndims(' || quote_ident(column_name) ||
            ') = ' || new_dim::text || ')' ;
        RAISE DEBUG '%', sql;
        EXECUTE sql;
    
        IF ( NOT (new_type = 'GEOMETRY')) THEN
            sql := 'ALTER TABLE ' ||
                quote_ident(real_schema) || '.' || quote_ident(table_name) || ' ADD CONSTRAINT ' ||
                quote_ident('enforce_geotype_' || column_name) ||
                ' CHECK (GeometryType(' ||
                quote_ident(column_name) || ')=' ||
                quote_literal(new_type) || ' OR (' ||
                quote_ident(column_name) || ') is null)';
            RAISE DEBUG '%', sql;
            EXECUTE sql;
        END IF;
    END IF;
	RETURN
		real_schema || '.' ||
		table_name || '.' || column_name ||
		' SRID:' || new_srid::text ||
		' TYPE:' || new_type ||
		' DIMS:' || new_dim::text || ' ';
END;
$function$

CREATE OR REPLACE FUNCTION public.addgeometrycolumn(table_name character varying, column_name character varying, new_srid integer, new_type character varying, new_dim integer, use_typmod boolean DEFAULT true)
 RETURNS text
 LANGUAGE plpgsql
 STRICT
AS $function$
DECLARE
	ret  text;
BEGIN
	SELECT AddGeometryColumn('','',$1,$2,$3,$4,$5, $6) into ret;
	RETURN ret;
END;
$function$
CREATE OR REPLACE FUNCTION public.addgeometrycolumn(schema_name character varying, table_name character varying, column_name character varying, new_srid integer, new_type character varying, new_dim integer, use_typmod boolean DEFAULT true)
 RETURNS text
 LANGUAGE plpgsql
 STABLE STRICT
AS $function$
DECLARE
	ret  text;
BEGIN
	SELECT AddGeometryColumn('',$1,$2,$3,$4,$5,$6,$7) into ret;
	RETURN ret;
END;
$function$
CREATE OR REPLACE FUNCTION public.addgeometrycolumn(catalog_name character varying, schema_name character varying, table_name character varying, column_name character varying, new_srid_in integer, new_type character varying, new_dim integer, use_typmod boolean DEFAULT true)
 RETURNS text
 LANGUAGE plpgsql
 STRICT
AS $function$
DECLARE
	rec RECORD;
	sr varchar;
	real_schema name;
	sql text;
	new_srid integer;
BEGIN
	-- Verify geometry type
	IF (postgis_type_name(new_type,new_dim) IS NULL )
	THEN
		RAISE EXCEPTION 'Invalid type name "%(%)" - valid ones are:
	POINT, MULTIPOINT,
	LINESTRING, MULTILINESTRING,
	POLYGON, MULTIPOLYGON,
	CIRCULARSTRING, COMPOUNDCURVE, MULTICURVE,
	CURVEPOLYGON, MULTISURFACE,
	GEOMETRY, GEOMETRYCOLLECTION,
	POINTM, MULTIPOINTM,
	LINESTRINGM, MULTILINESTRINGM,
	POLYGONM, MULTIPOLYGONM,
	CIRCULARSTRINGM, COMPOUNDCURVEM, MULTICURVEM
	CURVEPOLYGONM, MULTISURFACEM, TRIANGLE, TRIANGLEM,
	POLYHEDRALSURFACE, POLYHEDRALSURFACEM, TIN, TINM
	or GEOMETRYCOLLECTIONM', new_type, new_dim;
		RETURN 'fail';
	END IF;

	-- Verify dimension
	IF ( (new_dim >4) OR (new_dim <2) ) THEN
		RAISE EXCEPTION 'invalid dimension';
		RETURN 'fail';
	END IF;
	IF ( (new_type LIKE '%M') AND (new_dim!=3) ) THEN
		RAISE EXCEPTION 'TypeM needs 3 dimensions';
		RETURN 'fail';
	END IF;

	-- Verify SRID
	IF ( new_srid_in > 0 ) THEN
		IF new_srid_in > 998999 THEN
			RAISE EXCEPTION 'AddGeometryColumn() - SRID must be <= %', 998999;
		END IF;
		new_srid := new_srid_in;
		SELECT SRID INTO sr FROM spatial_ref_sys WHERE SRID = new_srid;
		IF NOT FOUND THEN
			RAISE EXCEPTION 'AddGeometryColumn() - invalid SRID';
			RETURN 'fail';
		END IF;
	ELSE
		new_srid := ST_SRID('POINT EMPTY'::geometry);
		IF ( new_srid_in != new_srid ) THEN
			RAISE NOTICE 'SRID value % converted to the officially unknown SRID value %', new_srid_in, new_srid;
		END IF;
	END IF;

	-- Verify schema
	IF ( schema_name IS NOT NULL AND schema_name != '' ) THEN
		sql := 'SELECT nspname FROM pg_namespace ' ||
			'WHERE text(nspname) = ' || quote_literal(schema_name) ||
			'LIMIT 1';
		RAISE DEBUG '%', sql;
		EXECUTE sql INTO real_schema;
		IF ( real_schema IS NULL ) THEN
			RAISE EXCEPTION 'Schema % is not a valid schemaname', quote_literal(schema_name);
			RETURN 'fail';
		END IF;
	END IF;
	IF ( real_schema IS NULL ) THEN
		RAISE DEBUG 'Detecting schema';
		sql := 'SELECT n.nspname AS schemaname ' ||
			'FROM pg_catalog.pg_class c ' ||
			  'JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace ' ||
			'WHERE c.relkind = ' || quote_literal('r') ||
			' AND n.nspname NOT IN (' || quote_literal('pg_catalog') || ', ' || quote_literal('pg_toast') || ')' ||
			' AND pg_catalog.pg_table_is_visible(c.oid)' ||
			' AND c.relname = ' || quote_literal(table_name);
		RAISE DEBUG '%', sql;
		EXECUTE sql INTO real_schema;
		IF ( real_schema IS NULL ) THEN
			RAISE EXCEPTION 'Table % does not occur in the search_path', quote_literal(table_name);
			RETURN 'fail';
		END IF;
	END IF;

	-- Add geometry column to table
	IF use_typmod THEN
	     sql := 'ALTER TABLE ' ||
            quote_ident(real_schema) || '.' || quote_ident(table_name)
            || ' ADD COLUMN ' || quote_ident(column_name) ||
            ' geometry(' || postgis_type_name(new_type, new_dim) || ', ' || new_srid::text || ')';
        RAISE DEBUG '%', sql;
	ELSE
        sql := 'ALTER TABLE ' ||
            quote_ident(real_schema) || '.' || quote_ident(table_name)
            || ' ADD COLUMN ' || quote_ident(column_name) ||
            ' geometry ';
        RAISE DEBUG '%', sql;
    END IF;
	EXECUTE sql;
	IF NOT use_typmod THEN
        -- Add table CHECKs
        sql := 'ALTER TABLE ' ||
            quote_ident(real_schema) || '.' || quote_ident(table_name)
            || ' ADD CONSTRAINT '
            || quote_ident('enforce_srid_' || column_name)
            || ' CHECK (st_srid(' || quote_ident(column_name) ||
            ') = ' || new_srid::text || ')' ;
        RAISE DEBUG '%', sql;
        EXECUTE sql;
    
        sql := 'ALTER TABLE ' ||
            quote_ident(real_schema) || '.' || quote_ident(table_name)
            || ' ADD CONSTRAINT '
            || quote_ident('enforce_dims_' || column_name)
            || ' CHECK (st_ndims(' || quote_ident(column_name) ||
            ') = ' || new_dim::text || ')' ;
        RAISE DEBUG '%', sql;
        EXECUTE sql;
    
        IF ( NOT (new_type = 'GEOMETRY')) THEN
            sql := 'ALTER TABLE ' ||
                quote_ident(real_schema) || '.' || quote_ident(table_name) || ' ADD CONSTRAINT ' ||
                quote_ident('enforce_geotype_' || column_name) ||
                ' CHECK (GeometryType(' ||
                quote_ident(column_name) || ')=' ||
                quote_literal(new_type) || ' OR (' ||
                quote_ident(column_name) || ') is null)';
            RAISE DEBUG '%', sql;
            EXECUTE sql;
        END IF;
    END IF;
	RETURN
		real_schema || '.' ||
		table_name || '.' || column_name ||
		' SRID:' || new_srid::text ||
		' TYPE:' || new_type ||
		' DIMS:' || new_dim::text || ' ';
END;
$function$

CREATE OR REPLACE FUNCTION public.addoverviewconstraints(ovtable name, ovcolumn name, reftable name, refcolumn name, ovfactor integer)
 RETURNS boolean
 LANGUAGE sql
 STRICT
AS $function$ SELECT AddOverviewConstraints('', $1, $2, '', $3, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.addoverviewconstraints(ovschema name, ovtable name, ovcolumn name, refschema name, reftable name, refcolumn name, ovfactor integer)
 RETURNS boolean
 LANGUAGE plpgsql
 STRICT
AS $function$
	DECLARE
		x int;
		s name;
		t name;
		oschema name;
		rschema name;
		sql text;
		rtn boolean;
	BEGIN
		FOR x IN 1..2 LOOP
			s := '';
			IF x = 1 THEN
				s := $1;
				t := $2;
			ELSE
				s := $4;
				t := $5;
			END IF;
			-- validate user-provided schema
			IF length(s) > 0 THEN
				sql := 'SELECT nspname FROM pg_namespace '
					|| 'WHERE nspname = ' || quote_literal(s)
					|| 'LIMIT 1';
				EXECUTE sql INTO s;
				IF s IS NULL THEN
					RAISE EXCEPTION 'The value % is not a valid schema', quote_literal(s);
					RETURN FALSE;
				END IF;
			END IF;
			-- no schema, determine what it could be using the table
			IF length(s) < 1 THEN
				sql := 'SELECT n.nspname AS schemaname '
					|| 'FROM pg_catalog.pg_class c '
					|| 'JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace '
					|| 'WHERE c.relkind = ' || quote_literal('r')
					|| ' AND n.nspname NOT IN (' || quote_literal('pg_catalog')
					|| ', ' || quote_literal('pg_toast')
					|| ') AND pg_catalog.pg_table_is_visible(c.oid)'
					|| ' AND c.relname = ' || quote_literal(t);
				EXECUTE sql INTO s;
				IF s IS NULL THEN
					RAISE EXCEPTION 'The table % does not occur in the search_path', quote_literal(t);
					RETURN FALSE;
				END IF;
			END IF;
			IF x = 1 THEN
				oschema := s;
			ELSE
				rschema := s;
			END IF;
		END LOOP;
		-- reference raster
		rtn := _add_overview_constraint(oschema, $2, $3, rschema, $5, $6, $7);
		IF rtn IS FALSE THEN
			RAISE EXCEPTION 'Unable to add the overview constraint.  Is the schema name, table name or column name incorrect?';
			RETURN FALSE;
		END IF;
		RETURN TRUE;
	END;
	$function$

CREATE OR REPLACE FUNCTION public.addrasterconstraints(rasttable name, rastcolumn name, VARIADIC constraints text[])
 RETURNS boolean
 LANGUAGE sql
 STRICT
AS $function$ SELECT AddRasterConstraints('', $1, $2, VARIADIC $3) $function$
CREATE OR REPLACE FUNCTION public.addrasterconstraints(rastschema name, rasttable name, rastcolumn name, VARIADIC constraints text[])
 RETURNS boolean
 LANGUAGE plpgsql
 STRICT
AS $function$
	DECLARE
		max int;
		cnt int;
		sql text;
		schema name;
		x int;
		kw text;
		rtn boolean;
	BEGIN
		cnt := 0;
		max := array_length(constraints, 1);
		IF max < 1 THEN
			RAISE NOTICE 'No constraints indicated to be added.  Doing nothing';
			RETURN TRUE;
		END IF;
		-- validate schema
		schema := NULL;
		IF length($1) > 0 THEN
			sql := 'SELECT nspname FROM pg_namespace '
				|| 'WHERE nspname = ' || quote_literal($1)
				|| 'LIMIT 1';
			EXECUTE sql INTO schema;
			IF schema IS NULL THEN
				RAISE EXCEPTION 'The value provided for schema is invalid';
				RETURN FALSE;
			END IF;
		END IF;
		IF schema IS NULL THEN
			sql := 'SELECT n.nspname AS schemaname '
				|| 'FROM pg_catalog.pg_class c '
				|| 'JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace '
				|| 'WHERE c.relkind = ' || quote_literal('r')
				|| ' AND n.nspname NOT IN (' || quote_literal('pg_catalog')
				|| ', ' || quote_literal('pg_toast')
				|| ') AND pg_catalog.pg_table_is_visible(c.oid)'
				|| ' AND c.relname = ' || quote_literal($2);
			EXECUTE sql INTO schema;
			IF schema IS NULL THEN
				RAISE EXCEPTION 'The table % does not occur in the search_path', quote_literal($2);
				RETURN FALSE;
			END IF;
		END IF;
		<<kwloop>>
		FOR x in 1..max LOOP
			kw := trim(both from lower(constraints[x]));
			BEGIN
				CASE
					WHEN kw = 'srid' THEN
						RAISE NOTICE 'Adding SRID constraint';
						rtn := _add_raster_constraint_srid(schema, $2, $3);
					WHEN kw IN ('scale_x', 'scalex') THEN
						RAISE NOTICE 'Adding scale-X constraint';
						rtn := _add_raster_constraint_scale(schema, $2, $3, 'x');
					WHEN kw IN ('scale_y', 'scaley') THEN
						RAISE NOTICE 'Adding scale-Y constraint';
						rtn := _add_raster_constraint_scale(schema, $2, $3, 'y');
					WHEN kw = 'scale' THEN
						RAISE NOTICE 'Adding scale-X constraint';
						rtn := _add_raster_constraint_scale(schema, $2, $3, 'x');
						RAISE NOTICE 'Adding scale-Y constraint';
						rtn := _add_raster_constraint_scale(schema, $2, $3, 'y');
					WHEN kw IN ('blocksize_x', 'blocksizex', 'width') THEN
						RAISE NOTICE 'Adding blocksize-X constraint';
						rtn := _add_raster_constraint_blocksize(schema, $2, $3, 'width');
					WHEN kw IN ('blocksize_y', 'blocksizey', 'height') THEN
						RAISE NOTICE 'Adding blocksize-Y constraint';
						rtn := _add_raster_constraint_blocksize(schema, $2, $3, 'height');
					WHEN kw = 'blocksize' THEN
						RAISE NOTICE 'Adding blocksize-X constraint';
						rtn := _add_raster_constraint_blocksize(schema, $2, $3, 'width');
						RAISE NOTICE 'Adding blocksize-Y constraint';
						rtn := _add_raster_constraint_blocksize(schema, $2, $3, 'height');
					WHEN kw IN ('same_alignment', 'samealignment', 'alignment') THEN
						RAISE NOTICE 'Adding alignment constraint';
						rtn := _add_raster_constraint_alignment(schema, $2, $3);
					WHEN kw IN ('regular_blocking', 'regularblocking') THEN
						RAISE NOTICE 'Adding coverage tile constraint required for regular blocking';
						rtn := _add_raster_constraint_coverage_tile(schema, $2, $3);
						IF rtn IS NOT FALSE THEN
							RAISE NOTICE 'Adding spatially unique constraint required for regular blocking';
							rtn := _add_raster_constraint_spatially_unique(schema, $2, $3);
						END IF;
					WHEN kw IN ('num_bands', 'numbands') THEN
						RAISE NOTICE 'Adding number of bands constraint';
						rtn := _add_raster_constraint_num_bands(schema, $2, $3);
					WHEN kw IN ('pixel_types', 'pixeltypes') THEN
						RAISE NOTICE 'Adding pixel type constraint';
						rtn := _add_raster_constraint_pixel_types(schema, $2, $3);
					WHEN kw IN ('nodata_values', 'nodatavalues', 'nodata') THEN
						RAISE NOTICE 'Adding nodata value constraint';
						rtn := _add_raster_constraint_nodata_values(schema, $2, $3);
					WHEN kw IN ('out_db', 'outdb') THEN
						RAISE NOTICE 'Adding out-of-database constraint';
						rtn := _add_raster_constraint_out_db(schema, $2, $3);
					WHEN kw = 'extent' THEN
						RAISE NOTICE 'Adding maximum extent constraint';
						rtn := _add_raster_constraint_extent(schema, $2, $3);
					ELSE
						RAISE NOTICE 'Unknown constraint: %.  Skipping', quote_literal(constraints[x]);
						CONTINUE kwloop;
				END CASE;
			END;
			IF rtn IS FALSE THEN
				cnt := cnt + 1;
				RAISE WARNING 'Unable to add constraint: %.  Skipping', quote_literal(constraints[x]);
			END IF;
		END LOOP kwloop;
		IF cnt = max THEN
			RAISE EXCEPTION 'None of the constraints specified could be added.  Is the schema name, table name or column name incorrect?';
			RETURN FALSE;
		END IF;
		RETURN TRUE;
	END;
	$function$
CREATE OR REPLACE FUNCTION public.addrasterconstraints(rasttable name, rastcolumn name, srid boolean DEFAULT true, scale_x boolean DEFAULT true, scale_y boolean DEFAULT true, blocksize_x boolean DEFAULT true, blocksize_y boolean DEFAULT true, same_alignment boolean DEFAULT true, regular_blocking boolean DEFAULT false, num_bands boolean DEFAULT true, pixel_types boolean DEFAULT true, nodata_values boolean DEFAULT true, out_db boolean DEFAULT true, extent boolean DEFAULT true)
 RETURNS boolean
 LANGUAGE sql
 STRICT
AS $function$ SELECT AddRasterConstraints('', $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14) $function$
CREATE OR REPLACE FUNCTION public.addrasterconstraints(rastschema name, rasttable name, rastcolumn name, srid boolean DEFAULT true, scale_x boolean DEFAULT true, scale_y boolean DEFAULT true, blocksize_x boolean DEFAULT true, blocksize_y boolean DEFAULT true, same_alignment boolean DEFAULT true, regular_blocking boolean DEFAULT false, num_bands boolean DEFAULT true, pixel_types boolean DEFAULT true, nodata_values boolean DEFAULT true, out_db boolean DEFAULT true, extent boolean DEFAULT true)
 RETURNS boolean
 LANGUAGE plpgsql
 STRICT
AS $function$
	DECLARE
		constraints text[];
	BEGIN
		IF srid IS TRUE THEN
			constraints := constraints || 'srid'::text;
		END IF;
		IF scale_x IS TRUE THEN
			constraints := constraints || 'scale_x'::text;
		END IF;
		IF scale_y IS TRUE THEN
			constraints := constraints || 'scale_y'::text;
		END IF;
		IF blocksize_x IS TRUE THEN
			constraints := constraints || 'blocksize_x'::text;
		END IF;
		IF blocksize_y IS TRUE THEN
			constraints := constraints || 'blocksize_y'::text;
		END IF;
		IF same_alignment IS TRUE THEN
			constraints := constraints || 'same_alignment'::text;
		END IF;
		IF regular_blocking IS TRUE THEN
			constraints := constraints || 'regular_blocking'::text;
		END IF;
		IF num_bands IS TRUE THEN
			constraints := constraints || 'num_bands'::text;
		END IF;
		IF pixel_types IS TRUE THEN
			constraints := constraints || 'pixel_types'::text;
		END IF;
		IF nodata_values IS TRUE THEN
			constraints := constraints || 'nodata_values'::text;
		END IF;
		IF out_db IS TRUE THEN
			constraints := constraints || 'out_db'::text;
		END IF;
		IF extent IS TRUE THEN
			constraints := constraints || 'extent'::text;
		END IF;
		RETURN AddRasterConstraints($1, $2, $3, VARIADIC constraints);
	END;
	$function$

CREATE OR REPLACE FUNCTION public.addrasterconstraints(rasttable name, rastcolumn name, VARIADIC constraints text[])
 RETURNS boolean
 LANGUAGE sql
 STRICT
AS $function$ SELECT AddRasterConstraints('', $1, $2, VARIADIC $3) $function$
CREATE OR REPLACE FUNCTION public.addrasterconstraints(rastschema name, rasttable name, rastcolumn name, VARIADIC constraints text[])
 RETURNS boolean
 LANGUAGE plpgsql
 STRICT
AS $function$
	DECLARE
		max int;
		cnt int;
		sql text;
		schema name;
		x int;
		kw text;
		rtn boolean;
	BEGIN
		cnt := 0;
		max := array_length(constraints, 1);
		IF max < 1 THEN
			RAISE NOTICE 'No constraints indicated to be added.  Doing nothing';
			RETURN TRUE;
		END IF;
		-- validate schema
		schema := NULL;
		IF length($1) > 0 THEN
			sql := 'SELECT nspname FROM pg_namespace '
				|| 'WHERE nspname = ' || quote_literal($1)
				|| 'LIMIT 1';
			EXECUTE sql INTO schema;
			IF schema IS NULL THEN
				RAISE EXCEPTION 'The value provided for schema is invalid';
				RETURN FALSE;
			END IF;
		END IF;
		IF schema IS NULL THEN
			sql := 'SELECT n.nspname AS schemaname '
				|| 'FROM pg_catalog.pg_class c '
				|| 'JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace '
				|| 'WHERE c.relkind = ' || quote_literal('r')
				|| ' AND n.nspname NOT IN (' || quote_literal('pg_catalog')
				|| ', ' || quote_literal('pg_toast')
				|| ') AND pg_catalog.pg_table_is_visible(c.oid)'
				|| ' AND c.relname = ' || quote_literal($2);
			EXECUTE sql INTO schema;
			IF schema IS NULL THEN
				RAISE EXCEPTION 'The table % does not occur in the search_path', quote_literal($2);
				RETURN FALSE;
			END IF;
		END IF;
		<<kwloop>>
		FOR x in 1..max LOOP
			kw := trim(both from lower(constraints[x]));
			BEGIN
				CASE
					WHEN kw = 'srid' THEN
						RAISE NOTICE 'Adding SRID constraint';
						rtn := _add_raster_constraint_srid(schema, $2, $3);
					WHEN kw IN ('scale_x', 'scalex') THEN
						RAISE NOTICE 'Adding scale-X constraint';
						rtn := _add_raster_constraint_scale(schema, $2, $3, 'x');
					WHEN kw IN ('scale_y', 'scaley') THEN
						RAISE NOTICE 'Adding scale-Y constraint';
						rtn := _add_raster_constraint_scale(schema, $2, $3, 'y');
					WHEN kw = 'scale' THEN
						RAISE NOTICE 'Adding scale-X constraint';
						rtn := _add_raster_constraint_scale(schema, $2, $3, 'x');
						RAISE NOTICE 'Adding scale-Y constraint';
						rtn := _add_raster_constraint_scale(schema, $2, $3, 'y');
					WHEN kw IN ('blocksize_x', 'blocksizex', 'width') THEN
						RAISE NOTICE 'Adding blocksize-X constraint';
						rtn := _add_raster_constraint_blocksize(schema, $2, $3, 'width');
					WHEN kw IN ('blocksize_y', 'blocksizey', 'height') THEN
						RAISE NOTICE 'Adding blocksize-Y constraint';
						rtn := _add_raster_constraint_blocksize(schema, $2, $3, 'height');
					WHEN kw = 'blocksize' THEN
						RAISE NOTICE 'Adding blocksize-X constraint';
						rtn := _add_raster_constraint_blocksize(schema, $2, $3, 'width');
						RAISE NOTICE 'Adding blocksize-Y constraint';
						rtn := _add_raster_constraint_blocksize(schema, $2, $3, 'height');
					WHEN kw IN ('same_alignment', 'samealignment', 'alignment') THEN
						RAISE NOTICE 'Adding alignment constraint';
						rtn := _add_raster_constraint_alignment(schema, $2, $3);
					WHEN kw IN ('regular_blocking', 'regularblocking') THEN
						RAISE NOTICE 'Adding coverage tile constraint required for regular blocking';
						rtn := _add_raster_constraint_coverage_tile(schema, $2, $3);
						IF rtn IS NOT FALSE THEN
							RAISE NOTICE 'Adding spatially unique constraint required for regular blocking';
							rtn := _add_raster_constraint_spatially_unique(schema, $2, $3);
						END IF;
					WHEN kw IN ('num_bands', 'numbands') THEN
						RAISE NOTICE 'Adding number of bands constraint';
						rtn := _add_raster_constraint_num_bands(schema, $2, $3);
					WHEN kw IN ('pixel_types', 'pixeltypes') THEN
						RAISE NOTICE 'Adding pixel type constraint';
						rtn := _add_raster_constraint_pixel_types(schema, $2, $3);
					WHEN kw IN ('nodata_values', 'nodatavalues', 'nodata') THEN
						RAISE NOTICE 'Adding nodata value constraint';
						rtn := _add_raster_constraint_nodata_values(schema, $2, $3);
					WHEN kw IN ('out_db', 'outdb') THEN
						RAISE NOTICE 'Adding out-of-database constraint';
						rtn := _add_raster_constraint_out_db(schema, $2, $3);
					WHEN kw = 'extent' THEN
						RAISE NOTICE 'Adding maximum extent constraint';
						rtn := _add_raster_constraint_extent(schema, $2, $3);
					ELSE
						RAISE NOTICE 'Unknown constraint: %.  Skipping', quote_literal(constraints[x]);
						CONTINUE kwloop;
				END CASE;
			END;
			IF rtn IS FALSE THEN
				cnt := cnt + 1;
				RAISE WARNING 'Unable to add constraint: %.  Skipping', quote_literal(constraints[x]);
			END IF;
		END LOOP kwloop;
		IF cnt = max THEN
			RAISE EXCEPTION 'None of the constraints specified could be added.  Is the schema name, table name or column name incorrect?';
			RETURN FALSE;
		END IF;
		RETURN TRUE;
	END;
	$function$
CREATE OR REPLACE FUNCTION public.addrasterconstraints(rasttable name, rastcolumn name, srid boolean DEFAULT true, scale_x boolean DEFAULT true, scale_y boolean DEFAULT true, blocksize_x boolean DEFAULT true, blocksize_y boolean DEFAULT true, same_alignment boolean DEFAULT true, regular_blocking boolean DEFAULT false, num_bands boolean DEFAULT true, pixel_types boolean DEFAULT true, nodata_values boolean DEFAULT true, out_db boolean DEFAULT true, extent boolean DEFAULT true)
 RETURNS boolean
 LANGUAGE sql
 STRICT
AS $function$ SELECT AddRasterConstraints('', $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14) $function$
CREATE OR REPLACE FUNCTION public.addrasterconstraints(rastschema name, rasttable name, rastcolumn name, srid boolean DEFAULT true, scale_x boolean DEFAULT true, scale_y boolean DEFAULT true, blocksize_x boolean DEFAULT true, blocksize_y boolean DEFAULT true, same_alignment boolean DEFAULT true, regular_blocking boolean DEFAULT false, num_bands boolean DEFAULT true, pixel_types boolean DEFAULT true, nodata_values boolean DEFAULT true, out_db boolean DEFAULT true, extent boolean DEFAULT true)
 RETURNS boolean
 LANGUAGE plpgsql
 STRICT
AS $function$
	DECLARE
		constraints text[];
	BEGIN
		IF srid IS TRUE THEN
			constraints := constraints || 'srid'::text;
		END IF;
		IF scale_x IS TRUE THEN
			constraints := constraints || 'scale_x'::text;
		END IF;
		IF scale_y IS TRUE THEN
			constraints := constraints || 'scale_y'::text;
		END IF;
		IF blocksize_x IS TRUE THEN
			constraints := constraints || 'blocksize_x'::text;
		END IF;
		IF blocksize_y IS TRUE THEN
			constraints := constraints || 'blocksize_y'::text;
		END IF;
		IF same_alignment IS TRUE THEN
			constraints := constraints || 'same_alignment'::text;
		END IF;
		IF regular_blocking IS TRUE THEN
			constraints := constraints || 'regular_blocking'::text;
		END IF;
		IF num_bands IS TRUE THEN
			constraints := constraints || 'num_bands'::text;
		END IF;
		IF pixel_types IS TRUE THEN
			constraints := constraints || 'pixel_types'::text;
		END IF;
		IF nodata_values IS TRUE THEN
			constraints := constraints || 'nodata_values'::text;
		END IF;
		IF out_db IS TRUE THEN
			constraints := constraints || 'out_db'::text;
		END IF;
		IF extent IS TRUE THEN
			constraints := constraints || 'extent'::text;
		END IF;
		RETURN AddRasterConstraints($1, $2, $3, VARIADIC constraints);
	END;
	$function$

CREATE OR REPLACE FUNCTION public.addrasterconstraints(rasttable name, rastcolumn name, VARIADIC constraints text[])
 RETURNS boolean
 LANGUAGE sql
 STRICT
AS $function$ SELECT AddRasterConstraints('', $1, $2, VARIADIC $3) $function$
CREATE OR REPLACE FUNCTION public.addrasterconstraints(rastschema name, rasttable name, rastcolumn name, VARIADIC constraints text[])
 RETURNS boolean
 LANGUAGE plpgsql
 STRICT
AS $function$
	DECLARE
		max int;
		cnt int;
		sql text;
		schema name;
		x int;
		kw text;
		rtn boolean;
	BEGIN
		cnt := 0;
		max := array_length(constraints, 1);
		IF max < 1 THEN
			RAISE NOTICE 'No constraints indicated to be added.  Doing nothing';
			RETURN TRUE;
		END IF;
		-- validate schema
		schema := NULL;
		IF length($1) > 0 THEN
			sql := 'SELECT nspname FROM pg_namespace '
				|| 'WHERE nspname = ' || quote_literal($1)
				|| 'LIMIT 1';
			EXECUTE sql INTO schema;
			IF schema IS NULL THEN
				RAISE EXCEPTION 'The value provided for schema is invalid';
				RETURN FALSE;
			END IF;
		END IF;
		IF schema IS NULL THEN
			sql := 'SELECT n.nspname AS schemaname '
				|| 'FROM pg_catalog.pg_class c '
				|| 'JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace '
				|| 'WHERE c.relkind = ' || quote_literal('r')
				|| ' AND n.nspname NOT IN (' || quote_literal('pg_catalog')
				|| ', ' || quote_literal('pg_toast')
				|| ') AND pg_catalog.pg_table_is_visible(c.oid)'
				|| ' AND c.relname = ' || quote_literal($2);
			EXECUTE sql INTO schema;
			IF schema IS NULL THEN
				RAISE EXCEPTION 'The table % does not occur in the search_path', quote_literal($2);
				RETURN FALSE;
			END IF;
		END IF;
		<<kwloop>>
		FOR x in 1..max LOOP
			kw := trim(both from lower(constraints[x]));
			BEGIN
				CASE
					WHEN kw = 'srid' THEN
						RAISE NOTICE 'Adding SRID constraint';
						rtn := _add_raster_constraint_srid(schema, $2, $3);
					WHEN kw IN ('scale_x', 'scalex') THEN
						RAISE NOTICE 'Adding scale-X constraint';
						rtn := _add_raster_constraint_scale(schema, $2, $3, 'x');
					WHEN kw IN ('scale_y', 'scaley') THEN
						RAISE NOTICE 'Adding scale-Y constraint';
						rtn := _add_raster_constraint_scale(schema, $2, $3, 'y');
					WHEN kw = 'scale' THEN
						RAISE NOTICE 'Adding scale-X constraint';
						rtn := _add_raster_constraint_scale(schema, $2, $3, 'x');
						RAISE NOTICE 'Adding scale-Y constraint';
						rtn := _add_raster_constraint_scale(schema, $2, $3, 'y');
					WHEN kw IN ('blocksize_x', 'blocksizex', 'width') THEN
						RAISE NOTICE 'Adding blocksize-X constraint';
						rtn := _add_raster_constraint_blocksize(schema, $2, $3, 'width');
					WHEN kw IN ('blocksize_y', 'blocksizey', 'height') THEN
						RAISE NOTICE 'Adding blocksize-Y constraint';
						rtn := _add_raster_constraint_blocksize(schema, $2, $3, 'height');
					WHEN kw = 'blocksize' THEN
						RAISE NOTICE 'Adding blocksize-X constraint';
						rtn := _add_raster_constraint_blocksize(schema, $2, $3, 'width');
						RAISE NOTICE 'Adding blocksize-Y constraint';
						rtn := _add_raster_constraint_blocksize(schema, $2, $3, 'height');
					WHEN kw IN ('same_alignment', 'samealignment', 'alignment') THEN
						RAISE NOTICE 'Adding alignment constraint';
						rtn := _add_raster_constraint_alignment(schema, $2, $3);
					WHEN kw IN ('regular_blocking', 'regularblocking') THEN
						RAISE NOTICE 'Adding coverage tile constraint required for regular blocking';
						rtn := _add_raster_constraint_coverage_tile(schema, $2, $3);
						IF rtn IS NOT FALSE THEN
							RAISE NOTICE 'Adding spatially unique constraint required for regular blocking';
							rtn := _add_raster_constraint_spatially_unique(schema, $2, $3);
						END IF;
					WHEN kw IN ('num_bands', 'numbands') THEN
						RAISE NOTICE 'Adding number of bands constraint';
						rtn := _add_raster_constraint_num_bands(schema, $2, $3);
					WHEN kw IN ('pixel_types', 'pixeltypes') THEN
						RAISE NOTICE 'Adding pixel type constraint';
						rtn := _add_raster_constraint_pixel_types(schema, $2, $3);
					WHEN kw IN ('nodata_values', 'nodatavalues', 'nodata') THEN
						RAISE NOTICE 'Adding nodata value constraint';
						rtn := _add_raster_constraint_nodata_values(schema, $2, $3);
					WHEN kw IN ('out_db', 'outdb') THEN
						RAISE NOTICE 'Adding out-of-database constraint';
						rtn := _add_raster_constraint_out_db(schema, $2, $3);
					WHEN kw = 'extent' THEN
						RAISE NOTICE 'Adding maximum extent constraint';
						rtn := _add_raster_constraint_extent(schema, $2, $3);
					ELSE
						RAISE NOTICE 'Unknown constraint: %.  Skipping', quote_literal(constraints[x]);
						CONTINUE kwloop;
				END CASE;
			END;
			IF rtn IS FALSE THEN
				cnt := cnt + 1;
				RAISE WARNING 'Unable to add constraint: %.  Skipping', quote_literal(constraints[x]);
			END IF;
		END LOOP kwloop;
		IF cnt = max THEN
			RAISE EXCEPTION 'None of the constraints specified could be added.  Is the schema name, table name or column name incorrect?';
			RETURN FALSE;
		END IF;
		RETURN TRUE;
	END;
	$function$
CREATE OR REPLACE FUNCTION public.addrasterconstraints(rasttable name, rastcolumn name, srid boolean DEFAULT true, scale_x boolean DEFAULT true, scale_y boolean DEFAULT true, blocksize_x boolean DEFAULT true, blocksize_y boolean DEFAULT true, same_alignment boolean DEFAULT true, regular_blocking boolean DEFAULT false, num_bands boolean DEFAULT true, pixel_types boolean DEFAULT true, nodata_values boolean DEFAULT true, out_db boolean DEFAULT true, extent boolean DEFAULT true)
 RETURNS boolean
 LANGUAGE sql
 STRICT
AS $function$ SELECT AddRasterConstraints('', $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14) $function$
CREATE OR REPLACE FUNCTION public.addrasterconstraints(rastschema name, rasttable name, rastcolumn name, srid boolean DEFAULT true, scale_x boolean DEFAULT true, scale_y boolean DEFAULT true, blocksize_x boolean DEFAULT true, blocksize_y boolean DEFAULT true, same_alignment boolean DEFAULT true, regular_blocking boolean DEFAULT false, num_bands boolean DEFAULT true, pixel_types boolean DEFAULT true, nodata_values boolean DEFAULT true, out_db boolean DEFAULT true, extent boolean DEFAULT true)
 RETURNS boolean
 LANGUAGE plpgsql
 STRICT
AS $function$
	DECLARE
		constraints text[];
	BEGIN
		IF srid IS TRUE THEN
			constraints := constraints || 'srid'::text;
		END IF;
		IF scale_x IS TRUE THEN
			constraints := constraints || 'scale_x'::text;
		END IF;
		IF scale_y IS TRUE THEN
			constraints := constraints || 'scale_y'::text;
		END IF;
		IF blocksize_x IS TRUE THEN
			constraints := constraints || 'blocksize_x'::text;
		END IF;
		IF blocksize_y IS TRUE THEN
			constraints := constraints || 'blocksize_y'::text;
		END IF;
		IF same_alignment IS TRUE THEN
			constraints := constraints || 'same_alignment'::text;
		END IF;
		IF regular_blocking IS TRUE THEN
			constraints := constraints || 'regular_blocking'::text;
		END IF;
		IF num_bands IS TRUE THEN
			constraints := constraints || 'num_bands'::text;
		END IF;
		IF pixel_types IS TRUE THEN
			constraints := constraints || 'pixel_types'::text;
		END IF;
		IF nodata_values IS TRUE THEN
			constraints := constraints || 'nodata_values'::text;
		END IF;
		IF out_db IS TRUE THEN
			constraints := constraints || 'out_db'::text;
		END IF;
		IF extent IS TRUE THEN
			constraints := constraints || 'extent'::text;
		END IF;
		RETURN AddRasterConstraints($1, $2, $3, VARIADIC constraints);
	END;
	$function$

CREATE OR REPLACE FUNCTION public.box(geometry)
 RETURNS box
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_to_BOX$function$
CREATE OR REPLACE FUNCTION public.box(box3d)
 RETURNS box
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$BOX3D_to_BOX$function$

CREATE OR REPLACE FUNCTION public.box2d(geometry)
 RETURNS box2d
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_to_BOX2D$function$
CREATE OR REPLACE FUNCTION public.box2d(box3d)
 RETURNS box2d
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$BOX3D_to_BOX2D$function$

CREATE OR REPLACE FUNCTION public.box3d(geometry)
 RETURNS box3d
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_to_BOX3D$function$
CREATE OR REPLACE FUNCTION public.box3d(box2d)
 RETURNS box3d
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$BOX2D_to_BOX3D$function$
CREATE OR REPLACE FUNCTION public.box3d(raster)
 RETURNS box3d
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$select box3d(st_convexhull($1))$function$

CREATE OR REPLACE FUNCTION public.box3d(geometry)
 RETURNS box3d
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_to_BOX3D$function$
CREATE OR REPLACE FUNCTION public.box3d(box2d)
 RETURNS box3d
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$BOX2D_to_BOX3D$function$
CREATE OR REPLACE FUNCTION public.box3d(raster)
 RETURNS box3d
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$select box3d(st_convexhull($1))$function$

CREATE OR REPLACE FUNCTION public.bytea(geometry)
 RETURNS bytea
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_to_bytea$function$
CREATE OR REPLACE FUNCTION public.bytea(geography)
 RETURNS bytea
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_to_bytea$function$
CREATE OR REPLACE FUNCTION public.bytea(raster)
 RETURNS bytea
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/rtpostgis-2.2', $function$RASTER_to_bytea$function$

CREATE OR REPLACE FUNCTION public.bytea(geometry)
 RETURNS bytea
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_to_bytea$function$
CREATE OR REPLACE FUNCTION public.bytea(geography)
 RETURNS bytea
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_to_bytea$function$
CREATE OR REPLACE FUNCTION public.bytea(raster)
 RETURNS bytea
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/rtpostgis-2.2', $function$RASTER_to_bytea$function$

CREATE OR REPLACE FUNCTION public.checkauth(text, text)
 RETURNS integer
 LANGUAGE sql
AS $function$ SELECT CheckAuth('', $1, $2) $function$
CREATE OR REPLACE FUNCTION public.checkauth(text, text, text)
 RETURNS integer
 LANGUAGE plpgsql
AS $function$ 
DECLARE
	schema text;
BEGIN
	IF NOT LongTransactionsEnabled() THEN
		RAISE EXCEPTION 'Long transaction support disabled, use EnableLongTransaction() to enable.';
	END IF;
	if ( $1 != '' ) THEN
		schema = $1;
	ELSE
		SELECT current_schema() into schema;
	END IF;
	-- TODO: check for an already existing trigger ?
	EXECUTE 'CREATE TRIGGER check_auth BEFORE UPDATE OR DELETE ON ' 
		|| quote_ident(schema) || '.' || quote_ident($2)
		||' FOR EACH ROW EXECUTE PROCEDURE CheckAuthTrigger('
		|| quote_literal($3) || ')';
	RETURN 0;
END;
$function$

CREATE OR REPLACE FUNCTION public.dropgeometrycolumn(table_name character varying, column_name character varying)
 RETURNS text
 LANGUAGE plpgsql
 STRICT
AS $function$
DECLARE
	ret text;
BEGIN
	SELECT DropGeometryColumn('','',$1,$2) into ret;
	RETURN ret;
END;
$function$
CREATE OR REPLACE FUNCTION public.dropgeometrycolumn(schema_name character varying, table_name character varying, column_name character varying)
 RETURNS text
 LANGUAGE plpgsql
 STRICT
AS $function$
DECLARE
	ret text;
BEGIN
	SELECT DropGeometryColumn('',$1,$2,$3) into ret;
	RETURN ret;
END;
$function$
CREATE OR REPLACE FUNCTION public.dropgeometrycolumn(catalog_name character varying, schema_name character varying, table_name character varying, column_name character varying)
 RETURNS text
 LANGUAGE plpgsql
 STRICT
AS $function$
DECLARE
	myrec RECORD;
	okay boolean;
	real_schema name;
BEGIN

	-- Find, check or fix schema_name
	IF ( schema_name != '' ) THEN
		okay = false;
		FOR myrec IN SELECT nspname FROM pg_namespace WHERE text(nspname) = schema_name LOOP
			okay := true;
		END LOOP;
		IF ( okay <>  true ) THEN
			RAISE NOTICE 'Invalid schema name - using current_schema()';
			SELECT current_schema() into real_schema;
		ELSE
			real_schema = schema_name;
		END IF;
	ELSE
		SELECT current_schema() into real_schema;
	END IF;
	-- Find out if the column is in the geometry_columns table
	okay = false;
	FOR myrec IN SELECT * from geometry_columns where f_table_schema = text(real_schema) and f_table_name = table_name and f_geometry_column = column_name LOOP
		okay := true;
	END LOOP;
	IF (okay <> true) THEN
		RAISE EXCEPTION 'column not found in geometry_columns table';
		RETURN false;
	END IF;
	-- Remove table column
	EXECUTE 'ALTER TABLE ' || quote_ident(real_schema) || '.' ||
		quote_ident(table_name) || ' DROP COLUMN ' ||
		quote_ident(column_name);
	RETURN real_schema || '.' || table_name || '.' || column_name ||' effectively removed.';
END;
$function$

CREATE OR REPLACE FUNCTION public.dropgeometrycolumn(table_name character varying, column_name character varying)
 RETURNS text
 LANGUAGE plpgsql
 STRICT
AS $function$
DECLARE
	ret text;
BEGIN
	SELECT DropGeometryColumn('','',$1,$2) into ret;
	RETURN ret;
END;
$function$
CREATE OR REPLACE FUNCTION public.dropgeometrycolumn(schema_name character varying, table_name character varying, column_name character varying)
 RETURNS text
 LANGUAGE plpgsql
 STRICT
AS $function$
DECLARE
	ret text;
BEGIN
	SELECT DropGeometryColumn('',$1,$2,$3) into ret;
	RETURN ret;
END;
$function$
CREATE OR REPLACE FUNCTION public.dropgeometrycolumn(catalog_name character varying, schema_name character varying, table_name character varying, column_name character varying)
 RETURNS text
 LANGUAGE plpgsql
 STRICT
AS $function$
DECLARE
	myrec RECORD;
	okay boolean;
	real_schema name;
BEGIN

	-- Find, check or fix schema_name
	IF ( schema_name != '' ) THEN
		okay = false;
		FOR myrec IN SELECT nspname FROM pg_namespace WHERE text(nspname) = schema_name LOOP
			okay := true;
		END LOOP;
		IF ( okay <>  true ) THEN
			RAISE NOTICE 'Invalid schema name - using current_schema()';
			SELECT current_schema() into real_schema;
		ELSE
			real_schema = schema_name;
		END IF;
	ELSE
		SELECT current_schema() into real_schema;
	END IF;
	-- Find out if the column is in the geometry_columns table
	okay = false;
	FOR myrec IN SELECT * from geometry_columns where f_table_schema = text(real_schema) and f_table_name = table_name and f_geometry_column = column_name LOOP
		okay := true;
	END LOOP;
	IF (okay <> true) THEN
		RAISE EXCEPTION 'column not found in geometry_columns table';
		RETURN false;
	END IF;
	-- Remove table column
	EXECUTE 'ALTER TABLE ' || quote_ident(real_schema) || '.' ||
		quote_ident(table_name) || ' DROP COLUMN ' ||
		quote_ident(column_name);
	RETURN real_schema || '.' || table_name || '.' || column_name ||' effectively removed.';
END;
$function$

CREATE OR REPLACE FUNCTION public.dropgeometrytable(table_name character varying)
 RETURNS text
 LANGUAGE sql
 STRICT
AS $function$ SELECT DropGeometryTable('','',$1) $function$
CREATE OR REPLACE FUNCTION public.dropgeometrytable(schema_name character varying, table_name character varying)
 RETURNS text
 LANGUAGE sql
 STRICT
AS $function$ SELECT DropGeometryTable('',$1,$2) $function$
CREATE OR REPLACE FUNCTION public.dropgeometrytable(catalog_name character varying, schema_name character varying, table_name character varying)
 RETURNS text
 LANGUAGE plpgsql
 STRICT
AS $function$
DECLARE
	real_schema name;
BEGIN
	IF ( schema_name = '' ) THEN
		SELECT current_schema() into real_schema;
	ELSE
		real_schema = schema_name;
	END IF;
	-- TODO: Should we warn if table doesn't exist probably instead just saying dropped
	-- Remove table
	EXECUTE 'DROP TABLE IF EXISTS '
		|| quote_ident(real_schema) || '.' ||
		quote_ident(table_name) || ' RESTRICT';
	RETURN
		real_schema || '.' ||
		table_name ||' dropped.';
END;
$function$

CREATE OR REPLACE FUNCTION public.dropgeometrytable(table_name character varying)
 RETURNS text
 LANGUAGE sql
 STRICT
AS $function$ SELECT DropGeometryTable('','',$1) $function$
CREATE OR REPLACE FUNCTION public.dropgeometrytable(schema_name character varying, table_name character varying)
 RETURNS text
 LANGUAGE sql
 STRICT
AS $function$ SELECT DropGeometryTable('',$1,$2) $function$
CREATE OR REPLACE FUNCTION public.dropgeometrytable(catalog_name character varying, schema_name character varying, table_name character varying)
 RETURNS text
 LANGUAGE plpgsql
 STRICT
AS $function$
DECLARE
	real_schema name;
BEGIN
	IF ( schema_name = '' ) THEN
		SELECT current_schema() into real_schema;
	ELSE
		real_schema = schema_name;
	END IF;
	-- TODO: Should we warn if table doesn't exist probably instead just saying dropped
	-- Remove table
	EXECUTE 'DROP TABLE IF EXISTS '
		|| quote_ident(real_schema) || '.' ||
		quote_ident(table_name) || ' RESTRICT';
	RETURN
		real_schema || '.' ||
		table_name ||' dropped.';
END;
$function$

CREATE OR REPLACE FUNCTION public.dropoverviewconstraints(ovtable name, ovcolumn name)
 RETURNS boolean
 LANGUAGE sql
 STRICT
AS $function$ SELECT DropOverviewConstraints('', $1, $2) $function$
CREATE OR REPLACE FUNCTION public.dropoverviewconstraints(ovschema name, ovtable name, ovcolumn name)
 RETURNS boolean
 LANGUAGE plpgsql
 STRICT
AS $function$
	DECLARE
		schema name;
		sql text;
		rtn boolean;
	BEGIN
		-- validate schema
		schema := NULL;
		IF length($1) > 0 THEN
			sql := 'SELECT nspname FROM pg_namespace '
				|| 'WHERE nspname = ' || quote_literal($1)
				|| 'LIMIT 1';
			EXECUTE sql INTO schema;
			IF schema IS NULL THEN
				RAISE EXCEPTION 'The value provided for schema is invalid';
				RETURN FALSE;
			END IF;
		END IF;
		IF schema IS NULL THEN
			sql := 'SELECT n.nspname AS schemaname '
				|| 'FROM pg_catalog.pg_class c '
				|| 'JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace '
				|| 'WHERE c.relkind = ' || quote_literal('r')
				|| ' AND n.nspname NOT IN (' || quote_literal('pg_catalog')
				|| ', ' || quote_literal('pg_toast')
				|| ') AND pg_catalog.pg_table_is_visible(c.oid)'
				|| ' AND c.relname = ' || quote_literal($2);
			EXECUTE sql INTO schema;
			IF schema IS NULL THEN
				RAISE EXCEPTION 'The table % does not occur in the search_path', quote_literal($2);
				RETURN FALSE;
			END IF;
		END IF;
		rtn := _drop_overview_constraint(schema, $2, $3);
		IF rtn IS FALSE THEN
			RAISE EXCEPTION 'Unable to drop the overview constraint .  Is the schema name, table name or column name incorrect?';
			RETURN FALSE;
		END IF;
		RETURN TRUE;
	END;
	$function$

CREATE OR REPLACE FUNCTION public.droprasterconstraints(rasttable name, rastcolumn name, VARIADIC constraints text[])
 RETURNS boolean
 LANGUAGE sql
 STRICT
AS $function$ SELECT DropRasterConstraints('', $1, $2, VARIADIC $3) $function$
CREATE OR REPLACE FUNCTION public.droprasterconstraints(rastschema name, rasttable name, rastcolumn name, VARIADIC constraints text[])
 RETURNS boolean
 LANGUAGE plpgsql
 STRICT
AS $function$
	DECLARE
		max int;
		x int;
		schema name;
		sql text;
		kw text;
		rtn boolean;
		cnt int;
	BEGIN
		cnt := 0;
		max := array_length(constraints, 1);
		IF max < 1 THEN
			RAISE NOTICE 'No constraints indicated to be dropped.  Doing nothing';
			RETURN TRUE;
		END IF;
		-- validate schema
		schema := NULL;
		IF length($1) > 0 THEN
			sql := 'SELECT nspname FROM pg_namespace '
				|| 'WHERE nspname = ' || quote_literal($1)
				|| 'LIMIT 1';
			EXECUTE sql INTO schema;
			IF schema IS NULL THEN
				RAISE EXCEPTION 'The value provided for schema is invalid';
				RETURN FALSE;
			END IF;
		END IF;
		IF schema IS NULL THEN
			sql := 'SELECT n.nspname AS schemaname '
				|| 'FROM pg_catalog.pg_class c '
				|| 'JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace '
				|| 'WHERE c.relkind = ' || quote_literal('r')
				|| ' AND n.nspname NOT IN (' || quote_literal('pg_catalog')
				|| ', ' || quote_literal('pg_toast')
				|| ') AND pg_catalog.pg_table_is_visible(c.oid)'
				|| ' AND c.relname = ' || quote_literal($2);
			EXECUTE sql INTO schema;
			IF schema IS NULL THEN
				RAISE EXCEPTION 'The table % does not occur in the search_path', quote_literal($2);
				RETURN FALSE;
			END IF;
		END IF;
		<<kwloop>>
		FOR x in 1..max LOOP
			kw := trim(both from lower(constraints[x]));
			BEGIN
				CASE
					WHEN kw = 'srid' THEN
						RAISE NOTICE 'Dropping SRID constraint';
						rtn := _drop_raster_constraint_srid(schema, $2, $3);
					WHEN kw IN ('scale_x', 'scalex') THEN
						RAISE NOTICE 'Dropping scale-X constraint';
						rtn := _drop_raster_constraint_scale(schema, $2, $3, 'x');
					WHEN kw IN ('scale_y', 'scaley') THEN
						RAISE NOTICE 'Dropping scale-Y constraint';
						rtn := _drop_raster_constraint_scale(schema, $2, $3, 'y');
					WHEN kw = 'scale' THEN
						RAISE NOTICE 'Dropping scale-X constraint';
						rtn := _drop_raster_constraint_scale(schema, $2, $3, 'x');
						RAISE NOTICE 'Dropping scale-Y constraint';
						rtn := _drop_raster_constraint_scale(schema, $2, $3, 'y');
					WHEN kw IN ('blocksize_x', 'blocksizex', 'width') THEN
						RAISE NOTICE 'Dropping blocksize-X constraint';
						rtn := _drop_raster_constraint_blocksize(schema, $2, $3, 'width');
					WHEN kw IN ('blocksize_y', 'blocksizey', 'height') THEN
						RAISE NOTICE 'Dropping blocksize-Y constraint';
						rtn := _drop_raster_constraint_blocksize(schema, $2, $3, 'height');
					WHEN kw = 'blocksize' THEN
						RAISE NOTICE 'Dropping blocksize-X constraint';
						rtn := _drop_raster_constraint_blocksize(schema, $2, $3, 'width');
						RAISE NOTICE 'Dropping blocksize-Y constraint';
						rtn := _drop_raster_constraint_blocksize(schema, $2, $3, 'height');
					WHEN kw IN ('same_alignment', 'samealignment', 'alignment') THEN
						RAISE NOTICE 'Dropping alignment constraint';
						rtn := _drop_raster_constraint_alignment(schema, $2, $3);
					WHEN kw IN ('regular_blocking', 'regularblocking') THEN
						rtn := _drop_raster_constraint_regular_blocking(schema, $2, $3);
						RAISE NOTICE 'Dropping coverage tile constraint required for regular blocking';
						rtn := _drop_raster_constraint_coverage_tile(schema, $2, $3);
						IF rtn IS NOT FALSE THEN
							RAISE NOTICE 'Dropping spatially unique constraint required for regular blocking';
							rtn := _drop_raster_constraint_spatially_unique(schema, $2, $3);
						END IF;
					WHEN kw IN ('num_bands', 'numbands') THEN
						RAISE NOTICE 'Dropping number of bands constraint';
						rtn := _drop_raster_constraint_num_bands(schema, $2, $3);
					WHEN kw IN ('pixel_types', 'pixeltypes') THEN
						RAISE NOTICE 'Dropping pixel type constraint';
						rtn := _drop_raster_constraint_pixel_types(schema, $2, $3);
					WHEN kw IN ('nodata_values', 'nodatavalues', 'nodata') THEN
						RAISE NOTICE 'Dropping nodata value constraint';
						rtn := _drop_raster_constraint_nodata_values(schema, $2, $3);
					WHEN kw IN ('out_db', 'outdb') THEN
						RAISE NOTICE 'Dropping out-of-database constraint';
						rtn := _drop_raster_constraint_out_db(schema, $2, $3);
					WHEN kw = 'extent' THEN
						RAISE NOTICE 'Dropping maximum extent constraint';
						rtn := _drop_raster_constraint_extent(schema, $2, $3);
					ELSE
						RAISE NOTICE 'Unknown constraint: %.  Skipping', quote_literal(constraints[x]);
						CONTINUE kwloop;
				END CASE;
			END;
			IF rtn IS FALSE THEN
				cnt := cnt + 1;
				RAISE WARNING 'Unable to drop constraint: %.  Skipping', quote_literal(constraints[x]);
			END IF;
		END LOOP kwloop;
		IF cnt = max THEN
			RAISE EXCEPTION 'None of the constraints specified could be dropped.  Is the schema name, table name or column name incorrect?';
			RETURN FALSE;
		END IF;
		RETURN TRUE;
	END;
	$function$
CREATE OR REPLACE FUNCTION public.droprasterconstraints(rasttable name, rastcolumn name, srid boolean DEFAULT true, scale_x boolean DEFAULT true, scale_y boolean DEFAULT true, blocksize_x boolean DEFAULT true, blocksize_y boolean DEFAULT true, same_alignment boolean DEFAULT true, regular_blocking boolean DEFAULT true, num_bands boolean DEFAULT true, pixel_types boolean DEFAULT true, nodata_values boolean DEFAULT true, out_db boolean DEFAULT true, extent boolean DEFAULT true)
 RETURNS boolean
 LANGUAGE sql
 STRICT
AS $function$ SELECT DropRasterConstraints('', $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14) $function$
CREATE OR REPLACE FUNCTION public.droprasterconstraints(rastschema name, rasttable name, rastcolumn name, srid boolean DEFAULT true, scale_x boolean DEFAULT true, scale_y boolean DEFAULT true, blocksize_x boolean DEFAULT true, blocksize_y boolean DEFAULT true, same_alignment boolean DEFAULT true, regular_blocking boolean DEFAULT true, num_bands boolean DEFAULT true, pixel_types boolean DEFAULT true, nodata_values boolean DEFAULT true, out_db boolean DEFAULT true, extent boolean DEFAULT true)
 RETURNS boolean
 LANGUAGE plpgsql
 STRICT
AS $function$
	DECLARE
		constraints text[];
	BEGIN
		IF srid IS TRUE THEN
			constraints := constraints || 'srid'::text;
		END IF;
		IF scale_x IS TRUE THEN
			constraints := constraints || 'scale_x'::text;
		END IF;
		IF scale_y IS TRUE THEN
			constraints := constraints || 'scale_y'::text;
		END IF;
		IF blocksize_x IS TRUE THEN
			constraints := constraints || 'blocksize_x'::text;
		END IF;
		IF blocksize_y IS TRUE THEN
			constraints := constraints || 'blocksize_y'::text;
		END IF;
		IF same_alignment IS TRUE THEN
			constraints := constraints || 'same_alignment'::text;
		END IF;
		IF regular_blocking IS TRUE THEN
			constraints := constraints || 'regular_blocking'::text;
		END IF;
		IF num_bands IS TRUE THEN
			constraints := constraints || 'num_bands'::text;
		END IF;
		IF pixel_types IS TRUE THEN
			constraints := constraints || 'pixel_types'::text;
		END IF;
		IF nodata_values IS TRUE THEN
			constraints := constraints || 'nodata_values'::text;
		END IF;
		IF out_db IS TRUE THEN
			constraints := constraints || 'out_db'::text;
		END IF;
		IF extent IS TRUE THEN
			constraints := constraints || 'extent'::text;
		END IF;
		RETURN DropRasterConstraints($1, $2, $3, VARIADIC constraints);
	END;
	$function$

CREATE OR REPLACE FUNCTION public.droprasterconstraints(rasttable name, rastcolumn name, VARIADIC constraints text[])
 RETURNS boolean
 LANGUAGE sql
 STRICT
AS $function$ SELECT DropRasterConstraints('', $1, $2, VARIADIC $3) $function$
CREATE OR REPLACE FUNCTION public.droprasterconstraints(rastschema name, rasttable name, rastcolumn name, VARIADIC constraints text[])
 RETURNS boolean
 LANGUAGE plpgsql
 STRICT
AS $function$
	DECLARE
		max int;
		x int;
		schema name;
		sql text;
		kw text;
		rtn boolean;
		cnt int;
	BEGIN
		cnt := 0;
		max := array_length(constraints, 1);
		IF max < 1 THEN
			RAISE NOTICE 'No constraints indicated to be dropped.  Doing nothing';
			RETURN TRUE;
		END IF;
		-- validate schema
		schema := NULL;
		IF length($1) > 0 THEN
			sql := 'SELECT nspname FROM pg_namespace '
				|| 'WHERE nspname = ' || quote_literal($1)
				|| 'LIMIT 1';
			EXECUTE sql INTO schema;
			IF schema IS NULL THEN
				RAISE EXCEPTION 'The value provided for schema is invalid';
				RETURN FALSE;
			END IF;
		END IF;
		IF schema IS NULL THEN
			sql := 'SELECT n.nspname AS schemaname '
				|| 'FROM pg_catalog.pg_class c '
				|| 'JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace '
				|| 'WHERE c.relkind = ' || quote_literal('r')
				|| ' AND n.nspname NOT IN (' || quote_literal('pg_catalog')
				|| ', ' || quote_literal('pg_toast')
				|| ') AND pg_catalog.pg_table_is_visible(c.oid)'
				|| ' AND c.relname = ' || quote_literal($2);
			EXECUTE sql INTO schema;
			IF schema IS NULL THEN
				RAISE EXCEPTION 'The table % does not occur in the search_path', quote_literal($2);
				RETURN FALSE;
			END IF;
		END IF;
		<<kwloop>>
		FOR x in 1..max LOOP
			kw := trim(both from lower(constraints[x]));
			BEGIN
				CASE
					WHEN kw = 'srid' THEN
						RAISE NOTICE 'Dropping SRID constraint';
						rtn := _drop_raster_constraint_srid(schema, $2, $3);
					WHEN kw IN ('scale_x', 'scalex') THEN
						RAISE NOTICE 'Dropping scale-X constraint';
						rtn := _drop_raster_constraint_scale(schema, $2, $3, 'x');
					WHEN kw IN ('scale_y', 'scaley') THEN
						RAISE NOTICE 'Dropping scale-Y constraint';
						rtn := _drop_raster_constraint_scale(schema, $2, $3, 'y');
					WHEN kw = 'scale' THEN
						RAISE NOTICE 'Dropping scale-X constraint';
						rtn := _drop_raster_constraint_scale(schema, $2, $3, 'x');
						RAISE NOTICE 'Dropping scale-Y constraint';
						rtn := _drop_raster_constraint_scale(schema, $2, $3, 'y');
					WHEN kw IN ('blocksize_x', 'blocksizex', 'width') THEN
						RAISE NOTICE 'Dropping blocksize-X constraint';
						rtn := _drop_raster_constraint_blocksize(schema, $2, $3, 'width');
					WHEN kw IN ('blocksize_y', 'blocksizey', 'height') THEN
						RAISE NOTICE 'Dropping blocksize-Y constraint';
						rtn := _drop_raster_constraint_blocksize(schema, $2, $3, 'height');
					WHEN kw = 'blocksize' THEN
						RAISE NOTICE 'Dropping blocksize-X constraint';
						rtn := _drop_raster_constraint_blocksize(schema, $2, $3, 'width');
						RAISE NOTICE 'Dropping blocksize-Y constraint';
						rtn := _drop_raster_constraint_blocksize(schema, $2, $3, 'height');
					WHEN kw IN ('same_alignment', 'samealignment', 'alignment') THEN
						RAISE NOTICE 'Dropping alignment constraint';
						rtn := _drop_raster_constraint_alignment(schema, $2, $3);
					WHEN kw IN ('regular_blocking', 'regularblocking') THEN
						rtn := _drop_raster_constraint_regular_blocking(schema, $2, $3);
						RAISE NOTICE 'Dropping coverage tile constraint required for regular blocking';
						rtn := _drop_raster_constraint_coverage_tile(schema, $2, $3);
						IF rtn IS NOT FALSE THEN
							RAISE NOTICE 'Dropping spatially unique constraint required for regular blocking';
							rtn := _drop_raster_constraint_spatially_unique(schema, $2, $3);
						END IF;
					WHEN kw IN ('num_bands', 'numbands') THEN
						RAISE NOTICE 'Dropping number of bands constraint';
						rtn := _drop_raster_constraint_num_bands(schema, $2, $3);
					WHEN kw IN ('pixel_types', 'pixeltypes') THEN
						RAISE NOTICE 'Dropping pixel type constraint';
						rtn := _drop_raster_constraint_pixel_types(schema, $2, $3);
					WHEN kw IN ('nodata_values', 'nodatavalues', 'nodata') THEN
						RAISE NOTICE 'Dropping nodata value constraint';
						rtn := _drop_raster_constraint_nodata_values(schema, $2, $3);
					WHEN kw IN ('out_db', 'outdb') THEN
						RAISE NOTICE 'Dropping out-of-database constraint';
						rtn := _drop_raster_constraint_out_db(schema, $2, $3);
					WHEN kw = 'extent' THEN
						RAISE NOTICE 'Dropping maximum extent constraint';
						rtn := _drop_raster_constraint_extent(schema, $2, $3);
					ELSE
						RAISE NOTICE 'Unknown constraint: %.  Skipping', quote_literal(constraints[x]);
						CONTINUE kwloop;
				END CASE;
			END;
			IF rtn IS FALSE THEN
				cnt := cnt + 1;
				RAISE WARNING 'Unable to drop constraint: %.  Skipping', quote_literal(constraints[x]);
			END IF;
		END LOOP kwloop;
		IF cnt = max THEN
			RAISE EXCEPTION 'None of the constraints specified could be dropped.  Is the schema name, table name or column name incorrect?';
			RETURN FALSE;
		END IF;
		RETURN TRUE;
	END;
	$function$
CREATE OR REPLACE FUNCTION public.droprasterconstraints(rasttable name, rastcolumn name, srid boolean DEFAULT true, scale_x boolean DEFAULT true, scale_y boolean DEFAULT true, blocksize_x boolean DEFAULT true, blocksize_y boolean DEFAULT true, same_alignment boolean DEFAULT true, regular_blocking boolean DEFAULT true, num_bands boolean DEFAULT true, pixel_types boolean DEFAULT true, nodata_values boolean DEFAULT true, out_db boolean DEFAULT true, extent boolean DEFAULT true)
 RETURNS boolean
 LANGUAGE sql
 STRICT
AS $function$ SELECT DropRasterConstraints('', $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14) $function$
CREATE OR REPLACE FUNCTION public.droprasterconstraints(rastschema name, rasttable name, rastcolumn name, srid boolean DEFAULT true, scale_x boolean DEFAULT true, scale_y boolean DEFAULT true, blocksize_x boolean DEFAULT true, blocksize_y boolean DEFAULT true, same_alignment boolean DEFAULT true, regular_blocking boolean DEFAULT true, num_bands boolean DEFAULT true, pixel_types boolean DEFAULT true, nodata_values boolean DEFAULT true, out_db boolean DEFAULT true, extent boolean DEFAULT true)
 RETURNS boolean
 LANGUAGE plpgsql
 STRICT
AS $function$
	DECLARE
		constraints text[];
	BEGIN
		IF srid IS TRUE THEN
			constraints := constraints || 'srid'::text;
		END IF;
		IF scale_x IS TRUE THEN
			constraints := constraints || 'scale_x'::text;
		END IF;
		IF scale_y IS TRUE THEN
			constraints := constraints || 'scale_y'::text;
		END IF;
		IF blocksize_x IS TRUE THEN
			constraints := constraints || 'blocksize_x'::text;
		END IF;
		IF blocksize_y IS TRUE THEN
			constraints := constraints || 'blocksize_y'::text;
		END IF;
		IF same_alignment IS TRUE THEN
			constraints := constraints || 'same_alignment'::text;
		END IF;
		IF regular_blocking IS TRUE THEN
			constraints := constraints || 'regular_blocking'::text;
		END IF;
		IF num_bands IS TRUE THEN
			constraints := constraints || 'num_bands'::text;
		END IF;
		IF pixel_types IS TRUE THEN
			constraints := constraints || 'pixel_types'::text;
		END IF;
		IF nodata_values IS TRUE THEN
			constraints := constraints || 'nodata_values'::text;
		END IF;
		IF out_db IS TRUE THEN
			constraints := constraints || 'out_db'::text;
		END IF;
		IF extent IS TRUE THEN
			constraints := constraints || 'extent'::text;
		END IF;
		RETURN DropRasterConstraints($1, $2, $3, VARIADIC constraints);
	END;
	$function$

CREATE OR REPLACE FUNCTION public.droprasterconstraints(rasttable name, rastcolumn name, VARIADIC constraints text[])
 RETURNS boolean
 LANGUAGE sql
 STRICT
AS $function$ SELECT DropRasterConstraints('', $1, $2, VARIADIC $3) $function$
CREATE OR REPLACE FUNCTION public.droprasterconstraints(rastschema name, rasttable name, rastcolumn name, VARIADIC constraints text[])
 RETURNS boolean
 LANGUAGE plpgsql
 STRICT
AS $function$
	DECLARE
		max int;
		x int;
		schema name;
		sql text;
		kw text;
		rtn boolean;
		cnt int;
	BEGIN
		cnt := 0;
		max := array_length(constraints, 1);
		IF max < 1 THEN
			RAISE NOTICE 'No constraints indicated to be dropped.  Doing nothing';
			RETURN TRUE;
		END IF;
		-- validate schema
		schema := NULL;
		IF length($1) > 0 THEN
			sql := 'SELECT nspname FROM pg_namespace '
				|| 'WHERE nspname = ' || quote_literal($1)
				|| 'LIMIT 1';
			EXECUTE sql INTO schema;
			IF schema IS NULL THEN
				RAISE EXCEPTION 'The value provided for schema is invalid';
				RETURN FALSE;
			END IF;
		END IF;
		IF schema IS NULL THEN
			sql := 'SELECT n.nspname AS schemaname '
				|| 'FROM pg_catalog.pg_class c '
				|| 'JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace '
				|| 'WHERE c.relkind = ' || quote_literal('r')
				|| ' AND n.nspname NOT IN (' || quote_literal('pg_catalog')
				|| ', ' || quote_literal('pg_toast')
				|| ') AND pg_catalog.pg_table_is_visible(c.oid)'
				|| ' AND c.relname = ' || quote_literal($2);
			EXECUTE sql INTO schema;
			IF schema IS NULL THEN
				RAISE EXCEPTION 'The table % does not occur in the search_path', quote_literal($2);
				RETURN FALSE;
			END IF;
		END IF;
		<<kwloop>>
		FOR x in 1..max LOOP
			kw := trim(both from lower(constraints[x]));
			BEGIN
				CASE
					WHEN kw = 'srid' THEN
						RAISE NOTICE 'Dropping SRID constraint';
						rtn := _drop_raster_constraint_srid(schema, $2, $3);
					WHEN kw IN ('scale_x', 'scalex') THEN
						RAISE NOTICE 'Dropping scale-X constraint';
						rtn := _drop_raster_constraint_scale(schema, $2, $3, 'x');
					WHEN kw IN ('scale_y', 'scaley') THEN
						RAISE NOTICE 'Dropping scale-Y constraint';
						rtn := _drop_raster_constraint_scale(schema, $2, $3, 'y');
					WHEN kw = 'scale' THEN
						RAISE NOTICE 'Dropping scale-X constraint';
						rtn := _drop_raster_constraint_scale(schema, $2, $3, 'x');
						RAISE NOTICE 'Dropping scale-Y constraint';
						rtn := _drop_raster_constraint_scale(schema, $2, $3, 'y');
					WHEN kw IN ('blocksize_x', 'blocksizex', 'width') THEN
						RAISE NOTICE 'Dropping blocksize-X constraint';
						rtn := _drop_raster_constraint_blocksize(schema, $2, $3, 'width');
					WHEN kw IN ('blocksize_y', 'blocksizey', 'height') THEN
						RAISE NOTICE 'Dropping blocksize-Y constraint';
						rtn := _drop_raster_constraint_blocksize(schema, $2, $3, 'height');
					WHEN kw = 'blocksize' THEN
						RAISE NOTICE 'Dropping blocksize-X constraint';
						rtn := _drop_raster_constraint_blocksize(schema, $2, $3, 'width');
						RAISE NOTICE 'Dropping blocksize-Y constraint';
						rtn := _drop_raster_constraint_blocksize(schema, $2, $3, 'height');
					WHEN kw IN ('same_alignment', 'samealignment', 'alignment') THEN
						RAISE NOTICE 'Dropping alignment constraint';
						rtn := _drop_raster_constraint_alignment(schema, $2, $3);
					WHEN kw IN ('regular_blocking', 'regularblocking') THEN
						rtn := _drop_raster_constraint_regular_blocking(schema, $2, $3);
						RAISE NOTICE 'Dropping coverage tile constraint required for regular blocking';
						rtn := _drop_raster_constraint_coverage_tile(schema, $2, $3);
						IF rtn IS NOT FALSE THEN
							RAISE NOTICE 'Dropping spatially unique constraint required for regular blocking';
							rtn := _drop_raster_constraint_spatially_unique(schema, $2, $3);
						END IF;
					WHEN kw IN ('num_bands', 'numbands') THEN
						RAISE NOTICE 'Dropping number of bands constraint';
						rtn := _drop_raster_constraint_num_bands(schema, $2, $3);
					WHEN kw IN ('pixel_types', 'pixeltypes') THEN
						RAISE NOTICE 'Dropping pixel type constraint';
						rtn := _drop_raster_constraint_pixel_types(schema, $2, $3);
					WHEN kw IN ('nodata_values', 'nodatavalues', 'nodata') THEN
						RAISE NOTICE 'Dropping nodata value constraint';
						rtn := _drop_raster_constraint_nodata_values(schema, $2, $3);
					WHEN kw IN ('out_db', 'outdb') THEN
						RAISE NOTICE 'Dropping out-of-database constraint';
						rtn := _drop_raster_constraint_out_db(schema, $2, $3);
					WHEN kw = 'extent' THEN
						RAISE NOTICE 'Dropping maximum extent constraint';
						rtn := _drop_raster_constraint_extent(schema, $2, $3);
					ELSE
						RAISE NOTICE 'Unknown constraint: %.  Skipping', quote_literal(constraints[x]);
						CONTINUE kwloop;
				END CASE;
			END;
			IF rtn IS FALSE THEN
				cnt := cnt + 1;
				RAISE WARNING 'Unable to drop constraint: %.  Skipping', quote_literal(constraints[x]);
			END IF;
		END LOOP kwloop;
		IF cnt = max THEN
			RAISE EXCEPTION 'None of the constraints specified could be dropped.  Is the schema name, table name or column name incorrect?';
			RETURN FALSE;
		END IF;
		RETURN TRUE;
	END;
	$function$
CREATE OR REPLACE FUNCTION public.droprasterconstraints(rasttable name, rastcolumn name, srid boolean DEFAULT true, scale_x boolean DEFAULT true, scale_y boolean DEFAULT true, blocksize_x boolean DEFAULT true, blocksize_y boolean DEFAULT true, same_alignment boolean DEFAULT true, regular_blocking boolean DEFAULT true, num_bands boolean DEFAULT true, pixel_types boolean DEFAULT true, nodata_values boolean DEFAULT true, out_db boolean DEFAULT true, extent boolean DEFAULT true)
 RETURNS boolean
 LANGUAGE sql
 STRICT
AS $function$ SELECT DropRasterConstraints('', $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14) $function$
CREATE OR REPLACE FUNCTION public.droprasterconstraints(rastschema name, rasttable name, rastcolumn name, srid boolean DEFAULT true, scale_x boolean DEFAULT true, scale_y boolean DEFAULT true, blocksize_x boolean DEFAULT true, blocksize_y boolean DEFAULT true, same_alignment boolean DEFAULT true, regular_blocking boolean DEFAULT true, num_bands boolean DEFAULT true, pixel_types boolean DEFAULT true, nodata_values boolean DEFAULT true, out_db boolean DEFAULT true, extent boolean DEFAULT true)
 RETURNS boolean
 LANGUAGE plpgsql
 STRICT
AS $function$
	DECLARE
		constraints text[];
	BEGIN
		IF srid IS TRUE THEN
			constraints := constraints || 'srid'::text;
		END IF;
		IF scale_x IS TRUE THEN
			constraints := constraints || 'scale_x'::text;
		END IF;
		IF scale_y IS TRUE THEN
			constraints := constraints || 'scale_y'::text;
		END IF;
		IF blocksize_x IS TRUE THEN
			constraints := constraints || 'blocksize_x'::text;
		END IF;
		IF blocksize_y IS TRUE THEN
			constraints := constraints || 'blocksize_y'::text;
		END IF;
		IF same_alignment IS TRUE THEN
			constraints := constraints || 'same_alignment'::text;
		END IF;
		IF regular_blocking IS TRUE THEN
			constraints := constraints || 'regular_blocking'::text;
		END IF;
		IF num_bands IS TRUE THEN
			constraints := constraints || 'num_bands'::text;
		END IF;
		IF pixel_types IS TRUE THEN
			constraints := constraints || 'pixel_types'::text;
		END IF;
		IF nodata_values IS TRUE THEN
			constraints := constraints || 'nodata_values'::text;
		END IF;
		IF out_db IS TRUE THEN
			constraints := constraints || 'out_db'::text;
		END IF;
		IF extent IS TRUE THEN
			constraints := constraints || 'extent'::text;
		END IF;
		RETURN DropRasterConstraints($1, $2, $3, VARIADIC constraints);
	END;
	$function$

CREATE OR REPLACE FUNCTION public.geography(bytea)
 RETURNS geography
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$geography_from_binary$function$
CREATE OR REPLACE FUNCTION public.geography(geometry)
 RETURNS geography
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$geography_from_geometry$function$
CREATE OR REPLACE FUNCTION public.geography(geography, integer, boolean)
 RETURNS geography
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$geography_enforce_typmod$function$

CREATE OR REPLACE FUNCTION public.geography(bytea)
 RETURNS geography
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$geography_from_binary$function$
CREATE OR REPLACE FUNCTION public.geography(geometry)
 RETURNS geography
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$geography_from_geometry$function$
CREATE OR REPLACE FUNCTION public.geography(geography, integer, boolean)
 RETURNS geography
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$geography_enforce_typmod$function$

CREATE OR REPLACE FUNCTION public.geometry(geometry, integer, boolean)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$geometry_enforce_typmod$function$
CREATE OR REPLACE FUNCTION public.geometry(point)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$point_to_geometry$function$
CREATE OR REPLACE FUNCTION public.geometry(path)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$path_to_geometry$function$
CREATE OR REPLACE FUNCTION public.geometry(polygon)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$polygon_to_geometry$function$
CREATE OR REPLACE FUNCTION public.geometry(box2d)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$BOX2D_to_LWGEOM$function$
CREATE OR REPLACE FUNCTION public.geometry(box3d)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$BOX3D_to_LWGEOM$function$
CREATE OR REPLACE FUNCTION public.geometry(text)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$parse_WKT_lwgeom$function$
CREATE OR REPLACE FUNCTION public.geometry(bytea)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_from_bytea$function$
CREATE OR REPLACE FUNCTION public.geometry(geography)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$geometry_from_geography$function$

CREATE OR REPLACE FUNCTION public.geometry(geometry, integer, boolean)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$geometry_enforce_typmod$function$
CREATE OR REPLACE FUNCTION public.geometry(point)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$point_to_geometry$function$
CREATE OR REPLACE FUNCTION public.geometry(path)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$path_to_geometry$function$
CREATE OR REPLACE FUNCTION public.geometry(polygon)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$polygon_to_geometry$function$
CREATE OR REPLACE FUNCTION public.geometry(box2d)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$BOX2D_to_LWGEOM$function$
CREATE OR REPLACE FUNCTION public.geometry(box3d)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$BOX3D_to_LWGEOM$function$
CREATE OR REPLACE FUNCTION public.geometry(text)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$parse_WKT_lwgeom$function$
CREATE OR REPLACE FUNCTION public.geometry(bytea)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_from_bytea$function$
CREATE OR REPLACE FUNCTION public.geometry(geography)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$geometry_from_geography$function$

CREATE OR REPLACE FUNCTION public.geometry(geometry, integer, boolean)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$geometry_enforce_typmod$function$
CREATE OR REPLACE FUNCTION public.geometry(point)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$point_to_geometry$function$
CREATE OR REPLACE FUNCTION public.geometry(path)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$path_to_geometry$function$
CREATE OR REPLACE FUNCTION public.geometry(polygon)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$polygon_to_geometry$function$
CREATE OR REPLACE FUNCTION public.geometry(box2d)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$BOX2D_to_LWGEOM$function$
CREATE OR REPLACE FUNCTION public.geometry(box3d)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$BOX3D_to_LWGEOM$function$
CREATE OR REPLACE FUNCTION public.geometry(text)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$parse_WKT_lwgeom$function$
CREATE OR REPLACE FUNCTION public.geometry(bytea)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_from_bytea$function$
CREATE OR REPLACE FUNCTION public.geometry(geography)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$geometry_from_geography$function$

CREATE OR REPLACE FUNCTION public.geometry(geometry, integer, boolean)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$geometry_enforce_typmod$function$
CREATE OR REPLACE FUNCTION public.geometry(point)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$point_to_geometry$function$
CREATE OR REPLACE FUNCTION public.geometry(path)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$path_to_geometry$function$
CREATE OR REPLACE FUNCTION public.geometry(polygon)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$polygon_to_geometry$function$
CREATE OR REPLACE FUNCTION public.geometry(box2d)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$BOX2D_to_LWGEOM$function$
CREATE OR REPLACE FUNCTION public.geometry(box3d)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$BOX3D_to_LWGEOM$function$
CREATE OR REPLACE FUNCTION public.geometry(text)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$parse_WKT_lwgeom$function$
CREATE OR REPLACE FUNCTION public.geometry(bytea)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_from_bytea$function$
CREATE OR REPLACE FUNCTION public.geometry(geography)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$geometry_from_geography$function$

CREATE OR REPLACE FUNCTION public.geometry(geometry, integer, boolean)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$geometry_enforce_typmod$function$
CREATE OR REPLACE FUNCTION public.geometry(point)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$point_to_geometry$function$
CREATE OR REPLACE FUNCTION public.geometry(path)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$path_to_geometry$function$
CREATE OR REPLACE FUNCTION public.geometry(polygon)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$polygon_to_geometry$function$
CREATE OR REPLACE FUNCTION public.geometry(box2d)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$BOX2D_to_LWGEOM$function$
CREATE OR REPLACE FUNCTION public.geometry(box3d)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$BOX3D_to_LWGEOM$function$
CREATE OR REPLACE FUNCTION public.geometry(text)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$parse_WKT_lwgeom$function$
CREATE OR REPLACE FUNCTION public.geometry(bytea)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_from_bytea$function$
CREATE OR REPLACE FUNCTION public.geometry(geography)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$geometry_from_geography$function$

CREATE OR REPLACE FUNCTION public.geometry(geometry, integer, boolean)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$geometry_enforce_typmod$function$
CREATE OR REPLACE FUNCTION public.geometry(point)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$point_to_geometry$function$
CREATE OR REPLACE FUNCTION public.geometry(path)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$path_to_geometry$function$
CREATE OR REPLACE FUNCTION public.geometry(polygon)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$polygon_to_geometry$function$
CREATE OR REPLACE FUNCTION public.geometry(box2d)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$BOX2D_to_LWGEOM$function$
CREATE OR REPLACE FUNCTION public.geometry(box3d)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$BOX3D_to_LWGEOM$function$
CREATE OR REPLACE FUNCTION public.geometry(text)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$parse_WKT_lwgeom$function$
CREATE OR REPLACE FUNCTION public.geometry(bytea)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_from_bytea$function$
CREATE OR REPLACE FUNCTION public.geometry(geography)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$geometry_from_geography$function$

CREATE OR REPLACE FUNCTION public.geometry(geometry, integer, boolean)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$geometry_enforce_typmod$function$
CREATE OR REPLACE FUNCTION public.geometry(point)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$point_to_geometry$function$
CREATE OR REPLACE FUNCTION public.geometry(path)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$path_to_geometry$function$
CREATE OR REPLACE FUNCTION public.geometry(polygon)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$polygon_to_geometry$function$
CREATE OR REPLACE FUNCTION public.geometry(box2d)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$BOX2D_to_LWGEOM$function$
CREATE OR REPLACE FUNCTION public.geometry(box3d)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$BOX3D_to_LWGEOM$function$
CREATE OR REPLACE FUNCTION public.geometry(text)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$parse_WKT_lwgeom$function$
CREATE OR REPLACE FUNCTION public.geometry(bytea)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_from_bytea$function$
CREATE OR REPLACE FUNCTION public.geometry(geography)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$geometry_from_geography$function$

CREATE OR REPLACE FUNCTION public.geometry(geometry, integer, boolean)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$geometry_enforce_typmod$function$
CREATE OR REPLACE FUNCTION public.geometry(point)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$point_to_geometry$function$
CREATE OR REPLACE FUNCTION public.geometry(path)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$path_to_geometry$function$
CREATE OR REPLACE FUNCTION public.geometry(polygon)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$polygon_to_geometry$function$
CREATE OR REPLACE FUNCTION public.geometry(box2d)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$BOX2D_to_LWGEOM$function$
CREATE OR REPLACE FUNCTION public.geometry(box3d)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$BOX3D_to_LWGEOM$function$
CREATE OR REPLACE FUNCTION public.geometry(text)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$parse_WKT_lwgeom$function$
CREATE OR REPLACE FUNCTION public.geometry(bytea)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_from_bytea$function$
CREATE OR REPLACE FUNCTION public.geometry(geography)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$geometry_from_geography$function$

CREATE OR REPLACE FUNCTION public.geometrytype(geometry)
 RETURNS text
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_getTYPE$function$
CREATE OR REPLACE FUNCTION public.geometrytype(geography)
 RETURNS text
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_getTYPE$function$

CREATE OR REPLACE FUNCTION public.levenshtein(text, text)
 RETURNS integer
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/fuzzystrmatch', $function$levenshtein$function$
CREATE OR REPLACE FUNCTION public.levenshtein(text, text, integer, integer, integer)
 RETURNS integer
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/fuzzystrmatch', $function$levenshtein_with_costs$function$

CREATE OR REPLACE FUNCTION public.levenshtein_less_equal(text, text, integer)
 RETURNS integer
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/fuzzystrmatch', $function$levenshtein_less_equal$function$
CREATE OR REPLACE FUNCTION public.levenshtein_less_equal(text, text, integer, integer, integer, integer)
 RETURNS integer
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/fuzzystrmatch', $function$levenshtein_less_equal_with_costs$function$

CREATE OR REPLACE FUNCTION public.lockrow(text, text, text)
 RETURNS integer
 LANGUAGE sql
 STRICT
AS $function$ SELECT LockRow(current_schema(), $1, $2, $3, now()::timestamp+'1:00'); $function$
CREATE OR REPLACE FUNCTION public.lockrow(text, text, text, text)
 RETURNS integer
 LANGUAGE sql
 STRICT
AS $function$ SELECT LockRow($1, $2, $3, $4, now()::timestamp+'1:00'); $function$
CREATE OR REPLACE FUNCTION public.lockrow(text, text, text, timestamp without time zone)
 RETURNS integer
 LANGUAGE sql
 STRICT
AS $function$ SELECT LockRow(current_schema(), $1, $2, $3, $4); $function$
CREATE OR REPLACE FUNCTION public.lockrow(text, text, text, text, timestamp without time zone)
 RETURNS integer
 LANGUAGE plpgsql
 STRICT
AS $function$ 
DECLARE
	myschema alias for $1;
	mytable alias for $2;
	myrid   alias for $3;
	authid alias for $4;
	expires alias for $5;
	ret int;
	mytoid oid;
	myrec RECORD;
	
BEGIN
	IF NOT LongTransactionsEnabled() THEN
		RAISE EXCEPTION 'Long transaction support disabled, use EnableLongTransaction() to enable.';
	END IF;
	EXECUTE 'DELETE FROM authorization_table WHERE expires < now()'; 
	SELECT c.oid INTO mytoid FROM pg_class c, pg_namespace n
		WHERE c.relname = mytable
		AND c.relnamespace = n.oid
		AND n.nspname = myschema;
	-- RAISE NOTICE 'toid: %', mytoid;
	FOR myrec IN SELECT * FROM authorization_table WHERE 
		toid = mytoid AND rid = myrid
	LOOP
		IF myrec.authid != authid THEN
			RETURN 0;
		ELSE
			RETURN 1;
		END IF;
	END LOOP;
	EXECUTE 'INSERT INTO authorization_table VALUES ('||
		quote_literal(mytoid::text)||','||quote_literal(myrid)||
		','||quote_literal(expires::text)||
		','||quote_literal(authid) ||')';
	GET DIAGNOSTICS ret = ROW_COUNT;
	RETURN ret;
END;
$function$

CREATE OR REPLACE FUNCTION public.lockrow(text, text, text)
 RETURNS integer
 LANGUAGE sql
 STRICT
AS $function$ SELECT LockRow(current_schema(), $1, $2, $3, now()::timestamp+'1:00'); $function$
CREATE OR REPLACE FUNCTION public.lockrow(text, text, text, text)
 RETURNS integer
 LANGUAGE sql
 STRICT
AS $function$ SELECT LockRow($1, $2, $3, $4, now()::timestamp+'1:00'); $function$
CREATE OR REPLACE FUNCTION public.lockrow(text, text, text, timestamp without time zone)
 RETURNS integer
 LANGUAGE sql
 STRICT
AS $function$ SELECT LockRow(current_schema(), $1, $2, $3, $4); $function$
CREATE OR REPLACE FUNCTION public.lockrow(text, text, text, text, timestamp without time zone)
 RETURNS integer
 LANGUAGE plpgsql
 STRICT
AS $function$ 
DECLARE
	myschema alias for $1;
	mytable alias for $2;
	myrid   alias for $3;
	authid alias for $4;
	expires alias for $5;
	ret int;
	mytoid oid;
	myrec RECORD;
	
BEGIN
	IF NOT LongTransactionsEnabled() THEN
		RAISE EXCEPTION 'Long transaction support disabled, use EnableLongTransaction() to enable.';
	END IF;
	EXECUTE 'DELETE FROM authorization_table WHERE expires < now()'; 
	SELECT c.oid INTO mytoid FROM pg_class c, pg_namespace n
		WHERE c.relname = mytable
		AND c.relnamespace = n.oid
		AND n.nspname = myschema;
	-- RAISE NOTICE 'toid: %', mytoid;
	FOR myrec IN SELECT * FROM authorization_table WHERE 
		toid = mytoid AND rid = myrid
	LOOP
		IF myrec.authid != authid THEN
			RETURN 0;
		ELSE
			RETURN 1;
		END IF;
	END LOOP;
	EXECUTE 'INSERT INTO authorization_table VALUES ('||
		quote_literal(mytoid::text)||','||quote_literal(myrid)||
		','||quote_literal(expires::text)||
		','||quote_literal(authid) ||')';
	GET DIAGNOSTICS ret = ROW_COUNT;
	RETURN ret;
END;
$function$

CREATE OR REPLACE FUNCTION public.lockrow(text, text, text)
 RETURNS integer
 LANGUAGE sql
 STRICT
AS $function$ SELECT LockRow(current_schema(), $1, $2, $3, now()::timestamp+'1:00'); $function$
CREATE OR REPLACE FUNCTION public.lockrow(text, text, text, text)
 RETURNS integer
 LANGUAGE sql
 STRICT
AS $function$ SELECT LockRow($1, $2, $3, $4, now()::timestamp+'1:00'); $function$
CREATE OR REPLACE FUNCTION public.lockrow(text, text, text, timestamp without time zone)
 RETURNS integer
 LANGUAGE sql
 STRICT
AS $function$ SELECT LockRow(current_schema(), $1, $2, $3, $4); $function$
CREATE OR REPLACE FUNCTION public.lockrow(text, text, text, text, timestamp without time zone)
 RETURNS integer
 LANGUAGE plpgsql
 STRICT
AS $function$ 
DECLARE
	myschema alias for $1;
	mytable alias for $2;
	myrid   alias for $3;
	authid alias for $4;
	expires alias for $5;
	ret int;
	mytoid oid;
	myrec RECORD;
	
BEGIN
	IF NOT LongTransactionsEnabled() THEN
		RAISE EXCEPTION 'Long transaction support disabled, use EnableLongTransaction() to enable.';
	END IF;
	EXECUTE 'DELETE FROM authorization_table WHERE expires < now()'; 
	SELECT c.oid INTO mytoid FROM pg_class c, pg_namespace n
		WHERE c.relname = mytable
		AND c.relnamespace = n.oid
		AND n.nspname = myschema;
	-- RAISE NOTICE 'toid: %', mytoid;
	FOR myrec IN SELECT * FROM authorization_table WHERE 
		toid = mytoid AND rid = myrid
	LOOP
		IF myrec.authid != authid THEN
			RETURN 0;
		ELSE
			RETURN 1;
		END IF;
	END LOOP;
	EXECUTE 'INSERT INTO authorization_table VALUES ('||
		quote_literal(mytoid::text)||','||quote_literal(myrid)||
		','||quote_literal(expires::text)||
		','||quote_literal(authid) ||')';
	GET DIAGNOSTICS ret = ROW_COUNT;
	RETURN ret;
END;
$function$

CREATE OR REPLACE FUNCTION public.pgis_geometry_accum_transfn(pgis_abs, geometry)
 RETURNS pgis_abs
 LANGUAGE c
AS '$libdir/postgis-2.2', $function$pgis_geometry_accum_transfn$function$
CREATE OR REPLACE FUNCTION public.pgis_geometry_accum_transfn(pgis_abs, geometry, double precision)
 RETURNS pgis_abs
 LANGUAGE c
AS '$libdir/postgis-2.2', $function$pgis_geometry_accum_transfn$function$

CREATE OR REPLACE FUNCTION public.populate_geometry_columns(use_typmod boolean DEFAULT true)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE
	inserted    integer;
	oldcount    integer;
	probed      integer;
	stale       integer;
	gcs         RECORD;
	gc          RECORD;
	gsrid       integer;
	gndims      integer;
	gtype       text;
	query       text;
	gc_is_valid boolean;
BEGIN
	SELECT count(*) INTO oldcount FROM geometry_columns;
	inserted := 0;
	-- Count the number of geometry columns in all tables and views
	SELECT count(DISTINCT c.oid) INTO probed
	FROM pg_class c,
		 pg_attribute a,
		 pg_type t,
		 pg_namespace n
	WHERE c.relkind IN('r','v')
		AND t.typname = 'geometry'
		AND a.attisdropped = false
		AND a.atttypid = t.oid
		AND a.attrelid = c.oid
		AND c.relnamespace = n.oid
		AND n.nspname NOT ILIKE 'pg_temp%' AND c.relname != 'raster_columns' ;
	-- Iterate through all non-dropped geometry columns
	RAISE DEBUG 'Processing Tables.....';
	FOR gcs IN
	SELECT DISTINCT ON (c.oid) c.oid, n.nspname, c.relname
		FROM pg_class c,
			 pg_attribute a,
			 pg_type t,
			 pg_namespace n
		WHERE c.relkind IN( 'r')
		AND t.typname = 'geometry'
		AND a.attisdropped = false
		AND a.atttypid = t.oid
		AND a.attrelid = c.oid
		AND c.relnamespace = n.oid
		AND n.nspname NOT ILIKE 'pg_temp%' AND c.relname != 'raster_columns' 
	LOOP
		inserted := inserted + populate_geometry_columns(gcs.oid, use_typmod);
	END LOOP;
	IF oldcount > inserted THEN
	    stale = oldcount-inserted;
	ELSE
	    stale = 0;
	END IF;
	RETURN 'probed:' ||probed|| ' inserted:'||inserted;
END
$function$
CREATE OR REPLACE FUNCTION public.populate_geometry_columns(tbl_oid oid, use_typmod boolean DEFAULT true)
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
DECLARE
	gcs         RECORD;
	gc          RECORD;
	gc_old      RECORD;
	gsrid       integer;
	gndims      integer;
	gtype       text;
	query       text;
	gc_is_valid boolean;
	inserted    integer;
	constraint_successful boolean := false;
BEGIN
	inserted := 0;
	-- Iterate through all geometry columns in this table
	FOR gcs IN
	SELECT n.nspname, c.relname, a.attname
		FROM pg_class c,
			 pg_attribute a,
			 pg_type t,
			 pg_namespace n
		WHERE c.relkind IN('r')
		AND t.typname = 'geometry'
		AND a.attisdropped = false
		AND a.atttypid = t.oid
		AND a.attrelid = c.oid
		AND c.relnamespace = n.oid
		AND n.nspname NOT ILIKE 'pg_temp%'
		AND c.oid = tbl_oid
	LOOP
        RAISE DEBUG 'Processing column %.%.%', gcs.nspname, gcs.relname, gcs.attname;
    
        gc_is_valid := true;
        -- Find the srid, coord_dimension, and type of current geometry
        -- in geometry_columns -- which is now a view
        
        SELECT type, srid, coord_dimension INTO gc_old 
            FROM geometry_columns 
            WHERE f_table_schema = gcs.nspname AND f_table_name = gcs.relname AND f_geometry_column = gcs.attname; 
            
        IF upper(gc_old.type) = 'GEOMETRY' THEN
        -- This is an unconstrained geometry we need to do something
        -- We need to figure out what to set the type by inspecting the data
            EXECUTE 'SELECT st_srid(' || quote_ident(gcs.attname) || ') As srid, GeometryType(' || quote_ident(gcs.attname) || ') As type, ST_NDims(' || quote_ident(gcs.attname) || ') As dims ' ||
                     ' FROM ONLY ' || quote_ident(gcs.nspname) || '.' || quote_ident(gcs.relname) || 
                     ' WHERE ' || quote_ident(gcs.attname) || ' IS NOT NULL LIMIT 1;'
                INTO gc;
            IF gc IS NULL THEN -- there is no data so we can not determine geometry type
            	RAISE WARNING 'No data in table %.%, so no information to determine geometry type and srid', gcs.nspname, gcs.relname;
            	RETURN 0;
            END IF;
            gsrid := gc.srid; gtype := gc.type; gndims := gc.dims;
            	
            IF use_typmod THEN
                BEGIN
                    EXECUTE 'ALTER TABLE ' || quote_ident(gcs.nspname) || '.' || quote_ident(gcs.relname) || ' ALTER COLUMN ' || quote_ident(gcs.attname) || 
                        ' TYPE geometry(' || postgis_type_name(gtype, gndims, true) || ', ' || gsrid::text  || ') ';
                    inserted := inserted + 1;
                EXCEPTION
                        WHEN invalid_parameter_value OR feature_not_supported THEN
                        RAISE WARNING 'Could not convert ''%'' in ''%.%'' to use typmod with srid %, type %: %', quote_ident(gcs.attname), quote_ident(gcs.nspname), quote_ident(gcs.relname), gsrid, postgis_type_name(gtype, gndims, true), SQLERRM;
                            gc_is_valid := false;
                END;
                
            ELSE
                -- Try to apply srid check to column
            	constraint_successful = false;
                IF (gsrid > 0 AND postgis_constraint_srid(gcs.nspname, gcs.relname,gcs.attname) IS NULL ) THEN
                    BEGIN
                        EXECUTE 'ALTER TABLE ONLY ' || quote_ident(gcs.nspname) || '.' || quote_ident(gcs.relname) || 
                                 ' ADD CONSTRAINT ' || quote_ident('enforce_srid_' || gcs.attname) || 
                                 ' CHECK (st_srid(' || quote_ident(gcs.attname) || ') = ' || gsrid || ')';
                        constraint_successful := true;
                    EXCEPTION
                        WHEN check_violation THEN
                            RAISE WARNING 'Not inserting ''%'' in ''%.%'' into geometry_columns: could not apply constraint CHECK (st_srid(%) = %)', quote_ident(gcs.attname), quote_ident(gcs.nspname), quote_ident(gcs.relname), quote_ident(gcs.attname), gsrid;
                            gc_is_valid := false;
                    END;
                END IF;
                
                -- Try to apply ndims check to column
                IF (gndims IS NOT NULL AND postgis_constraint_dims(gcs.nspname, gcs.relname,gcs.attname) IS NULL ) THEN
                    BEGIN
                        EXECUTE 'ALTER TABLE ONLY ' || quote_ident(gcs.nspname) || '.' || quote_ident(gcs.relname) || '
                                 ADD CONSTRAINT ' || quote_ident('enforce_dims_' || gcs.attname) || '
                                 CHECK (st_ndims(' || quote_ident(gcs.attname) || ') = '||gndims||')';
                        constraint_successful := true;
                    EXCEPTION
                        WHEN check_violation THEN
                            RAISE WARNING 'Not inserting ''%'' in ''%.%'' into geometry_columns: could not apply constraint CHECK (st_ndims(%) = %)', quote_ident(gcs.attname), quote_ident(gcs.nspname), quote_ident(gcs.relname), quote_ident(gcs.attname), gndims;
                            gc_is_valid := false;
                    END;
                END IF;
    
                -- Try to apply geometrytype check to column
                IF (gtype IS NOT NULL AND postgis_constraint_type(gcs.nspname, gcs.relname,gcs.attname) IS NULL ) THEN
                    BEGIN
                        EXECUTE 'ALTER TABLE ONLY ' || quote_ident(gcs.nspname) || '.' || quote_ident(gcs.relname) || '
                        ADD CONSTRAINT ' || quote_ident('enforce_geotype_' || gcs.attname) || '
                        CHECK (geometrytype(' || quote_ident(gcs.attname) || ') = ' || quote_literal(gtype) || ')';
                        constraint_successful := true;
                    EXCEPTION
                        WHEN check_violation THEN
                            -- No geometry check can be applied. This column contains a number of geometry types.
                            RAISE WARNING 'Could not add geometry type check (%) to table column: %.%.%', gtype, quote_ident(gcs.nspname),quote_ident(gcs.relname),quote_ident(gcs.attname);
                    END;
                END IF;
                 --only count if we were successful in applying at least one constraint
                IF constraint_successful THEN
                	inserted := inserted + 1;
                END IF;
            END IF;	        
	    END IF;
	END LOOP;
	RETURN inserted;
END
$function$

CREATE OR REPLACE FUNCTION public.postgis_noop(geometry)
 RETURNS geometry
 LANGUAGE c
 STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_noop$function$
CREATE OR REPLACE FUNCTION public.postgis_noop(raster)
 RETURNS geometry
 LANGUAGE c
 STRICT
AS '$libdir/rtpostgis-2.2', $function$RASTER_noop$function$

CREATE OR REPLACE FUNCTION public.st_addband(rast raster, addbandargset addbandarg[])
 RETURNS raster
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/rtpostgis-2.2', $function$RASTER_addBand$function$
CREATE OR REPLACE FUNCTION public.st_addband(rast raster, index integer, pixeltype text, initialvalue double precision DEFAULT 0::numeric, nodataval double precision DEFAULT NULL::double precision)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT st_addband($1, ARRAY[ROW($2, $3, $4, $5)]::addbandarg[]) $function$
CREATE OR REPLACE FUNCTION public.st_addband(rast raster, pixeltype text, initialvalue double precision DEFAULT 0::numeric, nodataval double precision DEFAULT NULL::double precision)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT st_addband($1, ARRAY[ROW(NULL, $2, $3, $4)]::addbandarg[]) $function$
CREATE OR REPLACE FUNCTION public.st_addband(torast raster, fromrast raster, fromband integer DEFAULT 1, torastindex integer DEFAULT NULL::integer)
 RETURNS raster
 LANGUAGE c
 IMMUTABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_copyBand$function$
CREATE OR REPLACE FUNCTION public.st_addband(torast raster, fromrasts raster[], fromband integer DEFAULT 1, torastindex integer DEFAULT NULL::integer)
 RETURNS raster
 LANGUAGE c
 IMMUTABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_addBandRasterArray$function$
CREATE OR REPLACE FUNCTION public.st_addband(rast raster, index integer, outdbfile text, outdbindex integer[], nodataval double precision DEFAULT NULL::double precision)
 RETURNS raster
 LANGUAGE c
 IMMUTABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_addBandOutDB$function$
CREATE OR REPLACE FUNCTION public.st_addband(rast raster, outdbfile text, outdbindex integer[], index integer DEFAULT NULL::integer, nodataval double precision DEFAULT NULL::double precision)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT ST_AddBand($1, $4, $2, $3, $5) $function$

CREATE OR REPLACE FUNCTION public.st_addband(rast raster, addbandargset addbandarg[])
 RETURNS raster
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/rtpostgis-2.2', $function$RASTER_addBand$function$
CREATE OR REPLACE FUNCTION public.st_addband(rast raster, index integer, pixeltype text, initialvalue double precision DEFAULT 0::numeric, nodataval double precision DEFAULT NULL::double precision)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT st_addband($1, ARRAY[ROW($2, $3, $4, $5)]::addbandarg[]) $function$
CREATE OR REPLACE FUNCTION public.st_addband(rast raster, pixeltype text, initialvalue double precision DEFAULT 0::numeric, nodataval double precision DEFAULT NULL::double precision)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT st_addband($1, ARRAY[ROW(NULL, $2, $3, $4)]::addbandarg[]) $function$
CREATE OR REPLACE FUNCTION public.st_addband(torast raster, fromrast raster, fromband integer DEFAULT 1, torastindex integer DEFAULT NULL::integer)
 RETURNS raster
 LANGUAGE c
 IMMUTABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_copyBand$function$
CREATE OR REPLACE FUNCTION public.st_addband(torast raster, fromrasts raster[], fromband integer DEFAULT 1, torastindex integer DEFAULT NULL::integer)
 RETURNS raster
 LANGUAGE c
 IMMUTABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_addBandRasterArray$function$
CREATE OR REPLACE FUNCTION public.st_addband(rast raster, index integer, outdbfile text, outdbindex integer[], nodataval double precision DEFAULT NULL::double precision)
 RETURNS raster
 LANGUAGE c
 IMMUTABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_addBandOutDB$function$
CREATE OR REPLACE FUNCTION public.st_addband(rast raster, outdbfile text, outdbindex integer[], index integer DEFAULT NULL::integer, nodataval double precision DEFAULT NULL::double precision)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT ST_AddBand($1, $4, $2, $3, $5) $function$

CREATE OR REPLACE FUNCTION public.st_addband(rast raster, addbandargset addbandarg[])
 RETURNS raster
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/rtpostgis-2.2', $function$RASTER_addBand$function$
CREATE OR REPLACE FUNCTION public.st_addband(rast raster, index integer, pixeltype text, initialvalue double precision DEFAULT 0::numeric, nodataval double precision DEFAULT NULL::double precision)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT st_addband($1, ARRAY[ROW($2, $3, $4, $5)]::addbandarg[]) $function$
CREATE OR REPLACE FUNCTION public.st_addband(rast raster, pixeltype text, initialvalue double precision DEFAULT 0::numeric, nodataval double precision DEFAULT NULL::double precision)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT st_addband($1, ARRAY[ROW(NULL, $2, $3, $4)]::addbandarg[]) $function$
CREATE OR REPLACE FUNCTION public.st_addband(torast raster, fromrast raster, fromband integer DEFAULT 1, torastindex integer DEFAULT NULL::integer)
 RETURNS raster
 LANGUAGE c
 IMMUTABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_copyBand$function$
CREATE OR REPLACE FUNCTION public.st_addband(torast raster, fromrasts raster[], fromband integer DEFAULT 1, torastindex integer DEFAULT NULL::integer)
 RETURNS raster
 LANGUAGE c
 IMMUTABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_addBandRasterArray$function$
CREATE OR REPLACE FUNCTION public.st_addband(rast raster, index integer, outdbfile text, outdbindex integer[], nodataval double precision DEFAULT NULL::double precision)
 RETURNS raster
 LANGUAGE c
 IMMUTABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_addBandOutDB$function$
CREATE OR REPLACE FUNCTION public.st_addband(rast raster, outdbfile text, outdbindex integer[], index integer DEFAULT NULL::integer, nodataval double precision DEFAULT NULL::double precision)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT ST_AddBand($1, $4, $2, $3, $5) $function$

CREATE OR REPLACE FUNCTION public.st_addband(rast raster, addbandargset addbandarg[])
 RETURNS raster
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/rtpostgis-2.2', $function$RASTER_addBand$function$
CREATE OR REPLACE FUNCTION public.st_addband(rast raster, index integer, pixeltype text, initialvalue double precision DEFAULT 0::numeric, nodataval double precision DEFAULT NULL::double precision)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT st_addband($1, ARRAY[ROW($2, $3, $4, $5)]::addbandarg[]) $function$
CREATE OR REPLACE FUNCTION public.st_addband(rast raster, pixeltype text, initialvalue double precision DEFAULT 0::numeric, nodataval double precision DEFAULT NULL::double precision)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT st_addband($1, ARRAY[ROW(NULL, $2, $3, $4)]::addbandarg[]) $function$
CREATE OR REPLACE FUNCTION public.st_addband(torast raster, fromrast raster, fromband integer DEFAULT 1, torastindex integer DEFAULT NULL::integer)
 RETURNS raster
 LANGUAGE c
 IMMUTABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_copyBand$function$
CREATE OR REPLACE FUNCTION public.st_addband(torast raster, fromrasts raster[], fromband integer DEFAULT 1, torastindex integer DEFAULT NULL::integer)
 RETURNS raster
 LANGUAGE c
 IMMUTABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_addBandRasterArray$function$
CREATE OR REPLACE FUNCTION public.st_addband(rast raster, index integer, outdbfile text, outdbindex integer[], nodataval double precision DEFAULT NULL::double precision)
 RETURNS raster
 LANGUAGE c
 IMMUTABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_addBandOutDB$function$
CREATE OR REPLACE FUNCTION public.st_addband(rast raster, outdbfile text, outdbindex integer[], index integer DEFAULT NULL::integer, nodataval double precision DEFAULT NULL::double precision)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT ST_AddBand($1, $4, $2, $3, $5) $function$

CREATE OR REPLACE FUNCTION public.st_addband(rast raster, addbandargset addbandarg[])
 RETURNS raster
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/rtpostgis-2.2', $function$RASTER_addBand$function$
CREATE OR REPLACE FUNCTION public.st_addband(rast raster, index integer, pixeltype text, initialvalue double precision DEFAULT 0::numeric, nodataval double precision DEFAULT NULL::double precision)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT st_addband($1, ARRAY[ROW($2, $3, $4, $5)]::addbandarg[]) $function$
CREATE OR REPLACE FUNCTION public.st_addband(rast raster, pixeltype text, initialvalue double precision DEFAULT 0::numeric, nodataval double precision DEFAULT NULL::double precision)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT st_addband($1, ARRAY[ROW(NULL, $2, $3, $4)]::addbandarg[]) $function$
CREATE OR REPLACE FUNCTION public.st_addband(torast raster, fromrast raster, fromband integer DEFAULT 1, torastindex integer DEFAULT NULL::integer)
 RETURNS raster
 LANGUAGE c
 IMMUTABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_copyBand$function$
CREATE OR REPLACE FUNCTION public.st_addband(torast raster, fromrasts raster[], fromband integer DEFAULT 1, torastindex integer DEFAULT NULL::integer)
 RETURNS raster
 LANGUAGE c
 IMMUTABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_addBandRasterArray$function$
CREATE OR REPLACE FUNCTION public.st_addband(rast raster, index integer, outdbfile text, outdbindex integer[], nodataval double precision DEFAULT NULL::double precision)
 RETURNS raster
 LANGUAGE c
 IMMUTABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_addBandOutDB$function$
CREATE OR REPLACE FUNCTION public.st_addband(rast raster, outdbfile text, outdbindex integer[], index integer DEFAULT NULL::integer, nodataval double precision DEFAULT NULL::double precision)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT ST_AddBand($1, $4, $2, $3, $5) $function$

CREATE OR REPLACE FUNCTION public.st_addband(rast raster, addbandargset addbandarg[])
 RETURNS raster
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/rtpostgis-2.2', $function$RASTER_addBand$function$
CREATE OR REPLACE FUNCTION public.st_addband(rast raster, index integer, pixeltype text, initialvalue double precision DEFAULT 0::numeric, nodataval double precision DEFAULT NULL::double precision)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT st_addband($1, ARRAY[ROW($2, $3, $4, $5)]::addbandarg[]) $function$
CREATE OR REPLACE FUNCTION public.st_addband(rast raster, pixeltype text, initialvalue double precision DEFAULT 0::numeric, nodataval double precision DEFAULT NULL::double precision)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT st_addband($1, ARRAY[ROW(NULL, $2, $3, $4)]::addbandarg[]) $function$
CREATE OR REPLACE FUNCTION public.st_addband(torast raster, fromrast raster, fromband integer DEFAULT 1, torastindex integer DEFAULT NULL::integer)
 RETURNS raster
 LANGUAGE c
 IMMUTABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_copyBand$function$
CREATE OR REPLACE FUNCTION public.st_addband(torast raster, fromrasts raster[], fromband integer DEFAULT 1, torastindex integer DEFAULT NULL::integer)
 RETURNS raster
 LANGUAGE c
 IMMUTABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_addBandRasterArray$function$
CREATE OR REPLACE FUNCTION public.st_addband(rast raster, index integer, outdbfile text, outdbindex integer[], nodataval double precision DEFAULT NULL::double precision)
 RETURNS raster
 LANGUAGE c
 IMMUTABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_addBandOutDB$function$
CREATE OR REPLACE FUNCTION public.st_addband(rast raster, outdbfile text, outdbindex integer[], index integer DEFAULT NULL::integer, nodataval double precision DEFAULT NULL::double precision)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT ST_AddBand($1, $4, $2, $3, $5) $function$

CREATE OR REPLACE FUNCTION public.st_addpoint(geom1 geometry, geom2 geometry)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_addpoint$function$
CREATE OR REPLACE FUNCTION public.st_addpoint(geom1 geometry, geom2 geometry, integer)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_addpoint$function$

CREATE OR REPLACE FUNCTION public.st_affine(geometry, double precision, double precision, double precision, double precision, double precision, double precision)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT ST_Affine($1,  $2, $3, 0,  $4, $5, 0,  0, 0, 1,  $6, $7, 0)$function$
CREATE OR REPLACE FUNCTION public.st_affine(geometry, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_affine$function$

CREATE OR REPLACE FUNCTION public.st_approxcount(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1)
 RETURNS bigint
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_count($1, $2, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_approxcount(rast raster, nband integer, sample_percent double precision)
 RETURNS bigint
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_count($1, $2, TRUE, $3) $function$
CREATE OR REPLACE FUNCTION public.st_approxcount(rast raster, exclude_nodata_value boolean, sample_percent double precision DEFAULT 0.1)
 RETURNS bigint
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_count($1, 1, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_approxcount(rast raster, sample_percent double precision)
 RETURNS bigint
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_count($1, 1, TRUE, $2) $function$
CREATE OR REPLACE FUNCTION public.st_approxcount(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1)
 RETURNS bigint
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_count($1, $2, $3, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_approxcount(rastertable text, rastercolumn text, nband integer, sample_percent double precision)
 RETURNS bigint
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_count($1, $2, $3, TRUE, $4) $function$
CREATE OR REPLACE FUNCTION public.st_approxcount(rastertable text, rastercolumn text, exclude_nodata_value boolean, sample_percent double precision DEFAULT 0.1)
 RETURNS bigint
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_count($1, $2, 1, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_approxcount(rastertable text, rastercolumn text, sample_percent double precision)
 RETURNS bigint
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_count($1, $2, 1, TRUE, $3) $function$

CREATE OR REPLACE FUNCTION public.st_approxcount(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1)
 RETURNS bigint
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_count($1, $2, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_approxcount(rast raster, nband integer, sample_percent double precision)
 RETURNS bigint
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_count($1, $2, TRUE, $3) $function$
CREATE OR REPLACE FUNCTION public.st_approxcount(rast raster, exclude_nodata_value boolean, sample_percent double precision DEFAULT 0.1)
 RETURNS bigint
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_count($1, 1, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_approxcount(rast raster, sample_percent double precision)
 RETURNS bigint
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_count($1, 1, TRUE, $2) $function$
CREATE OR REPLACE FUNCTION public.st_approxcount(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1)
 RETURNS bigint
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_count($1, $2, $3, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_approxcount(rastertable text, rastercolumn text, nband integer, sample_percent double precision)
 RETURNS bigint
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_count($1, $2, $3, TRUE, $4) $function$
CREATE OR REPLACE FUNCTION public.st_approxcount(rastertable text, rastercolumn text, exclude_nodata_value boolean, sample_percent double precision DEFAULT 0.1)
 RETURNS bigint
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_count($1, $2, 1, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_approxcount(rastertable text, rastercolumn text, sample_percent double precision)
 RETURNS bigint
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_count($1, $2, 1, TRUE, $3) $function$

CREATE OR REPLACE FUNCTION public.st_approxcount(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1)
 RETURNS bigint
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_count($1, $2, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_approxcount(rast raster, nband integer, sample_percent double precision)
 RETURNS bigint
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_count($1, $2, TRUE, $3) $function$
CREATE OR REPLACE FUNCTION public.st_approxcount(rast raster, exclude_nodata_value boolean, sample_percent double precision DEFAULT 0.1)
 RETURNS bigint
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_count($1, 1, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_approxcount(rast raster, sample_percent double precision)
 RETURNS bigint
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_count($1, 1, TRUE, $2) $function$
CREATE OR REPLACE FUNCTION public.st_approxcount(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1)
 RETURNS bigint
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_count($1, $2, $3, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_approxcount(rastertable text, rastercolumn text, nband integer, sample_percent double precision)
 RETURNS bigint
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_count($1, $2, $3, TRUE, $4) $function$
CREATE OR REPLACE FUNCTION public.st_approxcount(rastertable text, rastercolumn text, exclude_nodata_value boolean, sample_percent double precision DEFAULT 0.1)
 RETURNS bigint
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_count($1, $2, 1, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_approxcount(rastertable text, rastercolumn text, sample_percent double precision)
 RETURNS bigint
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_count($1, $2, 1, TRUE, $3) $function$

CREATE OR REPLACE FUNCTION public.st_approxcount(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1)
 RETURNS bigint
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_count($1, $2, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_approxcount(rast raster, nband integer, sample_percent double precision)
 RETURNS bigint
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_count($1, $2, TRUE, $3) $function$
CREATE OR REPLACE FUNCTION public.st_approxcount(rast raster, exclude_nodata_value boolean, sample_percent double precision DEFAULT 0.1)
 RETURNS bigint
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_count($1, 1, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_approxcount(rast raster, sample_percent double precision)
 RETURNS bigint
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_count($1, 1, TRUE, $2) $function$
CREATE OR REPLACE FUNCTION public.st_approxcount(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1)
 RETURNS bigint
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_count($1, $2, $3, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_approxcount(rastertable text, rastercolumn text, nband integer, sample_percent double precision)
 RETURNS bigint
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_count($1, $2, $3, TRUE, $4) $function$
CREATE OR REPLACE FUNCTION public.st_approxcount(rastertable text, rastercolumn text, exclude_nodata_value boolean, sample_percent double precision DEFAULT 0.1)
 RETURNS bigint
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_count($1, $2, 1, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_approxcount(rastertable text, rastercolumn text, sample_percent double precision)
 RETURNS bigint
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_count($1, $2, 1, TRUE, $3) $function$

CREATE OR REPLACE FUNCTION public.st_approxcount(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1)
 RETURNS bigint
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_count($1, $2, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_approxcount(rast raster, nband integer, sample_percent double precision)
 RETURNS bigint
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_count($1, $2, TRUE, $3) $function$
CREATE OR REPLACE FUNCTION public.st_approxcount(rast raster, exclude_nodata_value boolean, sample_percent double precision DEFAULT 0.1)
 RETURNS bigint
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_count($1, 1, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_approxcount(rast raster, sample_percent double precision)
 RETURNS bigint
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_count($1, 1, TRUE, $2) $function$
CREATE OR REPLACE FUNCTION public.st_approxcount(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1)
 RETURNS bigint
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_count($1, $2, $3, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_approxcount(rastertable text, rastercolumn text, nband integer, sample_percent double precision)
 RETURNS bigint
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_count($1, $2, $3, TRUE, $4) $function$
CREATE OR REPLACE FUNCTION public.st_approxcount(rastertable text, rastercolumn text, exclude_nodata_value boolean, sample_percent double precision DEFAULT 0.1)
 RETURNS bigint
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_count($1, $2, 1, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_approxcount(rastertable text, rastercolumn text, sample_percent double precision)
 RETURNS bigint
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_count($1, $2, 1, TRUE, $3) $function$

CREATE OR REPLACE FUNCTION public.st_approxcount(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1)
 RETURNS bigint
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_count($1, $2, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_approxcount(rast raster, nband integer, sample_percent double precision)
 RETURNS bigint
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_count($1, $2, TRUE, $3) $function$
CREATE OR REPLACE FUNCTION public.st_approxcount(rast raster, exclude_nodata_value boolean, sample_percent double precision DEFAULT 0.1)
 RETURNS bigint
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_count($1, 1, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_approxcount(rast raster, sample_percent double precision)
 RETURNS bigint
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_count($1, 1, TRUE, $2) $function$
CREATE OR REPLACE FUNCTION public.st_approxcount(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1)
 RETURNS bigint
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_count($1, $2, $3, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_approxcount(rastertable text, rastercolumn text, nband integer, sample_percent double precision)
 RETURNS bigint
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_count($1, $2, $3, TRUE, $4) $function$
CREATE OR REPLACE FUNCTION public.st_approxcount(rastertable text, rastercolumn text, exclude_nodata_value boolean, sample_percent double precision DEFAULT 0.1)
 RETURNS bigint
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_count($1, $2, 1, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_approxcount(rastertable text, rastercolumn text, sample_percent double precision)
 RETURNS bigint
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_count($1, $2, 1, TRUE, $3) $function$

CREATE OR REPLACE FUNCTION public.st_approxcount(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1)
 RETURNS bigint
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_count($1, $2, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_approxcount(rast raster, nband integer, sample_percent double precision)
 RETURNS bigint
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_count($1, $2, TRUE, $3) $function$
CREATE OR REPLACE FUNCTION public.st_approxcount(rast raster, exclude_nodata_value boolean, sample_percent double precision DEFAULT 0.1)
 RETURNS bigint
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_count($1, 1, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_approxcount(rast raster, sample_percent double precision)
 RETURNS bigint
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_count($1, 1, TRUE, $2) $function$
CREATE OR REPLACE FUNCTION public.st_approxcount(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1)
 RETURNS bigint
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_count($1, $2, $3, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_approxcount(rastertable text, rastercolumn text, nband integer, sample_percent double precision)
 RETURNS bigint
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_count($1, $2, $3, TRUE, $4) $function$
CREATE OR REPLACE FUNCTION public.st_approxcount(rastertable text, rastercolumn text, exclude_nodata_value boolean, sample_percent double precision DEFAULT 0.1)
 RETURNS bigint
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_count($1, $2, 1, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_approxcount(rastertable text, rastercolumn text, sample_percent double precision)
 RETURNS bigint
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_count($1, $2, 1, TRUE, $3) $function$

CREATE OR REPLACE FUNCTION public.st_approxhistogram(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1, bins integer DEFAULT 0, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, $3, $4, $5, $6, $7) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rast raster, nband integer, exclude_nodata_value boolean, sample_percent double precision, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, $3, $4, $5, NULL, $6) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rast raster, nband integer, sample_percent double precision, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, TRUE, $3, 0, NULL, FALSE) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rast raster, sample_percent double precision, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, 1, TRUE, $2, 0, NULL, FALSE) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rast raster, nband integer, sample_percent double precision, bins integer, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, TRUE, $3, $4, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rast raster, nband integer, sample_percent double precision, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, TRUE, $3, $4, NULL, $5) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1, bins integer DEFAULT 0, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_histogram($1, $2, $3, $4, $5, $6, $7, $8) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, sample_percent double precision, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_histogram($1, $2, $3, $4, $5, $6, NULL, $7) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rastertable text, rastercolumn text, nband integer, sample_percent double precision, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_histogram($1, $2, $3, TRUE, $4, 0, NULL, FALSE) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rastertable text, rastercolumn text, sample_percent double precision, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_histogram($1, $2, 1, TRUE, $3, 0, NULL, FALSE) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rastertable text, rastercolumn text, nband integer, sample_percent double precision, bins integer, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_histogram($1, $2, $3, TRUE, $4, $5, $6, $7) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rastertable text, rastercolumn text, nband integer, sample_percent double precision, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_histogram($1, $2, $3, TRUE, $4, $5, NULL, $6) $function$

CREATE OR REPLACE FUNCTION public.st_approxhistogram(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1, bins integer DEFAULT 0, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, $3, $4, $5, $6, $7) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rast raster, nband integer, exclude_nodata_value boolean, sample_percent double precision, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, $3, $4, $5, NULL, $6) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rast raster, nband integer, sample_percent double precision, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, TRUE, $3, 0, NULL, FALSE) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rast raster, sample_percent double precision, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, 1, TRUE, $2, 0, NULL, FALSE) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rast raster, nband integer, sample_percent double precision, bins integer, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, TRUE, $3, $4, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rast raster, nband integer, sample_percent double precision, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, TRUE, $3, $4, NULL, $5) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1, bins integer DEFAULT 0, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_histogram($1, $2, $3, $4, $5, $6, $7, $8) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, sample_percent double precision, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_histogram($1, $2, $3, $4, $5, $6, NULL, $7) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rastertable text, rastercolumn text, nband integer, sample_percent double precision, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_histogram($1, $2, $3, TRUE, $4, 0, NULL, FALSE) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rastertable text, rastercolumn text, sample_percent double precision, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_histogram($1, $2, 1, TRUE, $3, 0, NULL, FALSE) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rastertable text, rastercolumn text, nband integer, sample_percent double precision, bins integer, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_histogram($1, $2, $3, TRUE, $4, $5, $6, $7) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rastertable text, rastercolumn text, nband integer, sample_percent double precision, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_histogram($1, $2, $3, TRUE, $4, $5, NULL, $6) $function$

CREATE OR REPLACE FUNCTION public.st_approxhistogram(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1, bins integer DEFAULT 0, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, $3, $4, $5, $6, $7) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rast raster, nband integer, exclude_nodata_value boolean, sample_percent double precision, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, $3, $4, $5, NULL, $6) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rast raster, nband integer, sample_percent double precision, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, TRUE, $3, 0, NULL, FALSE) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rast raster, sample_percent double precision, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, 1, TRUE, $2, 0, NULL, FALSE) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rast raster, nband integer, sample_percent double precision, bins integer, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, TRUE, $3, $4, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rast raster, nband integer, sample_percent double precision, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, TRUE, $3, $4, NULL, $5) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1, bins integer DEFAULT 0, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_histogram($1, $2, $3, $4, $5, $6, $7, $8) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, sample_percent double precision, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_histogram($1, $2, $3, $4, $5, $6, NULL, $7) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rastertable text, rastercolumn text, nband integer, sample_percent double precision, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_histogram($1, $2, $3, TRUE, $4, 0, NULL, FALSE) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rastertable text, rastercolumn text, sample_percent double precision, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_histogram($1, $2, 1, TRUE, $3, 0, NULL, FALSE) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rastertable text, rastercolumn text, nband integer, sample_percent double precision, bins integer, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_histogram($1, $2, $3, TRUE, $4, $5, $6, $7) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rastertable text, rastercolumn text, nband integer, sample_percent double precision, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_histogram($1, $2, $3, TRUE, $4, $5, NULL, $6) $function$

CREATE OR REPLACE FUNCTION public.st_approxhistogram(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1, bins integer DEFAULT 0, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, $3, $4, $5, $6, $7) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rast raster, nband integer, exclude_nodata_value boolean, sample_percent double precision, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, $3, $4, $5, NULL, $6) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rast raster, nband integer, sample_percent double precision, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, TRUE, $3, 0, NULL, FALSE) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rast raster, sample_percent double precision, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, 1, TRUE, $2, 0, NULL, FALSE) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rast raster, nband integer, sample_percent double precision, bins integer, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, TRUE, $3, $4, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rast raster, nband integer, sample_percent double precision, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, TRUE, $3, $4, NULL, $5) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1, bins integer DEFAULT 0, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_histogram($1, $2, $3, $4, $5, $6, $7, $8) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, sample_percent double precision, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_histogram($1, $2, $3, $4, $5, $6, NULL, $7) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rastertable text, rastercolumn text, nband integer, sample_percent double precision, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_histogram($1, $2, $3, TRUE, $4, 0, NULL, FALSE) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rastertable text, rastercolumn text, sample_percent double precision, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_histogram($1, $2, 1, TRUE, $3, 0, NULL, FALSE) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rastertable text, rastercolumn text, nband integer, sample_percent double precision, bins integer, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_histogram($1, $2, $3, TRUE, $4, $5, $6, $7) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rastertable text, rastercolumn text, nband integer, sample_percent double precision, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_histogram($1, $2, $3, TRUE, $4, $5, NULL, $6) $function$

CREATE OR REPLACE FUNCTION public.st_approxhistogram(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1, bins integer DEFAULT 0, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, $3, $4, $5, $6, $7) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rast raster, nband integer, exclude_nodata_value boolean, sample_percent double precision, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, $3, $4, $5, NULL, $6) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rast raster, nband integer, sample_percent double precision, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, TRUE, $3, 0, NULL, FALSE) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rast raster, sample_percent double precision, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, 1, TRUE, $2, 0, NULL, FALSE) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rast raster, nband integer, sample_percent double precision, bins integer, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, TRUE, $3, $4, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rast raster, nband integer, sample_percent double precision, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, TRUE, $3, $4, NULL, $5) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1, bins integer DEFAULT 0, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_histogram($1, $2, $3, $4, $5, $6, $7, $8) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, sample_percent double precision, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_histogram($1, $2, $3, $4, $5, $6, NULL, $7) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rastertable text, rastercolumn text, nband integer, sample_percent double precision, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_histogram($1, $2, $3, TRUE, $4, 0, NULL, FALSE) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rastertable text, rastercolumn text, sample_percent double precision, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_histogram($1, $2, 1, TRUE, $3, 0, NULL, FALSE) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rastertable text, rastercolumn text, nband integer, sample_percent double precision, bins integer, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_histogram($1, $2, $3, TRUE, $4, $5, $6, $7) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rastertable text, rastercolumn text, nband integer, sample_percent double precision, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_histogram($1, $2, $3, TRUE, $4, $5, NULL, $6) $function$

CREATE OR REPLACE FUNCTION public.st_approxhistogram(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1, bins integer DEFAULT 0, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, $3, $4, $5, $6, $7) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rast raster, nband integer, exclude_nodata_value boolean, sample_percent double precision, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, $3, $4, $5, NULL, $6) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rast raster, nband integer, sample_percent double precision, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, TRUE, $3, 0, NULL, FALSE) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rast raster, sample_percent double precision, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, 1, TRUE, $2, 0, NULL, FALSE) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rast raster, nband integer, sample_percent double precision, bins integer, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, TRUE, $3, $4, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rast raster, nband integer, sample_percent double precision, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, TRUE, $3, $4, NULL, $5) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1, bins integer DEFAULT 0, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_histogram($1, $2, $3, $4, $5, $6, $7, $8) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, sample_percent double precision, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_histogram($1, $2, $3, $4, $5, $6, NULL, $7) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rastertable text, rastercolumn text, nband integer, sample_percent double precision, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_histogram($1, $2, $3, TRUE, $4, 0, NULL, FALSE) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rastertable text, rastercolumn text, sample_percent double precision, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_histogram($1, $2, 1, TRUE, $3, 0, NULL, FALSE) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rastertable text, rastercolumn text, nband integer, sample_percent double precision, bins integer, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_histogram($1, $2, $3, TRUE, $4, $5, $6, $7) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rastertable text, rastercolumn text, nband integer, sample_percent double precision, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_histogram($1, $2, $3, TRUE, $4, $5, NULL, $6) $function$

CREATE OR REPLACE FUNCTION public.st_approxhistogram(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1, bins integer DEFAULT 0, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, $3, $4, $5, $6, $7) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rast raster, nband integer, exclude_nodata_value boolean, sample_percent double precision, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, $3, $4, $5, NULL, $6) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rast raster, nband integer, sample_percent double precision, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, TRUE, $3, 0, NULL, FALSE) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rast raster, sample_percent double precision, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, 1, TRUE, $2, 0, NULL, FALSE) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rast raster, nband integer, sample_percent double precision, bins integer, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, TRUE, $3, $4, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rast raster, nband integer, sample_percent double precision, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, TRUE, $3, $4, NULL, $5) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1, bins integer DEFAULT 0, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_histogram($1, $2, $3, $4, $5, $6, $7, $8) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, sample_percent double precision, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_histogram($1, $2, $3, $4, $5, $6, NULL, $7) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rastertable text, rastercolumn text, nband integer, sample_percent double precision, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_histogram($1, $2, $3, TRUE, $4, 0, NULL, FALSE) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rastertable text, rastercolumn text, sample_percent double precision, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_histogram($1, $2, 1, TRUE, $3, 0, NULL, FALSE) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rastertable text, rastercolumn text, nband integer, sample_percent double precision, bins integer, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_histogram($1, $2, $3, TRUE, $4, $5, $6, $7) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rastertable text, rastercolumn text, nband integer, sample_percent double precision, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_histogram($1, $2, $3, TRUE, $4, $5, NULL, $6) $function$

CREATE OR REPLACE FUNCTION public.st_approxhistogram(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1, bins integer DEFAULT 0, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, $3, $4, $5, $6, $7) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rast raster, nband integer, exclude_nodata_value boolean, sample_percent double precision, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, $3, $4, $5, NULL, $6) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rast raster, nband integer, sample_percent double precision, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, TRUE, $3, 0, NULL, FALSE) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rast raster, sample_percent double precision, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, 1, TRUE, $2, 0, NULL, FALSE) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rast raster, nband integer, sample_percent double precision, bins integer, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, TRUE, $3, $4, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rast raster, nband integer, sample_percent double precision, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, TRUE, $3, $4, NULL, $5) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1, bins integer DEFAULT 0, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_histogram($1, $2, $3, $4, $5, $6, $7, $8) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, sample_percent double precision, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_histogram($1, $2, $3, $4, $5, $6, NULL, $7) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rastertable text, rastercolumn text, nband integer, sample_percent double precision, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_histogram($1, $2, $3, TRUE, $4, 0, NULL, FALSE) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rastertable text, rastercolumn text, sample_percent double precision, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_histogram($1, $2, 1, TRUE, $3, 0, NULL, FALSE) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rastertable text, rastercolumn text, nband integer, sample_percent double precision, bins integer, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_histogram($1, $2, $3, TRUE, $4, $5, $6, $7) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rastertable text, rastercolumn text, nband integer, sample_percent double precision, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_histogram($1, $2, $3, TRUE, $4, $5, NULL, $6) $function$

CREATE OR REPLACE FUNCTION public.st_approxhistogram(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1, bins integer DEFAULT 0, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, $3, $4, $5, $6, $7) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rast raster, nband integer, exclude_nodata_value boolean, sample_percent double precision, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, $3, $4, $5, NULL, $6) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rast raster, nband integer, sample_percent double precision, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, TRUE, $3, 0, NULL, FALSE) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rast raster, sample_percent double precision, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, 1, TRUE, $2, 0, NULL, FALSE) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rast raster, nband integer, sample_percent double precision, bins integer, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, TRUE, $3, $4, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rast raster, nband integer, sample_percent double precision, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, TRUE, $3, $4, NULL, $5) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1, bins integer DEFAULT 0, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_histogram($1, $2, $3, $4, $5, $6, $7, $8) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, sample_percent double precision, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_histogram($1, $2, $3, $4, $5, $6, NULL, $7) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rastertable text, rastercolumn text, nband integer, sample_percent double precision, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_histogram($1, $2, $3, TRUE, $4, 0, NULL, FALSE) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rastertable text, rastercolumn text, sample_percent double precision, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_histogram($1, $2, 1, TRUE, $3, 0, NULL, FALSE) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rastertable text, rastercolumn text, nband integer, sample_percent double precision, bins integer, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_histogram($1, $2, $3, TRUE, $4, $5, $6, $7) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rastertable text, rastercolumn text, nband integer, sample_percent double precision, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_histogram($1, $2, $3, TRUE, $4, $5, NULL, $6) $function$

CREATE OR REPLACE FUNCTION public.st_approxhistogram(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1, bins integer DEFAULT 0, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, $3, $4, $5, $6, $7) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rast raster, nband integer, exclude_nodata_value boolean, sample_percent double precision, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, $3, $4, $5, NULL, $6) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rast raster, nband integer, sample_percent double precision, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, TRUE, $3, 0, NULL, FALSE) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rast raster, sample_percent double precision, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, 1, TRUE, $2, 0, NULL, FALSE) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rast raster, nband integer, sample_percent double precision, bins integer, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, TRUE, $3, $4, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rast raster, nband integer, sample_percent double precision, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, TRUE, $3, $4, NULL, $5) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1, bins integer DEFAULT 0, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_histogram($1, $2, $3, $4, $5, $6, $7, $8) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, sample_percent double precision, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_histogram($1, $2, $3, $4, $5, $6, NULL, $7) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rastertable text, rastercolumn text, nband integer, sample_percent double precision, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_histogram($1, $2, $3, TRUE, $4, 0, NULL, FALSE) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rastertable text, rastercolumn text, sample_percent double precision, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_histogram($1, $2, 1, TRUE, $3, 0, NULL, FALSE) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rastertable text, rastercolumn text, nband integer, sample_percent double precision, bins integer, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_histogram($1, $2, $3, TRUE, $4, $5, $6, $7) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rastertable text, rastercolumn text, nband integer, sample_percent double precision, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_histogram($1, $2, $3, TRUE, $4, $5, NULL, $6) $function$

CREATE OR REPLACE FUNCTION public.st_approxhistogram(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1, bins integer DEFAULT 0, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, $3, $4, $5, $6, $7) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rast raster, nband integer, exclude_nodata_value boolean, sample_percent double precision, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, $3, $4, $5, NULL, $6) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rast raster, nband integer, sample_percent double precision, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, TRUE, $3, 0, NULL, FALSE) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rast raster, sample_percent double precision, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, 1, TRUE, $2, 0, NULL, FALSE) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rast raster, nband integer, sample_percent double precision, bins integer, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, TRUE, $3, $4, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rast raster, nband integer, sample_percent double precision, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, TRUE, $3, $4, NULL, $5) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1, bins integer DEFAULT 0, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_histogram($1, $2, $3, $4, $5, $6, $7, $8) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, sample_percent double precision, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_histogram($1, $2, $3, $4, $5, $6, NULL, $7) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rastertable text, rastercolumn text, nband integer, sample_percent double precision, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_histogram($1, $2, $3, TRUE, $4, 0, NULL, FALSE) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rastertable text, rastercolumn text, sample_percent double precision, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_histogram($1, $2, 1, TRUE, $3, 0, NULL, FALSE) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rastertable text, rastercolumn text, nband integer, sample_percent double precision, bins integer, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_histogram($1, $2, $3, TRUE, $4, $5, $6, $7) $function$
CREATE OR REPLACE FUNCTION public.st_approxhistogram(rastertable text, rastercolumn text, nband integer, sample_percent double precision, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_histogram($1, $2, $3, TRUE, $4, $5, NULL, $6) $function$

CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_quantile($1, $2, $3, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, nband integer, sample_percent double precision, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_quantile($1, $2, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, sample_percent double precision, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_quantile($1, 1, TRUE, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_quantile($1, 1, TRUE, 0.1, $2) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, nband integer, exclude_nodata_value boolean, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, $4, ARRAY[$5]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, nband integer, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, TRUE, $3, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, 1, TRUE, $2, ARRAY[$3]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, exclude_nodata_value boolean, quantile double precision DEFAULT NULL::double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT (_st_quantile($1, 1, $2, 0.1, ARRAY[$3]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT (_st_quantile($1, 1, TRUE, 0.1, ARRAY[$2]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_quantile($1, $2, $3, $4, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, nband integer, sample_percent double precision, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_quantile($1, $2, $3, TRUE, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, sample_percent double precision, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_quantile($1, $2, 1, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_quantile($1, $2, 1, TRUE, 0.1, $3) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, $4, $5, ARRAY[$6]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, nband integer, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, TRUE, $4, ARRAY[$5]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, 1, TRUE, $3, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, exclude_nodata_value boolean, quantile double precision DEFAULT NULL::double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE
AS $function$ SELECT (_st_quantile($1, $2, 1, $3, 0.1, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE
AS $function$ SELECT (_st_quantile($1, $2, 1, TRUE, 0.1, ARRAY[$3]::double precision[])).value $function$

CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_quantile($1, $2, $3, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, nband integer, sample_percent double precision, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_quantile($1, $2, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, sample_percent double precision, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_quantile($1, 1, TRUE, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_quantile($1, 1, TRUE, 0.1, $2) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, nband integer, exclude_nodata_value boolean, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, $4, ARRAY[$5]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, nband integer, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, TRUE, $3, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, 1, TRUE, $2, ARRAY[$3]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, exclude_nodata_value boolean, quantile double precision DEFAULT NULL::double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT (_st_quantile($1, 1, $2, 0.1, ARRAY[$3]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT (_st_quantile($1, 1, TRUE, 0.1, ARRAY[$2]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_quantile($1, $2, $3, $4, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, nband integer, sample_percent double precision, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_quantile($1, $2, $3, TRUE, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, sample_percent double precision, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_quantile($1, $2, 1, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_quantile($1, $2, 1, TRUE, 0.1, $3) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, $4, $5, ARRAY[$6]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, nband integer, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, TRUE, $4, ARRAY[$5]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, 1, TRUE, $3, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, exclude_nodata_value boolean, quantile double precision DEFAULT NULL::double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE
AS $function$ SELECT (_st_quantile($1, $2, 1, $3, 0.1, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE
AS $function$ SELECT (_st_quantile($1, $2, 1, TRUE, 0.1, ARRAY[$3]::double precision[])).value $function$

CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_quantile($1, $2, $3, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, nband integer, sample_percent double precision, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_quantile($1, $2, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, sample_percent double precision, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_quantile($1, 1, TRUE, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_quantile($1, 1, TRUE, 0.1, $2) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, nband integer, exclude_nodata_value boolean, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, $4, ARRAY[$5]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, nband integer, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, TRUE, $3, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, 1, TRUE, $2, ARRAY[$3]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, exclude_nodata_value boolean, quantile double precision DEFAULT NULL::double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT (_st_quantile($1, 1, $2, 0.1, ARRAY[$3]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT (_st_quantile($1, 1, TRUE, 0.1, ARRAY[$2]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_quantile($1, $2, $3, $4, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, nband integer, sample_percent double precision, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_quantile($1, $2, $3, TRUE, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, sample_percent double precision, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_quantile($1, $2, 1, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_quantile($1, $2, 1, TRUE, 0.1, $3) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, $4, $5, ARRAY[$6]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, nband integer, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, TRUE, $4, ARRAY[$5]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, 1, TRUE, $3, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, exclude_nodata_value boolean, quantile double precision DEFAULT NULL::double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE
AS $function$ SELECT (_st_quantile($1, $2, 1, $3, 0.1, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE
AS $function$ SELECT (_st_quantile($1, $2, 1, TRUE, 0.1, ARRAY[$3]::double precision[])).value $function$

CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_quantile($1, $2, $3, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, nband integer, sample_percent double precision, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_quantile($1, $2, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, sample_percent double precision, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_quantile($1, 1, TRUE, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_quantile($1, 1, TRUE, 0.1, $2) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, nband integer, exclude_nodata_value boolean, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, $4, ARRAY[$5]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, nband integer, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, TRUE, $3, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, 1, TRUE, $2, ARRAY[$3]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, exclude_nodata_value boolean, quantile double precision DEFAULT NULL::double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT (_st_quantile($1, 1, $2, 0.1, ARRAY[$3]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT (_st_quantile($1, 1, TRUE, 0.1, ARRAY[$2]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_quantile($1, $2, $3, $4, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, nband integer, sample_percent double precision, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_quantile($1, $2, $3, TRUE, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, sample_percent double precision, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_quantile($1, $2, 1, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_quantile($1, $2, 1, TRUE, 0.1, $3) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, $4, $5, ARRAY[$6]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, nband integer, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, TRUE, $4, ARRAY[$5]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, 1, TRUE, $3, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, exclude_nodata_value boolean, quantile double precision DEFAULT NULL::double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE
AS $function$ SELECT (_st_quantile($1, $2, 1, $3, 0.1, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE
AS $function$ SELECT (_st_quantile($1, $2, 1, TRUE, 0.1, ARRAY[$3]::double precision[])).value $function$

CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_quantile($1, $2, $3, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, nband integer, sample_percent double precision, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_quantile($1, $2, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, sample_percent double precision, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_quantile($1, 1, TRUE, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_quantile($1, 1, TRUE, 0.1, $2) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, nband integer, exclude_nodata_value boolean, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, $4, ARRAY[$5]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, nband integer, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, TRUE, $3, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, 1, TRUE, $2, ARRAY[$3]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, exclude_nodata_value boolean, quantile double precision DEFAULT NULL::double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT (_st_quantile($1, 1, $2, 0.1, ARRAY[$3]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT (_st_quantile($1, 1, TRUE, 0.1, ARRAY[$2]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_quantile($1, $2, $3, $4, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, nband integer, sample_percent double precision, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_quantile($1, $2, $3, TRUE, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, sample_percent double precision, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_quantile($1, $2, 1, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_quantile($1, $2, 1, TRUE, 0.1, $3) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, $4, $5, ARRAY[$6]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, nband integer, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, TRUE, $4, ARRAY[$5]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, 1, TRUE, $3, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, exclude_nodata_value boolean, quantile double precision DEFAULT NULL::double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE
AS $function$ SELECT (_st_quantile($1, $2, 1, $3, 0.1, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE
AS $function$ SELECT (_st_quantile($1, $2, 1, TRUE, 0.1, ARRAY[$3]::double precision[])).value $function$

CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_quantile($1, $2, $3, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, nband integer, sample_percent double precision, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_quantile($1, $2, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, sample_percent double precision, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_quantile($1, 1, TRUE, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_quantile($1, 1, TRUE, 0.1, $2) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, nband integer, exclude_nodata_value boolean, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, $4, ARRAY[$5]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, nband integer, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, TRUE, $3, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, 1, TRUE, $2, ARRAY[$3]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, exclude_nodata_value boolean, quantile double precision DEFAULT NULL::double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT (_st_quantile($1, 1, $2, 0.1, ARRAY[$3]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT (_st_quantile($1, 1, TRUE, 0.1, ARRAY[$2]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_quantile($1, $2, $3, $4, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, nband integer, sample_percent double precision, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_quantile($1, $2, $3, TRUE, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, sample_percent double precision, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_quantile($1, $2, 1, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_quantile($1, $2, 1, TRUE, 0.1, $3) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, $4, $5, ARRAY[$6]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, nband integer, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, TRUE, $4, ARRAY[$5]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, 1, TRUE, $3, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, exclude_nodata_value boolean, quantile double precision DEFAULT NULL::double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE
AS $function$ SELECT (_st_quantile($1, $2, 1, $3, 0.1, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE
AS $function$ SELECT (_st_quantile($1, $2, 1, TRUE, 0.1, ARRAY[$3]::double precision[])).value $function$

CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_quantile($1, $2, $3, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, nband integer, sample_percent double precision, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_quantile($1, $2, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, sample_percent double precision, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_quantile($1, 1, TRUE, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_quantile($1, 1, TRUE, 0.1, $2) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, nband integer, exclude_nodata_value boolean, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, $4, ARRAY[$5]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, nband integer, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, TRUE, $3, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, 1, TRUE, $2, ARRAY[$3]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, exclude_nodata_value boolean, quantile double precision DEFAULT NULL::double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT (_st_quantile($1, 1, $2, 0.1, ARRAY[$3]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT (_st_quantile($1, 1, TRUE, 0.1, ARRAY[$2]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_quantile($1, $2, $3, $4, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, nband integer, sample_percent double precision, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_quantile($1, $2, $3, TRUE, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, sample_percent double precision, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_quantile($1, $2, 1, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_quantile($1, $2, 1, TRUE, 0.1, $3) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, $4, $5, ARRAY[$6]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, nband integer, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, TRUE, $4, ARRAY[$5]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, 1, TRUE, $3, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, exclude_nodata_value boolean, quantile double precision DEFAULT NULL::double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE
AS $function$ SELECT (_st_quantile($1, $2, 1, $3, 0.1, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE
AS $function$ SELECT (_st_quantile($1, $2, 1, TRUE, 0.1, ARRAY[$3]::double precision[])).value $function$

CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_quantile($1, $2, $3, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, nband integer, sample_percent double precision, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_quantile($1, $2, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, sample_percent double precision, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_quantile($1, 1, TRUE, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_quantile($1, 1, TRUE, 0.1, $2) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, nband integer, exclude_nodata_value boolean, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, $4, ARRAY[$5]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, nband integer, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, TRUE, $3, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, 1, TRUE, $2, ARRAY[$3]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, exclude_nodata_value boolean, quantile double precision DEFAULT NULL::double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT (_st_quantile($1, 1, $2, 0.1, ARRAY[$3]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT (_st_quantile($1, 1, TRUE, 0.1, ARRAY[$2]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_quantile($1, $2, $3, $4, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, nband integer, sample_percent double precision, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_quantile($1, $2, $3, TRUE, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, sample_percent double precision, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_quantile($1, $2, 1, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_quantile($1, $2, 1, TRUE, 0.1, $3) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, $4, $5, ARRAY[$6]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, nband integer, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, TRUE, $4, ARRAY[$5]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, 1, TRUE, $3, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, exclude_nodata_value boolean, quantile double precision DEFAULT NULL::double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE
AS $function$ SELECT (_st_quantile($1, $2, 1, $3, 0.1, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE
AS $function$ SELECT (_st_quantile($1, $2, 1, TRUE, 0.1, ARRAY[$3]::double precision[])).value $function$

CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_quantile($1, $2, $3, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, nband integer, sample_percent double precision, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_quantile($1, $2, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, sample_percent double precision, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_quantile($1, 1, TRUE, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_quantile($1, 1, TRUE, 0.1, $2) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, nband integer, exclude_nodata_value boolean, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, $4, ARRAY[$5]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, nband integer, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, TRUE, $3, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, 1, TRUE, $2, ARRAY[$3]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, exclude_nodata_value boolean, quantile double precision DEFAULT NULL::double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT (_st_quantile($1, 1, $2, 0.1, ARRAY[$3]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT (_st_quantile($1, 1, TRUE, 0.1, ARRAY[$2]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_quantile($1, $2, $3, $4, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, nband integer, sample_percent double precision, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_quantile($1, $2, $3, TRUE, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, sample_percent double precision, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_quantile($1, $2, 1, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_quantile($1, $2, 1, TRUE, 0.1, $3) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, $4, $5, ARRAY[$6]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, nband integer, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, TRUE, $4, ARRAY[$5]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, 1, TRUE, $3, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, exclude_nodata_value boolean, quantile double precision DEFAULT NULL::double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE
AS $function$ SELECT (_st_quantile($1, $2, 1, $3, 0.1, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE
AS $function$ SELECT (_st_quantile($1, $2, 1, TRUE, 0.1, ARRAY[$3]::double precision[])).value $function$

CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_quantile($1, $2, $3, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, nband integer, sample_percent double precision, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_quantile($1, $2, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, sample_percent double precision, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_quantile($1, 1, TRUE, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_quantile($1, 1, TRUE, 0.1, $2) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, nband integer, exclude_nodata_value boolean, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, $4, ARRAY[$5]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, nband integer, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, TRUE, $3, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, 1, TRUE, $2, ARRAY[$3]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, exclude_nodata_value boolean, quantile double precision DEFAULT NULL::double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT (_st_quantile($1, 1, $2, 0.1, ARRAY[$3]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT (_st_quantile($1, 1, TRUE, 0.1, ARRAY[$2]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_quantile($1, $2, $3, $4, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, nband integer, sample_percent double precision, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_quantile($1, $2, $3, TRUE, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, sample_percent double precision, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_quantile($1, $2, 1, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_quantile($1, $2, 1, TRUE, 0.1, $3) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, $4, $5, ARRAY[$6]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, nband integer, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, TRUE, $4, ARRAY[$5]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, 1, TRUE, $3, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, exclude_nodata_value boolean, quantile double precision DEFAULT NULL::double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE
AS $function$ SELECT (_st_quantile($1, $2, 1, $3, 0.1, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE
AS $function$ SELECT (_st_quantile($1, $2, 1, TRUE, 0.1, ARRAY[$3]::double precision[])).value $function$

CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_quantile($1, $2, $3, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, nband integer, sample_percent double precision, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_quantile($1, $2, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, sample_percent double precision, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_quantile($1, 1, TRUE, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_quantile($1, 1, TRUE, 0.1, $2) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, nband integer, exclude_nodata_value boolean, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, $4, ARRAY[$5]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, nband integer, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, TRUE, $3, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, 1, TRUE, $2, ARRAY[$3]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, exclude_nodata_value boolean, quantile double precision DEFAULT NULL::double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT (_st_quantile($1, 1, $2, 0.1, ARRAY[$3]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT (_st_quantile($1, 1, TRUE, 0.1, ARRAY[$2]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_quantile($1, $2, $3, $4, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, nband integer, sample_percent double precision, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_quantile($1, $2, $3, TRUE, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, sample_percent double precision, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_quantile($1, $2, 1, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_quantile($1, $2, 1, TRUE, 0.1, $3) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, $4, $5, ARRAY[$6]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, nband integer, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, TRUE, $4, ARRAY[$5]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, 1, TRUE, $3, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, exclude_nodata_value boolean, quantile double precision DEFAULT NULL::double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE
AS $function$ SELECT (_st_quantile($1, $2, 1, $3, 0.1, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE
AS $function$ SELECT (_st_quantile($1, $2, 1, TRUE, 0.1, ARRAY[$3]::double precision[])).value $function$

CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_quantile($1, $2, $3, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, nband integer, sample_percent double precision, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_quantile($1, $2, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, sample_percent double precision, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_quantile($1, 1, TRUE, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_quantile($1, 1, TRUE, 0.1, $2) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, nband integer, exclude_nodata_value boolean, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, $4, ARRAY[$5]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, nband integer, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, TRUE, $3, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, 1, TRUE, $2, ARRAY[$3]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, exclude_nodata_value boolean, quantile double precision DEFAULT NULL::double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT (_st_quantile($1, 1, $2, 0.1, ARRAY[$3]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT (_st_quantile($1, 1, TRUE, 0.1, ARRAY[$2]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_quantile($1, $2, $3, $4, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, nband integer, sample_percent double precision, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_quantile($1, $2, $3, TRUE, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, sample_percent double precision, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_quantile($1, $2, 1, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_quantile($1, $2, 1, TRUE, 0.1, $3) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, $4, $5, ARRAY[$6]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, nband integer, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, TRUE, $4, ARRAY[$5]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, 1, TRUE, $3, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, exclude_nodata_value boolean, quantile double precision DEFAULT NULL::double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE
AS $function$ SELECT (_st_quantile($1, $2, 1, $3, 0.1, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE
AS $function$ SELECT (_st_quantile($1, $2, 1, TRUE, 0.1, ARRAY[$3]::double precision[])).value $function$

CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_quantile($1, $2, $3, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, nband integer, sample_percent double precision, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_quantile($1, $2, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, sample_percent double precision, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_quantile($1, 1, TRUE, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_quantile($1, 1, TRUE, 0.1, $2) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, nband integer, exclude_nodata_value boolean, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, $4, ARRAY[$5]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, nband integer, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, TRUE, $3, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, 1, TRUE, $2, ARRAY[$3]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, exclude_nodata_value boolean, quantile double precision DEFAULT NULL::double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT (_st_quantile($1, 1, $2, 0.1, ARRAY[$3]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT (_st_quantile($1, 1, TRUE, 0.1, ARRAY[$2]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_quantile($1, $2, $3, $4, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, nband integer, sample_percent double precision, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_quantile($1, $2, $3, TRUE, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, sample_percent double precision, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_quantile($1, $2, 1, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_quantile($1, $2, 1, TRUE, 0.1, $3) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, $4, $5, ARRAY[$6]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, nband integer, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, TRUE, $4, ARRAY[$5]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, 1, TRUE, $3, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, exclude_nodata_value boolean, quantile double precision DEFAULT NULL::double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE
AS $function$ SELECT (_st_quantile($1, $2, 1, $3, 0.1, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE
AS $function$ SELECT (_st_quantile($1, $2, 1, TRUE, 0.1, ARRAY[$3]::double precision[])).value $function$

CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_quantile($1, $2, $3, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, nband integer, sample_percent double precision, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_quantile($1, $2, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, sample_percent double precision, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_quantile($1, 1, TRUE, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_quantile($1, 1, TRUE, 0.1, $2) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, nband integer, exclude_nodata_value boolean, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, $4, ARRAY[$5]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, nband integer, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, TRUE, $3, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, 1, TRUE, $2, ARRAY[$3]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, exclude_nodata_value boolean, quantile double precision DEFAULT NULL::double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT (_st_quantile($1, 1, $2, 0.1, ARRAY[$3]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT (_st_quantile($1, 1, TRUE, 0.1, ARRAY[$2]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_quantile($1, $2, $3, $4, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, nband integer, sample_percent double precision, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_quantile($1, $2, $3, TRUE, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, sample_percent double precision, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_quantile($1, $2, 1, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_quantile($1, $2, 1, TRUE, 0.1, $3) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, $4, $5, ARRAY[$6]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, nband integer, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, TRUE, $4, ARRAY[$5]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, 1, TRUE, $3, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, exclude_nodata_value boolean, quantile double precision DEFAULT NULL::double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE
AS $function$ SELECT (_st_quantile($1, $2, 1, $3, 0.1, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE
AS $function$ SELECT (_st_quantile($1, $2, 1, TRUE, 0.1, ARRAY[$3]::double precision[])).value $function$

CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_quantile($1, $2, $3, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, nband integer, sample_percent double precision, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_quantile($1, $2, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, sample_percent double precision, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_quantile($1, 1, TRUE, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_quantile($1, 1, TRUE, 0.1, $2) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, nband integer, exclude_nodata_value boolean, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, $4, ARRAY[$5]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, nband integer, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, TRUE, $3, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, 1, TRUE, $2, ARRAY[$3]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, exclude_nodata_value boolean, quantile double precision DEFAULT NULL::double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT (_st_quantile($1, 1, $2, 0.1, ARRAY[$3]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT (_st_quantile($1, 1, TRUE, 0.1, ARRAY[$2]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_quantile($1, $2, $3, $4, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, nband integer, sample_percent double precision, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_quantile($1, $2, $3, TRUE, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, sample_percent double precision, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_quantile($1, $2, 1, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_quantile($1, $2, 1, TRUE, 0.1, $3) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, $4, $5, ARRAY[$6]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, nband integer, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, TRUE, $4, ARRAY[$5]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, 1, TRUE, $3, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, exclude_nodata_value boolean, quantile double precision DEFAULT NULL::double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE
AS $function$ SELECT (_st_quantile($1, $2, 1, $3, 0.1, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE
AS $function$ SELECT (_st_quantile($1, $2, 1, TRUE, 0.1, ARRAY[$3]::double precision[])).value $function$

CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_quantile($1, $2, $3, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, nband integer, sample_percent double precision, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_quantile($1, $2, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, sample_percent double precision, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_quantile($1, 1, TRUE, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_quantile($1, 1, TRUE, 0.1, $2) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, nband integer, exclude_nodata_value boolean, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, $4, ARRAY[$5]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, nband integer, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, TRUE, $3, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, 1, TRUE, $2, ARRAY[$3]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, exclude_nodata_value boolean, quantile double precision DEFAULT NULL::double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT (_st_quantile($1, 1, $2, 0.1, ARRAY[$3]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT (_st_quantile($1, 1, TRUE, 0.1, ARRAY[$2]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_quantile($1, $2, $3, $4, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, nband integer, sample_percent double precision, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_quantile($1, $2, $3, TRUE, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, sample_percent double precision, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_quantile($1, $2, 1, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_quantile($1, $2, 1, TRUE, 0.1, $3) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, $4, $5, ARRAY[$6]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, nband integer, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, TRUE, $4, ARRAY[$5]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, 1, TRUE, $3, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, exclude_nodata_value boolean, quantile double precision DEFAULT NULL::double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE
AS $function$ SELECT (_st_quantile($1, $2, 1, $3, 0.1, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE
AS $function$ SELECT (_st_quantile($1, $2, 1, TRUE, 0.1, ARRAY[$3]::double precision[])).value $function$

CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_quantile($1, $2, $3, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, nband integer, sample_percent double precision, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_quantile($1, $2, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, sample_percent double precision, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_quantile($1, 1, TRUE, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_quantile($1, 1, TRUE, 0.1, $2) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, nband integer, exclude_nodata_value boolean, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, $4, ARRAY[$5]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, nband integer, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, TRUE, $3, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, 1, TRUE, $2, ARRAY[$3]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, exclude_nodata_value boolean, quantile double precision DEFAULT NULL::double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT (_st_quantile($1, 1, $2, 0.1, ARRAY[$3]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rast raster, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT (_st_quantile($1, 1, TRUE, 0.1, ARRAY[$2]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_quantile($1, $2, $3, $4, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, nband integer, sample_percent double precision, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_quantile($1, $2, $3, TRUE, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, sample_percent double precision, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_quantile($1, $2, 1, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_quantile($1, $2, 1, TRUE, 0.1, $3) $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, $4, $5, ARRAY[$6]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, nband integer, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, TRUE, $4, ARRAY[$5]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, sample_percent double precision, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, 1, TRUE, $3, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, exclude_nodata_value boolean, quantile double precision DEFAULT NULL::double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE
AS $function$ SELECT (_st_quantile($1, $2, 1, $3, 0.1, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_approxquantile(rastertable text, rastercolumn text, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE
AS $function$ SELECT (_st_quantile($1, $2, 1, TRUE, 0.1, ARRAY[$3]::double precision[])).value $function$

CREATE OR REPLACE FUNCTION public.st_approxsummarystats(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1)
 RETURNS summarystats
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_summarystats($1, $2, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_approxsummarystats(rast raster, nband integer, sample_percent double precision)
 RETURNS summarystats
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_summarystats($1, $2, TRUE, $3) $function$
CREATE OR REPLACE FUNCTION public.st_approxsummarystats(rast raster, exclude_nodata_value boolean, sample_percent double precision DEFAULT 0.1)
 RETURNS summarystats
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_summarystats($1, 1, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_approxsummarystats(rast raster, sample_percent double precision)
 RETURNS summarystats
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_summarystats($1, 1, TRUE, $2) $function$
CREATE OR REPLACE FUNCTION public.st_approxsummarystats(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1)
 RETURNS summarystats
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_summarystats($1, $2, $3, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_approxsummarystats(rastertable text, rastercolumn text, nband integer, sample_percent double precision)
 RETURNS summarystats
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_summarystats($1, $2, $3, TRUE, $4) $function$
CREATE OR REPLACE FUNCTION public.st_approxsummarystats(rastertable text, rastercolumn text, exclude_nodata_value boolean)
 RETURNS summarystats
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_summarystats($1, $2, 1, $3, 0.1) $function$
CREATE OR REPLACE FUNCTION public.st_approxsummarystats(rastertable text, rastercolumn text, sample_percent double precision)
 RETURNS summarystats
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_summarystats($1, $2, 1, TRUE, $3) $function$

CREATE OR REPLACE FUNCTION public.st_approxsummarystats(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1)
 RETURNS summarystats
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_summarystats($1, $2, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_approxsummarystats(rast raster, nband integer, sample_percent double precision)
 RETURNS summarystats
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_summarystats($1, $2, TRUE, $3) $function$
CREATE OR REPLACE FUNCTION public.st_approxsummarystats(rast raster, exclude_nodata_value boolean, sample_percent double precision DEFAULT 0.1)
 RETURNS summarystats
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_summarystats($1, 1, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_approxsummarystats(rast raster, sample_percent double precision)
 RETURNS summarystats
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_summarystats($1, 1, TRUE, $2) $function$
CREATE OR REPLACE FUNCTION public.st_approxsummarystats(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1)
 RETURNS summarystats
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_summarystats($1, $2, $3, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_approxsummarystats(rastertable text, rastercolumn text, nband integer, sample_percent double precision)
 RETURNS summarystats
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_summarystats($1, $2, $3, TRUE, $4) $function$
CREATE OR REPLACE FUNCTION public.st_approxsummarystats(rastertable text, rastercolumn text, exclude_nodata_value boolean)
 RETURNS summarystats
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_summarystats($1, $2, 1, $3, 0.1) $function$
CREATE OR REPLACE FUNCTION public.st_approxsummarystats(rastertable text, rastercolumn text, sample_percent double precision)
 RETURNS summarystats
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_summarystats($1, $2, 1, TRUE, $3) $function$

CREATE OR REPLACE FUNCTION public.st_approxsummarystats(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1)
 RETURNS summarystats
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_summarystats($1, $2, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_approxsummarystats(rast raster, nband integer, sample_percent double precision)
 RETURNS summarystats
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_summarystats($1, $2, TRUE, $3) $function$
CREATE OR REPLACE FUNCTION public.st_approxsummarystats(rast raster, exclude_nodata_value boolean, sample_percent double precision DEFAULT 0.1)
 RETURNS summarystats
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_summarystats($1, 1, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_approxsummarystats(rast raster, sample_percent double precision)
 RETURNS summarystats
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_summarystats($1, 1, TRUE, $2) $function$
CREATE OR REPLACE FUNCTION public.st_approxsummarystats(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1)
 RETURNS summarystats
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_summarystats($1, $2, $3, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_approxsummarystats(rastertable text, rastercolumn text, nband integer, sample_percent double precision)
 RETURNS summarystats
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_summarystats($1, $2, $3, TRUE, $4) $function$
CREATE OR REPLACE FUNCTION public.st_approxsummarystats(rastertable text, rastercolumn text, exclude_nodata_value boolean)
 RETURNS summarystats
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_summarystats($1, $2, 1, $3, 0.1) $function$
CREATE OR REPLACE FUNCTION public.st_approxsummarystats(rastertable text, rastercolumn text, sample_percent double precision)
 RETURNS summarystats
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_summarystats($1, $2, 1, TRUE, $3) $function$

CREATE OR REPLACE FUNCTION public.st_approxsummarystats(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1)
 RETURNS summarystats
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_summarystats($1, $2, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_approxsummarystats(rast raster, nband integer, sample_percent double precision)
 RETURNS summarystats
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_summarystats($1, $2, TRUE, $3) $function$
CREATE OR REPLACE FUNCTION public.st_approxsummarystats(rast raster, exclude_nodata_value boolean, sample_percent double precision DEFAULT 0.1)
 RETURNS summarystats
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_summarystats($1, 1, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_approxsummarystats(rast raster, sample_percent double precision)
 RETURNS summarystats
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_summarystats($1, 1, TRUE, $2) $function$
CREATE OR REPLACE FUNCTION public.st_approxsummarystats(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1)
 RETURNS summarystats
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_summarystats($1, $2, $3, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_approxsummarystats(rastertable text, rastercolumn text, nband integer, sample_percent double precision)
 RETURNS summarystats
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_summarystats($1, $2, $3, TRUE, $4) $function$
CREATE OR REPLACE FUNCTION public.st_approxsummarystats(rastertable text, rastercolumn text, exclude_nodata_value boolean)
 RETURNS summarystats
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_summarystats($1, $2, 1, $3, 0.1) $function$
CREATE OR REPLACE FUNCTION public.st_approxsummarystats(rastertable text, rastercolumn text, sample_percent double precision)
 RETURNS summarystats
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_summarystats($1, $2, 1, TRUE, $3) $function$

CREATE OR REPLACE FUNCTION public.st_approxsummarystats(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1)
 RETURNS summarystats
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_summarystats($1, $2, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_approxsummarystats(rast raster, nband integer, sample_percent double precision)
 RETURNS summarystats
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_summarystats($1, $2, TRUE, $3) $function$
CREATE OR REPLACE FUNCTION public.st_approxsummarystats(rast raster, exclude_nodata_value boolean, sample_percent double precision DEFAULT 0.1)
 RETURNS summarystats
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_summarystats($1, 1, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_approxsummarystats(rast raster, sample_percent double precision)
 RETURNS summarystats
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_summarystats($1, 1, TRUE, $2) $function$
CREATE OR REPLACE FUNCTION public.st_approxsummarystats(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1)
 RETURNS summarystats
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_summarystats($1, $2, $3, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_approxsummarystats(rastertable text, rastercolumn text, nband integer, sample_percent double precision)
 RETURNS summarystats
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_summarystats($1, $2, $3, TRUE, $4) $function$
CREATE OR REPLACE FUNCTION public.st_approxsummarystats(rastertable text, rastercolumn text, exclude_nodata_value boolean)
 RETURNS summarystats
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_summarystats($1, $2, 1, $3, 0.1) $function$
CREATE OR REPLACE FUNCTION public.st_approxsummarystats(rastertable text, rastercolumn text, sample_percent double precision)
 RETURNS summarystats
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_summarystats($1, $2, 1, TRUE, $3) $function$

CREATE OR REPLACE FUNCTION public.st_approxsummarystats(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1)
 RETURNS summarystats
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_summarystats($1, $2, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_approxsummarystats(rast raster, nband integer, sample_percent double precision)
 RETURNS summarystats
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_summarystats($1, $2, TRUE, $3) $function$
CREATE OR REPLACE FUNCTION public.st_approxsummarystats(rast raster, exclude_nodata_value boolean, sample_percent double precision DEFAULT 0.1)
 RETURNS summarystats
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_summarystats($1, 1, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_approxsummarystats(rast raster, sample_percent double precision)
 RETURNS summarystats
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_summarystats($1, 1, TRUE, $2) $function$
CREATE OR REPLACE FUNCTION public.st_approxsummarystats(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1)
 RETURNS summarystats
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_summarystats($1, $2, $3, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_approxsummarystats(rastertable text, rastercolumn text, nband integer, sample_percent double precision)
 RETURNS summarystats
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_summarystats($1, $2, $3, TRUE, $4) $function$
CREATE OR REPLACE FUNCTION public.st_approxsummarystats(rastertable text, rastercolumn text, exclude_nodata_value boolean)
 RETURNS summarystats
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_summarystats($1, $2, 1, $3, 0.1) $function$
CREATE OR REPLACE FUNCTION public.st_approxsummarystats(rastertable text, rastercolumn text, sample_percent double precision)
 RETURNS summarystats
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_summarystats($1, $2, 1, TRUE, $3) $function$

CREATE OR REPLACE FUNCTION public.st_approxsummarystats(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1)
 RETURNS summarystats
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_summarystats($1, $2, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_approxsummarystats(rast raster, nband integer, sample_percent double precision)
 RETURNS summarystats
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_summarystats($1, $2, TRUE, $3) $function$
CREATE OR REPLACE FUNCTION public.st_approxsummarystats(rast raster, exclude_nodata_value boolean, sample_percent double precision DEFAULT 0.1)
 RETURNS summarystats
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_summarystats($1, 1, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_approxsummarystats(rast raster, sample_percent double precision)
 RETURNS summarystats
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_summarystats($1, 1, TRUE, $2) $function$
CREATE OR REPLACE FUNCTION public.st_approxsummarystats(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, sample_percent double precision DEFAULT 0.1)
 RETURNS summarystats
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_summarystats($1, $2, $3, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_approxsummarystats(rastertable text, rastercolumn text, nband integer, sample_percent double precision)
 RETURNS summarystats
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_summarystats($1, $2, $3, TRUE, $4) $function$
CREATE OR REPLACE FUNCTION public.st_approxsummarystats(rastertable text, rastercolumn text, exclude_nodata_value boolean)
 RETURNS summarystats
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_summarystats($1, $2, 1, $3, 0.1) $function$
CREATE OR REPLACE FUNCTION public.st_approxsummarystats(rastertable text, rastercolumn text, sample_percent double precision)
 RETURNS summarystats
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_summarystats($1, $2, 1, TRUE, $3) $function$

CREATE OR REPLACE FUNCTION public.st_area(text)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT ST_Area($1::geometry);  $function$
CREATE OR REPLACE FUNCTION public.st_area(geometry)
 RETURNS double precision
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$area$function$
CREATE OR REPLACE FUNCTION public.st_area(geog geography, use_spheroid boolean DEFAULT true)
 RETURNS double precision
 LANGUAGE c
 IMMUTABLE STRICT COST 100
AS '$libdir/postgis-2.2', $function$geography_area$function$

CREATE OR REPLACE FUNCTION public.st_area(text)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT ST_Area($1::geometry);  $function$
CREATE OR REPLACE FUNCTION public.st_area(geometry)
 RETURNS double precision
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$area$function$
CREATE OR REPLACE FUNCTION public.st_area(geog geography, use_spheroid boolean DEFAULT true)
 RETURNS double precision
 LANGUAGE c
 IMMUTABLE STRICT COST 100
AS '$libdir/postgis-2.2', $function$geography_area$function$

CREATE OR REPLACE FUNCTION public.st_asbinary(geometry)
 RETURNS bytea
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_asBinary$function$
CREATE OR REPLACE FUNCTION public.st_asbinary(geography)
 RETURNS bytea
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_asBinary$function$
CREATE OR REPLACE FUNCTION public.st_asbinary(geometry, text)
 RETURNS bytea
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_asBinary$function$
CREATE OR REPLACE FUNCTION public.st_asbinary(geography, text)
 RETURNS bytea
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT ST_AsBinary($1::geometry, $2);  $function$
CREATE OR REPLACE FUNCTION public.st_asbinary(raster, outasin boolean DEFAULT false)
 RETURNS bytea
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/rtpostgis-2.2', $function$RASTER_to_binary$function$

CREATE OR REPLACE FUNCTION public.st_asbinary(geometry)
 RETURNS bytea
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_asBinary$function$
CREATE OR REPLACE FUNCTION public.st_asbinary(geography)
 RETURNS bytea
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_asBinary$function$
CREATE OR REPLACE FUNCTION public.st_asbinary(geometry, text)
 RETURNS bytea
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_asBinary$function$
CREATE OR REPLACE FUNCTION public.st_asbinary(geography, text)
 RETURNS bytea
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT ST_AsBinary($1::geometry, $2);  $function$
CREATE OR REPLACE FUNCTION public.st_asbinary(raster, outasin boolean DEFAULT false)
 RETURNS bytea
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/rtpostgis-2.2', $function$RASTER_to_binary$function$

CREATE OR REPLACE FUNCTION public.st_asbinary(geometry)
 RETURNS bytea
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_asBinary$function$
CREATE OR REPLACE FUNCTION public.st_asbinary(geography)
 RETURNS bytea
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_asBinary$function$
CREATE OR REPLACE FUNCTION public.st_asbinary(geometry, text)
 RETURNS bytea
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_asBinary$function$
CREATE OR REPLACE FUNCTION public.st_asbinary(geography, text)
 RETURNS bytea
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT ST_AsBinary($1::geometry, $2);  $function$
CREATE OR REPLACE FUNCTION public.st_asbinary(raster, outasin boolean DEFAULT false)
 RETURNS bytea
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/rtpostgis-2.2', $function$RASTER_to_binary$function$

CREATE OR REPLACE FUNCTION public.st_asbinary(geometry)
 RETURNS bytea
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_asBinary$function$
CREATE OR REPLACE FUNCTION public.st_asbinary(geography)
 RETURNS bytea
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_asBinary$function$
CREATE OR REPLACE FUNCTION public.st_asbinary(geometry, text)
 RETURNS bytea
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_asBinary$function$
CREATE OR REPLACE FUNCTION public.st_asbinary(geography, text)
 RETURNS bytea
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT ST_AsBinary($1::geometry, $2);  $function$
CREATE OR REPLACE FUNCTION public.st_asbinary(raster, outasin boolean DEFAULT false)
 RETURNS bytea
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/rtpostgis-2.2', $function$RASTER_to_binary$function$

CREATE OR REPLACE FUNCTION public.st_asewkb(geometry)
 RETURNS bytea
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$WKBFromLWGEOM$function$
CREATE OR REPLACE FUNCTION public.st_asewkb(geometry, text)
 RETURNS bytea
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$WKBFromLWGEOM$function$

CREATE OR REPLACE FUNCTION public.st_asewkt(text)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT ST_AsEWKT($1::geometry);  $function$
CREATE OR REPLACE FUNCTION public.st_asewkt(geometry)
 RETURNS text
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_asEWKT$function$
CREATE OR REPLACE FUNCTION public.st_asewkt(geography)
 RETURNS text
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_asEWKT$function$

CREATE OR REPLACE FUNCTION public.st_asewkt(text)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT ST_AsEWKT($1::geometry);  $function$
CREATE OR REPLACE FUNCTION public.st_asewkt(geometry)
 RETURNS text
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_asEWKT$function$
CREATE OR REPLACE FUNCTION public.st_asewkt(geography)
 RETURNS text
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_asEWKT$function$

CREATE OR REPLACE FUNCTION public.st_asgeojson(text)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _ST_AsGeoJson(1, $1::geometry,15,0);  $function$
CREATE OR REPLACE FUNCTION public.st_asgeojson(geom geometry, maxdecimaldigits integer DEFAULT 15, options integer DEFAULT 0)
 RETURNS text
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_asGeoJson$function$
CREATE OR REPLACE FUNCTION public.st_asgeojson(geog geography, maxdecimaldigits integer DEFAULT 15, options integer DEFAULT 0)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _ST_AsGeoJson(1, $1, $2, $3); $function$
CREATE OR REPLACE FUNCTION public.st_asgeojson(gj_version integer, geom geometry, maxdecimaldigits integer DEFAULT 15, options integer DEFAULT 0)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT ST_AsGeoJson($2::geometry, $3::int4, $4::int4); $function$
CREATE OR REPLACE FUNCTION public.st_asgeojson(gj_version integer, geog geography, maxdecimaldigits integer DEFAULT 15, options integer DEFAULT 0)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _ST_AsGeoJson($1, $2, $3, $4); $function$

CREATE OR REPLACE FUNCTION public.st_asgeojson(text)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _ST_AsGeoJson(1, $1::geometry,15,0);  $function$
CREATE OR REPLACE FUNCTION public.st_asgeojson(geom geometry, maxdecimaldigits integer DEFAULT 15, options integer DEFAULT 0)
 RETURNS text
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_asGeoJson$function$
CREATE OR REPLACE FUNCTION public.st_asgeojson(geog geography, maxdecimaldigits integer DEFAULT 15, options integer DEFAULT 0)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _ST_AsGeoJson(1, $1, $2, $3); $function$
CREATE OR REPLACE FUNCTION public.st_asgeojson(gj_version integer, geom geometry, maxdecimaldigits integer DEFAULT 15, options integer DEFAULT 0)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT ST_AsGeoJson($2::geometry, $3::int4, $4::int4); $function$
CREATE OR REPLACE FUNCTION public.st_asgeojson(gj_version integer, geog geography, maxdecimaldigits integer DEFAULT 15, options integer DEFAULT 0)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _ST_AsGeoJson($1, $2, $3, $4); $function$

CREATE OR REPLACE FUNCTION public.st_asgeojson(text)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _ST_AsGeoJson(1, $1::geometry,15,0);  $function$
CREATE OR REPLACE FUNCTION public.st_asgeojson(geom geometry, maxdecimaldigits integer DEFAULT 15, options integer DEFAULT 0)
 RETURNS text
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_asGeoJson$function$
CREATE OR REPLACE FUNCTION public.st_asgeojson(geog geography, maxdecimaldigits integer DEFAULT 15, options integer DEFAULT 0)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _ST_AsGeoJson(1, $1, $2, $3); $function$
CREATE OR REPLACE FUNCTION public.st_asgeojson(gj_version integer, geom geometry, maxdecimaldigits integer DEFAULT 15, options integer DEFAULT 0)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT ST_AsGeoJson($2::geometry, $3::int4, $4::int4); $function$
CREATE OR REPLACE FUNCTION public.st_asgeojson(gj_version integer, geog geography, maxdecimaldigits integer DEFAULT 15, options integer DEFAULT 0)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _ST_AsGeoJson($1, $2, $3, $4); $function$

CREATE OR REPLACE FUNCTION public.st_asgeojson(text)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _ST_AsGeoJson(1, $1::geometry,15,0);  $function$
CREATE OR REPLACE FUNCTION public.st_asgeojson(geom geometry, maxdecimaldigits integer DEFAULT 15, options integer DEFAULT 0)
 RETURNS text
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_asGeoJson$function$
CREATE OR REPLACE FUNCTION public.st_asgeojson(geog geography, maxdecimaldigits integer DEFAULT 15, options integer DEFAULT 0)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _ST_AsGeoJson(1, $1, $2, $3); $function$
CREATE OR REPLACE FUNCTION public.st_asgeojson(gj_version integer, geom geometry, maxdecimaldigits integer DEFAULT 15, options integer DEFAULT 0)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT ST_AsGeoJson($2::geometry, $3::int4, $4::int4); $function$
CREATE OR REPLACE FUNCTION public.st_asgeojson(gj_version integer, geog geography, maxdecimaldigits integer DEFAULT 15, options integer DEFAULT 0)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _ST_AsGeoJson($1, $2, $3, $4); $function$

CREATE OR REPLACE FUNCTION public.st_asgml(text)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _ST_AsGML(2,$1::geometry,15,0, NULL, NULL);  $function$
CREATE OR REPLACE FUNCTION public.st_asgml(geom geometry, maxdecimaldigits integer DEFAULT 15, options integer DEFAULT 0)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _ST_AsGML(2, $1, $2, $3, null, null); $function$
CREATE OR REPLACE FUNCTION public.st_asgml(geog geography, maxdecimaldigits integer DEFAULT 15, options integer DEFAULT 0)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT _ST_AsGML(2, $1, $2, $3, null, null)$function$
CREATE OR REPLACE FUNCTION public.st_asgml(version integer, geom geometry, maxdecimaldigits integer DEFAULT 15, options integer DEFAULT 0, nprefix text DEFAULT NULL::text, id text DEFAULT NULL::text)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _ST_AsGML($1, $2, $3, $4, $5, $6); $function$
CREATE OR REPLACE FUNCTION public.st_asgml(version integer, geog geography, maxdecimaldigits integer DEFAULT 15, options integer DEFAULT 0, nprefix text DEFAULT NULL::text, id text DEFAULT NULL::text)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _ST_AsGML($1, $2, $3, $4, $5, $6);$function$

CREATE OR REPLACE FUNCTION public.st_asgml(text)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _ST_AsGML(2,$1::geometry,15,0, NULL, NULL);  $function$
CREATE OR REPLACE FUNCTION public.st_asgml(geom geometry, maxdecimaldigits integer DEFAULT 15, options integer DEFAULT 0)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _ST_AsGML(2, $1, $2, $3, null, null); $function$
CREATE OR REPLACE FUNCTION public.st_asgml(geog geography, maxdecimaldigits integer DEFAULT 15, options integer DEFAULT 0)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT _ST_AsGML(2, $1, $2, $3, null, null)$function$
CREATE OR REPLACE FUNCTION public.st_asgml(version integer, geom geometry, maxdecimaldigits integer DEFAULT 15, options integer DEFAULT 0, nprefix text DEFAULT NULL::text, id text DEFAULT NULL::text)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _ST_AsGML($1, $2, $3, $4, $5, $6); $function$
CREATE OR REPLACE FUNCTION public.st_asgml(version integer, geog geography, maxdecimaldigits integer DEFAULT 15, options integer DEFAULT 0, nprefix text DEFAULT NULL::text, id text DEFAULT NULL::text)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _ST_AsGML($1, $2, $3, $4, $5, $6);$function$

CREATE OR REPLACE FUNCTION public.st_asgml(text)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _ST_AsGML(2,$1::geometry,15,0, NULL, NULL);  $function$
CREATE OR REPLACE FUNCTION public.st_asgml(geom geometry, maxdecimaldigits integer DEFAULT 15, options integer DEFAULT 0)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _ST_AsGML(2, $1, $2, $3, null, null); $function$
CREATE OR REPLACE FUNCTION public.st_asgml(geog geography, maxdecimaldigits integer DEFAULT 15, options integer DEFAULT 0)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT _ST_AsGML(2, $1, $2, $3, null, null)$function$
CREATE OR REPLACE FUNCTION public.st_asgml(version integer, geom geometry, maxdecimaldigits integer DEFAULT 15, options integer DEFAULT 0, nprefix text DEFAULT NULL::text, id text DEFAULT NULL::text)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _ST_AsGML($1, $2, $3, $4, $5, $6); $function$
CREATE OR REPLACE FUNCTION public.st_asgml(version integer, geog geography, maxdecimaldigits integer DEFAULT 15, options integer DEFAULT 0, nprefix text DEFAULT NULL::text, id text DEFAULT NULL::text)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _ST_AsGML($1, $2, $3, $4, $5, $6);$function$

CREATE OR REPLACE FUNCTION public.st_asgml(text)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _ST_AsGML(2,$1::geometry,15,0, NULL, NULL);  $function$
CREATE OR REPLACE FUNCTION public.st_asgml(geom geometry, maxdecimaldigits integer DEFAULT 15, options integer DEFAULT 0)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _ST_AsGML(2, $1, $2, $3, null, null); $function$
CREATE OR REPLACE FUNCTION public.st_asgml(geog geography, maxdecimaldigits integer DEFAULT 15, options integer DEFAULT 0)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT _ST_AsGML(2, $1, $2, $3, null, null)$function$
CREATE OR REPLACE FUNCTION public.st_asgml(version integer, geom geometry, maxdecimaldigits integer DEFAULT 15, options integer DEFAULT 0, nprefix text DEFAULT NULL::text, id text DEFAULT NULL::text)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _ST_AsGML($1, $2, $3, $4, $5, $6); $function$
CREATE OR REPLACE FUNCTION public.st_asgml(version integer, geog geography, maxdecimaldigits integer DEFAULT 15, options integer DEFAULT 0, nprefix text DEFAULT NULL::text, id text DEFAULT NULL::text)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _ST_AsGML($1, $2, $3, $4, $5, $6);$function$

CREATE OR REPLACE FUNCTION public.st_ashexewkb(geometry)
 RETURNS text
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_asHEXEWKB$function$
CREATE OR REPLACE FUNCTION public.st_ashexewkb(geometry, text)
 RETURNS text
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_asHEXEWKB$function$

CREATE OR REPLACE FUNCTION public.st_asjpeg(rast raster, options text[] DEFAULT NULL::text[])
 RETURNS bytea
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
	DECLARE
		rast2 raster;
		num_bands int;
		i int;
	BEGIN
		IF rast IS NULL THEN
			RETURN NULL;
		END IF;
		num_bands := st_numbands($1);
		-- JPEG allows 1 or 3 bands
		IF num_bands <> 1 AND num_bands <> 3 THEN
			RAISE NOTICE 'The JPEG format only permits one or three bands.  The first band will be used.';
			rast2 := st_band(rast, ARRAY[1]);
			num_bands := st_numbands(rast);
		ELSE
			rast2 := rast;
		END IF;
		-- JPEG only supports 8BUI pixeltype
		FOR i IN 1..num_bands LOOP
			IF st_bandpixeltype(rast, i) != '8BUI' THEN
				RAISE EXCEPTION 'The pixel type of band % in the raster is not 8BUI.  The JPEG format can only be used with the 8BUI pixel type.', i;
			END IF;
		END LOOP;
		RETURN st_asgdalraster(rast2, 'JPEG', $2, NULL);
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_asjpeg(rast raster, nband integer, quality integer)
 RETURNS bytea
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT st_asjpeg($1, ARRAY[$2], $3) $function$
CREATE OR REPLACE FUNCTION public.st_asjpeg(rast raster, nband integer, options text[] DEFAULT NULL::text[])
 RETURNS bytea
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT st_asjpeg(st_band($1, $2), $3) $function$
CREATE OR REPLACE FUNCTION public.st_asjpeg(rast raster, nbands integer[], quality integer)
 RETURNS bytea
 LANGUAGE plpgsql
 IMMUTABLE STRICT
AS $function$
	DECLARE
		quality2 int;
		options text[];
	BEGIN
		IF quality IS NOT NULL THEN
			IF quality > 100 THEN
				quality2 := 100;
			ELSEIF quality < 10 THEN
				quality2 := 10;
			ELSE
				quality2 := quality;
			END IF;
			options := array_append(options, 'QUALITY=' || quality2);
		END IF;
		RETURN st_asjpeg(st_band($1, $2), options);
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_asjpeg(rast raster, nbands integer[], options text[] DEFAULT NULL::text[])
 RETURNS bytea
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT st_asjpeg(st_band($1, $2), $3) $function$

CREATE OR REPLACE FUNCTION public.st_asjpeg(rast raster, options text[] DEFAULT NULL::text[])
 RETURNS bytea
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
	DECLARE
		rast2 raster;
		num_bands int;
		i int;
	BEGIN
		IF rast IS NULL THEN
			RETURN NULL;
		END IF;
		num_bands := st_numbands($1);
		-- JPEG allows 1 or 3 bands
		IF num_bands <> 1 AND num_bands <> 3 THEN
			RAISE NOTICE 'The JPEG format only permits one or three bands.  The first band will be used.';
			rast2 := st_band(rast, ARRAY[1]);
			num_bands := st_numbands(rast);
		ELSE
			rast2 := rast;
		END IF;
		-- JPEG only supports 8BUI pixeltype
		FOR i IN 1..num_bands LOOP
			IF st_bandpixeltype(rast, i) != '8BUI' THEN
				RAISE EXCEPTION 'The pixel type of band % in the raster is not 8BUI.  The JPEG format can only be used with the 8BUI pixel type.', i;
			END IF;
		END LOOP;
		RETURN st_asgdalraster(rast2, 'JPEG', $2, NULL);
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_asjpeg(rast raster, nband integer, quality integer)
 RETURNS bytea
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT st_asjpeg($1, ARRAY[$2], $3) $function$
CREATE OR REPLACE FUNCTION public.st_asjpeg(rast raster, nband integer, options text[] DEFAULT NULL::text[])
 RETURNS bytea
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT st_asjpeg(st_band($1, $2), $3) $function$
CREATE OR REPLACE FUNCTION public.st_asjpeg(rast raster, nbands integer[], quality integer)
 RETURNS bytea
 LANGUAGE plpgsql
 IMMUTABLE STRICT
AS $function$
	DECLARE
		quality2 int;
		options text[];
	BEGIN
		IF quality IS NOT NULL THEN
			IF quality > 100 THEN
				quality2 := 100;
			ELSEIF quality < 10 THEN
				quality2 := 10;
			ELSE
				quality2 := quality;
			END IF;
			options := array_append(options, 'QUALITY=' || quality2);
		END IF;
		RETURN st_asjpeg(st_band($1, $2), options);
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_asjpeg(rast raster, nbands integer[], options text[] DEFAULT NULL::text[])
 RETURNS bytea
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT st_asjpeg(st_band($1, $2), $3) $function$

CREATE OR REPLACE FUNCTION public.st_asjpeg(rast raster, options text[] DEFAULT NULL::text[])
 RETURNS bytea
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
	DECLARE
		rast2 raster;
		num_bands int;
		i int;
	BEGIN
		IF rast IS NULL THEN
			RETURN NULL;
		END IF;
		num_bands := st_numbands($1);
		-- JPEG allows 1 or 3 bands
		IF num_bands <> 1 AND num_bands <> 3 THEN
			RAISE NOTICE 'The JPEG format only permits one or three bands.  The first band will be used.';
			rast2 := st_band(rast, ARRAY[1]);
			num_bands := st_numbands(rast);
		ELSE
			rast2 := rast;
		END IF;
		-- JPEG only supports 8BUI pixeltype
		FOR i IN 1..num_bands LOOP
			IF st_bandpixeltype(rast, i) != '8BUI' THEN
				RAISE EXCEPTION 'The pixel type of band % in the raster is not 8BUI.  The JPEG format can only be used with the 8BUI pixel type.', i;
			END IF;
		END LOOP;
		RETURN st_asgdalraster(rast2, 'JPEG', $2, NULL);
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_asjpeg(rast raster, nband integer, quality integer)
 RETURNS bytea
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT st_asjpeg($1, ARRAY[$2], $3) $function$
CREATE OR REPLACE FUNCTION public.st_asjpeg(rast raster, nband integer, options text[] DEFAULT NULL::text[])
 RETURNS bytea
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT st_asjpeg(st_band($1, $2), $3) $function$
CREATE OR REPLACE FUNCTION public.st_asjpeg(rast raster, nbands integer[], quality integer)
 RETURNS bytea
 LANGUAGE plpgsql
 IMMUTABLE STRICT
AS $function$
	DECLARE
		quality2 int;
		options text[];
	BEGIN
		IF quality IS NOT NULL THEN
			IF quality > 100 THEN
				quality2 := 100;
			ELSEIF quality < 10 THEN
				quality2 := 10;
			ELSE
				quality2 := quality;
			END IF;
			options := array_append(options, 'QUALITY=' || quality2);
		END IF;
		RETURN st_asjpeg(st_band($1, $2), options);
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_asjpeg(rast raster, nbands integer[], options text[] DEFAULT NULL::text[])
 RETURNS bytea
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT st_asjpeg(st_band($1, $2), $3) $function$

CREATE OR REPLACE FUNCTION public.st_asjpeg(rast raster, options text[] DEFAULT NULL::text[])
 RETURNS bytea
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
	DECLARE
		rast2 raster;
		num_bands int;
		i int;
	BEGIN
		IF rast IS NULL THEN
			RETURN NULL;
		END IF;
		num_bands := st_numbands($1);
		-- JPEG allows 1 or 3 bands
		IF num_bands <> 1 AND num_bands <> 3 THEN
			RAISE NOTICE 'The JPEG format only permits one or three bands.  The first band will be used.';
			rast2 := st_band(rast, ARRAY[1]);
			num_bands := st_numbands(rast);
		ELSE
			rast2 := rast;
		END IF;
		-- JPEG only supports 8BUI pixeltype
		FOR i IN 1..num_bands LOOP
			IF st_bandpixeltype(rast, i) != '8BUI' THEN
				RAISE EXCEPTION 'The pixel type of band % in the raster is not 8BUI.  The JPEG format can only be used with the 8BUI pixel type.', i;
			END IF;
		END LOOP;
		RETURN st_asgdalraster(rast2, 'JPEG', $2, NULL);
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_asjpeg(rast raster, nband integer, quality integer)
 RETURNS bytea
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT st_asjpeg($1, ARRAY[$2], $3) $function$
CREATE OR REPLACE FUNCTION public.st_asjpeg(rast raster, nband integer, options text[] DEFAULT NULL::text[])
 RETURNS bytea
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT st_asjpeg(st_band($1, $2), $3) $function$
CREATE OR REPLACE FUNCTION public.st_asjpeg(rast raster, nbands integer[], quality integer)
 RETURNS bytea
 LANGUAGE plpgsql
 IMMUTABLE STRICT
AS $function$
	DECLARE
		quality2 int;
		options text[];
	BEGIN
		IF quality IS NOT NULL THEN
			IF quality > 100 THEN
				quality2 := 100;
			ELSEIF quality < 10 THEN
				quality2 := 10;
			ELSE
				quality2 := quality;
			END IF;
			options := array_append(options, 'QUALITY=' || quality2);
		END IF;
		RETURN st_asjpeg(st_band($1, $2), options);
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_asjpeg(rast raster, nbands integer[], options text[] DEFAULT NULL::text[])
 RETURNS bytea
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT st_asjpeg(st_band($1, $2), $3) $function$

CREATE OR REPLACE FUNCTION public.st_askml(text)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _ST_AsKML(2, $1::geometry, 15, null);  $function$
CREATE OR REPLACE FUNCTION public.st_askml(geom geometry, maxdecimaldigits integer DEFAULT 15)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _ST_AsKML(2, ST_Transform($1,4326), $2, null); $function$
CREATE OR REPLACE FUNCTION public.st_askml(geog geography, maxdecimaldigits integer DEFAULT 15)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT _ST_AsKML(2, $1, $2, null)$function$
CREATE OR REPLACE FUNCTION public.st_askml(version integer, geom geometry, maxdecimaldigits integer DEFAULT 15, nprefix text DEFAULT NULL::text)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _ST_AsKML($1, ST_Transform($2,4326), $3, $4); $function$
CREATE OR REPLACE FUNCTION public.st_askml(version integer, geog geography, maxdecimaldigits integer DEFAULT 15, nprefix text DEFAULT NULL::text)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE
AS $function$SELECT _ST_AsKML($1, $2, $3, $4)$function$

CREATE OR REPLACE FUNCTION public.st_askml(text)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _ST_AsKML(2, $1::geometry, 15, null);  $function$
CREATE OR REPLACE FUNCTION public.st_askml(geom geometry, maxdecimaldigits integer DEFAULT 15)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _ST_AsKML(2, ST_Transform($1,4326), $2, null); $function$
CREATE OR REPLACE FUNCTION public.st_askml(geog geography, maxdecimaldigits integer DEFAULT 15)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT _ST_AsKML(2, $1, $2, null)$function$
CREATE OR REPLACE FUNCTION public.st_askml(version integer, geom geometry, maxdecimaldigits integer DEFAULT 15, nprefix text DEFAULT NULL::text)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _ST_AsKML($1, ST_Transform($2,4326), $3, $4); $function$
CREATE OR REPLACE FUNCTION public.st_askml(version integer, geog geography, maxdecimaldigits integer DEFAULT 15, nprefix text DEFAULT NULL::text)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE
AS $function$SELECT _ST_AsKML($1, $2, $3, $4)$function$

CREATE OR REPLACE FUNCTION public.st_askml(text)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _ST_AsKML(2, $1::geometry, 15, null);  $function$
CREATE OR REPLACE FUNCTION public.st_askml(geom geometry, maxdecimaldigits integer DEFAULT 15)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _ST_AsKML(2, ST_Transform($1,4326), $2, null); $function$
CREATE OR REPLACE FUNCTION public.st_askml(geog geography, maxdecimaldigits integer DEFAULT 15)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT _ST_AsKML(2, $1, $2, null)$function$
CREATE OR REPLACE FUNCTION public.st_askml(version integer, geom geometry, maxdecimaldigits integer DEFAULT 15, nprefix text DEFAULT NULL::text)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _ST_AsKML($1, ST_Transform($2,4326), $3, $4); $function$
CREATE OR REPLACE FUNCTION public.st_askml(version integer, geog geography, maxdecimaldigits integer DEFAULT 15, nprefix text DEFAULT NULL::text)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE
AS $function$SELECT _ST_AsKML($1, $2, $3, $4)$function$

CREATE OR REPLACE FUNCTION public.st_askml(text)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _ST_AsKML(2, $1::geometry, 15, null);  $function$
CREATE OR REPLACE FUNCTION public.st_askml(geom geometry, maxdecimaldigits integer DEFAULT 15)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _ST_AsKML(2, ST_Transform($1,4326), $2, null); $function$
CREATE OR REPLACE FUNCTION public.st_askml(geog geography, maxdecimaldigits integer DEFAULT 15)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT _ST_AsKML(2, $1, $2, null)$function$
CREATE OR REPLACE FUNCTION public.st_askml(version integer, geom geometry, maxdecimaldigits integer DEFAULT 15, nprefix text DEFAULT NULL::text)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _ST_AsKML($1, ST_Transform($2,4326), $3, $4); $function$
CREATE OR REPLACE FUNCTION public.st_askml(version integer, geog geography, maxdecimaldigits integer DEFAULT 15, nprefix text DEFAULT NULL::text)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE
AS $function$SELECT _ST_AsKML($1, $2, $3, $4)$function$

CREATE OR REPLACE FUNCTION public.st_aspect(rast raster, nband integer DEFAULT 1, pixeltype text DEFAULT '32BF'::text, units text DEFAULT 'DEGREES'::text, interpolate_nodata boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT st_aspect($1, $2, NULL::raster, $3, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_aspect(rast raster, nband integer, customextent raster, pixeltype text DEFAULT '32BF'::text, units text DEFAULT 'DEGREES'::text, interpolate_nodata boolean DEFAULT false)
 RETURNS raster
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
	DECLARE
		_rast raster;
		_nband integer;
		_pixtype text;
		_width integer;
		_height integer;
		_customextent raster;
		_extenttype text;
	BEGIN
		_customextent := customextent;
		IF _customextent IS NULL THEN
			_extenttype := 'FIRST';
		ELSE
			_extenttype := 'CUSTOM';
		END IF;
		IF interpolate_nodata IS TRUE THEN
			_rast := ST_MapAlgebra(
				ARRAY[ROW(rast, nband)]::rastbandarg[],
				'st_invdistweight4ma(double precision[][][], integer[][], text[])'::regprocedure,
				pixeltype,
				'FIRST', NULL,
				1, 1
			);
			_nband := 1;
			_pixtype := NULL;
		ELSE
			_rast := rast;
			_nband := nband;
			_pixtype := pixeltype;
		END IF;
		-- get properties
		SELECT width, height INTO _width, _height FROM ST_Metadata(_rast);
		RETURN ST_MapAlgebra(
			ARRAY[ROW(_rast, _nband)]::rastbandarg[],
			'_st_aspect4ma(double precision[][][], integer[][], text[])'::regprocedure,
			_pixtype,
			_extenttype, _customextent,
			1, 1,
			_width::text, _height::text,
			units::text
		);
	END;
	$function$

CREATE OR REPLACE FUNCTION public.st_aspng(rast raster, options text[] DEFAULT NULL::text[])
 RETURNS bytea
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
	DECLARE
		rast2 raster;
		num_bands int;
		i int;
		pt text;
	BEGIN
		IF rast IS NULL THEN
			RETURN NULL;
		END IF;
		num_bands := st_numbands($1);
		-- PNG allows 1, 3 or 4 bands
		IF num_bands <> 1 AND num_bands <> 3 AND num_bands <> 4 THEN
			RAISE NOTICE 'The PNG format only permits one, three or four bands.  The first band will be used.';
			rast2 := st_band($1, ARRAY[1]);
			num_bands := st_numbands(rast2);
		ELSE
			rast2 := rast;
		END IF;
		-- PNG only supports 8BUI and 16BUI pixeltype
		FOR i IN 1..num_bands LOOP
			pt = st_bandpixeltype(rast, i);
			IF pt != '8BUI' AND pt != '16BUI' THEN
				RAISE EXCEPTION 'The pixel type of band % in the raster is not 8BUI or 16BUI.  The PNG format can only be used with 8BUI and 16BUI pixel types.', i;
			END IF;
		END LOOP;
		RETURN st_asgdalraster(rast2, 'PNG', $2, NULL);
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_aspng(rast raster, nband integer, compression integer)
 RETURNS bytea
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT st_aspng($1, ARRAY[$2], $3) $function$
CREATE OR REPLACE FUNCTION public.st_aspng(rast raster, nband integer, options text[] DEFAULT NULL::text[])
 RETURNS bytea
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT st_aspng(st_band($1, $2), $3) $function$
CREATE OR REPLACE FUNCTION public.st_aspng(rast raster, nbands integer[], compression integer)
 RETURNS bytea
 LANGUAGE plpgsql
 IMMUTABLE STRICT
AS $function$
	DECLARE
		compression2 int;
		options text[];
	BEGIN
		IF compression IS NOT NULL THEN
			IF compression > 9 THEN
				compression2 := 9;
			ELSEIF compression < 1 THEN
				compression2 := 1;
			ELSE
				compression2 := compression;
			END IF;
			options := array_append(options, 'ZLEVEL=' || compression2);
		END IF;
		RETURN st_aspng(st_band($1, $2), options);
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_aspng(rast raster, nbands integer[], options text[] DEFAULT NULL::text[])
 RETURNS bytea
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT st_aspng(st_band($1, $2), $3) $function$

CREATE OR REPLACE FUNCTION public.st_aspng(rast raster, options text[] DEFAULT NULL::text[])
 RETURNS bytea
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
	DECLARE
		rast2 raster;
		num_bands int;
		i int;
		pt text;
	BEGIN
		IF rast IS NULL THEN
			RETURN NULL;
		END IF;
		num_bands := st_numbands($1);
		-- PNG allows 1, 3 or 4 bands
		IF num_bands <> 1 AND num_bands <> 3 AND num_bands <> 4 THEN
			RAISE NOTICE 'The PNG format only permits one, three or four bands.  The first band will be used.';
			rast2 := st_band($1, ARRAY[1]);
			num_bands := st_numbands(rast2);
		ELSE
			rast2 := rast;
		END IF;
		-- PNG only supports 8BUI and 16BUI pixeltype
		FOR i IN 1..num_bands LOOP
			pt = st_bandpixeltype(rast, i);
			IF pt != '8BUI' AND pt != '16BUI' THEN
				RAISE EXCEPTION 'The pixel type of band % in the raster is not 8BUI or 16BUI.  The PNG format can only be used with 8BUI and 16BUI pixel types.', i;
			END IF;
		END LOOP;
		RETURN st_asgdalraster(rast2, 'PNG', $2, NULL);
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_aspng(rast raster, nband integer, compression integer)
 RETURNS bytea
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT st_aspng($1, ARRAY[$2], $3) $function$
CREATE OR REPLACE FUNCTION public.st_aspng(rast raster, nband integer, options text[] DEFAULT NULL::text[])
 RETURNS bytea
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT st_aspng(st_band($1, $2), $3) $function$
CREATE OR REPLACE FUNCTION public.st_aspng(rast raster, nbands integer[], compression integer)
 RETURNS bytea
 LANGUAGE plpgsql
 IMMUTABLE STRICT
AS $function$
	DECLARE
		compression2 int;
		options text[];
	BEGIN
		IF compression IS NOT NULL THEN
			IF compression > 9 THEN
				compression2 := 9;
			ELSEIF compression < 1 THEN
				compression2 := 1;
			ELSE
				compression2 := compression;
			END IF;
			options := array_append(options, 'ZLEVEL=' || compression2);
		END IF;
		RETURN st_aspng(st_band($1, $2), options);
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_aspng(rast raster, nbands integer[], options text[] DEFAULT NULL::text[])
 RETURNS bytea
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT st_aspng(st_band($1, $2), $3) $function$

CREATE OR REPLACE FUNCTION public.st_aspng(rast raster, options text[] DEFAULT NULL::text[])
 RETURNS bytea
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
	DECLARE
		rast2 raster;
		num_bands int;
		i int;
		pt text;
	BEGIN
		IF rast IS NULL THEN
			RETURN NULL;
		END IF;
		num_bands := st_numbands($1);
		-- PNG allows 1, 3 or 4 bands
		IF num_bands <> 1 AND num_bands <> 3 AND num_bands <> 4 THEN
			RAISE NOTICE 'The PNG format only permits one, three or four bands.  The first band will be used.';
			rast2 := st_band($1, ARRAY[1]);
			num_bands := st_numbands(rast2);
		ELSE
			rast2 := rast;
		END IF;
		-- PNG only supports 8BUI and 16BUI pixeltype
		FOR i IN 1..num_bands LOOP
			pt = st_bandpixeltype(rast, i);
			IF pt != '8BUI' AND pt != '16BUI' THEN
				RAISE EXCEPTION 'The pixel type of band % in the raster is not 8BUI or 16BUI.  The PNG format can only be used with 8BUI and 16BUI pixel types.', i;
			END IF;
		END LOOP;
		RETURN st_asgdalraster(rast2, 'PNG', $2, NULL);
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_aspng(rast raster, nband integer, compression integer)
 RETURNS bytea
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT st_aspng($1, ARRAY[$2], $3) $function$
CREATE OR REPLACE FUNCTION public.st_aspng(rast raster, nband integer, options text[] DEFAULT NULL::text[])
 RETURNS bytea
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT st_aspng(st_band($1, $2), $3) $function$
CREATE OR REPLACE FUNCTION public.st_aspng(rast raster, nbands integer[], compression integer)
 RETURNS bytea
 LANGUAGE plpgsql
 IMMUTABLE STRICT
AS $function$
	DECLARE
		compression2 int;
		options text[];
	BEGIN
		IF compression IS NOT NULL THEN
			IF compression > 9 THEN
				compression2 := 9;
			ELSEIF compression < 1 THEN
				compression2 := 1;
			ELSE
				compression2 := compression;
			END IF;
			options := array_append(options, 'ZLEVEL=' || compression2);
		END IF;
		RETURN st_aspng(st_band($1, $2), options);
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_aspng(rast raster, nbands integer[], options text[] DEFAULT NULL::text[])
 RETURNS bytea
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT st_aspng(st_band($1, $2), $3) $function$

CREATE OR REPLACE FUNCTION public.st_aspng(rast raster, options text[] DEFAULT NULL::text[])
 RETURNS bytea
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
	DECLARE
		rast2 raster;
		num_bands int;
		i int;
		pt text;
	BEGIN
		IF rast IS NULL THEN
			RETURN NULL;
		END IF;
		num_bands := st_numbands($1);
		-- PNG allows 1, 3 or 4 bands
		IF num_bands <> 1 AND num_bands <> 3 AND num_bands <> 4 THEN
			RAISE NOTICE 'The PNG format only permits one, three or four bands.  The first band will be used.';
			rast2 := st_band($1, ARRAY[1]);
			num_bands := st_numbands(rast2);
		ELSE
			rast2 := rast;
		END IF;
		-- PNG only supports 8BUI and 16BUI pixeltype
		FOR i IN 1..num_bands LOOP
			pt = st_bandpixeltype(rast, i);
			IF pt != '8BUI' AND pt != '16BUI' THEN
				RAISE EXCEPTION 'The pixel type of band % in the raster is not 8BUI or 16BUI.  The PNG format can only be used with 8BUI and 16BUI pixel types.', i;
			END IF;
		END LOOP;
		RETURN st_asgdalraster(rast2, 'PNG', $2, NULL);
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_aspng(rast raster, nband integer, compression integer)
 RETURNS bytea
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT st_aspng($1, ARRAY[$2], $3) $function$
CREATE OR REPLACE FUNCTION public.st_aspng(rast raster, nband integer, options text[] DEFAULT NULL::text[])
 RETURNS bytea
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT st_aspng(st_band($1, $2), $3) $function$
CREATE OR REPLACE FUNCTION public.st_aspng(rast raster, nbands integer[], compression integer)
 RETURNS bytea
 LANGUAGE plpgsql
 IMMUTABLE STRICT
AS $function$
	DECLARE
		compression2 int;
		options text[];
	BEGIN
		IF compression IS NOT NULL THEN
			IF compression > 9 THEN
				compression2 := 9;
			ELSEIF compression < 1 THEN
				compression2 := 1;
			ELSE
				compression2 := compression;
			END IF;
			options := array_append(options, 'ZLEVEL=' || compression2);
		END IF;
		RETURN st_aspng(st_band($1, $2), options);
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_aspng(rast raster, nbands integer[], options text[] DEFAULT NULL::text[])
 RETURNS bytea
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT st_aspng(st_band($1, $2), $3) $function$

CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, scalex double precision, scaley double precision, gridx double precision DEFAULT NULL::double precision, gridy double precision DEFAULT NULL::double precision, pixeltype text[] DEFAULT ARRAY['8BUI'::text], value double precision[] DEFAULT ARRAY[(1)::double precision], nodataval double precision[] DEFAULT ARRAY[(0)::double precision], skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, $2, $3, NULL, NULL, $6, $7, $8, NULL, NULL, $4, $5, $9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, scalex double precision, scaley double precision, pixeltype text[], value double precision[] DEFAULT ARRAY[(1)::double precision], nodataval double precision[] DEFAULT ARRAY[(0)::double precision], upperleftx double precision DEFAULT NULL::double precision, upperlefty double precision DEFAULT NULL::double precision, skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, $2, $3, NULL, NULL, $4, $5, $6, $7, $8, NULL, NULL,	$9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, width integer, height integer, gridx double precision DEFAULT NULL::double precision, gridy double precision DEFAULT NULL::double precision, pixeltype text[] DEFAULT ARRAY['8BUI'::text], value double precision[] DEFAULT ARRAY[(1)::double precision], nodataval double precision[] DEFAULT ARRAY[(0)::double precision], skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, NULL, NULL, $2, $3, $6, $7, $8, NULL, NULL, $4, $5, $9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, width integer, height integer, pixeltype text[], value double precision[] DEFAULT ARRAY[(1)::double precision], nodataval double precision[] DEFAULT ARRAY[(0)::double precision], upperleftx double precision DEFAULT NULL::double precision, upperlefty double precision DEFAULT NULL::double precision, skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, NULL, NULL, $2, $3, $4, $5, $6, $7, $8, NULL, NULL,	$9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, scalex double precision, scaley double precision, gridx double precision, gridy double precision, pixeltype text, value double precision DEFAULT 1, nodataval double precision DEFAULT 0, skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, $2, $3, NULL, NULL, ARRAY[$6]::text[], ARRAY[$7]::double precision[], ARRAY[$8]::double precision[], NULL, NULL, $4, $5, $9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, scalex double precision, scaley double precision, pixeltype text, value double precision DEFAULT 1, nodataval double precision DEFAULT 0, upperleftx double precision DEFAULT NULL::double precision, upperlefty double precision DEFAULT NULL::double precision, skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, $2, $3, NULL, NULL, ARRAY[$4]::text[], ARRAY[$5]::double precision[], ARRAY[$6]::double precision[], $7, $8, NULL, NULL, $9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, width integer, height integer, gridx double precision, gridy double precision, pixeltype text, value double precision DEFAULT 1, nodataval double precision DEFAULT 0, skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, NULL, NULL, $2, $3, ARRAY[$6]::text[], ARRAY[$7]::double precision[], ARRAY[$8]::double precision[], NULL, NULL, $4, $5, $9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, width integer, height integer, pixeltype text, value double precision DEFAULT 1, nodataval double precision DEFAULT 0, upperleftx double precision DEFAULT NULL::double precision, upperlefty double precision DEFAULT NULL::double precision, skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, NULL, NULL, $2, $3, ARRAY[$4]::text[], ARRAY[$5]::double precision[], ARRAY[$6]::double precision[], $7, $8, NULL, NULL,$9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, ref raster, pixeltype text[] DEFAULT ARRAY['8BUI'::text], value double precision[] DEFAULT ARRAY[(1)::double precision], nodataval double precision[] DEFAULT ARRAY[(0)::double precision], touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE plpgsql
 STABLE
AS $function$
	DECLARE
		g geometry;
		g_srid integer;
		ul_x double precision;
		ul_y double precision;
		scale_x double precision;
		scale_y double precision;
		skew_x double precision;
		skew_y double precision;
		sr_id integer;
	BEGIN
		SELECT upperleftx, upperlefty, scalex, scaley, skewx, skewy, srid INTO ul_x, ul_y, scale_x, scale_y, skew_x, skew_y, sr_id FROM ST_Metadata(ref);
		--RAISE NOTICE '%, %, %, %, %, %, %', ul_x, ul_y, scale_x, scale_y, skew_x, skew_y, sr_id;
		-- geometry and raster has different SRID
		g_srid := ST_SRID(geom);
		IF g_srid != sr_id THEN
			RAISE NOTICE 'The geometry''s SRID (%) is not the same as the raster''s SRID (%).  The geometry will be transformed to the raster''s projection', g_srid, sr_id;
			g := ST_Transform(geom, sr_id);
		ELSE
			g := geom;
		END IF;
		RETURN _st_asraster(g, scale_x, scale_y, NULL, NULL, $3, $4, $5, NULL, NULL, ul_x, ul_y, skew_x, skew_y, $6);
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, ref raster, pixeltype text, value double precision DEFAULT 1, nodataval double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_asraster($1, $2, ARRAY[$3]::text[], ARRAY[$4]::double precision[], ARRAY[$5]::double precision[], $6) $function$

CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, scalex double precision, scaley double precision, gridx double precision DEFAULT NULL::double precision, gridy double precision DEFAULT NULL::double precision, pixeltype text[] DEFAULT ARRAY['8BUI'::text], value double precision[] DEFAULT ARRAY[(1)::double precision], nodataval double precision[] DEFAULT ARRAY[(0)::double precision], skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, $2, $3, NULL, NULL, $6, $7, $8, NULL, NULL, $4, $5, $9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, scalex double precision, scaley double precision, pixeltype text[], value double precision[] DEFAULT ARRAY[(1)::double precision], nodataval double precision[] DEFAULT ARRAY[(0)::double precision], upperleftx double precision DEFAULT NULL::double precision, upperlefty double precision DEFAULT NULL::double precision, skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, $2, $3, NULL, NULL, $4, $5, $6, $7, $8, NULL, NULL,	$9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, width integer, height integer, gridx double precision DEFAULT NULL::double precision, gridy double precision DEFAULT NULL::double precision, pixeltype text[] DEFAULT ARRAY['8BUI'::text], value double precision[] DEFAULT ARRAY[(1)::double precision], nodataval double precision[] DEFAULT ARRAY[(0)::double precision], skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, NULL, NULL, $2, $3, $6, $7, $8, NULL, NULL, $4, $5, $9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, width integer, height integer, pixeltype text[], value double precision[] DEFAULT ARRAY[(1)::double precision], nodataval double precision[] DEFAULT ARRAY[(0)::double precision], upperleftx double precision DEFAULT NULL::double precision, upperlefty double precision DEFAULT NULL::double precision, skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, NULL, NULL, $2, $3, $4, $5, $6, $7, $8, NULL, NULL,	$9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, scalex double precision, scaley double precision, gridx double precision, gridy double precision, pixeltype text, value double precision DEFAULT 1, nodataval double precision DEFAULT 0, skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, $2, $3, NULL, NULL, ARRAY[$6]::text[], ARRAY[$7]::double precision[], ARRAY[$8]::double precision[], NULL, NULL, $4, $5, $9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, scalex double precision, scaley double precision, pixeltype text, value double precision DEFAULT 1, nodataval double precision DEFAULT 0, upperleftx double precision DEFAULT NULL::double precision, upperlefty double precision DEFAULT NULL::double precision, skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, $2, $3, NULL, NULL, ARRAY[$4]::text[], ARRAY[$5]::double precision[], ARRAY[$6]::double precision[], $7, $8, NULL, NULL, $9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, width integer, height integer, gridx double precision, gridy double precision, pixeltype text, value double precision DEFAULT 1, nodataval double precision DEFAULT 0, skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, NULL, NULL, $2, $3, ARRAY[$6]::text[], ARRAY[$7]::double precision[], ARRAY[$8]::double precision[], NULL, NULL, $4, $5, $9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, width integer, height integer, pixeltype text, value double precision DEFAULT 1, nodataval double precision DEFAULT 0, upperleftx double precision DEFAULT NULL::double precision, upperlefty double precision DEFAULT NULL::double precision, skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, NULL, NULL, $2, $3, ARRAY[$4]::text[], ARRAY[$5]::double precision[], ARRAY[$6]::double precision[], $7, $8, NULL, NULL,$9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, ref raster, pixeltype text[] DEFAULT ARRAY['8BUI'::text], value double precision[] DEFAULT ARRAY[(1)::double precision], nodataval double precision[] DEFAULT ARRAY[(0)::double precision], touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE plpgsql
 STABLE
AS $function$
	DECLARE
		g geometry;
		g_srid integer;
		ul_x double precision;
		ul_y double precision;
		scale_x double precision;
		scale_y double precision;
		skew_x double precision;
		skew_y double precision;
		sr_id integer;
	BEGIN
		SELECT upperleftx, upperlefty, scalex, scaley, skewx, skewy, srid INTO ul_x, ul_y, scale_x, scale_y, skew_x, skew_y, sr_id FROM ST_Metadata(ref);
		--RAISE NOTICE '%, %, %, %, %, %, %', ul_x, ul_y, scale_x, scale_y, skew_x, skew_y, sr_id;
		-- geometry and raster has different SRID
		g_srid := ST_SRID(geom);
		IF g_srid != sr_id THEN
			RAISE NOTICE 'The geometry''s SRID (%) is not the same as the raster''s SRID (%).  The geometry will be transformed to the raster''s projection', g_srid, sr_id;
			g := ST_Transform(geom, sr_id);
		ELSE
			g := geom;
		END IF;
		RETURN _st_asraster(g, scale_x, scale_y, NULL, NULL, $3, $4, $5, NULL, NULL, ul_x, ul_y, skew_x, skew_y, $6);
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, ref raster, pixeltype text, value double precision DEFAULT 1, nodataval double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_asraster($1, $2, ARRAY[$3]::text[], ARRAY[$4]::double precision[], ARRAY[$5]::double precision[], $6) $function$

CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, scalex double precision, scaley double precision, gridx double precision DEFAULT NULL::double precision, gridy double precision DEFAULT NULL::double precision, pixeltype text[] DEFAULT ARRAY['8BUI'::text], value double precision[] DEFAULT ARRAY[(1)::double precision], nodataval double precision[] DEFAULT ARRAY[(0)::double precision], skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, $2, $3, NULL, NULL, $6, $7, $8, NULL, NULL, $4, $5, $9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, scalex double precision, scaley double precision, pixeltype text[], value double precision[] DEFAULT ARRAY[(1)::double precision], nodataval double precision[] DEFAULT ARRAY[(0)::double precision], upperleftx double precision DEFAULT NULL::double precision, upperlefty double precision DEFAULT NULL::double precision, skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, $2, $3, NULL, NULL, $4, $5, $6, $7, $8, NULL, NULL,	$9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, width integer, height integer, gridx double precision DEFAULT NULL::double precision, gridy double precision DEFAULT NULL::double precision, pixeltype text[] DEFAULT ARRAY['8BUI'::text], value double precision[] DEFAULT ARRAY[(1)::double precision], nodataval double precision[] DEFAULT ARRAY[(0)::double precision], skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, NULL, NULL, $2, $3, $6, $7, $8, NULL, NULL, $4, $5, $9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, width integer, height integer, pixeltype text[], value double precision[] DEFAULT ARRAY[(1)::double precision], nodataval double precision[] DEFAULT ARRAY[(0)::double precision], upperleftx double precision DEFAULT NULL::double precision, upperlefty double precision DEFAULT NULL::double precision, skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, NULL, NULL, $2, $3, $4, $5, $6, $7, $8, NULL, NULL,	$9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, scalex double precision, scaley double precision, gridx double precision, gridy double precision, pixeltype text, value double precision DEFAULT 1, nodataval double precision DEFAULT 0, skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, $2, $3, NULL, NULL, ARRAY[$6]::text[], ARRAY[$7]::double precision[], ARRAY[$8]::double precision[], NULL, NULL, $4, $5, $9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, scalex double precision, scaley double precision, pixeltype text, value double precision DEFAULT 1, nodataval double precision DEFAULT 0, upperleftx double precision DEFAULT NULL::double precision, upperlefty double precision DEFAULT NULL::double precision, skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, $2, $3, NULL, NULL, ARRAY[$4]::text[], ARRAY[$5]::double precision[], ARRAY[$6]::double precision[], $7, $8, NULL, NULL, $9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, width integer, height integer, gridx double precision, gridy double precision, pixeltype text, value double precision DEFAULT 1, nodataval double precision DEFAULT 0, skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, NULL, NULL, $2, $3, ARRAY[$6]::text[], ARRAY[$7]::double precision[], ARRAY[$8]::double precision[], NULL, NULL, $4, $5, $9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, width integer, height integer, pixeltype text, value double precision DEFAULT 1, nodataval double precision DEFAULT 0, upperleftx double precision DEFAULT NULL::double precision, upperlefty double precision DEFAULT NULL::double precision, skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, NULL, NULL, $2, $3, ARRAY[$4]::text[], ARRAY[$5]::double precision[], ARRAY[$6]::double precision[], $7, $8, NULL, NULL,$9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, ref raster, pixeltype text[] DEFAULT ARRAY['8BUI'::text], value double precision[] DEFAULT ARRAY[(1)::double precision], nodataval double precision[] DEFAULT ARRAY[(0)::double precision], touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE plpgsql
 STABLE
AS $function$
	DECLARE
		g geometry;
		g_srid integer;
		ul_x double precision;
		ul_y double precision;
		scale_x double precision;
		scale_y double precision;
		skew_x double precision;
		skew_y double precision;
		sr_id integer;
	BEGIN
		SELECT upperleftx, upperlefty, scalex, scaley, skewx, skewy, srid INTO ul_x, ul_y, scale_x, scale_y, skew_x, skew_y, sr_id FROM ST_Metadata(ref);
		--RAISE NOTICE '%, %, %, %, %, %, %', ul_x, ul_y, scale_x, scale_y, skew_x, skew_y, sr_id;
		-- geometry and raster has different SRID
		g_srid := ST_SRID(geom);
		IF g_srid != sr_id THEN
			RAISE NOTICE 'The geometry''s SRID (%) is not the same as the raster''s SRID (%).  The geometry will be transformed to the raster''s projection', g_srid, sr_id;
			g := ST_Transform(geom, sr_id);
		ELSE
			g := geom;
		END IF;
		RETURN _st_asraster(g, scale_x, scale_y, NULL, NULL, $3, $4, $5, NULL, NULL, ul_x, ul_y, skew_x, skew_y, $6);
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, ref raster, pixeltype text, value double precision DEFAULT 1, nodataval double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_asraster($1, $2, ARRAY[$3]::text[], ARRAY[$4]::double precision[], ARRAY[$5]::double precision[], $6) $function$

CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, scalex double precision, scaley double precision, gridx double precision DEFAULT NULL::double precision, gridy double precision DEFAULT NULL::double precision, pixeltype text[] DEFAULT ARRAY['8BUI'::text], value double precision[] DEFAULT ARRAY[(1)::double precision], nodataval double precision[] DEFAULT ARRAY[(0)::double precision], skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, $2, $3, NULL, NULL, $6, $7, $8, NULL, NULL, $4, $5, $9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, scalex double precision, scaley double precision, pixeltype text[], value double precision[] DEFAULT ARRAY[(1)::double precision], nodataval double precision[] DEFAULT ARRAY[(0)::double precision], upperleftx double precision DEFAULT NULL::double precision, upperlefty double precision DEFAULT NULL::double precision, skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, $2, $3, NULL, NULL, $4, $5, $6, $7, $8, NULL, NULL,	$9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, width integer, height integer, gridx double precision DEFAULT NULL::double precision, gridy double precision DEFAULT NULL::double precision, pixeltype text[] DEFAULT ARRAY['8BUI'::text], value double precision[] DEFAULT ARRAY[(1)::double precision], nodataval double precision[] DEFAULT ARRAY[(0)::double precision], skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, NULL, NULL, $2, $3, $6, $7, $8, NULL, NULL, $4, $5, $9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, width integer, height integer, pixeltype text[], value double precision[] DEFAULT ARRAY[(1)::double precision], nodataval double precision[] DEFAULT ARRAY[(0)::double precision], upperleftx double precision DEFAULT NULL::double precision, upperlefty double precision DEFAULT NULL::double precision, skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, NULL, NULL, $2, $3, $4, $5, $6, $7, $8, NULL, NULL,	$9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, scalex double precision, scaley double precision, gridx double precision, gridy double precision, pixeltype text, value double precision DEFAULT 1, nodataval double precision DEFAULT 0, skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, $2, $3, NULL, NULL, ARRAY[$6]::text[], ARRAY[$7]::double precision[], ARRAY[$8]::double precision[], NULL, NULL, $4, $5, $9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, scalex double precision, scaley double precision, pixeltype text, value double precision DEFAULT 1, nodataval double precision DEFAULT 0, upperleftx double precision DEFAULT NULL::double precision, upperlefty double precision DEFAULT NULL::double precision, skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, $2, $3, NULL, NULL, ARRAY[$4]::text[], ARRAY[$5]::double precision[], ARRAY[$6]::double precision[], $7, $8, NULL, NULL, $9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, width integer, height integer, gridx double precision, gridy double precision, pixeltype text, value double precision DEFAULT 1, nodataval double precision DEFAULT 0, skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, NULL, NULL, $2, $3, ARRAY[$6]::text[], ARRAY[$7]::double precision[], ARRAY[$8]::double precision[], NULL, NULL, $4, $5, $9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, width integer, height integer, pixeltype text, value double precision DEFAULT 1, nodataval double precision DEFAULT 0, upperleftx double precision DEFAULT NULL::double precision, upperlefty double precision DEFAULT NULL::double precision, skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, NULL, NULL, $2, $3, ARRAY[$4]::text[], ARRAY[$5]::double precision[], ARRAY[$6]::double precision[], $7, $8, NULL, NULL,$9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, ref raster, pixeltype text[] DEFAULT ARRAY['8BUI'::text], value double precision[] DEFAULT ARRAY[(1)::double precision], nodataval double precision[] DEFAULT ARRAY[(0)::double precision], touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE plpgsql
 STABLE
AS $function$
	DECLARE
		g geometry;
		g_srid integer;
		ul_x double precision;
		ul_y double precision;
		scale_x double precision;
		scale_y double precision;
		skew_x double precision;
		skew_y double precision;
		sr_id integer;
	BEGIN
		SELECT upperleftx, upperlefty, scalex, scaley, skewx, skewy, srid INTO ul_x, ul_y, scale_x, scale_y, skew_x, skew_y, sr_id FROM ST_Metadata(ref);
		--RAISE NOTICE '%, %, %, %, %, %, %', ul_x, ul_y, scale_x, scale_y, skew_x, skew_y, sr_id;
		-- geometry and raster has different SRID
		g_srid := ST_SRID(geom);
		IF g_srid != sr_id THEN
			RAISE NOTICE 'The geometry''s SRID (%) is not the same as the raster''s SRID (%).  The geometry will be transformed to the raster''s projection', g_srid, sr_id;
			g := ST_Transform(geom, sr_id);
		ELSE
			g := geom;
		END IF;
		RETURN _st_asraster(g, scale_x, scale_y, NULL, NULL, $3, $4, $5, NULL, NULL, ul_x, ul_y, skew_x, skew_y, $6);
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, ref raster, pixeltype text, value double precision DEFAULT 1, nodataval double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_asraster($1, $2, ARRAY[$3]::text[], ARRAY[$4]::double precision[], ARRAY[$5]::double precision[], $6) $function$

CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, scalex double precision, scaley double precision, gridx double precision DEFAULT NULL::double precision, gridy double precision DEFAULT NULL::double precision, pixeltype text[] DEFAULT ARRAY['8BUI'::text], value double precision[] DEFAULT ARRAY[(1)::double precision], nodataval double precision[] DEFAULT ARRAY[(0)::double precision], skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, $2, $3, NULL, NULL, $6, $7, $8, NULL, NULL, $4, $5, $9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, scalex double precision, scaley double precision, pixeltype text[], value double precision[] DEFAULT ARRAY[(1)::double precision], nodataval double precision[] DEFAULT ARRAY[(0)::double precision], upperleftx double precision DEFAULT NULL::double precision, upperlefty double precision DEFAULT NULL::double precision, skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, $2, $3, NULL, NULL, $4, $5, $6, $7, $8, NULL, NULL,	$9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, width integer, height integer, gridx double precision DEFAULT NULL::double precision, gridy double precision DEFAULT NULL::double precision, pixeltype text[] DEFAULT ARRAY['8BUI'::text], value double precision[] DEFAULT ARRAY[(1)::double precision], nodataval double precision[] DEFAULT ARRAY[(0)::double precision], skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, NULL, NULL, $2, $3, $6, $7, $8, NULL, NULL, $4, $5, $9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, width integer, height integer, pixeltype text[], value double precision[] DEFAULT ARRAY[(1)::double precision], nodataval double precision[] DEFAULT ARRAY[(0)::double precision], upperleftx double precision DEFAULT NULL::double precision, upperlefty double precision DEFAULT NULL::double precision, skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, NULL, NULL, $2, $3, $4, $5, $6, $7, $8, NULL, NULL,	$9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, scalex double precision, scaley double precision, gridx double precision, gridy double precision, pixeltype text, value double precision DEFAULT 1, nodataval double precision DEFAULT 0, skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, $2, $3, NULL, NULL, ARRAY[$6]::text[], ARRAY[$7]::double precision[], ARRAY[$8]::double precision[], NULL, NULL, $4, $5, $9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, scalex double precision, scaley double precision, pixeltype text, value double precision DEFAULT 1, nodataval double precision DEFAULT 0, upperleftx double precision DEFAULT NULL::double precision, upperlefty double precision DEFAULT NULL::double precision, skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, $2, $3, NULL, NULL, ARRAY[$4]::text[], ARRAY[$5]::double precision[], ARRAY[$6]::double precision[], $7, $8, NULL, NULL, $9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, width integer, height integer, gridx double precision, gridy double precision, pixeltype text, value double precision DEFAULT 1, nodataval double precision DEFAULT 0, skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, NULL, NULL, $2, $3, ARRAY[$6]::text[], ARRAY[$7]::double precision[], ARRAY[$8]::double precision[], NULL, NULL, $4, $5, $9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, width integer, height integer, pixeltype text, value double precision DEFAULT 1, nodataval double precision DEFAULT 0, upperleftx double precision DEFAULT NULL::double precision, upperlefty double precision DEFAULT NULL::double precision, skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, NULL, NULL, $2, $3, ARRAY[$4]::text[], ARRAY[$5]::double precision[], ARRAY[$6]::double precision[], $7, $8, NULL, NULL,$9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, ref raster, pixeltype text[] DEFAULT ARRAY['8BUI'::text], value double precision[] DEFAULT ARRAY[(1)::double precision], nodataval double precision[] DEFAULT ARRAY[(0)::double precision], touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE plpgsql
 STABLE
AS $function$
	DECLARE
		g geometry;
		g_srid integer;
		ul_x double precision;
		ul_y double precision;
		scale_x double precision;
		scale_y double precision;
		skew_x double precision;
		skew_y double precision;
		sr_id integer;
	BEGIN
		SELECT upperleftx, upperlefty, scalex, scaley, skewx, skewy, srid INTO ul_x, ul_y, scale_x, scale_y, skew_x, skew_y, sr_id FROM ST_Metadata(ref);
		--RAISE NOTICE '%, %, %, %, %, %, %', ul_x, ul_y, scale_x, scale_y, skew_x, skew_y, sr_id;
		-- geometry and raster has different SRID
		g_srid := ST_SRID(geom);
		IF g_srid != sr_id THEN
			RAISE NOTICE 'The geometry''s SRID (%) is not the same as the raster''s SRID (%).  The geometry will be transformed to the raster''s projection', g_srid, sr_id;
			g := ST_Transform(geom, sr_id);
		ELSE
			g := geom;
		END IF;
		RETURN _st_asraster(g, scale_x, scale_y, NULL, NULL, $3, $4, $5, NULL, NULL, ul_x, ul_y, skew_x, skew_y, $6);
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, ref raster, pixeltype text, value double precision DEFAULT 1, nodataval double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_asraster($1, $2, ARRAY[$3]::text[], ARRAY[$4]::double precision[], ARRAY[$5]::double precision[], $6) $function$

CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, scalex double precision, scaley double precision, gridx double precision DEFAULT NULL::double precision, gridy double precision DEFAULT NULL::double precision, pixeltype text[] DEFAULT ARRAY['8BUI'::text], value double precision[] DEFAULT ARRAY[(1)::double precision], nodataval double precision[] DEFAULT ARRAY[(0)::double precision], skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, $2, $3, NULL, NULL, $6, $7, $8, NULL, NULL, $4, $5, $9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, scalex double precision, scaley double precision, pixeltype text[], value double precision[] DEFAULT ARRAY[(1)::double precision], nodataval double precision[] DEFAULT ARRAY[(0)::double precision], upperleftx double precision DEFAULT NULL::double precision, upperlefty double precision DEFAULT NULL::double precision, skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, $2, $3, NULL, NULL, $4, $5, $6, $7, $8, NULL, NULL,	$9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, width integer, height integer, gridx double precision DEFAULT NULL::double precision, gridy double precision DEFAULT NULL::double precision, pixeltype text[] DEFAULT ARRAY['8BUI'::text], value double precision[] DEFAULT ARRAY[(1)::double precision], nodataval double precision[] DEFAULT ARRAY[(0)::double precision], skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, NULL, NULL, $2, $3, $6, $7, $8, NULL, NULL, $4, $5, $9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, width integer, height integer, pixeltype text[], value double precision[] DEFAULT ARRAY[(1)::double precision], nodataval double precision[] DEFAULT ARRAY[(0)::double precision], upperleftx double precision DEFAULT NULL::double precision, upperlefty double precision DEFAULT NULL::double precision, skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, NULL, NULL, $2, $3, $4, $5, $6, $7, $8, NULL, NULL,	$9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, scalex double precision, scaley double precision, gridx double precision, gridy double precision, pixeltype text, value double precision DEFAULT 1, nodataval double precision DEFAULT 0, skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, $2, $3, NULL, NULL, ARRAY[$6]::text[], ARRAY[$7]::double precision[], ARRAY[$8]::double precision[], NULL, NULL, $4, $5, $9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, scalex double precision, scaley double precision, pixeltype text, value double precision DEFAULT 1, nodataval double precision DEFAULT 0, upperleftx double precision DEFAULT NULL::double precision, upperlefty double precision DEFAULT NULL::double precision, skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, $2, $3, NULL, NULL, ARRAY[$4]::text[], ARRAY[$5]::double precision[], ARRAY[$6]::double precision[], $7, $8, NULL, NULL, $9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, width integer, height integer, gridx double precision, gridy double precision, pixeltype text, value double precision DEFAULT 1, nodataval double precision DEFAULT 0, skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, NULL, NULL, $2, $3, ARRAY[$6]::text[], ARRAY[$7]::double precision[], ARRAY[$8]::double precision[], NULL, NULL, $4, $5, $9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, width integer, height integer, pixeltype text, value double precision DEFAULT 1, nodataval double precision DEFAULT 0, upperleftx double precision DEFAULT NULL::double precision, upperlefty double precision DEFAULT NULL::double precision, skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, NULL, NULL, $2, $3, ARRAY[$4]::text[], ARRAY[$5]::double precision[], ARRAY[$6]::double precision[], $7, $8, NULL, NULL,$9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, ref raster, pixeltype text[] DEFAULT ARRAY['8BUI'::text], value double precision[] DEFAULT ARRAY[(1)::double precision], nodataval double precision[] DEFAULT ARRAY[(0)::double precision], touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE plpgsql
 STABLE
AS $function$
	DECLARE
		g geometry;
		g_srid integer;
		ul_x double precision;
		ul_y double precision;
		scale_x double precision;
		scale_y double precision;
		skew_x double precision;
		skew_y double precision;
		sr_id integer;
	BEGIN
		SELECT upperleftx, upperlefty, scalex, scaley, skewx, skewy, srid INTO ul_x, ul_y, scale_x, scale_y, skew_x, skew_y, sr_id FROM ST_Metadata(ref);
		--RAISE NOTICE '%, %, %, %, %, %, %', ul_x, ul_y, scale_x, scale_y, skew_x, skew_y, sr_id;
		-- geometry and raster has different SRID
		g_srid := ST_SRID(geom);
		IF g_srid != sr_id THEN
			RAISE NOTICE 'The geometry''s SRID (%) is not the same as the raster''s SRID (%).  The geometry will be transformed to the raster''s projection', g_srid, sr_id;
			g := ST_Transform(geom, sr_id);
		ELSE
			g := geom;
		END IF;
		RETURN _st_asraster(g, scale_x, scale_y, NULL, NULL, $3, $4, $5, NULL, NULL, ul_x, ul_y, skew_x, skew_y, $6);
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, ref raster, pixeltype text, value double precision DEFAULT 1, nodataval double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_asraster($1, $2, ARRAY[$3]::text[], ARRAY[$4]::double precision[], ARRAY[$5]::double precision[], $6) $function$

CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, scalex double precision, scaley double precision, gridx double precision DEFAULT NULL::double precision, gridy double precision DEFAULT NULL::double precision, pixeltype text[] DEFAULT ARRAY['8BUI'::text], value double precision[] DEFAULT ARRAY[(1)::double precision], nodataval double precision[] DEFAULT ARRAY[(0)::double precision], skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, $2, $3, NULL, NULL, $6, $7, $8, NULL, NULL, $4, $5, $9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, scalex double precision, scaley double precision, pixeltype text[], value double precision[] DEFAULT ARRAY[(1)::double precision], nodataval double precision[] DEFAULT ARRAY[(0)::double precision], upperleftx double precision DEFAULT NULL::double precision, upperlefty double precision DEFAULT NULL::double precision, skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, $2, $3, NULL, NULL, $4, $5, $6, $7, $8, NULL, NULL,	$9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, width integer, height integer, gridx double precision DEFAULT NULL::double precision, gridy double precision DEFAULT NULL::double precision, pixeltype text[] DEFAULT ARRAY['8BUI'::text], value double precision[] DEFAULT ARRAY[(1)::double precision], nodataval double precision[] DEFAULT ARRAY[(0)::double precision], skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, NULL, NULL, $2, $3, $6, $7, $8, NULL, NULL, $4, $5, $9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, width integer, height integer, pixeltype text[], value double precision[] DEFAULT ARRAY[(1)::double precision], nodataval double precision[] DEFAULT ARRAY[(0)::double precision], upperleftx double precision DEFAULT NULL::double precision, upperlefty double precision DEFAULT NULL::double precision, skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, NULL, NULL, $2, $3, $4, $5, $6, $7, $8, NULL, NULL,	$9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, scalex double precision, scaley double precision, gridx double precision, gridy double precision, pixeltype text, value double precision DEFAULT 1, nodataval double precision DEFAULT 0, skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, $2, $3, NULL, NULL, ARRAY[$6]::text[], ARRAY[$7]::double precision[], ARRAY[$8]::double precision[], NULL, NULL, $4, $5, $9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, scalex double precision, scaley double precision, pixeltype text, value double precision DEFAULT 1, nodataval double precision DEFAULT 0, upperleftx double precision DEFAULT NULL::double precision, upperlefty double precision DEFAULT NULL::double precision, skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, $2, $3, NULL, NULL, ARRAY[$4]::text[], ARRAY[$5]::double precision[], ARRAY[$6]::double precision[], $7, $8, NULL, NULL, $9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, width integer, height integer, gridx double precision, gridy double precision, pixeltype text, value double precision DEFAULT 1, nodataval double precision DEFAULT 0, skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, NULL, NULL, $2, $3, ARRAY[$6]::text[], ARRAY[$7]::double precision[], ARRAY[$8]::double precision[], NULL, NULL, $4, $5, $9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, width integer, height integer, pixeltype text, value double precision DEFAULT 1, nodataval double precision DEFAULT 0, upperleftx double precision DEFAULT NULL::double precision, upperlefty double precision DEFAULT NULL::double precision, skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, NULL, NULL, $2, $3, ARRAY[$4]::text[], ARRAY[$5]::double precision[], ARRAY[$6]::double precision[], $7, $8, NULL, NULL,$9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, ref raster, pixeltype text[] DEFAULT ARRAY['8BUI'::text], value double precision[] DEFAULT ARRAY[(1)::double precision], nodataval double precision[] DEFAULT ARRAY[(0)::double precision], touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE plpgsql
 STABLE
AS $function$
	DECLARE
		g geometry;
		g_srid integer;
		ul_x double precision;
		ul_y double precision;
		scale_x double precision;
		scale_y double precision;
		skew_x double precision;
		skew_y double precision;
		sr_id integer;
	BEGIN
		SELECT upperleftx, upperlefty, scalex, scaley, skewx, skewy, srid INTO ul_x, ul_y, scale_x, scale_y, skew_x, skew_y, sr_id FROM ST_Metadata(ref);
		--RAISE NOTICE '%, %, %, %, %, %, %', ul_x, ul_y, scale_x, scale_y, skew_x, skew_y, sr_id;
		-- geometry and raster has different SRID
		g_srid := ST_SRID(geom);
		IF g_srid != sr_id THEN
			RAISE NOTICE 'The geometry''s SRID (%) is not the same as the raster''s SRID (%).  The geometry will be transformed to the raster''s projection', g_srid, sr_id;
			g := ST_Transform(geom, sr_id);
		ELSE
			g := geom;
		END IF;
		RETURN _st_asraster(g, scale_x, scale_y, NULL, NULL, $3, $4, $5, NULL, NULL, ul_x, ul_y, skew_x, skew_y, $6);
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, ref raster, pixeltype text, value double precision DEFAULT 1, nodataval double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_asraster($1, $2, ARRAY[$3]::text[], ARRAY[$4]::double precision[], ARRAY[$5]::double precision[], $6) $function$

CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, scalex double precision, scaley double precision, gridx double precision DEFAULT NULL::double precision, gridy double precision DEFAULT NULL::double precision, pixeltype text[] DEFAULT ARRAY['8BUI'::text], value double precision[] DEFAULT ARRAY[(1)::double precision], nodataval double precision[] DEFAULT ARRAY[(0)::double precision], skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, $2, $3, NULL, NULL, $6, $7, $8, NULL, NULL, $4, $5, $9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, scalex double precision, scaley double precision, pixeltype text[], value double precision[] DEFAULT ARRAY[(1)::double precision], nodataval double precision[] DEFAULT ARRAY[(0)::double precision], upperleftx double precision DEFAULT NULL::double precision, upperlefty double precision DEFAULT NULL::double precision, skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, $2, $3, NULL, NULL, $4, $5, $6, $7, $8, NULL, NULL,	$9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, width integer, height integer, gridx double precision DEFAULT NULL::double precision, gridy double precision DEFAULT NULL::double precision, pixeltype text[] DEFAULT ARRAY['8BUI'::text], value double precision[] DEFAULT ARRAY[(1)::double precision], nodataval double precision[] DEFAULT ARRAY[(0)::double precision], skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, NULL, NULL, $2, $3, $6, $7, $8, NULL, NULL, $4, $5, $9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, width integer, height integer, pixeltype text[], value double precision[] DEFAULT ARRAY[(1)::double precision], nodataval double precision[] DEFAULT ARRAY[(0)::double precision], upperleftx double precision DEFAULT NULL::double precision, upperlefty double precision DEFAULT NULL::double precision, skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, NULL, NULL, $2, $3, $4, $5, $6, $7, $8, NULL, NULL,	$9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, scalex double precision, scaley double precision, gridx double precision, gridy double precision, pixeltype text, value double precision DEFAULT 1, nodataval double precision DEFAULT 0, skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, $2, $3, NULL, NULL, ARRAY[$6]::text[], ARRAY[$7]::double precision[], ARRAY[$8]::double precision[], NULL, NULL, $4, $5, $9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, scalex double precision, scaley double precision, pixeltype text, value double precision DEFAULT 1, nodataval double precision DEFAULT 0, upperleftx double precision DEFAULT NULL::double precision, upperlefty double precision DEFAULT NULL::double precision, skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, $2, $3, NULL, NULL, ARRAY[$4]::text[], ARRAY[$5]::double precision[], ARRAY[$6]::double precision[], $7, $8, NULL, NULL, $9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, width integer, height integer, gridx double precision, gridy double precision, pixeltype text, value double precision DEFAULT 1, nodataval double precision DEFAULT 0, skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, NULL, NULL, $2, $3, ARRAY[$6]::text[], ARRAY[$7]::double precision[], ARRAY[$8]::double precision[], NULL, NULL, $4, $5, $9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, width integer, height integer, pixeltype text, value double precision DEFAULT 1, nodataval double precision DEFAULT 0, upperleftx double precision DEFAULT NULL::double precision, upperlefty double precision DEFAULT NULL::double precision, skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, NULL, NULL, $2, $3, ARRAY[$4]::text[], ARRAY[$5]::double precision[], ARRAY[$6]::double precision[], $7, $8, NULL, NULL,$9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, ref raster, pixeltype text[] DEFAULT ARRAY['8BUI'::text], value double precision[] DEFAULT ARRAY[(1)::double precision], nodataval double precision[] DEFAULT ARRAY[(0)::double precision], touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE plpgsql
 STABLE
AS $function$
	DECLARE
		g geometry;
		g_srid integer;
		ul_x double precision;
		ul_y double precision;
		scale_x double precision;
		scale_y double precision;
		skew_x double precision;
		skew_y double precision;
		sr_id integer;
	BEGIN
		SELECT upperleftx, upperlefty, scalex, scaley, skewx, skewy, srid INTO ul_x, ul_y, scale_x, scale_y, skew_x, skew_y, sr_id FROM ST_Metadata(ref);
		--RAISE NOTICE '%, %, %, %, %, %, %', ul_x, ul_y, scale_x, scale_y, skew_x, skew_y, sr_id;
		-- geometry and raster has different SRID
		g_srid := ST_SRID(geom);
		IF g_srid != sr_id THEN
			RAISE NOTICE 'The geometry''s SRID (%) is not the same as the raster''s SRID (%).  The geometry will be transformed to the raster''s projection', g_srid, sr_id;
			g := ST_Transform(geom, sr_id);
		ELSE
			g := geom;
		END IF;
		RETURN _st_asraster(g, scale_x, scale_y, NULL, NULL, $3, $4, $5, NULL, NULL, ul_x, ul_y, skew_x, skew_y, $6);
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, ref raster, pixeltype text, value double precision DEFAULT 1, nodataval double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_asraster($1, $2, ARRAY[$3]::text[], ARRAY[$4]::double precision[], ARRAY[$5]::double precision[], $6) $function$

CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, scalex double precision, scaley double precision, gridx double precision DEFAULT NULL::double precision, gridy double precision DEFAULT NULL::double precision, pixeltype text[] DEFAULT ARRAY['8BUI'::text], value double precision[] DEFAULT ARRAY[(1)::double precision], nodataval double precision[] DEFAULT ARRAY[(0)::double precision], skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, $2, $3, NULL, NULL, $6, $7, $8, NULL, NULL, $4, $5, $9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, scalex double precision, scaley double precision, pixeltype text[], value double precision[] DEFAULT ARRAY[(1)::double precision], nodataval double precision[] DEFAULT ARRAY[(0)::double precision], upperleftx double precision DEFAULT NULL::double precision, upperlefty double precision DEFAULT NULL::double precision, skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, $2, $3, NULL, NULL, $4, $5, $6, $7, $8, NULL, NULL,	$9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, width integer, height integer, gridx double precision DEFAULT NULL::double precision, gridy double precision DEFAULT NULL::double precision, pixeltype text[] DEFAULT ARRAY['8BUI'::text], value double precision[] DEFAULT ARRAY[(1)::double precision], nodataval double precision[] DEFAULT ARRAY[(0)::double precision], skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, NULL, NULL, $2, $3, $6, $7, $8, NULL, NULL, $4, $5, $9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, width integer, height integer, pixeltype text[], value double precision[] DEFAULT ARRAY[(1)::double precision], nodataval double precision[] DEFAULT ARRAY[(0)::double precision], upperleftx double precision DEFAULT NULL::double precision, upperlefty double precision DEFAULT NULL::double precision, skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, NULL, NULL, $2, $3, $4, $5, $6, $7, $8, NULL, NULL,	$9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, scalex double precision, scaley double precision, gridx double precision, gridy double precision, pixeltype text, value double precision DEFAULT 1, nodataval double precision DEFAULT 0, skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, $2, $3, NULL, NULL, ARRAY[$6]::text[], ARRAY[$7]::double precision[], ARRAY[$8]::double precision[], NULL, NULL, $4, $5, $9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, scalex double precision, scaley double precision, pixeltype text, value double precision DEFAULT 1, nodataval double precision DEFAULT 0, upperleftx double precision DEFAULT NULL::double precision, upperlefty double precision DEFAULT NULL::double precision, skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, $2, $3, NULL, NULL, ARRAY[$4]::text[], ARRAY[$5]::double precision[], ARRAY[$6]::double precision[], $7, $8, NULL, NULL, $9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, width integer, height integer, gridx double precision, gridy double precision, pixeltype text, value double precision DEFAULT 1, nodataval double precision DEFAULT 0, skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, NULL, NULL, $2, $3, ARRAY[$6]::text[], ARRAY[$7]::double precision[], ARRAY[$8]::double precision[], NULL, NULL, $4, $5, $9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, width integer, height integer, pixeltype text, value double precision DEFAULT 1, nodataval double precision DEFAULT 0, upperleftx double precision DEFAULT NULL::double precision, upperlefty double precision DEFAULT NULL::double precision, skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_asraster($1, NULL, NULL, $2, $3, ARRAY[$4]::text[], ARRAY[$5]::double precision[], ARRAY[$6]::double precision[], $7, $8, NULL, NULL,$9, $10, $11) $function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, ref raster, pixeltype text[] DEFAULT ARRAY['8BUI'::text], value double precision[] DEFAULT ARRAY[(1)::double precision], nodataval double precision[] DEFAULT ARRAY[(0)::double precision], touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE plpgsql
 STABLE
AS $function$
	DECLARE
		g geometry;
		g_srid integer;
		ul_x double precision;
		ul_y double precision;
		scale_x double precision;
		scale_y double precision;
		skew_x double precision;
		skew_y double precision;
		sr_id integer;
	BEGIN
		SELECT upperleftx, upperlefty, scalex, scaley, skewx, skewy, srid INTO ul_x, ul_y, scale_x, scale_y, skew_x, skew_y, sr_id FROM ST_Metadata(ref);
		--RAISE NOTICE '%, %, %, %, %, %, %', ul_x, ul_y, scale_x, scale_y, skew_x, skew_y, sr_id;
		-- geometry and raster has different SRID
		g_srid := ST_SRID(geom);
		IF g_srid != sr_id THEN
			RAISE NOTICE 'The geometry''s SRID (%) is not the same as the raster''s SRID (%).  The geometry will be transformed to the raster''s projection', g_srid, sr_id;
			g := ST_Transform(geom, sr_id);
		ELSE
			g := geom;
		END IF;
		RETURN _st_asraster(g, scale_x, scale_y, NULL, NULL, $3, $4, $5, NULL, NULL, ul_x, ul_y, skew_x, skew_y, $6);
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_asraster(geom geometry, ref raster, pixeltype text, value double precision DEFAULT 1, nodataval double precision DEFAULT 0, touched boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_asraster($1, $2, ARRAY[$3]::text[], ARRAY[$4]::double precision[], ARRAY[$5]::double precision[], $6) $function$

CREATE OR REPLACE FUNCTION public.st_assvg(text)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT ST_AsSVG($1::geometry,0,15);  $function$
CREATE OR REPLACE FUNCTION public.st_assvg(geom geometry, rel integer DEFAULT 0, maxdecimaldigits integer DEFAULT 15)
 RETURNS text
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_asSVG$function$
CREATE OR REPLACE FUNCTION public.st_assvg(geog geography, rel integer DEFAULT 0, maxdecimaldigits integer DEFAULT 15)
 RETURNS text
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$geography_as_svg$function$

CREATE OR REPLACE FUNCTION public.st_assvg(text)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT ST_AsSVG($1::geometry,0,15);  $function$
CREATE OR REPLACE FUNCTION public.st_assvg(geom geometry, rel integer DEFAULT 0, maxdecimaldigits integer DEFAULT 15)
 RETURNS text
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_asSVG$function$
CREATE OR REPLACE FUNCTION public.st_assvg(geog geography, rel integer DEFAULT 0, maxdecimaldigits integer DEFAULT 15)
 RETURNS text
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$geography_as_svg$function$

CREATE OR REPLACE FUNCTION public.st_astext(text)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT ST_AsText($1::geometry);  $function$
CREATE OR REPLACE FUNCTION public.st_astext(geometry)
 RETURNS text
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_asText$function$
CREATE OR REPLACE FUNCTION public.st_astext(geography)
 RETURNS text
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_asText$function$

CREATE OR REPLACE FUNCTION public.st_astext(text)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT ST_AsText($1::geometry);  $function$
CREATE OR REPLACE FUNCTION public.st_astext(geometry)
 RETURNS text
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_asText$function$
CREATE OR REPLACE FUNCTION public.st_astext(geography)
 RETURNS text
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_asText$function$

CREATE OR REPLACE FUNCTION public.st_astiff(rast raster, compression text, srid integer DEFAULT NULL::integer)
 RETURNS bytea
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
	DECLARE
		compression2 text;
		c_type text;
		c_level int;
		i int;
		num_bands int;
		options text[];
	BEGIN
		IF rast IS NULL THEN
			RETURN NULL;
		END IF;
		compression2 := trim(both from upper(compression));
		IF length(compression2) > 0 THEN
			-- JPEG
			IF position('JPEG' in compression2) != 0 THEN
				c_type := 'JPEG';
				c_level := substring(compression2 from '[0-9]+$');
				IF c_level IS NOT NULL THEN
					IF c_level > 100 THEN
						c_level := 100;
					ELSEIF c_level < 1 THEN
						c_level := 1;
					END IF;
					options := array_append(options, 'JPEG_QUALITY=' || c_level);
				END IF;
				-- per band pixel type check
				num_bands := st_numbands($1);
				FOR i IN 1..num_bands LOOP
					IF st_bandpixeltype($1, i) != '8BUI' THEN
						RAISE EXCEPTION 'The pixel type of band % in the raster is not 8BUI.  JPEG compression can only be used with the 8BUI pixel type.', i;
					END IF;
				END LOOP;
			-- DEFLATE
			ELSEIF position('DEFLATE' in compression2) != 0 THEN
				c_type := 'DEFLATE';
				c_level := substring(compression2 from '[0-9]+$');
				IF c_level IS NOT NULL THEN
					IF c_level > 9 THEN
						c_level := 9;
					ELSEIF c_level < 1 THEN
						c_level := 1;
					END IF;
					options := array_append(options, 'ZLEVEL=' || c_level);
				END IF;
			ELSE
				c_type := compression2;
				-- CCITT
				IF position('CCITT' in compression2) THEN
					-- per band pixel type check
					num_bands := st_numbands($1);
					FOR i IN 1..num_bands LOOP
						IF st_bandpixeltype($1, i) != '1BB' THEN
							RAISE EXCEPTION 'The pixel type of band % in the raster is not 1BB.  CCITT compression can only be used with the 1BB pixel type.', i;
						END IF;
					END LOOP;
				END IF;
			END IF;
			-- compression type check
			IF ARRAY[c_type] <@ ARRAY['JPEG', 'LZW', 'PACKBITS', 'DEFLATE', 'CCITTRLE', 'CCITTFAX3', 'CCITTFAX4', 'NONE'] THEN
				options := array_append(options, 'COMPRESS=' || c_type);
			ELSE
				RAISE NOTICE 'Unknown compression type: %.  The outputted TIFF will not be COMPRESSED.', c_type;
			END IF;
		END IF;
		RETURN st_astiff($1, options, $3);
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_astiff(rast raster, options text[] DEFAULT NULL::text[], srid integer DEFAULT NULL::integer)
 RETURNS bytea
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
	DECLARE
		i int;
		num_bands int;
		nodata double precision;
		last_nodata double precision;
	BEGIN
		IF rast IS NULL THEN
			RETURN NULL;
		END IF;
		num_bands := st_numbands($1);
		-- TIFF only allows one NODATA value for ALL bands
		FOR i IN 1..num_bands LOOP
			nodata := st_bandnodatavalue($1, i);
			IF last_nodata IS NULL THEN
				last_nodata := nodata;
			ELSEIF nodata != last_nodata THEN
				RAISE NOTICE 'The TIFF format only permits one NODATA value for all bands.  The value used will be the last band with a NODATA value.';
			END IF;
		END LOOP;
		RETURN st_asgdalraster($1, 'GTiff', $2, $3);
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_astiff(rast raster, nbands integer[], compression text, srid integer DEFAULT NULL::integer)
 RETURNS bytea
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT st_astiff(st_band($1, $2), $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_astiff(rast raster, nbands integer[], options text[] DEFAULT NULL::text[], srid integer DEFAULT NULL::integer)
 RETURNS bytea
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT st_astiff(st_band($1, $2), $3, $4) $function$

CREATE OR REPLACE FUNCTION public.st_astiff(rast raster, compression text, srid integer DEFAULT NULL::integer)
 RETURNS bytea
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
	DECLARE
		compression2 text;
		c_type text;
		c_level int;
		i int;
		num_bands int;
		options text[];
	BEGIN
		IF rast IS NULL THEN
			RETURN NULL;
		END IF;
		compression2 := trim(both from upper(compression));
		IF length(compression2) > 0 THEN
			-- JPEG
			IF position('JPEG' in compression2) != 0 THEN
				c_type := 'JPEG';
				c_level := substring(compression2 from '[0-9]+$');
				IF c_level IS NOT NULL THEN
					IF c_level > 100 THEN
						c_level := 100;
					ELSEIF c_level < 1 THEN
						c_level := 1;
					END IF;
					options := array_append(options, 'JPEG_QUALITY=' || c_level);
				END IF;
				-- per band pixel type check
				num_bands := st_numbands($1);
				FOR i IN 1..num_bands LOOP
					IF st_bandpixeltype($1, i) != '8BUI' THEN
						RAISE EXCEPTION 'The pixel type of band % in the raster is not 8BUI.  JPEG compression can only be used with the 8BUI pixel type.', i;
					END IF;
				END LOOP;
			-- DEFLATE
			ELSEIF position('DEFLATE' in compression2) != 0 THEN
				c_type := 'DEFLATE';
				c_level := substring(compression2 from '[0-9]+$');
				IF c_level IS NOT NULL THEN
					IF c_level > 9 THEN
						c_level := 9;
					ELSEIF c_level < 1 THEN
						c_level := 1;
					END IF;
					options := array_append(options, 'ZLEVEL=' || c_level);
				END IF;
			ELSE
				c_type := compression2;
				-- CCITT
				IF position('CCITT' in compression2) THEN
					-- per band pixel type check
					num_bands := st_numbands($1);
					FOR i IN 1..num_bands LOOP
						IF st_bandpixeltype($1, i) != '1BB' THEN
							RAISE EXCEPTION 'The pixel type of band % in the raster is not 1BB.  CCITT compression can only be used with the 1BB pixel type.', i;
						END IF;
					END LOOP;
				END IF;
			END IF;
			-- compression type check
			IF ARRAY[c_type] <@ ARRAY['JPEG', 'LZW', 'PACKBITS', 'DEFLATE', 'CCITTRLE', 'CCITTFAX3', 'CCITTFAX4', 'NONE'] THEN
				options := array_append(options, 'COMPRESS=' || c_type);
			ELSE
				RAISE NOTICE 'Unknown compression type: %.  The outputted TIFF will not be COMPRESSED.', c_type;
			END IF;
		END IF;
		RETURN st_astiff($1, options, $3);
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_astiff(rast raster, options text[] DEFAULT NULL::text[], srid integer DEFAULT NULL::integer)
 RETURNS bytea
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
	DECLARE
		i int;
		num_bands int;
		nodata double precision;
		last_nodata double precision;
	BEGIN
		IF rast IS NULL THEN
			RETURN NULL;
		END IF;
		num_bands := st_numbands($1);
		-- TIFF only allows one NODATA value for ALL bands
		FOR i IN 1..num_bands LOOP
			nodata := st_bandnodatavalue($1, i);
			IF last_nodata IS NULL THEN
				last_nodata := nodata;
			ELSEIF nodata != last_nodata THEN
				RAISE NOTICE 'The TIFF format only permits one NODATA value for all bands.  The value used will be the last band with a NODATA value.';
			END IF;
		END LOOP;
		RETURN st_asgdalraster($1, 'GTiff', $2, $3);
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_astiff(rast raster, nbands integer[], compression text, srid integer DEFAULT NULL::integer)
 RETURNS bytea
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT st_astiff(st_band($1, $2), $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_astiff(rast raster, nbands integer[], options text[] DEFAULT NULL::text[], srid integer DEFAULT NULL::integer)
 RETURNS bytea
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT st_astiff(st_band($1, $2), $3, $4) $function$

CREATE OR REPLACE FUNCTION public.st_astiff(rast raster, compression text, srid integer DEFAULT NULL::integer)
 RETURNS bytea
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
	DECLARE
		compression2 text;
		c_type text;
		c_level int;
		i int;
		num_bands int;
		options text[];
	BEGIN
		IF rast IS NULL THEN
			RETURN NULL;
		END IF;
		compression2 := trim(both from upper(compression));
		IF length(compression2) > 0 THEN
			-- JPEG
			IF position('JPEG' in compression2) != 0 THEN
				c_type := 'JPEG';
				c_level := substring(compression2 from '[0-9]+$');
				IF c_level IS NOT NULL THEN
					IF c_level > 100 THEN
						c_level := 100;
					ELSEIF c_level < 1 THEN
						c_level := 1;
					END IF;
					options := array_append(options, 'JPEG_QUALITY=' || c_level);
				END IF;
				-- per band pixel type check
				num_bands := st_numbands($1);
				FOR i IN 1..num_bands LOOP
					IF st_bandpixeltype($1, i) != '8BUI' THEN
						RAISE EXCEPTION 'The pixel type of band % in the raster is not 8BUI.  JPEG compression can only be used with the 8BUI pixel type.', i;
					END IF;
				END LOOP;
			-- DEFLATE
			ELSEIF position('DEFLATE' in compression2) != 0 THEN
				c_type := 'DEFLATE';
				c_level := substring(compression2 from '[0-9]+$');
				IF c_level IS NOT NULL THEN
					IF c_level > 9 THEN
						c_level := 9;
					ELSEIF c_level < 1 THEN
						c_level := 1;
					END IF;
					options := array_append(options, 'ZLEVEL=' || c_level);
				END IF;
			ELSE
				c_type := compression2;
				-- CCITT
				IF position('CCITT' in compression2) THEN
					-- per band pixel type check
					num_bands := st_numbands($1);
					FOR i IN 1..num_bands LOOP
						IF st_bandpixeltype($1, i) != '1BB' THEN
							RAISE EXCEPTION 'The pixel type of band % in the raster is not 1BB.  CCITT compression can only be used with the 1BB pixel type.', i;
						END IF;
					END LOOP;
				END IF;
			END IF;
			-- compression type check
			IF ARRAY[c_type] <@ ARRAY['JPEG', 'LZW', 'PACKBITS', 'DEFLATE', 'CCITTRLE', 'CCITTFAX3', 'CCITTFAX4', 'NONE'] THEN
				options := array_append(options, 'COMPRESS=' || c_type);
			ELSE
				RAISE NOTICE 'Unknown compression type: %.  The outputted TIFF will not be COMPRESSED.', c_type;
			END IF;
		END IF;
		RETURN st_astiff($1, options, $3);
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_astiff(rast raster, options text[] DEFAULT NULL::text[], srid integer DEFAULT NULL::integer)
 RETURNS bytea
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
	DECLARE
		i int;
		num_bands int;
		nodata double precision;
		last_nodata double precision;
	BEGIN
		IF rast IS NULL THEN
			RETURN NULL;
		END IF;
		num_bands := st_numbands($1);
		-- TIFF only allows one NODATA value for ALL bands
		FOR i IN 1..num_bands LOOP
			nodata := st_bandnodatavalue($1, i);
			IF last_nodata IS NULL THEN
				last_nodata := nodata;
			ELSEIF nodata != last_nodata THEN
				RAISE NOTICE 'The TIFF format only permits one NODATA value for all bands.  The value used will be the last band with a NODATA value.';
			END IF;
		END LOOP;
		RETURN st_asgdalraster($1, 'GTiff', $2, $3);
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_astiff(rast raster, nbands integer[], compression text, srid integer DEFAULT NULL::integer)
 RETURNS bytea
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT st_astiff(st_band($1, $2), $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_astiff(rast raster, nbands integer[], options text[] DEFAULT NULL::text[], srid integer DEFAULT NULL::integer)
 RETURNS bytea
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT st_astiff(st_band($1, $2), $3, $4) $function$

CREATE OR REPLACE FUNCTION public.st_astwkb(geom geometry, prec integer DEFAULT NULL::integer, prec_z integer DEFAULT NULL::integer, prec_m integer DEFAULT NULL::integer, with_sizes boolean DEFAULT NULL::boolean, with_boxes boolean DEFAULT NULL::boolean)
 RETURNS bytea
 LANGUAGE c
 IMMUTABLE
AS '$libdir/postgis-2.2', $function$TWKBFromLWGEOM$function$
CREATE OR REPLACE FUNCTION public.st_astwkb(geom geometry[], ids bigint[], prec integer DEFAULT NULL::integer, prec_z integer DEFAULT NULL::integer, prec_m integer DEFAULT NULL::integer, with_sizes boolean DEFAULT NULL::boolean, with_boxes boolean DEFAULT NULL::boolean)
 RETURNS bytea
 LANGUAGE c
 IMMUTABLE
AS '$libdir/postgis-2.2', $function$TWKBFromLWGEOMArray$function$

CREATE OR REPLACE FUNCTION public.st_azimuth(geom1 geometry, geom2 geometry)
 RETURNS double precision
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_azimuth$function$
CREATE OR REPLACE FUNCTION public.st_azimuth(geog1 geography, geog2 geography)
 RETURNS double precision
 LANGUAGE c
 IMMUTABLE STRICT COST 100
AS '$libdir/postgis-2.2', $function$geography_azimuth$function$

CREATE OR REPLACE FUNCTION public.st_band(rast raster, nband integer)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT st_band($1, ARRAY[$2]) $function$
CREATE OR REPLACE FUNCTION public.st_band(rast raster, nbands integer[] DEFAULT ARRAY[1])
 RETURNS raster
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/rtpostgis-2.2', $function$RASTER_band$function$
CREATE OR REPLACE FUNCTION public.st_band(rast raster, nbands text, delimiter character DEFAULT ','::bpchar)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT st_band($1, regexp_split_to_array(regexp_replace($2, '[[:space:]]', '', 'g'), E'\\' || array_to_string(regexp_split_to_array($3, ''), E'\\'))::int[]) $function$

CREATE OR REPLACE FUNCTION public.st_band(rast raster, nband integer)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT st_band($1, ARRAY[$2]) $function$
CREATE OR REPLACE FUNCTION public.st_band(rast raster, nbands integer[] DEFAULT ARRAY[1])
 RETURNS raster
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/rtpostgis-2.2', $function$RASTER_band$function$
CREATE OR REPLACE FUNCTION public.st_band(rast raster, nbands text, delimiter character DEFAULT ','::bpchar)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT st_band($1, regexp_split_to_array(regexp_replace($2, '[[:space:]]', '', 'g'), E'\\' || array_to_string(regexp_split_to_array($3, ''), E'\\'))::int[]) $function$

CREATE OR REPLACE FUNCTION public.st_bandisnodata(rast raster, forcechecking boolean)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT st_bandisnodata($1, 1, $2) $function$
CREATE OR REPLACE FUNCTION public.st_bandisnodata(rast raster, band integer DEFAULT 1, forcechecking boolean DEFAULT false)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/rtpostgis-2.2', $function$RASTER_bandIsNoData$function$

CREATE OR REPLACE FUNCTION public.st_bandmetadata(rast raster, band integer DEFAULT 1, OUT pixeltype text, OUT nodatavalue double precision, OUT isoutdb boolean, OUT path text)
 RETURNS record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT pixeltype, nodatavalue, isoutdb, path FROM st_bandmetadata($1, ARRAY[$2]::int[]) LIMIT 1 $function$
CREATE OR REPLACE FUNCTION public.st_bandmetadata(rast raster, band integer[], OUT bandnum integer, OUT pixeltype text, OUT nodatavalue double precision, OUT isoutdb boolean, OUT path text)
 RETURNS record
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/rtpostgis-2.2', $function$RASTER_bandmetadata$function$

CREATE OR REPLACE FUNCTION public.st_buffer(text, double precision)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT ST_Buffer($1::geometry, $2);  $function$
CREATE OR REPLACE FUNCTION public.st_buffer(geometry, double precision)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT COST 100
AS '$libdir/postgis-2.2', $function$buffer$function$
CREATE OR REPLACE FUNCTION public.st_buffer(geography, double precision)
 RETURNS geography
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT geography(ST_Transform(ST_Buffer(ST_Transform(geometry($1), _ST_BestSRID($1)), $2), 4326))$function$
CREATE OR REPLACE FUNCTION public.st_buffer(geometry, double precision, integer)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _ST_Buffer($1, $2,
		CAST('quad_segs='||CAST($3 AS text) as cstring))
	   $function$
CREATE OR REPLACE FUNCTION public.st_buffer(geometry, double precision, text)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _ST_Buffer($1, $2,
		CAST( regexp_replace($3, '^[0123456789]+$',
			'quad_segs='||$3) AS cstring)
		)
	   $function$

CREATE OR REPLACE FUNCTION public.st_buffer(text, double precision)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT ST_Buffer($1::geometry, $2);  $function$
CREATE OR REPLACE FUNCTION public.st_buffer(geometry, double precision)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT COST 100
AS '$libdir/postgis-2.2', $function$buffer$function$
CREATE OR REPLACE FUNCTION public.st_buffer(geography, double precision)
 RETURNS geography
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT geography(ST_Transform(ST_Buffer(ST_Transform(geometry($1), _ST_BestSRID($1)), $2), 4326))$function$
CREATE OR REPLACE FUNCTION public.st_buffer(geometry, double precision, integer)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _ST_Buffer($1, $2,
		CAST('quad_segs='||CAST($3 AS text) as cstring))
	   $function$
CREATE OR REPLACE FUNCTION public.st_buffer(geometry, double precision, text)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _ST_Buffer($1, $2,
		CAST( regexp_replace($3, '^[0123456789]+$',
			'quad_segs='||$3) AS cstring)
		)
	   $function$

CREATE OR REPLACE FUNCTION public.st_buffer(text, double precision)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT ST_Buffer($1::geometry, $2);  $function$
CREATE OR REPLACE FUNCTION public.st_buffer(geometry, double precision)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT COST 100
AS '$libdir/postgis-2.2', $function$buffer$function$
CREATE OR REPLACE FUNCTION public.st_buffer(geography, double precision)
 RETURNS geography
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT geography(ST_Transform(ST_Buffer(ST_Transform(geometry($1), _ST_BestSRID($1)), $2), 4326))$function$
CREATE OR REPLACE FUNCTION public.st_buffer(geometry, double precision, integer)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _ST_Buffer($1, $2,
		CAST('quad_segs='||CAST($3 AS text) as cstring))
	   $function$
CREATE OR REPLACE FUNCTION public.st_buffer(geometry, double precision, text)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _ST_Buffer($1, $2,
		CAST( regexp_replace($3, '^[0123456789]+$',
			'quad_segs='||$3) AS cstring)
		)
	   $function$

CREATE OR REPLACE FUNCTION public.st_buffer(text, double precision)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT ST_Buffer($1::geometry, $2);  $function$
CREATE OR REPLACE FUNCTION public.st_buffer(geometry, double precision)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT COST 100
AS '$libdir/postgis-2.2', $function$buffer$function$
CREATE OR REPLACE FUNCTION public.st_buffer(geography, double precision)
 RETURNS geography
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT geography(ST_Transform(ST_Buffer(ST_Transform(geometry($1), _ST_BestSRID($1)), $2), 4326))$function$
CREATE OR REPLACE FUNCTION public.st_buffer(geometry, double precision, integer)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _ST_Buffer($1, $2,
		CAST('quad_segs='||CAST($3 AS text) as cstring))
	   $function$
CREATE OR REPLACE FUNCTION public.st_buffer(geometry, double precision, text)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _ST_Buffer($1, $2,
		CAST( regexp_replace($3, '^[0123456789]+$',
			'quad_segs='||$3) AS cstring)
		)
	   $function$

CREATE OR REPLACE FUNCTION public.st_clip(rast raster, nband integer[], geom geometry, nodataval double precision[] DEFAULT NULL::double precision[], crop boolean DEFAULT true)
 RETURNS raster
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
	BEGIN
		-- short-cut if geometry's extent fully contains raster's extent
		IF (nodataval IS NULL OR array_length(nodataval, 1) < 1) AND geom ~ ST_Envelope(rast) THEN
			RETURN rast;
		END IF;
		RETURN _ST_Clip($1, $2, $3, $4, $5);
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_clip(rast raster, nband integer, geom geometry, nodataval double precision, crop boolean DEFAULT true)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT ST_Clip($1, ARRAY[$2]::integer[], $3, ARRAY[$4]::double precision[], $5) $function$
CREATE OR REPLACE FUNCTION public.st_clip(rast raster, nband integer, geom geometry, crop boolean)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT ST_Clip($1, ARRAY[$2]::integer[], $3, null::double precision[], $4) $function$
CREATE OR REPLACE FUNCTION public.st_clip(rast raster, geom geometry, nodataval double precision[] DEFAULT NULL::double precision[], crop boolean DEFAULT true)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT ST_Clip($1, NULL, $2, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_clip(rast raster, geom geometry, nodataval double precision, crop boolean DEFAULT true)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT ST_Clip($1, NULL, $2, ARRAY[$3]::double precision[], $4) $function$
CREATE OR REPLACE FUNCTION public.st_clip(rast raster, geom geometry, crop boolean)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT ST_Clip($1, NULL, $2, null::double precision[], $3) $function$

CREATE OR REPLACE FUNCTION public.st_clip(rast raster, nband integer[], geom geometry, nodataval double precision[] DEFAULT NULL::double precision[], crop boolean DEFAULT true)
 RETURNS raster
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
	BEGIN
		-- short-cut if geometry's extent fully contains raster's extent
		IF (nodataval IS NULL OR array_length(nodataval, 1) < 1) AND geom ~ ST_Envelope(rast) THEN
			RETURN rast;
		END IF;
		RETURN _ST_Clip($1, $2, $3, $4, $5);
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_clip(rast raster, nband integer, geom geometry, nodataval double precision, crop boolean DEFAULT true)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT ST_Clip($1, ARRAY[$2]::integer[], $3, ARRAY[$4]::double precision[], $5) $function$
CREATE OR REPLACE FUNCTION public.st_clip(rast raster, nband integer, geom geometry, crop boolean)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT ST_Clip($1, ARRAY[$2]::integer[], $3, null::double precision[], $4) $function$
CREATE OR REPLACE FUNCTION public.st_clip(rast raster, geom geometry, nodataval double precision[] DEFAULT NULL::double precision[], crop boolean DEFAULT true)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT ST_Clip($1, NULL, $2, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_clip(rast raster, geom geometry, nodataval double precision, crop boolean DEFAULT true)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT ST_Clip($1, NULL, $2, ARRAY[$3]::double precision[], $4) $function$
CREATE OR REPLACE FUNCTION public.st_clip(rast raster, geom geometry, crop boolean)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT ST_Clip($1, NULL, $2, null::double precision[], $3) $function$

CREATE OR REPLACE FUNCTION public.st_clip(rast raster, nband integer[], geom geometry, nodataval double precision[] DEFAULT NULL::double precision[], crop boolean DEFAULT true)
 RETURNS raster
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
	BEGIN
		-- short-cut if geometry's extent fully contains raster's extent
		IF (nodataval IS NULL OR array_length(nodataval, 1) < 1) AND geom ~ ST_Envelope(rast) THEN
			RETURN rast;
		END IF;
		RETURN _ST_Clip($1, $2, $3, $4, $5);
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_clip(rast raster, nband integer, geom geometry, nodataval double precision, crop boolean DEFAULT true)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT ST_Clip($1, ARRAY[$2]::integer[], $3, ARRAY[$4]::double precision[], $5) $function$
CREATE OR REPLACE FUNCTION public.st_clip(rast raster, nband integer, geom geometry, crop boolean)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT ST_Clip($1, ARRAY[$2]::integer[], $3, null::double precision[], $4) $function$
CREATE OR REPLACE FUNCTION public.st_clip(rast raster, geom geometry, nodataval double precision[] DEFAULT NULL::double precision[], crop boolean DEFAULT true)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT ST_Clip($1, NULL, $2, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_clip(rast raster, geom geometry, nodataval double precision, crop boolean DEFAULT true)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT ST_Clip($1, NULL, $2, ARRAY[$3]::double precision[], $4) $function$
CREATE OR REPLACE FUNCTION public.st_clip(rast raster, geom geometry, crop boolean)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT ST_Clip($1, NULL, $2, null::double precision[], $3) $function$

CREATE OR REPLACE FUNCTION public.st_clip(rast raster, nband integer[], geom geometry, nodataval double precision[] DEFAULT NULL::double precision[], crop boolean DEFAULT true)
 RETURNS raster
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
	BEGIN
		-- short-cut if geometry's extent fully contains raster's extent
		IF (nodataval IS NULL OR array_length(nodataval, 1) < 1) AND geom ~ ST_Envelope(rast) THEN
			RETURN rast;
		END IF;
		RETURN _ST_Clip($1, $2, $3, $4, $5);
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_clip(rast raster, nband integer, geom geometry, nodataval double precision, crop boolean DEFAULT true)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT ST_Clip($1, ARRAY[$2]::integer[], $3, ARRAY[$4]::double precision[], $5) $function$
CREATE OR REPLACE FUNCTION public.st_clip(rast raster, nband integer, geom geometry, crop boolean)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT ST_Clip($1, ARRAY[$2]::integer[], $3, null::double precision[], $4) $function$
CREATE OR REPLACE FUNCTION public.st_clip(rast raster, geom geometry, nodataval double precision[] DEFAULT NULL::double precision[], crop boolean DEFAULT true)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT ST_Clip($1, NULL, $2, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_clip(rast raster, geom geometry, nodataval double precision, crop boolean DEFAULT true)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT ST_Clip($1, NULL, $2, ARRAY[$3]::double precision[], $4) $function$
CREATE OR REPLACE FUNCTION public.st_clip(rast raster, geom geometry, crop boolean)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT ST_Clip($1, NULL, $2, null::double precision[], $3) $function$

CREATE OR REPLACE FUNCTION public.st_clip(rast raster, nband integer[], geom geometry, nodataval double precision[] DEFAULT NULL::double precision[], crop boolean DEFAULT true)
 RETURNS raster
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
	BEGIN
		-- short-cut if geometry's extent fully contains raster's extent
		IF (nodataval IS NULL OR array_length(nodataval, 1) < 1) AND geom ~ ST_Envelope(rast) THEN
			RETURN rast;
		END IF;
		RETURN _ST_Clip($1, $2, $3, $4, $5);
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_clip(rast raster, nband integer, geom geometry, nodataval double precision, crop boolean DEFAULT true)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT ST_Clip($1, ARRAY[$2]::integer[], $3, ARRAY[$4]::double precision[], $5) $function$
CREATE OR REPLACE FUNCTION public.st_clip(rast raster, nband integer, geom geometry, crop boolean)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT ST_Clip($1, ARRAY[$2]::integer[], $3, null::double precision[], $4) $function$
CREATE OR REPLACE FUNCTION public.st_clip(rast raster, geom geometry, nodataval double precision[] DEFAULT NULL::double precision[], crop boolean DEFAULT true)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT ST_Clip($1, NULL, $2, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_clip(rast raster, geom geometry, nodataval double precision, crop boolean DEFAULT true)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT ST_Clip($1, NULL, $2, ARRAY[$3]::double precision[], $4) $function$
CREATE OR REPLACE FUNCTION public.st_clip(rast raster, geom geometry, crop boolean)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT ST_Clip($1, NULL, $2, null::double precision[], $3) $function$

CREATE OR REPLACE FUNCTION public.st_clusterintersecting(geometry[])
 RETURNS geometry[]
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$clusterintersecting_garray$function$

CREATE OR REPLACE FUNCTION public.st_clusterwithin(geometry[], double precision)
 RETURNS geometry[]
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$cluster_within_distance_garray$function$

CREATE OR REPLACE FUNCTION public.st_collect(geometry[])
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_collect_garray$function$
CREATE OR REPLACE FUNCTION public.st_collect(geom1 geometry, geom2 geometry)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE
AS '$libdir/postgis-2.2', $function$LWGEOM_collect$function$

CREATE OR REPLACE FUNCTION public.st_collect(geometry[])
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_collect_garray$function$
CREATE OR REPLACE FUNCTION public.st_collect(geom1 geometry, geom2 geometry)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE
AS '$libdir/postgis-2.2', $function$LWGEOM_collect$function$

CREATE OR REPLACE FUNCTION public.st_colormap(rast raster, colormap text, method text DEFAULT 'INTERPOLATE'::text)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT ST_ColorMap($1, 1, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_colormap(rast raster, nband integer DEFAULT 1, colormap text DEFAULT 'grayscale'::text, method text DEFAULT 'INTERPOLATE'::text)
 RETURNS raster
 LANGUAGE plpgsql
 IMMUTABLE STRICT
AS $function$
	DECLARE
		_ismap boolean;
		_colormap text;
		_element text[];
	BEGIN
		_ismap := TRUE;
		-- clean colormap to see what it is
		_colormap := split_part(colormap, E'\n', 1);
		_colormap := regexp_replace(_colormap, E':+', ' ', 'g');
		_colormap := regexp_replace(_colormap, E',+', ' ', 'g');
		_colormap := regexp_replace(_colormap, E'\\t+', ' ', 'g');
		_colormap := regexp_replace(_colormap, E' +', ' ', 'g');
		_element := regexp_split_to_array(_colormap, ' ');
		-- treat as colormap
		IF (array_length(_element, 1) > 1) THEN
			_colormap := colormap;
		-- treat as keyword
		ELSE
			method := 'INTERPOLATE';
			CASE lower(trim(both from _colormap))
				WHEN 'grayscale', 'greyscale' THEN
					_colormap := '
100%   0
  0% 254
  nv 255 
					';
				WHEN 'pseudocolor' THEN
					_colormap := '
100% 255   0   0 255
 50%   0 255   0 255
  0%   0   0 255 255
  nv   0   0   0   0
					';
				WHEN 'fire' THEN
					_colormap := '
  100% 243 255 221 255
93.75% 242 255 178 255
 87.5% 255 255 135 255
81.25% 255 228  96 255
   75% 255 187  53 255
68.75% 255 131   7 255
 62.5% 255  84   0 255
56.25% 255  42   0 255
   50% 255   0   0 255
43.75% 255  42   0 255
 37.5% 224  74   0 255
31.25% 183  91   0 255
   25% 140  93   0 255
18.75%  99  82   0 255
 12.5%  58  58   1 255
 6.25%  12  15   0 255
    0%   0   0   0 255
    nv   0   0   0   0
					';
				WHEN 'bluered' THEN
					_colormap := '
100.00% 165   0  33 255
 94.12% 216  21  47 255
 88.24% 247  39  53 255
 82.35% 255  61  61 255
 76.47% 255 120  86 255
 70.59% 255 172 117 255
 64.71% 255 214 153 255
 58.82% 255 241 188 255
 52.94% 255 255 234 255
 47.06% 234 255 255 255
 41.18% 188 249 255 255
 35.29% 153 234 255 255
 29.41% 117 211 255 255
 23.53%  86 176 255 255
 17.65%  61 135 255 255
 11.76%  40  87 255 255
  5.88%  24  28 247 255
  0.00%  36   0 216 255
     nv   0   0   0   0
					';
				ELSE
					RAISE EXCEPTION 'Unknown colormap keyword: %', colormap;
			END CASE;
		END IF;
		RETURN _st_colormap($1, $2, _colormap, $4);
	END;
	$function$

CREATE OR REPLACE FUNCTION public.st_combine_bbox(box3d, geometry)
 RETURNS box3d
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _postgis_deprecate('ST_Combine_BBox', 'ST_CombineBbox', '2.2.0');
    SELECT ST_CombineBbox($1,$2);
  $function$
CREATE OR REPLACE FUNCTION public.st_combine_bbox(box2d, geometry)
 RETURNS box2d
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _postgis_deprecate('ST_Combine_BBox', 'ST_CombineBbox', '2.2.0');
    SELECT ST_CombineBbox($1,$2);
  $function$

CREATE OR REPLACE FUNCTION public.st_combinebbox(box3d, geometry)
 RETURNS box3d
 LANGUAGE c
 IMMUTABLE
AS '$libdir/postgis-2.2', $function$BOX3D_combine$function$
CREATE OR REPLACE FUNCTION public.st_combinebbox(box2d, geometry)
 RETURNS box2d
 LANGUAGE c
 IMMUTABLE
AS '$libdir/postgis-2.2', $function$BOX2D_combine$function$

CREATE OR REPLACE FUNCTION public.st_contains(geom1 geometry, geom2 geometry)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$SELECT $1 ~ $2 AND _ST_Contains($1,$2)$function$
CREATE OR REPLACE FUNCTION public.st_contains(rast1 raster, rast2 raster)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT st_contains($1, NULL::integer, $2, NULL::integer) $function$
CREATE OR REPLACE FUNCTION public.st_contains(rast1 raster, nband1 integer, rast2 raster, nband2 integer)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT $1 && $3 AND CASE WHEN $2 IS NULL OR $4 IS NULL THEN _st_contains(st_convexhull($1), st_convexhull($3)) ELSE _st_contains($1, $2, $3, $4) END $function$

CREATE OR REPLACE FUNCTION public.st_contains(geom1 geometry, geom2 geometry)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$SELECT $1 ~ $2 AND _ST_Contains($1,$2)$function$
CREATE OR REPLACE FUNCTION public.st_contains(rast1 raster, rast2 raster)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT st_contains($1, NULL::integer, $2, NULL::integer) $function$
CREATE OR REPLACE FUNCTION public.st_contains(rast1 raster, nband1 integer, rast2 raster, nband2 integer)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT $1 && $3 AND CASE WHEN $2 IS NULL OR $4 IS NULL THEN _st_contains(st_convexhull($1), st_convexhull($3)) ELSE _st_contains($1, $2, $3, $4) END $function$

CREATE OR REPLACE FUNCTION public.st_containsproperly(geom1 geometry, geom2 geometry)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$SELECT $1 ~ $2 AND _ST_ContainsProperly($1,$2)$function$
CREATE OR REPLACE FUNCTION public.st_containsproperly(rast1 raster, rast2 raster)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT st_containsproperly($1, NULL::integer, $2, NULL::integer) $function$
CREATE OR REPLACE FUNCTION public.st_containsproperly(rast1 raster, nband1 integer, rast2 raster, nband2 integer)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT $1 && $3 AND CASE WHEN $2 IS NULL OR $4 IS NULL THEN _st_containsproperly(st_convexhull($1), st_convexhull($3)) ELSE _st_containsproperly($1, $2, $3, $4) END $function$

CREATE OR REPLACE FUNCTION public.st_containsproperly(geom1 geometry, geom2 geometry)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$SELECT $1 ~ $2 AND _ST_ContainsProperly($1,$2)$function$
CREATE OR REPLACE FUNCTION public.st_containsproperly(rast1 raster, rast2 raster)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT st_containsproperly($1, NULL::integer, $2, NULL::integer) $function$
CREATE OR REPLACE FUNCTION public.st_containsproperly(rast1 raster, nband1 integer, rast2 raster, nband2 integer)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT $1 && $3 AND CASE WHEN $2 IS NULL OR $4 IS NULL THEN _st_containsproperly(st_convexhull($1), st_convexhull($3)) ELSE _st_containsproperly($1, $2, $3, $4) END $function$

CREATE OR REPLACE FUNCTION public.st_convexhull(geometry)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT COST 100
AS '$libdir/postgis-2.2', $function$convexhull$function$
CREATE OR REPLACE FUNCTION public.st_convexhull(raster)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT COST 300
AS '$libdir/rtpostgis-2.2', $function$RASTER_convex_hull$function$

CREATE OR REPLACE FUNCTION public.st_count(rast raster, exclude_nodata_value boolean)
 RETURNS bigint
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_count($1, 1, $2, 1) $function$
CREATE OR REPLACE FUNCTION public.st_count(rastertable text, rastercolumn text, exclude_nodata_value boolean)
 RETURNS bigint
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_count($1, $2, 1, $3, 1) $function$
CREATE OR REPLACE FUNCTION public.st_count(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true)
 RETURNS bigint
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_count($1, $2, $3, 1) $function$
CREATE OR REPLACE FUNCTION public.st_count(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true)
 RETURNS bigint
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_count($1, $2, $3, $4, 1) $function$

CREATE OR REPLACE FUNCTION public.st_count(rast raster, exclude_nodata_value boolean)
 RETURNS bigint
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_count($1, 1, $2, 1) $function$
CREATE OR REPLACE FUNCTION public.st_count(rastertable text, rastercolumn text, exclude_nodata_value boolean)
 RETURNS bigint
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_count($1, $2, 1, $3, 1) $function$
CREATE OR REPLACE FUNCTION public.st_count(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true)
 RETURNS bigint
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_count($1, $2, $3, 1) $function$
CREATE OR REPLACE FUNCTION public.st_count(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true)
 RETURNS bigint
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_count($1, $2, $3, $4, 1) $function$

CREATE OR REPLACE FUNCTION public.st_count(rast raster, exclude_nodata_value boolean)
 RETURNS bigint
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_count($1, 1, $2, 1) $function$
CREATE OR REPLACE FUNCTION public.st_count(rastertable text, rastercolumn text, exclude_nodata_value boolean)
 RETURNS bigint
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_count($1, $2, 1, $3, 1) $function$
CREATE OR REPLACE FUNCTION public.st_count(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true)
 RETURNS bigint
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_count($1, $2, $3, 1) $function$
CREATE OR REPLACE FUNCTION public.st_count(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true)
 RETURNS bigint
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_count($1, $2, $3, $4, 1) $function$

CREATE OR REPLACE FUNCTION public.st_coveredby(text, text)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT ST_CoveredBy($1::geometry, $2::geometry);  $function$
CREATE OR REPLACE FUNCTION public.st_coveredby(geom1 geometry, geom2 geometry)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$SELECT $1 @ $2 AND _ST_CoveredBy($1,$2)$function$
CREATE OR REPLACE FUNCTION public.st_coveredby(geography, geography)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$SELECT $1 && $2 AND _ST_Covers($2, $1)$function$
CREATE OR REPLACE FUNCTION public.st_coveredby(rast1 raster, rast2 raster)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT st_coveredby($1, NULL::integer, $2, NULL::integer) $function$
CREATE OR REPLACE FUNCTION public.st_coveredby(rast1 raster, nband1 integer, rast2 raster, nband2 integer)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT $1 && $3 AND CASE WHEN $2 IS NULL OR $4 IS NULL THEN _st_coveredby(st_convexhull($1), st_convexhull($3)) ELSE _st_coveredby($1, $2, $3, $4) END $function$

CREATE OR REPLACE FUNCTION public.st_coveredby(text, text)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT ST_CoveredBy($1::geometry, $2::geometry);  $function$
CREATE OR REPLACE FUNCTION public.st_coveredby(geom1 geometry, geom2 geometry)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$SELECT $1 @ $2 AND _ST_CoveredBy($1,$2)$function$
CREATE OR REPLACE FUNCTION public.st_coveredby(geography, geography)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$SELECT $1 && $2 AND _ST_Covers($2, $1)$function$
CREATE OR REPLACE FUNCTION public.st_coveredby(rast1 raster, rast2 raster)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT st_coveredby($1, NULL::integer, $2, NULL::integer) $function$
CREATE OR REPLACE FUNCTION public.st_coveredby(rast1 raster, nband1 integer, rast2 raster, nband2 integer)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT $1 && $3 AND CASE WHEN $2 IS NULL OR $4 IS NULL THEN _st_coveredby(st_convexhull($1), st_convexhull($3)) ELSE _st_coveredby($1, $2, $3, $4) END $function$

CREATE OR REPLACE FUNCTION public.st_coveredby(text, text)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT ST_CoveredBy($1::geometry, $2::geometry);  $function$
CREATE OR REPLACE FUNCTION public.st_coveredby(geom1 geometry, geom2 geometry)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$SELECT $1 @ $2 AND _ST_CoveredBy($1,$2)$function$
CREATE OR REPLACE FUNCTION public.st_coveredby(geography, geography)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$SELECT $1 && $2 AND _ST_Covers($2, $1)$function$
CREATE OR REPLACE FUNCTION public.st_coveredby(rast1 raster, rast2 raster)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT st_coveredby($1, NULL::integer, $2, NULL::integer) $function$
CREATE OR REPLACE FUNCTION public.st_coveredby(rast1 raster, nband1 integer, rast2 raster, nband2 integer)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT $1 && $3 AND CASE WHEN $2 IS NULL OR $4 IS NULL THEN _st_coveredby(st_convexhull($1), st_convexhull($3)) ELSE _st_coveredby($1, $2, $3, $4) END $function$

CREATE OR REPLACE FUNCTION public.st_coveredby(text, text)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT ST_CoveredBy($1::geometry, $2::geometry);  $function$
CREATE OR REPLACE FUNCTION public.st_coveredby(geom1 geometry, geom2 geometry)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$SELECT $1 @ $2 AND _ST_CoveredBy($1,$2)$function$
CREATE OR REPLACE FUNCTION public.st_coveredby(geography, geography)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$SELECT $1 && $2 AND _ST_Covers($2, $1)$function$
CREATE OR REPLACE FUNCTION public.st_coveredby(rast1 raster, rast2 raster)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT st_coveredby($1, NULL::integer, $2, NULL::integer) $function$
CREATE OR REPLACE FUNCTION public.st_coveredby(rast1 raster, nband1 integer, rast2 raster, nband2 integer)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT $1 && $3 AND CASE WHEN $2 IS NULL OR $4 IS NULL THEN _st_coveredby(st_convexhull($1), st_convexhull($3)) ELSE _st_coveredby($1, $2, $3, $4) END $function$

CREATE OR REPLACE FUNCTION public.st_covers(text, text)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT ST_Covers($1::geometry, $2::geometry);  $function$
CREATE OR REPLACE FUNCTION public.st_covers(geom1 geometry, geom2 geometry)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$SELECT $1 ~ $2 AND _ST_Covers($1,$2)$function$
CREATE OR REPLACE FUNCTION public.st_covers(geography, geography)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$SELECT $1 && $2 AND _ST_Covers($1, $2)$function$
CREATE OR REPLACE FUNCTION public.st_covers(rast1 raster, rast2 raster)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT st_covers($1, NULL::integer, $2, NULL::integer) $function$
CREATE OR REPLACE FUNCTION public.st_covers(rast1 raster, nband1 integer, rast2 raster, nband2 integer)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT $1 && $3 AND CASE WHEN $2 IS NULL OR $4 IS NULL THEN _st_covers(st_convexhull($1), st_convexhull($3)) ELSE _st_covers($1, $2, $3, $4) END $function$

CREATE OR REPLACE FUNCTION public.st_covers(text, text)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT ST_Covers($1::geometry, $2::geometry);  $function$
CREATE OR REPLACE FUNCTION public.st_covers(geom1 geometry, geom2 geometry)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$SELECT $1 ~ $2 AND _ST_Covers($1,$2)$function$
CREATE OR REPLACE FUNCTION public.st_covers(geography, geography)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$SELECT $1 && $2 AND _ST_Covers($1, $2)$function$
CREATE OR REPLACE FUNCTION public.st_covers(rast1 raster, rast2 raster)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT st_covers($1, NULL::integer, $2, NULL::integer) $function$
CREATE OR REPLACE FUNCTION public.st_covers(rast1 raster, nband1 integer, rast2 raster, nband2 integer)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT $1 && $3 AND CASE WHEN $2 IS NULL OR $4 IS NULL THEN _st_covers(st_convexhull($1), st_convexhull($3)) ELSE _st_covers($1, $2, $3, $4) END $function$

CREATE OR REPLACE FUNCTION public.st_covers(text, text)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT ST_Covers($1::geometry, $2::geometry);  $function$
CREATE OR REPLACE FUNCTION public.st_covers(geom1 geometry, geom2 geometry)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$SELECT $1 ~ $2 AND _ST_Covers($1,$2)$function$
CREATE OR REPLACE FUNCTION public.st_covers(geography, geography)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$SELECT $1 && $2 AND _ST_Covers($1, $2)$function$
CREATE OR REPLACE FUNCTION public.st_covers(rast1 raster, rast2 raster)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT st_covers($1, NULL::integer, $2, NULL::integer) $function$
CREATE OR REPLACE FUNCTION public.st_covers(rast1 raster, nband1 integer, rast2 raster, nband2 integer)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT $1 && $3 AND CASE WHEN $2 IS NULL OR $4 IS NULL THEN _st_covers(st_convexhull($1), st_convexhull($3)) ELSE _st_covers($1, $2, $3, $4) END $function$

CREATE OR REPLACE FUNCTION public.st_covers(text, text)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT ST_Covers($1::geometry, $2::geometry);  $function$
CREATE OR REPLACE FUNCTION public.st_covers(geom1 geometry, geom2 geometry)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$SELECT $1 ~ $2 AND _ST_Covers($1,$2)$function$
CREATE OR REPLACE FUNCTION public.st_covers(geography, geography)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$SELECT $1 && $2 AND _ST_Covers($1, $2)$function$
CREATE OR REPLACE FUNCTION public.st_covers(rast1 raster, rast2 raster)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT st_covers($1, NULL::integer, $2, NULL::integer) $function$
CREATE OR REPLACE FUNCTION public.st_covers(rast1 raster, nband1 integer, rast2 raster, nband2 integer)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT $1 && $3 AND CASE WHEN $2 IS NULL OR $4 IS NULL THEN _st_covers(st_convexhull($1), st_convexhull($3)) ELSE _st_covers($1, $2, $3, $4) END $function$

CREATE OR REPLACE FUNCTION public.st_curvetoline(geometry)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT ST_CurveToLine($1, 32)$function$
CREATE OR REPLACE FUNCTION public.st_curvetoline(geometry, integer)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_curve_segmentize$function$

CREATE OR REPLACE FUNCTION public.st_dfullywithin(geom1 geometry, geom2 geometry, double precision)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$SELECT $1 && ST_Expand($2,$3) AND $2 && ST_Expand($1,$3) AND _ST_DFullyWithin(ST_ConvexHull($1), ST_ConvexHull($2), $3)$function$
CREATE OR REPLACE FUNCTION public.st_dfullywithin(rast1 raster, rast2 raster, distance double precision)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT st_dfullywithin($1, NULL::integer, $2, NULL::integer, $3) $function$
CREATE OR REPLACE FUNCTION public.st_dfullywithin(rast1 raster, nband1 integer, rast2 raster, nband2 integer, distance double precision)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT $1::geometry && ST_Expand(ST_ConvexHull($3), $5) AND $3::geometry && ST_Expand(ST_ConvexHull($1), $5) AND CASE WHEN $2 IS NULL OR $4 IS NULL THEN _st_dfullywithin(st_convexhull($1), st_convexhull($3), $5) ELSE _st_dfullywithin($1, $2, $3, $4, $5) END $function$

CREATE OR REPLACE FUNCTION public.st_dfullywithin(geom1 geometry, geom2 geometry, double precision)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$SELECT $1 && ST_Expand($2,$3) AND $2 && ST_Expand($1,$3) AND _ST_DFullyWithin(ST_ConvexHull($1), ST_ConvexHull($2), $3)$function$
CREATE OR REPLACE FUNCTION public.st_dfullywithin(rast1 raster, rast2 raster, distance double precision)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT st_dfullywithin($1, NULL::integer, $2, NULL::integer, $3) $function$
CREATE OR REPLACE FUNCTION public.st_dfullywithin(rast1 raster, nband1 integer, rast2 raster, nband2 integer, distance double precision)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT $1::geometry && ST_Expand(ST_ConvexHull($3), $5) AND $3::geometry && ST_Expand(ST_ConvexHull($1), $5) AND CASE WHEN $2 IS NULL OR $4 IS NULL THEN _st_dfullywithin(st_convexhull($1), st_convexhull($3), $5) ELSE _st_dfullywithin($1, $2, $3, $4, $5) END $function$

CREATE OR REPLACE FUNCTION public.st_disjoint(geom1 geometry, geom2 geometry)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$disjoint$function$
CREATE OR REPLACE FUNCTION public.st_disjoint(rast1 raster, rast2 raster)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT st_disjoint($1, NULL::integer, $2, NULL::integer) $function$
CREATE OR REPLACE FUNCTION public.st_disjoint(rast1 raster, nband1 integer, rast2 raster, nband2 integer)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT CASE WHEN $2 IS NULL OR $4 IS NULL THEN st_disjoint(st_convexhull($1), st_convexhull($3)) ELSE NOT _st_intersects($1, $2, $3, $4) END $function$

CREATE OR REPLACE FUNCTION public.st_disjoint(geom1 geometry, geom2 geometry)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$disjoint$function$
CREATE OR REPLACE FUNCTION public.st_disjoint(rast1 raster, rast2 raster)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT st_disjoint($1, NULL::integer, $2, NULL::integer) $function$
CREATE OR REPLACE FUNCTION public.st_disjoint(rast1 raster, nband1 integer, rast2 raster, nband2 integer)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT CASE WHEN $2 IS NULL OR $4 IS NULL THEN st_disjoint(st_convexhull($1), st_convexhull($3)) ELSE NOT _st_intersects($1, $2, $3, $4) END $function$

CREATE OR REPLACE FUNCTION public.st_distance(text, text)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT ST_Distance($1::geometry, $2::geometry);  $function$
CREATE OR REPLACE FUNCTION public.st_distance(geom1 geometry, geom2 geometry)
 RETURNS double precision
 LANGUAGE c
 IMMUTABLE STRICT COST 100
AS '$libdir/postgis-2.2', $function$distance$function$
CREATE OR REPLACE FUNCTION public.st_distance(geography, geography)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT _ST_Distance($1, $2, 0.0, true)$function$
CREATE OR REPLACE FUNCTION public.st_distance(geography, geography, boolean)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT _ST_Distance($1, $2, 0.0, $3)$function$

CREATE OR REPLACE FUNCTION public.st_distance(text, text)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT ST_Distance($1::geometry, $2::geometry);  $function$
CREATE OR REPLACE FUNCTION public.st_distance(geom1 geometry, geom2 geometry)
 RETURNS double precision
 LANGUAGE c
 IMMUTABLE STRICT COST 100
AS '$libdir/postgis-2.2', $function$distance$function$
CREATE OR REPLACE FUNCTION public.st_distance(geography, geography)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT _ST_Distance($1, $2, 0.0, true)$function$
CREATE OR REPLACE FUNCTION public.st_distance(geography, geography, boolean)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT _ST_Distance($1, $2, 0.0, $3)$function$

CREATE OR REPLACE FUNCTION public.st_distance(text, text)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT ST_Distance($1::geometry, $2::geometry);  $function$
CREATE OR REPLACE FUNCTION public.st_distance(geom1 geometry, geom2 geometry)
 RETURNS double precision
 LANGUAGE c
 IMMUTABLE STRICT COST 100
AS '$libdir/postgis-2.2', $function$distance$function$
CREATE OR REPLACE FUNCTION public.st_distance(geography, geography)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT _ST_Distance($1, $2, 0.0, true)$function$
CREATE OR REPLACE FUNCTION public.st_distance(geography, geography, boolean)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT _ST_Distance($1, $2, 0.0, $3)$function$

CREATE OR REPLACE FUNCTION public.st_distinct4ma(matrix double precision[], nodatamode text, VARIADIC args text[])
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT COUNT(DISTINCT unnest)::float FROM unnest($1) $function$
CREATE OR REPLACE FUNCTION public.st_distinct4ma(value double precision[], pos integer[], VARIADIC userargs text[] DEFAULT NULL::text[])
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT COUNT(DISTINCT unnest)::double precision FROM unnest($1) $function$

CREATE OR REPLACE FUNCTION public.st_dumpvalues(rast raster, nband integer, exclude_nodata_value boolean DEFAULT true)
 RETURNS double precision[]
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT valarray FROM st_dumpvalues($1, ARRAY[$2]::integer[], $3) $function$
CREATE OR REPLACE FUNCTION public.st_dumpvalues(rast raster, nband integer[] DEFAULT NULL::integer[], exclude_nodata_value boolean DEFAULT true, OUT nband integer, OUT valarray double precision[])
 RETURNS SETOF record
 LANGUAGE c
 IMMUTABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_dumpValues$function$

CREATE OR REPLACE FUNCTION public.st_dwithin(geom1 geometry, geom2 geometry, double precision)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$SELECT $1 && ST_Expand($2,$3) AND $2 && ST_Expand($1,$3) AND _ST_DWithin($1, $2, $3)$function$
CREATE OR REPLACE FUNCTION public.st_dwithin(geography, geography, double precision, boolean)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$SELECT $1 && _ST_Expand($2,$3) AND $2 && _ST_Expand($1,$3) AND _ST_DWithin($1, $2, $3, $4)$function$
CREATE OR REPLACE FUNCTION public.st_dwithin(geography, geography, double precision)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$SELECT $1 && _ST_Expand($2,$3) AND $2 && _ST_Expand($1,$3) AND _ST_DWithin($1, $2, $3, true)$function$
CREATE OR REPLACE FUNCTION public.st_dwithin(text, text, double precision)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT ST_DWithin($1::geometry, $2::geometry, $3);  $function$
CREATE OR REPLACE FUNCTION public.st_dwithin(rast1 raster, nband1 integer, rast2 raster, nband2 integer, distance double precision)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT $1::geometry && ST_Expand(ST_ConvexHull($3), $5) AND $3::geometry && ST_Expand(ST_ConvexHull($1), $5) AND CASE WHEN $2 IS NULL OR $4 IS NULL THEN _st_dwithin(st_convexhull($1), st_convexhull($3), $5) ELSE _st_dwithin($1, $2, $3, $4, $5) END $function$
CREATE OR REPLACE FUNCTION public.st_dwithin(rast1 raster, rast2 raster, distance double precision)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT st_dwithin($1, NULL::integer, $2, NULL::integer, $3) $function$

CREATE OR REPLACE FUNCTION public.st_dwithin(geom1 geometry, geom2 geometry, double precision)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$SELECT $1 && ST_Expand($2,$3) AND $2 && ST_Expand($1,$3) AND _ST_DWithin($1, $2, $3)$function$
CREATE OR REPLACE FUNCTION public.st_dwithin(geography, geography, double precision, boolean)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$SELECT $1 && _ST_Expand($2,$3) AND $2 && _ST_Expand($1,$3) AND _ST_DWithin($1, $2, $3, $4)$function$
CREATE OR REPLACE FUNCTION public.st_dwithin(geography, geography, double precision)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$SELECT $1 && _ST_Expand($2,$3) AND $2 && _ST_Expand($1,$3) AND _ST_DWithin($1, $2, $3, true)$function$
CREATE OR REPLACE FUNCTION public.st_dwithin(text, text, double precision)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT ST_DWithin($1::geometry, $2::geometry, $3);  $function$
CREATE OR REPLACE FUNCTION public.st_dwithin(rast1 raster, nband1 integer, rast2 raster, nband2 integer, distance double precision)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT $1::geometry && ST_Expand(ST_ConvexHull($3), $5) AND $3::geometry && ST_Expand(ST_ConvexHull($1), $5) AND CASE WHEN $2 IS NULL OR $4 IS NULL THEN _st_dwithin(st_convexhull($1), st_convexhull($3), $5) ELSE _st_dwithin($1, $2, $3, $4, $5) END $function$
CREATE OR REPLACE FUNCTION public.st_dwithin(rast1 raster, rast2 raster, distance double precision)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT st_dwithin($1, NULL::integer, $2, NULL::integer, $3) $function$

CREATE OR REPLACE FUNCTION public.st_dwithin(geom1 geometry, geom2 geometry, double precision)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$SELECT $1 && ST_Expand($2,$3) AND $2 && ST_Expand($1,$3) AND _ST_DWithin($1, $2, $3)$function$
CREATE OR REPLACE FUNCTION public.st_dwithin(geography, geography, double precision, boolean)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$SELECT $1 && _ST_Expand($2,$3) AND $2 && _ST_Expand($1,$3) AND _ST_DWithin($1, $2, $3, $4)$function$
CREATE OR REPLACE FUNCTION public.st_dwithin(geography, geography, double precision)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$SELECT $1 && _ST_Expand($2,$3) AND $2 && _ST_Expand($1,$3) AND _ST_DWithin($1, $2, $3, true)$function$
CREATE OR REPLACE FUNCTION public.st_dwithin(text, text, double precision)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT ST_DWithin($1::geometry, $2::geometry, $3);  $function$
CREATE OR REPLACE FUNCTION public.st_dwithin(rast1 raster, nband1 integer, rast2 raster, nband2 integer, distance double precision)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT $1::geometry && ST_Expand(ST_ConvexHull($3), $5) AND $3::geometry && ST_Expand(ST_ConvexHull($1), $5) AND CASE WHEN $2 IS NULL OR $4 IS NULL THEN _st_dwithin(st_convexhull($1), st_convexhull($3), $5) ELSE _st_dwithin($1, $2, $3, $4, $5) END $function$
CREATE OR REPLACE FUNCTION public.st_dwithin(rast1 raster, rast2 raster, distance double precision)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT st_dwithin($1, NULL::integer, $2, NULL::integer, $3) $function$

CREATE OR REPLACE FUNCTION public.st_dwithin(geom1 geometry, geom2 geometry, double precision)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$SELECT $1 && ST_Expand($2,$3) AND $2 && ST_Expand($1,$3) AND _ST_DWithin($1, $2, $3)$function$
CREATE OR REPLACE FUNCTION public.st_dwithin(geography, geography, double precision, boolean)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$SELECT $1 && _ST_Expand($2,$3) AND $2 && _ST_Expand($1,$3) AND _ST_DWithin($1, $2, $3, $4)$function$
CREATE OR REPLACE FUNCTION public.st_dwithin(geography, geography, double precision)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$SELECT $1 && _ST_Expand($2,$3) AND $2 && _ST_Expand($1,$3) AND _ST_DWithin($1, $2, $3, true)$function$
CREATE OR REPLACE FUNCTION public.st_dwithin(text, text, double precision)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT ST_DWithin($1::geometry, $2::geometry, $3);  $function$
CREATE OR REPLACE FUNCTION public.st_dwithin(rast1 raster, nband1 integer, rast2 raster, nband2 integer, distance double precision)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT $1::geometry && ST_Expand(ST_ConvexHull($3), $5) AND $3::geometry && ST_Expand(ST_ConvexHull($1), $5) AND CASE WHEN $2 IS NULL OR $4 IS NULL THEN _st_dwithin(st_convexhull($1), st_convexhull($3), $5) ELSE _st_dwithin($1, $2, $3, $4, $5) END $function$
CREATE OR REPLACE FUNCTION public.st_dwithin(rast1 raster, rast2 raster, distance double precision)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT st_dwithin($1, NULL::integer, $2, NULL::integer, $3) $function$

CREATE OR REPLACE FUNCTION public.st_dwithin(geom1 geometry, geom2 geometry, double precision)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$SELECT $1 && ST_Expand($2,$3) AND $2 && ST_Expand($1,$3) AND _ST_DWithin($1, $2, $3)$function$
CREATE OR REPLACE FUNCTION public.st_dwithin(geography, geography, double precision, boolean)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$SELECT $1 && _ST_Expand($2,$3) AND $2 && _ST_Expand($1,$3) AND _ST_DWithin($1, $2, $3, $4)$function$
CREATE OR REPLACE FUNCTION public.st_dwithin(geography, geography, double precision)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$SELECT $1 && _ST_Expand($2,$3) AND $2 && _ST_Expand($1,$3) AND _ST_DWithin($1, $2, $3, true)$function$
CREATE OR REPLACE FUNCTION public.st_dwithin(text, text, double precision)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT ST_DWithin($1::geometry, $2::geometry, $3);  $function$
CREATE OR REPLACE FUNCTION public.st_dwithin(rast1 raster, nband1 integer, rast2 raster, nband2 integer, distance double precision)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT $1::geometry && ST_Expand(ST_ConvexHull($3), $5) AND $3::geometry && ST_Expand(ST_ConvexHull($1), $5) AND CASE WHEN $2 IS NULL OR $4 IS NULL THEN _st_dwithin(st_convexhull($1), st_convexhull($3), $5) ELSE _st_dwithin($1, $2, $3, $4, $5) END $function$
CREATE OR REPLACE FUNCTION public.st_dwithin(rast1 raster, rast2 raster, distance double precision)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT st_dwithin($1, NULL::integer, $2, NULL::integer, $3) $function$

CREATE OR REPLACE FUNCTION public.st_envelope(geometry)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_envelope$function$
CREATE OR REPLACE FUNCTION public.st_envelope(raster)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/rtpostgis-2.2', $function$RASTER_envelope$function$

CREATE OR REPLACE FUNCTION public.st_estimated_extent(text, text)
 RETURNS box2d
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _postgis_deprecate('ST_Estimated_Extent', 'ST_EstimatedExtent', '2.1.0');
    -- We use security invoker instead of security definer 
    -- to prevent malicious injection of a same named different function
    -- that would be run under elevated permissions
    SELECT ST_EstimatedExtent($1, $2);
  $function$
CREATE OR REPLACE FUNCTION public.st_estimated_extent(text, text, text)
 RETURNS box2d
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _postgis_deprecate('ST_Estimated_Extent', 'ST_EstimatedExtent', '2.1.0');
    -- We use security invoker instead of security definer 
    -- to prevent malicious injection of a different same named function
    SELECT ST_EstimatedExtent($1, $2, $3);
  $function$

CREATE OR REPLACE FUNCTION public.st_estimatedextent(text, text)
 RETURNS box2d
 LANGUAGE c
 IMMUTABLE STRICT SECURITY DEFINER
AS '$libdir/postgis-2.2', $function$gserialized_estimated_extent$function$
CREATE OR REPLACE FUNCTION public.st_estimatedextent(text, text, text)
 RETURNS box2d
 LANGUAGE c
 IMMUTABLE STRICT SECURITY DEFINER
AS '$libdir/postgis-2.2', $function$gserialized_estimated_extent$function$

CREATE OR REPLACE FUNCTION public.st_expand(geometry, double precision)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_expand$function$
CREATE OR REPLACE FUNCTION public.st_expand(box3d, double precision)
 RETURNS box3d
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$BOX3D_expand$function$
CREATE OR REPLACE FUNCTION public.st_expand(box2d, double precision)
 RETURNS box2d
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$BOX2D_expand$function$

CREATE OR REPLACE FUNCTION public.st_expand(geometry, double precision)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_expand$function$
CREATE OR REPLACE FUNCTION public.st_expand(box3d, double precision)
 RETURNS box3d
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$BOX3D_expand$function$
CREATE OR REPLACE FUNCTION public.st_expand(box2d, double precision)
 RETURNS box2d
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$BOX2D_expand$function$

CREATE OR REPLACE FUNCTION public.st_find_extent(text, text)
 RETURNS box2d
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _postgis_deprecate('ST_Find_Extent', 'ST_FindExtent', '2.2.0');
    SELECT ST_FindExtent($1,$2);
  $function$
CREATE OR REPLACE FUNCTION public.st_find_extent(text, text, text)
 RETURNS box2d
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _postgis_deprecate('ST_Find_Extent', 'ST_FindExtent', '2.2.0');
    SELECT ST_FindExtent($1,$2,$3);
  $function$

CREATE OR REPLACE FUNCTION public.st_findextent(text, text)
 RETURNS box2d
 LANGUAGE plpgsql
 IMMUTABLE STRICT
AS $function$
DECLARE
	tablename alias for $1;
	columnname alias for $2;
	myrec RECORD;
BEGIN
	FOR myrec IN EXECUTE 'SELECT ST_Extent("' || columnname || '") As extent FROM "' || tablename || '"' LOOP
		return myrec.extent;
	END LOOP;
END;
$function$
CREATE OR REPLACE FUNCTION public.st_findextent(text, text, text)
 RETURNS box2d
 LANGUAGE plpgsql
 IMMUTABLE STRICT
AS $function$
DECLARE
	schemaname alias for $1;
	tablename alias for $2;
	columnname alias for $3;
	myrec RECORD;
BEGIN
	FOR myrec IN EXECUTE 'SELECT ST_Extent("' || columnname || '") As extent FROM "' || schemaname || '"."' || tablename || '"' LOOP
		return myrec.extent;
	END LOOP;
END;
$function$

CREATE OR REPLACE FUNCTION public.st_forcesfs(geometry)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_force_sfs$function$
CREATE OR REPLACE FUNCTION public.st_forcesfs(geometry, version text)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_force_sfs$function$

CREATE OR REPLACE FUNCTION public.st_geohash(geom geometry, maxchars integer DEFAULT 0)
 RETURNS text
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$ST_GeoHash$function$
CREATE OR REPLACE FUNCTION public.st_geohash(geog geography, maxchars integer DEFAULT 0)
 RETURNS text
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$ST_GeoHash$function$

CREATE OR REPLACE FUNCTION public.st_geomcollfromtext(text)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
	SELECT CASE
	WHEN geometrytype(ST_GeomFromText($1)) = 'GEOMETRYCOLLECTION'
	THEN ST_GeomFromText($1)
	ELSE NULL END
	$function$
CREATE OR REPLACE FUNCTION public.st_geomcollfromtext(text, integer)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
	SELECT CASE
	WHEN geometrytype(ST_GeomFromText($1, $2)) = 'GEOMETRYCOLLECTION'
	THEN ST_GeomFromText($1,$2)
	ELSE NULL END
	$function$

CREATE OR REPLACE FUNCTION public.st_geomcollfromwkb(bytea)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
	SELECT CASE
	WHEN geometrytype(ST_GeomFromWKB($1)) = 'GEOMETRYCOLLECTION'
	THEN ST_GeomFromWKB($1)
	ELSE NULL END
	$function$
CREATE OR REPLACE FUNCTION public.st_geomcollfromwkb(bytea, integer)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
	SELECT CASE
	WHEN geometrytype(ST_GeomFromWKB($1, $2)) = 'GEOMETRYCOLLECTION'
	THEN ST_GeomFromWKB($1, $2)
	ELSE NULL END
	$function$

CREATE OR REPLACE FUNCTION public.st_geometryfromtext(text)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_from_text$function$
CREATE OR REPLACE FUNCTION public.st_geometryfromtext(text, integer)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_from_text$function$

CREATE OR REPLACE FUNCTION public.st_geomfromgml(text)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT _ST_GeomFromGML($1, 0)$function$
CREATE OR REPLACE FUNCTION public.st_geomfromgml(text, integer)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$geom_from_gml$function$

CREATE OR REPLACE FUNCTION public.st_geomfromtext(text)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_from_text$function$
CREATE OR REPLACE FUNCTION public.st_geomfromtext(text, integer)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_from_text$function$

CREATE OR REPLACE FUNCTION public.st_geomfromwkb(bytea)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_from_WKB$function$
CREATE OR REPLACE FUNCTION public.st_geomfromwkb(bytea, integer)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT ST_SetSRID(ST_GeomFromWKB($1), $2)$function$

CREATE OR REPLACE FUNCTION public.st_gmltosql(text)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT _ST_GeomFromGML($1, 0)$function$
CREATE OR REPLACE FUNCTION public.st_gmltosql(text, integer)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$geom_from_gml$function$

CREATE OR REPLACE FUNCTION public.st_hausdorffdistance(geom1 geometry, geom2 geometry)
 RETURNS double precision
 LANGUAGE c
 IMMUTABLE STRICT COST 100
AS '$libdir/postgis-2.2', $function$hausdorffdistance$function$
CREATE OR REPLACE FUNCTION public.st_hausdorffdistance(geom1 geometry, geom2 geometry, double precision)
 RETURNS double precision
 LANGUAGE c
 IMMUTABLE STRICT COST 100
AS '$libdir/postgis-2.2', $function$hausdorffdistancedensify$function$

CREATE OR REPLACE FUNCTION public.st_hillshade(rast raster, nband integer DEFAULT 1, pixeltype text DEFAULT '32BF'::text, azimuth double precision DEFAULT 315.0, altitude double precision DEFAULT 45.0, max_bright double precision DEFAULT 255.0, scale double precision DEFAULT 1.0, interpolate_nodata boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT st_hillshade($1, $2, NULL::raster, $3, $4, $5, $6, $7, $8) $function$
CREATE OR REPLACE FUNCTION public.st_hillshade(rast raster, nband integer, customextent raster, pixeltype text DEFAULT '32BF'::text, azimuth double precision DEFAULT 315.0, altitude double precision DEFAULT 45.0, max_bright double precision DEFAULT 255.0, scale double precision DEFAULT 1.0, interpolate_nodata boolean DEFAULT false)
 RETURNS raster
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
	DECLARE
		_rast raster;
		_nband integer;
		_pixtype text;
		_pixwidth double precision;
		_pixheight double precision;
		_width integer;
		_height integer;
		_customextent raster;
		_extenttype text;
	BEGIN
		_customextent := customextent;
		IF _customextent IS NULL THEN
			_extenttype := 'FIRST';
		ELSE
			_extenttype := 'CUSTOM';
		END IF;
		IF interpolate_nodata IS TRUE THEN
			_rast := ST_MapAlgebra(
				ARRAY[ROW(rast, nband)]::rastbandarg[],
				'st_invdistweight4ma(double precision[][][], integer[][], text[])'::regprocedure,
				pixeltype,
				'FIRST', NULL,
				1, 1
			);
			_nband := 1;
			_pixtype := NULL;
		ELSE
			_rast := rast;
			_nband := nband;
			_pixtype := pixeltype;
		END IF;
		-- get properties
		_pixwidth := ST_PixelWidth(_rast);
		_pixheight := ST_PixelHeight(_rast);
		SELECT width, height, scalex INTO _width, _height FROM ST_Metadata(_rast);
		RETURN ST_MapAlgebra(
			ARRAY[ROW(_rast, _nband)]::rastbandarg[],
			'_st_hillshade4ma(double precision[][][], integer[][], text[])'::regprocedure,
			_pixtype,
			_extenttype, _customextent,
			1, 1,
			_pixwidth::text, _pixheight::text,
			_width::text, _height::text,
			$5::text, $6::text,
			$7::text, $8::text
		);
	END;
	$function$

CREATE OR REPLACE FUNCTION public.st_histogram(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, bins integer DEFAULT 0, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, $3, 1, $4, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_histogram(rast raster, nband integer, exclude_nodata_value boolean, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, $3, 1, $4, NULL, $5) $function$
CREATE OR REPLACE FUNCTION public.st_histogram(rast raster, nband integer, bins integer, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, TRUE, 1, $3, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_histogram(rast raster, nband integer, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, TRUE, 1, $3, NULL, $4) $function$
CREATE OR REPLACE FUNCTION public.st_histogram(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, bins integer DEFAULT 0, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_histogram($1, $2, $3, $4, 1, $5, $6, $7) $function$
CREATE OR REPLACE FUNCTION public.st_histogram(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_histogram($1, $2, $3, $4, 1, $5, NULL, $6) $function$
CREATE OR REPLACE FUNCTION public.st_histogram(rastertable text, rastercolumn text, nband integer, bins integer, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_histogram($1, $2, $3, TRUE, 1, $4, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_histogram(rastertable text, rastercolumn text, nband integer, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_histogram($1, $2, $3, TRUE, 1, $4, NULL, $5) $function$

CREATE OR REPLACE FUNCTION public.st_histogram(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, bins integer DEFAULT 0, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, $3, 1, $4, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_histogram(rast raster, nband integer, exclude_nodata_value boolean, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, $3, 1, $4, NULL, $5) $function$
CREATE OR REPLACE FUNCTION public.st_histogram(rast raster, nband integer, bins integer, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, TRUE, 1, $3, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_histogram(rast raster, nband integer, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, TRUE, 1, $3, NULL, $4) $function$
CREATE OR REPLACE FUNCTION public.st_histogram(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, bins integer DEFAULT 0, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_histogram($1, $2, $3, $4, 1, $5, $6, $7) $function$
CREATE OR REPLACE FUNCTION public.st_histogram(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_histogram($1, $2, $3, $4, 1, $5, NULL, $6) $function$
CREATE OR REPLACE FUNCTION public.st_histogram(rastertable text, rastercolumn text, nband integer, bins integer, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_histogram($1, $2, $3, TRUE, 1, $4, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_histogram(rastertable text, rastercolumn text, nband integer, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_histogram($1, $2, $3, TRUE, 1, $4, NULL, $5) $function$

CREATE OR REPLACE FUNCTION public.st_histogram(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, bins integer DEFAULT 0, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, $3, 1, $4, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_histogram(rast raster, nband integer, exclude_nodata_value boolean, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, $3, 1, $4, NULL, $5) $function$
CREATE OR REPLACE FUNCTION public.st_histogram(rast raster, nband integer, bins integer, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, TRUE, 1, $3, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_histogram(rast raster, nband integer, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, TRUE, 1, $3, NULL, $4) $function$
CREATE OR REPLACE FUNCTION public.st_histogram(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, bins integer DEFAULT 0, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_histogram($1, $2, $3, $4, 1, $5, $6, $7) $function$
CREATE OR REPLACE FUNCTION public.st_histogram(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_histogram($1, $2, $3, $4, 1, $5, NULL, $6) $function$
CREATE OR REPLACE FUNCTION public.st_histogram(rastertable text, rastercolumn text, nband integer, bins integer, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_histogram($1, $2, $3, TRUE, 1, $4, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_histogram(rastertable text, rastercolumn text, nband integer, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_histogram($1, $2, $3, TRUE, 1, $4, NULL, $5) $function$

CREATE OR REPLACE FUNCTION public.st_histogram(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, bins integer DEFAULT 0, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, $3, 1, $4, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_histogram(rast raster, nband integer, exclude_nodata_value boolean, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, $3, 1, $4, NULL, $5) $function$
CREATE OR REPLACE FUNCTION public.st_histogram(rast raster, nband integer, bins integer, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, TRUE, 1, $3, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_histogram(rast raster, nband integer, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, TRUE, 1, $3, NULL, $4) $function$
CREATE OR REPLACE FUNCTION public.st_histogram(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, bins integer DEFAULT 0, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_histogram($1, $2, $3, $4, 1, $5, $6, $7) $function$
CREATE OR REPLACE FUNCTION public.st_histogram(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_histogram($1, $2, $3, $4, 1, $5, NULL, $6) $function$
CREATE OR REPLACE FUNCTION public.st_histogram(rastertable text, rastercolumn text, nband integer, bins integer, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_histogram($1, $2, $3, TRUE, 1, $4, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_histogram(rastertable text, rastercolumn text, nband integer, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_histogram($1, $2, $3, TRUE, 1, $4, NULL, $5) $function$

CREATE OR REPLACE FUNCTION public.st_histogram(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, bins integer DEFAULT 0, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, $3, 1, $4, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_histogram(rast raster, nband integer, exclude_nodata_value boolean, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, $3, 1, $4, NULL, $5) $function$
CREATE OR REPLACE FUNCTION public.st_histogram(rast raster, nband integer, bins integer, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, TRUE, 1, $3, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_histogram(rast raster, nband integer, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, TRUE, 1, $3, NULL, $4) $function$
CREATE OR REPLACE FUNCTION public.st_histogram(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, bins integer DEFAULT 0, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_histogram($1, $2, $3, $4, 1, $5, $6, $7) $function$
CREATE OR REPLACE FUNCTION public.st_histogram(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_histogram($1, $2, $3, $4, 1, $5, NULL, $6) $function$
CREATE OR REPLACE FUNCTION public.st_histogram(rastertable text, rastercolumn text, nband integer, bins integer, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_histogram($1, $2, $3, TRUE, 1, $4, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_histogram(rastertable text, rastercolumn text, nband integer, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_histogram($1, $2, $3, TRUE, 1, $4, NULL, $5) $function$

CREATE OR REPLACE FUNCTION public.st_histogram(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, bins integer DEFAULT 0, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, $3, 1, $4, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_histogram(rast raster, nband integer, exclude_nodata_value boolean, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, $3, 1, $4, NULL, $5) $function$
CREATE OR REPLACE FUNCTION public.st_histogram(rast raster, nband integer, bins integer, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, TRUE, 1, $3, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_histogram(rast raster, nband integer, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, TRUE, 1, $3, NULL, $4) $function$
CREATE OR REPLACE FUNCTION public.st_histogram(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, bins integer DEFAULT 0, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_histogram($1, $2, $3, $4, 1, $5, $6, $7) $function$
CREATE OR REPLACE FUNCTION public.st_histogram(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_histogram($1, $2, $3, $4, 1, $5, NULL, $6) $function$
CREATE OR REPLACE FUNCTION public.st_histogram(rastertable text, rastercolumn text, nband integer, bins integer, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_histogram($1, $2, $3, TRUE, 1, $4, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_histogram(rastertable text, rastercolumn text, nband integer, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_histogram($1, $2, $3, TRUE, 1, $4, NULL, $5) $function$

CREATE OR REPLACE FUNCTION public.st_histogram(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, bins integer DEFAULT 0, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, $3, 1, $4, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_histogram(rast raster, nband integer, exclude_nodata_value boolean, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, $3, 1, $4, NULL, $5) $function$
CREATE OR REPLACE FUNCTION public.st_histogram(rast raster, nband integer, bins integer, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, TRUE, 1, $3, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_histogram(rast raster, nband integer, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT min, max, count, percent FROM _st_histogram($1, $2, TRUE, 1, $3, NULL, $4) $function$
CREATE OR REPLACE FUNCTION public.st_histogram(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, bins integer DEFAULT 0, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_histogram($1, $2, $3, $4, 1, $5, $6, $7) $function$
CREATE OR REPLACE FUNCTION public.st_histogram(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_histogram($1, $2, $3, $4, 1, $5, NULL, $6) $function$
CREATE OR REPLACE FUNCTION public.st_histogram(rastertable text, rastercolumn text, nband integer, bins integer, width double precision[] DEFAULT NULL::double precision[], "right" boolean DEFAULT false, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_histogram($1, $2, $3, TRUE, 1, $4, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_histogram(rastertable text, rastercolumn text, nband integer, bins integer, "right" boolean, OUT min double precision, OUT max double precision, OUT count bigint, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_histogram($1, $2, $3, TRUE, 1, $4, NULL, $5) $function$

CREATE OR REPLACE FUNCTION public.st_intersection(geom1 geometry, geom2 geometry)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT COST 100
AS '$libdir/postgis-2.2', $function$intersection$function$
CREATE OR REPLACE FUNCTION public.st_intersection(geography, geography)
 RETURNS geography
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT geography(ST_Transform(ST_Intersection(ST_Transform(geometry($1), _ST_BestSRID($1, $2)), ST_Transform(geometry($2), _ST_BestSRID($1, $2))), 4326))$function$
CREATE OR REPLACE FUNCTION public.st_intersection(text, text)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT ST_Intersection($1::geometry, $2::geometry);  $function$
CREATE OR REPLACE FUNCTION public.st_intersection(geomin geometry, rast raster, band integer DEFAULT 1)
 RETURNS SETOF geomval
 LANGUAGE plpgsql
 IMMUTABLE STRICT
AS $function$
	DECLARE
		intersects boolean := FALSE;
	BEGIN
		intersects := ST_Intersects(geomin, rast, band);
		IF intersects THEN
			-- Return the intersections of the geometry with the vectorized parts of
			-- the raster and the values associated with those parts, if really their
			-- intersection is not empty.
			RETURN QUERY
				SELECT
					intgeom,
					val
				FROM (
					SELECT
						ST_Intersection((gv).geom, geomin) AS intgeom,
						(gv).val
					FROM ST_DumpAsPolygons(rast, band) gv
					WHERE ST_Intersects((gv).geom, geomin)
				) foo
				WHERE NOT ST_IsEmpty(intgeom);
		ELSE
			-- If the geometry does not intersect with the raster, return an empty
			-- geometry and a null value
			RETURN QUERY
				SELECT
					emptygeom,
					NULL::float8
				FROM ST_GeomCollFromText('GEOMETRYCOLLECTION EMPTY', ST_SRID($1)) emptygeom;
		END IF;
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast raster, band integer, geomin geometry)
 RETURNS SETOF geomval
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($3, $1, $2) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast raster, geomin geometry)
 RETURNS SETOF geomval
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($2, $1, 1) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, band1 integer, rast2 raster, band2 integer, returnband text DEFAULT 'BOTH'::text, nodataval double precision[] DEFAULT NULL::double precision[])
 RETURNS raster
 LANGUAGE plpgsql
 STABLE
AS $function$
	DECLARE
		rtn raster;
		_returnband text;
		newnodata1 float8;
		newnodata2 float8;
	BEGIN
		IF ST_SRID(rast1) != ST_SRID(rast2) THEN
			RAISE EXCEPTION 'The two rasters do not have the same SRID';
		END IF;
		newnodata1 := coalesce(nodataval[1], ST_BandNodataValue(rast1, band1), ST_MinPossibleValue(ST_BandPixelType(rast1, band1)));
		newnodata2 := coalesce(nodataval[2], ST_BandNodataValue(rast2, band2), ST_MinPossibleValue(ST_BandPixelType(rast2, band2)));
		
		_returnband := upper(returnband);
		rtn := NULL;
		CASE
			WHEN _returnband = 'BAND1' THEN
				rtn := ST_MapAlgebraExpr(rast1, band1, rast2, band2, '[rast1.val]', ST_BandPixelType(rast1, band1), 'INTERSECTION', newnodata1::text, newnodata1::text, newnodata1);
				rtn := ST_SetBandNodataValue(rtn, 1, newnodata1);
			WHEN _returnband = 'BAND2' THEN
				rtn := ST_MapAlgebraExpr(rast1, band1, rast2, band2, '[rast2.val]', ST_BandPixelType(rast2, band2), 'INTERSECTION', newnodata2::text, newnodata2::text, newnodata2);
				rtn := ST_SetBandNodataValue(rtn, 1, newnodata2);
			WHEN _returnband = 'BOTH' THEN
				rtn := ST_MapAlgebraExpr(rast1, band1, rast2, band2, '[rast1.val]', ST_BandPixelType(rast1, band1), 'INTERSECTION', newnodata1::text, newnodata1::text, newnodata1);
				rtn := ST_SetBandNodataValue(rtn, 1, newnodata1);
				rtn := ST_AddBand(rtn, ST_MapAlgebraExpr(rast1, band1, rast2, band2, '[rast2.val]', ST_BandPixelType(rast2, band2), 'INTERSECTION', newnodata2::text, newnodata2::text, newnodata2));
				rtn := ST_SetBandNodataValue(rtn, 2, newnodata2);
			ELSE
				RAISE EXCEPTION 'Unknown value provided for returnband: %', returnband;
				RETURN NULL;
		END CASE;
		RETURN rtn;
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, band1 integer, rast2 raster, band2 integer, returnband text, nodataval double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, $2, $3, $4, $5, ARRAY[$6, $6]) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, band1 integer, rast2 raster, band2 integer, nodataval double precision[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, $2, $3, $4, 'BOTH', $5) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, band1 integer, rast2 raster, band2 integer, nodataval double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, $2, $3, $4, 'BOTH', ARRAY[$5, $5]) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, rast2 raster, returnband text DEFAULT 'BOTH'::text, nodataval double precision[] DEFAULT NULL::double precision[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, 1, $2, 1, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, rast2 raster, returnband text, nodataval double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, 1, $2, 1, $3, ARRAY[$4, $4]) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, rast2 raster, nodataval double precision[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, 1, $2, 1, 'BOTH', $3) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, rast2 raster, nodataval double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, 1, $2, 1, 'BOTH', ARRAY[$3, $3]) $function$

CREATE OR REPLACE FUNCTION public.st_intersection(geom1 geometry, geom2 geometry)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT COST 100
AS '$libdir/postgis-2.2', $function$intersection$function$
CREATE OR REPLACE FUNCTION public.st_intersection(geography, geography)
 RETURNS geography
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT geography(ST_Transform(ST_Intersection(ST_Transform(geometry($1), _ST_BestSRID($1, $2)), ST_Transform(geometry($2), _ST_BestSRID($1, $2))), 4326))$function$
CREATE OR REPLACE FUNCTION public.st_intersection(text, text)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT ST_Intersection($1::geometry, $2::geometry);  $function$
CREATE OR REPLACE FUNCTION public.st_intersection(geomin geometry, rast raster, band integer DEFAULT 1)
 RETURNS SETOF geomval
 LANGUAGE plpgsql
 IMMUTABLE STRICT
AS $function$
	DECLARE
		intersects boolean := FALSE;
	BEGIN
		intersects := ST_Intersects(geomin, rast, band);
		IF intersects THEN
			-- Return the intersections of the geometry with the vectorized parts of
			-- the raster and the values associated with those parts, if really their
			-- intersection is not empty.
			RETURN QUERY
				SELECT
					intgeom,
					val
				FROM (
					SELECT
						ST_Intersection((gv).geom, geomin) AS intgeom,
						(gv).val
					FROM ST_DumpAsPolygons(rast, band) gv
					WHERE ST_Intersects((gv).geom, geomin)
				) foo
				WHERE NOT ST_IsEmpty(intgeom);
		ELSE
			-- If the geometry does not intersect with the raster, return an empty
			-- geometry and a null value
			RETURN QUERY
				SELECT
					emptygeom,
					NULL::float8
				FROM ST_GeomCollFromText('GEOMETRYCOLLECTION EMPTY', ST_SRID($1)) emptygeom;
		END IF;
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast raster, band integer, geomin geometry)
 RETURNS SETOF geomval
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($3, $1, $2) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast raster, geomin geometry)
 RETURNS SETOF geomval
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($2, $1, 1) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, band1 integer, rast2 raster, band2 integer, returnband text DEFAULT 'BOTH'::text, nodataval double precision[] DEFAULT NULL::double precision[])
 RETURNS raster
 LANGUAGE plpgsql
 STABLE
AS $function$
	DECLARE
		rtn raster;
		_returnband text;
		newnodata1 float8;
		newnodata2 float8;
	BEGIN
		IF ST_SRID(rast1) != ST_SRID(rast2) THEN
			RAISE EXCEPTION 'The two rasters do not have the same SRID';
		END IF;
		newnodata1 := coalesce(nodataval[1], ST_BandNodataValue(rast1, band1), ST_MinPossibleValue(ST_BandPixelType(rast1, band1)));
		newnodata2 := coalesce(nodataval[2], ST_BandNodataValue(rast2, band2), ST_MinPossibleValue(ST_BandPixelType(rast2, band2)));
		
		_returnband := upper(returnband);
		rtn := NULL;
		CASE
			WHEN _returnband = 'BAND1' THEN
				rtn := ST_MapAlgebraExpr(rast1, band1, rast2, band2, '[rast1.val]', ST_BandPixelType(rast1, band1), 'INTERSECTION', newnodata1::text, newnodata1::text, newnodata1);
				rtn := ST_SetBandNodataValue(rtn, 1, newnodata1);
			WHEN _returnband = 'BAND2' THEN
				rtn := ST_MapAlgebraExpr(rast1, band1, rast2, band2, '[rast2.val]', ST_BandPixelType(rast2, band2), 'INTERSECTION', newnodata2::text, newnodata2::text, newnodata2);
				rtn := ST_SetBandNodataValue(rtn, 1, newnodata2);
			WHEN _returnband = 'BOTH' THEN
				rtn := ST_MapAlgebraExpr(rast1, band1, rast2, band2, '[rast1.val]', ST_BandPixelType(rast1, band1), 'INTERSECTION', newnodata1::text, newnodata1::text, newnodata1);
				rtn := ST_SetBandNodataValue(rtn, 1, newnodata1);
				rtn := ST_AddBand(rtn, ST_MapAlgebraExpr(rast1, band1, rast2, band2, '[rast2.val]', ST_BandPixelType(rast2, band2), 'INTERSECTION', newnodata2::text, newnodata2::text, newnodata2));
				rtn := ST_SetBandNodataValue(rtn, 2, newnodata2);
			ELSE
				RAISE EXCEPTION 'Unknown value provided for returnband: %', returnband;
				RETURN NULL;
		END CASE;
		RETURN rtn;
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, band1 integer, rast2 raster, band2 integer, returnband text, nodataval double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, $2, $3, $4, $5, ARRAY[$6, $6]) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, band1 integer, rast2 raster, band2 integer, nodataval double precision[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, $2, $3, $4, 'BOTH', $5) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, band1 integer, rast2 raster, band2 integer, nodataval double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, $2, $3, $4, 'BOTH', ARRAY[$5, $5]) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, rast2 raster, returnband text DEFAULT 'BOTH'::text, nodataval double precision[] DEFAULT NULL::double precision[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, 1, $2, 1, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, rast2 raster, returnband text, nodataval double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, 1, $2, 1, $3, ARRAY[$4, $4]) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, rast2 raster, nodataval double precision[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, 1, $2, 1, 'BOTH', $3) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, rast2 raster, nodataval double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, 1, $2, 1, 'BOTH', ARRAY[$3, $3]) $function$

CREATE OR REPLACE FUNCTION public.st_intersection(geom1 geometry, geom2 geometry)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT COST 100
AS '$libdir/postgis-2.2', $function$intersection$function$
CREATE OR REPLACE FUNCTION public.st_intersection(geography, geography)
 RETURNS geography
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT geography(ST_Transform(ST_Intersection(ST_Transform(geometry($1), _ST_BestSRID($1, $2)), ST_Transform(geometry($2), _ST_BestSRID($1, $2))), 4326))$function$
CREATE OR REPLACE FUNCTION public.st_intersection(text, text)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT ST_Intersection($1::geometry, $2::geometry);  $function$
CREATE OR REPLACE FUNCTION public.st_intersection(geomin geometry, rast raster, band integer DEFAULT 1)
 RETURNS SETOF geomval
 LANGUAGE plpgsql
 IMMUTABLE STRICT
AS $function$
	DECLARE
		intersects boolean := FALSE;
	BEGIN
		intersects := ST_Intersects(geomin, rast, band);
		IF intersects THEN
			-- Return the intersections of the geometry with the vectorized parts of
			-- the raster and the values associated with those parts, if really their
			-- intersection is not empty.
			RETURN QUERY
				SELECT
					intgeom,
					val
				FROM (
					SELECT
						ST_Intersection((gv).geom, geomin) AS intgeom,
						(gv).val
					FROM ST_DumpAsPolygons(rast, band) gv
					WHERE ST_Intersects((gv).geom, geomin)
				) foo
				WHERE NOT ST_IsEmpty(intgeom);
		ELSE
			-- If the geometry does not intersect with the raster, return an empty
			-- geometry and a null value
			RETURN QUERY
				SELECT
					emptygeom,
					NULL::float8
				FROM ST_GeomCollFromText('GEOMETRYCOLLECTION EMPTY', ST_SRID($1)) emptygeom;
		END IF;
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast raster, band integer, geomin geometry)
 RETURNS SETOF geomval
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($3, $1, $2) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast raster, geomin geometry)
 RETURNS SETOF geomval
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($2, $1, 1) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, band1 integer, rast2 raster, band2 integer, returnband text DEFAULT 'BOTH'::text, nodataval double precision[] DEFAULT NULL::double precision[])
 RETURNS raster
 LANGUAGE plpgsql
 STABLE
AS $function$
	DECLARE
		rtn raster;
		_returnband text;
		newnodata1 float8;
		newnodata2 float8;
	BEGIN
		IF ST_SRID(rast1) != ST_SRID(rast2) THEN
			RAISE EXCEPTION 'The two rasters do not have the same SRID';
		END IF;
		newnodata1 := coalesce(nodataval[1], ST_BandNodataValue(rast1, band1), ST_MinPossibleValue(ST_BandPixelType(rast1, band1)));
		newnodata2 := coalesce(nodataval[2], ST_BandNodataValue(rast2, band2), ST_MinPossibleValue(ST_BandPixelType(rast2, band2)));
		
		_returnband := upper(returnband);
		rtn := NULL;
		CASE
			WHEN _returnband = 'BAND1' THEN
				rtn := ST_MapAlgebraExpr(rast1, band1, rast2, band2, '[rast1.val]', ST_BandPixelType(rast1, band1), 'INTERSECTION', newnodata1::text, newnodata1::text, newnodata1);
				rtn := ST_SetBandNodataValue(rtn, 1, newnodata1);
			WHEN _returnband = 'BAND2' THEN
				rtn := ST_MapAlgebraExpr(rast1, band1, rast2, band2, '[rast2.val]', ST_BandPixelType(rast2, band2), 'INTERSECTION', newnodata2::text, newnodata2::text, newnodata2);
				rtn := ST_SetBandNodataValue(rtn, 1, newnodata2);
			WHEN _returnband = 'BOTH' THEN
				rtn := ST_MapAlgebraExpr(rast1, band1, rast2, band2, '[rast1.val]', ST_BandPixelType(rast1, band1), 'INTERSECTION', newnodata1::text, newnodata1::text, newnodata1);
				rtn := ST_SetBandNodataValue(rtn, 1, newnodata1);
				rtn := ST_AddBand(rtn, ST_MapAlgebraExpr(rast1, band1, rast2, band2, '[rast2.val]', ST_BandPixelType(rast2, band2), 'INTERSECTION', newnodata2::text, newnodata2::text, newnodata2));
				rtn := ST_SetBandNodataValue(rtn, 2, newnodata2);
			ELSE
				RAISE EXCEPTION 'Unknown value provided for returnband: %', returnband;
				RETURN NULL;
		END CASE;
		RETURN rtn;
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, band1 integer, rast2 raster, band2 integer, returnband text, nodataval double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, $2, $3, $4, $5, ARRAY[$6, $6]) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, band1 integer, rast2 raster, band2 integer, nodataval double precision[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, $2, $3, $4, 'BOTH', $5) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, band1 integer, rast2 raster, band2 integer, nodataval double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, $2, $3, $4, 'BOTH', ARRAY[$5, $5]) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, rast2 raster, returnband text DEFAULT 'BOTH'::text, nodataval double precision[] DEFAULT NULL::double precision[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, 1, $2, 1, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, rast2 raster, returnband text, nodataval double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, 1, $2, 1, $3, ARRAY[$4, $4]) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, rast2 raster, nodataval double precision[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, 1, $2, 1, 'BOTH', $3) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, rast2 raster, nodataval double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, 1, $2, 1, 'BOTH', ARRAY[$3, $3]) $function$

CREATE OR REPLACE FUNCTION public.st_intersection(geom1 geometry, geom2 geometry)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT COST 100
AS '$libdir/postgis-2.2', $function$intersection$function$
CREATE OR REPLACE FUNCTION public.st_intersection(geography, geography)
 RETURNS geography
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT geography(ST_Transform(ST_Intersection(ST_Transform(geometry($1), _ST_BestSRID($1, $2)), ST_Transform(geometry($2), _ST_BestSRID($1, $2))), 4326))$function$
CREATE OR REPLACE FUNCTION public.st_intersection(text, text)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT ST_Intersection($1::geometry, $2::geometry);  $function$
CREATE OR REPLACE FUNCTION public.st_intersection(geomin geometry, rast raster, band integer DEFAULT 1)
 RETURNS SETOF geomval
 LANGUAGE plpgsql
 IMMUTABLE STRICT
AS $function$
	DECLARE
		intersects boolean := FALSE;
	BEGIN
		intersects := ST_Intersects(geomin, rast, band);
		IF intersects THEN
			-- Return the intersections of the geometry with the vectorized parts of
			-- the raster and the values associated with those parts, if really their
			-- intersection is not empty.
			RETURN QUERY
				SELECT
					intgeom,
					val
				FROM (
					SELECT
						ST_Intersection((gv).geom, geomin) AS intgeom,
						(gv).val
					FROM ST_DumpAsPolygons(rast, band) gv
					WHERE ST_Intersects((gv).geom, geomin)
				) foo
				WHERE NOT ST_IsEmpty(intgeom);
		ELSE
			-- If the geometry does not intersect with the raster, return an empty
			-- geometry and a null value
			RETURN QUERY
				SELECT
					emptygeom,
					NULL::float8
				FROM ST_GeomCollFromText('GEOMETRYCOLLECTION EMPTY', ST_SRID($1)) emptygeom;
		END IF;
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast raster, band integer, geomin geometry)
 RETURNS SETOF geomval
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($3, $1, $2) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast raster, geomin geometry)
 RETURNS SETOF geomval
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($2, $1, 1) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, band1 integer, rast2 raster, band2 integer, returnband text DEFAULT 'BOTH'::text, nodataval double precision[] DEFAULT NULL::double precision[])
 RETURNS raster
 LANGUAGE plpgsql
 STABLE
AS $function$
	DECLARE
		rtn raster;
		_returnband text;
		newnodata1 float8;
		newnodata2 float8;
	BEGIN
		IF ST_SRID(rast1) != ST_SRID(rast2) THEN
			RAISE EXCEPTION 'The two rasters do not have the same SRID';
		END IF;
		newnodata1 := coalesce(nodataval[1], ST_BandNodataValue(rast1, band1), ST_MinPossibleValue(ST_BandPixelType(rast1, band1)));
		newnodata2 := coalesce(nodataval[2], ST_BandNodataValue(rast2, band2), ST_MinPossibleValue(ST_BandPixelType(rast2, band2)));
		
		_returnband := upper(returnband);
		rtn := NULL;
		CASE
			WHEN _returnband = 'BAND1' THEN
				rtn := ST_MapAlgebraExpr(rast1, band1, rast2, band2, '[rast1.val]', ST_BandPixelType(rast1, band1), 'INTERSECTION', newnodata1::text, newnodata1::text, newnodata1);
				rtn := ST_SetBandNodataValue(rtn, 1, newnodata1);
			WHEN _returnband = 'BAND2' THEN
				rtn := ST_MapAlgebraExpr(rast1, band1, rast2, band2, '[rast2.val]', ST_BandPixelType(rast2, band2), 'INTERSECTION', newnodata2::text, newnodata2::text, newnodata2);
				rtn := ST_SetBandNodataValue(rtn, 1, newnodata2);
			WHEN _returnband = 'BOTH' THEN
				rtn := ST_MapAlgebraExpr(rast1, band1, rast2, band2, '[rast1.val]', ST_BandPixelType(rast1, band1), 'INTERSECTION', newnodata1::text, newnodata1::text, newnodata1);
				rtn := ST_SetBandNodataValue(rtn, 1, newnodata1);
				rtn := ST_AddBand(rtn, ST_MapAlgebraExpr(rast1, band1, rast2, band2, '[rast2.val]', ST_BandPixelType(rast2, band2), 'INTERSECTION', newnodata2::text, newnodata2::text, newnodata2));
				rtn := ST_SetBandNodataValue(rtn, 2, newnodata2);
			ELSE
				RAISE EXCEPTION 'Unknown value provided for returnband: %', returnband;
				RETURN NULL;
		END CASE;
		RETURN rtn;
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, band1 integer, rast2 raster, band2 integer, returnband text, nodataval double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, $2, $3, $4, $5, ARRAY[$6, $6]) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, band1 integer, rast2 raster, band2 integer, nodataval double precision[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, $2, $3, $4, 'BOTH', $5) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, band1 integer, rast2 raster, band2 integer, nodataval double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, $2, $3, $4, 'BOTH', ARRAY[$5, $5]) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, rast2 raster, returnband text DEFAULT 'BOTH'::text, nodataval double precision[] DEFAULT NULL::double precision[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, 1, $2, 1, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, rast2 raster, returnband text, nodataval double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, 1, $2, 1, $3, ARRAY[$4, $4]) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, rast2 raster, nodataval double precision[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, 1, $2, 1, 'BOTH', $3) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, rast2 raster, nodataval double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, 1, $2, 1, 'BOTH', ARRAY[$3, $3]) $function$

CREATE OR REPLACE FUNCTION public.st_intersection(geom1 geometry, geom2 geometry)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT COST 100
AS '$libdir/postgis-2.2', $function$intersection$function$
CREATE OR REPLACE FUNCTION public.st_intersection(geography, geography)
 RETURNS geography
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT geography(ST_Transform(ST_Intersection(ST_Transform(geometry($1), _ST_BestSRID($1, $2)), ST_Transform(geometry($2), _ST_BestSRID($1, $2))), 4326))$function$
CREATE OR REPLACE FUNCTION public.st_intersection(text, text)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT ST_Intersection($1::geometry, $2::geometry);  $function$
CREATE OR REPLACE FUNCTION public.st_intersection(geomin geometry, rast raster, band integer DEFAULT 1)
 RETURNS SETOF geomval
 LANGUAGE plpgsql
 IMMUTABLE STRICT
AS $function$
	DECLARE
		intersects boolean := FALSE;
	BEGIN
		intersects := ST_Intersects(geomin, rast, band);
		IF intersects THEN
			-- Return the intersections of the geometry with the vectorized parts of
			-- the raster and the values associated with those parts, if really their
			-- intersection is not empty.
			RETURN QUERY
				SELECT
					intgeom,
					val
				FROM (
					SELECT
						ST_Intersection((gv).geom, geomin) AS intgeom,
						(gv).val
					FROM ST_DumpAsPolygons(rast, band) gv
					WHERE ST_Intersects((gv).geom, geomin)
				) foo
				WHERE NOT ST_IsEmpty(intgeom);
		ELSE
			-- If the geometry does not intersect with the raster, return an empty
			-- geometry and a null value
			RETURN QUERY
				SELECT
					emptygeom,
					NULL::float8
				FROM ST_GeomCollFromText('GEOMETRYCOLLECTION EMPTY', ST_SRID($1)) emptygeom;
		END IF;
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast raster, band integer, geomin geometry)
 RETURNS SETOF geomval
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($3, $1, $2) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast raster, geomin geometry)
 RETURNS SETOF geomval
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($2, $1, 1) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, band1 integer, rast2 raster, band2 integer, returnband text DEFAULT 'BOTH'::text, nodataval double precision[] DEFAULT NULL::double precision[])
 RETURNS raster
 LANGUAGE plpgsql
 STABLE
AS $function$
	DECLARE
		rtn raster;
		_returnband text;
		newnodata1 float8;
		newnodata2 float8;
	BEGIN
		IF ST_SRID(rast1) != ST_SRID(rast2) THEN
			RAISE EXCEPTION 'The two rasters do not have the same SRID';
		END IF;
		newnodata1 := coalesce(nodataval[1], ST_BandNodataValue(rast1, band1), ST_MinPossibleValue(ST_BandPixelType(rast1, band1)));
		newnodata2 := coalesce(nodataval[2], ST_BandNodataValue(rast2, band2), ST_MinPossibleValue(ST_BandPixelType(rast2, band2)));
		
		_returnband := upper(returnband);
		rtn := NULL;
		CASE
			WHEN _returnband = 'BAND1' THEN
				rtn := ST_MapAlgebraExpr(rast1, band1, rast2, band2, '[rast1.val]', ST_BandPixelType(rast1, band1), 'INTERSECTION', newnodata1::text, newnodata1::text, newnodata1);
				rtn := ST_SetBandNodataValue(rtn, 1, newnodata1);
			WHEN _returnband = 'BAND2' THEN
				rtn := ST_MapAlgebraExpr(rast1, band1, rast2, band2, '[rast2.val]', ST_BandPixelType(rast2, band2), 'INTERSECTION', newnodata2::text, newnodata2::text, newnodata2);
				rtn := ST_SetBandNodataValue(rtn, 1, newnodata2);
			WHEN _returnband = 'BOTH' THEN
				rtn := ST_MapAlgebraExpr(rast1, band1, rast2, band2, '[rast1.val]', ST_BandPixelType(rast1, band1), 'INTERSECTION', newnodata1::text, newnodata1::text, newnodata1);
				rtn := ST_SetBandNodataValue(rtn, 1, newnodata1);
				rtn := ST_AddBand(rtn, ST_MapAlgebraExpr(rast1, band1, rast2, band2, '[rast2.val]', ST_BandPixelType(rast2, band2), 'INTERSECTION', newnodata2::text, newnodata2::text, newnodata2));
				rtn := ST_SetBandNodataValue(rtn, 2, newnodata2);
			ELSE
				RAISE EXCEPTION 'Unknown value provided for returnband: %', returnband;
				RETURN NULL;
		END CASE;
		RETURN rtn;
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, band1 integer, rast2 raster, band2 integer, returnband text, nodataval double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, $2, $3, $4, $5, ARRAY[$6, $6]) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, band1 integer, rast2 raster, band2 integer, nodataval double precision[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, $2, $3, $4, 'BOTH', $5) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, band1 integer, rast2 raster, band2 integer, nodataval double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, $2, $3, $4, 'BOTH', ARRAY[$5, $5]) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, rast2 raster, returnband text DEFAULT 'BOTH'::text, nodataval double precision[] DEFAULT NULL::double precision[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, 1, $2, 1, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, rast2 raster, returnband text, nodataval double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, 1, $2, 1, $3, ARRAY[$4, $4]) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, rast2 raster, nodataval double precision[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, 1, $2, 1, 'BOTH', $3) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, rast2 raster, nodataval double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, 1, $2, 1, 'BOTH', ARRAY[$3, $3]) $function$

CREATE OR REPLACE FUNCTION public.st_intersection(geom1 geometry, geom2 geometry)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT COST 100
AS '$libdir/postgis-2.2', $function$intersection$function$
CREATE OR REPLACE FUNCTION public.st_intersection(geography, geography)
 RETURNS geography
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT geography(ST_Transform(ST_Intersection(ST_Transform(geometry($1), _ST_BestSRID($1, $2)), ST_Transform(geometry($2), _ST_BestSRID($1, $2))), 4326))$function$
CREATE OR REPLACE FUNCTION public.st_intersection(text, text)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT ST_Intersection($1::geometry, $2::geometry);  $function$
CREATE OR REPLACE FUNCTION public.st_intersection(geomin geometry, rast raster, band integer DEFAULT 1)
 RETURNS SETOF geomval
 LANGUAGE plpgsql
 IMMUTABLE STRICT
AS $function$
	DECLARE
		intersects boolean := FALSE;
	BEGIN
		intersects := ST_Intersects(geomin, rast, band);
		IF intersects THEN
			-- Return the intersections of the geometry with the vectorized parts of
			-- the raster and the values associated with those parts, if really their
			-- intersection is not empty.
			RETURN QUERY
				SELECT
					intgeom,
					val
				FROM (
					SELECT
						ST_Intersection((gv).geom, geomin) AS intgeom,
						(gv).val
					FROM ST_DumpAsPolygons(rast, band) gv
					WHERE ST_Intersects((gv).geom, geomin)
				) foo
				WHERE NOT ST_IsEmpty(intgeom);
		ELSE
			-- If the geometry does not intersect with the raster, return an empty
			-- geometry and a null value
			RETURN QUERY
				SELECT
					emptygeom,
					NULL::float8
				FROM ST_GeomCollFromText('GEOMETRYCOLLECTION EMPTY', ST_SRID($1)) emptygeom;
		END IF;
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast raster, band integer, geomin geometry)
 RETURNS SETOF geomval
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($3, $1, $2) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast raster, geomin geometry)
 RETURNS SETOF geomval
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($2, $1, 1) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, band1 integer, rast2 raster, band2 integer, returnband text DEFAULT 'BOTH'::text, nodataval double precision[] DEFAULT NULL::double precision[])
 RETURNS raster
 LANGUAGE plpgsql
 STABLE
AS $function$
	DECLARE
		rtn raster;
		_returnband text;
		newnodata1 float8;
		newnodata2 float8;
	BEGIN
		IF ST_SRID(rast1) != ST_SRID(rast2) THEN
			RAISE EXCEPTION 'The two rasters do not have the same SRID';
		END IF;
		newnodata1 := coalesce(nodataval[1], ST_BandNodataValue(rast1, band1), ST_MinPossibleValue(ST_BandPixelType(rast1, band1)));
		newnodata2 := coalesce(nodataval[2], ST_BandNodataValue(rast2, band2), ST_MinPossibleValue(ST_BandPixelType(rast2, band2)));
		
		_returnband := upper(returnband);
		rtn := NULL;
		CASE
			WHEN _returnband = 'BAND1' THEN
				rtn := ST_MapAlgebraExpr(rast1, band1, rast2, band2, '[rast1.val]', ST_BandPixelType(rast1, band1), 'INTERSECTION', newnodata1::text, newnodata1::text, newnodata1);
				rtn := ST_SetBandNodataValue(rtn, 1, newnodata1);
			WHEN _returnband = 'BAND2' THEN
				rtn := ST_MapAlgebraExpr(rast1, band1, rast2, band2, '[rast2.val]', ST_BandPixelType(rast2, band2), 'INTERSECTION', newnodata2::text, newnodata2::text, newnodata2);
				rtn := ST_SetBandNodataValue(rtn, 1, newnodata2);
			WHEN _returnband = 'BOTH' THEN
				rtn := ST_MapAlgebraExpr(rast1, band1, rast2, band2, '[rast1.val]', ST_BandPixelType(rast1, band1), 'INTERSECTION', newnodata1::text, newnodata1::text, newnodata1);
				rtn := ST_SetBandNodataValue(rtn, 1, newnodata1);
				rtn := ST_AddBand(rtn, ST_MapAlgebraExpr(rast1, band1, rast2, band2, '[rast2.val]', ST_BandPixelType(rast2, band2), 'INTERSECTION', newnodata2::text, newnodata2::text, newnodata2));
				rtn := ST_SetBandNodataValue(rtn, 2, newnodata2);
			ELSE
				RAISE EXCEPTION 'Unknown value provided for returnband: %', returnband;
				RETURN NULL;
		END CASE;
		RETURN rtn;
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, band1 integer, rast2 raster, band2 integer, returnband text, nodataval double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, $2, $3, $4, $5, ARRAY[$6, $6]) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, band1 integer, rast2 raster, band2 integer, nodataval double precision[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, $2, $3, $4, 'BOTH', $5) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, band1 integer, rast2 raster, band2 integer, nodataval double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, $2, $3, $4, 'BOTH', ARRAY[$5, $5]) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, rast2 raster, returnband text DEFAULT 'BOTH'::text, nodataval double precision[] DEFAULT NULL::double precision[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, 1, $2, 1, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, rast2 raster, returnband text, nodataval double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, 1, $2, 1, $3, ARRAY[$4, $4]) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, rast2 raster, nodataval double precision[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, 1, $2, 1, 'BOTH', $3) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, rast2 raster, nodataval double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, 1, $2, 1, 'BOTH', ARRAY[$3, $3]) $function$

CREATE OR REPLACE FUNCTION public.st_intersection(geom1 geometry, geom2 geometry)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT COST 100
AS '$libdir/postgis-2.2', $function$intersection$function$
CREATE OR REPLACE FUNCTION public.st_intersection(geography, geography)
 RETURNS geography
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT geography(ST_Transform(ST_Intersection(ST_Transform(geometry($1), _ST_BestSRID($1, $2)), ST_Transform(geometry($2), _ST_BestSRID($1, $2))), 4326))$function$
CREATE OR REPLACE FUNCTION public.st_intersection(text, text)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT ST_Intersection($1::geometry, $2::geometry);  $function$
CREATE OR REPLACE FUNCTION public.st_intersection(geomin geometry, rast raster, band integer DEFAULT 1)
 RETURNS SETOF geomval
 LANGUAGE plpgsql
 IMMUTABLE STRICT
AS $function$
	DECLARE
		intersects boolean := FALSE;
	BEGIN
		intersects := ST_Intersects(geomin, rast, band);
		IF intersects THEN
			-- Return the intersections of the geometry with the vectorized parts of
			-- the raster and the values associated with those parts, if really their
			-- intersection is not empty.
			RETURN QUERY
				SELECT
					intgeom,
					val
				FROM (
					SELECT
						ST_Intersection((gv).geom, geomin) AS intgeom,
						(gv).val
					FROM ST_DumpAsPolygons(rast, band) gv
					WHERE ST_Intersects((gv).geom, geomin)
				) foo
				WHERE NOT ST_IsEmpty(intgeom);
		ELSE
			-- If the geometry does not intersect with the raster, return an empty
			-- geometry and a null value
			RETURN QUERY
				SELECT
					emptygeom,
					NULL::float8
				FROM ST_GeomCollFromText('GEOMETRYCOLLECTION EMPTY', ST_SRID($1)) emptygeom;
		END IF;
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast raster, band integer, geomin geometry)
 RETURNS SETOF geomval
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($3, $1, $2) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast raster, geomin geometry)
 RETURNS SETOF geomval
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($2, $1, 1) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, band1 integer, rast2 raster, band2 integer, returnband text DEFAULT 'BOTH'::text, nodataval double precision[] DEFAULT NULL::double precision[])
 RETURNS raster
 LANGUAGE plpgsql
 STABLE
AS $function$
	DECLARE
		rtn raster;
		_returnband text;
		newnodata1 float8;
		newnodata2 float8;
	BEGIN
		IF ST_SRID(rast1) != ST_SRID(rast2) THEN
			RAISE EXCEPTION 'The two rasters do not have the same SRID';
		END IF;
		newnodata1 := coalesce(nodataval[1], ST_BandNodataValue(rast1, band1), ST_MinPossibleValue(ST_BandPixelType(rast1, band1)));
		newnodata2 := coalesce(nodataval[2], ST_BandNodataValue(rast2, band2), ST_MinPossibleValue(ST_BandPixelType(rast2, band2)));
		
		_returnband := upper(returnband);
		rtn := NULL;
		CASE
			WHEN _returnband = 'BAND1' THEN
				rtn := ST_MapAlgebraExpr(rast1, band1, rast2, band2, '[rast1.val]', ST_BandPixelType(rast1, band1), 'INTERSECTION', newnodata1::text, newnodata1::text, newnodata1);
				rtn := ST_SetBandNodataValue(rtn, 1, newnodata1);
			WHEN _returnband = 'BAND2' THEN
				rtn := ST_MapAlgebraExpr(rast1, band1, rast2, band2, '[rast2.val]', ST_BandPixelType(rast2, band2), 'INTERSECTION', newnodata2::text, newnodata2::text, newnodata2);
				rtn := ST_SetBandNodataValue(rtn, 1, newnodata2);
			WHEN _returnband = 'BOTH' THEN
				rtn := ST_MapAlgebraExpr(rast1, band1, rast2, band2, '[rast1.val]', ST_BandPixelType(rast1, band1), 'INTERSECTION', newnodata1::text, newnodata1::text, newnodata1);
				rtn := ST_SetBandNodataValue(rtn, 1, newnodata1);
				rtn := ST_AddBand(rtn, ST_MapAlgebraExpr(rast1, band1, rast2, band2, '[rast2.val]', ST_BandPixelType(rast2, band2), 'INTERSECTION', newnodata2::text, newnodata2::text, newnodata2));
				rtn := ST_SetBandNodataValue(rtn, 2, newnodata2);
			ELSE
				RAISE EXCEPTION 'Unknown value provided for returnband: %', returnband;
				RETURN NULL;
		END CASE;
		RETURN rtn;
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, band1 integer, rast2 raster, band2 integer, returnband text, nodataval double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, $2, $3, $4, $5, ARRAY[$6, $6]) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, band1 integer, rast2 raster, band2 integer, nodataval double precision[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, $2, $3, $4, 'BOTH', $5) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, band1 integer, rast2 raster, band2 integer, nodataval double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, $2, $3, $4, 'BOTH', ARRAY[$5, $5]) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, rast2 raster, returnband text DEFAULT 'BOTH'::text, nodataval double precision[] DEFAULT NULL::double precision[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, 1, $2, 1, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, rast2 raster, returnband text, nodataval double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, 1, $2, 1, $3, ARRAY[$4, $4]) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, rast2 raster, nodataval double precision[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, 1, $2, 1, 'BOTH', $3) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, rast2 raster, nodataval double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, 1, $2, 1, 'BOTH', ARRAY[$3, $3]) $function$

CREATE OR REPLACE FUNCTION public.st_intersection(geom1 geometry, geom2 geometry)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT COST 100
AS '$libdir/postgis-2.2', $function$intersection$function$
CREATE OR REPLACE FUNCTION public.st_intersection(geography, geography)
 RETURNS geography
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT geography(ST_Transform(ST_Intersection(ST_Transform(geometry($1), _ST_BestSRID($1, $2)), ST_Transform(geometry($2), _ST_BestSRID($1, $2))), 4326))$function$
CREATE OR REPLACE FUNCTION public.st_intersection(text, text)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT ST_Intersection($1::geometry, $2::geometry);  $function$
CREATE OR REPLACE FUNCTION public.st_intersection(geomin geometry, rast raster, band integer DEFAULT 1)
 RETURNS SETOF geomval
 LANGUAGE plpgsql
 IMMUTABLE STRICT
AS $function$
	DECLARE
		intersects boolean := FALSE;
	BEGIN
		intersects := ST_Intersects(geomin, rast, band);
		IF intersects THEN
			-- Return the intersections of the geometry with the vectorized parts of
			-- the raster and the values associated with those parts, if really their
			-- intersection is not empty.
			RETURN QUERY
				SELECT
					intgeom,
					val
				FROM (
					SELECT
						ST_Intersection((gv).geom, geomin) AS intgeom,
						(gv).val
					FROM ST_DumpAsPolygons(rast, band) gv
					WHERE ST_Intersects((gv).geom, geomin)
				) foo
				WHERE NOT ST_IsEmpty(intgeom);
		ELSE
			-- If the geometry does not intersect with the raster, return an empty
			-- geometry and a null value
			RETURN QUERY
				SELECT
					emptygeom,
					NULL::float8
				FROM ST_GeomCollFromText('GEOMETRYCOLLECTION EMPTY', ST_SRID($1)) emptygeom;
		END IF;
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast raster, band integer, geomin geometry)
 RETURNS SETOF geomval
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($3, $1, $2) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast raster, geomin geometry)
 RETURNS SETOF geomval
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($2, $1, 1) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, band1 integer, rast2 raster, band2 integer, returnband text DEFAULT 'BOTH'::text, nodataval double precision[] DEFAULT NULL::double precision[])
 RETURNS raster
 LANGUAGE plpgsql
 STABLE
AS $function$
	DECLARE
		rtn raster;
		_returnband text;
		newnodata1 float8;
		newnodata2 float8;
	BEGIN
		IF ST_SRID(rast1) != ST_SRID(rast2) THEN
			RAISE EXCEPTION 'The two rasters do not have the same SRID';
		END IF;
		newnodata1 := coalesce(nodataval[1], ST_BandNodataValue(rast1, band1), ST_MinPossibleValue(ST_BandPixelType(rast1, band1)));
		newnodata2 := coalesce(nodataval[2], ST_BandNodataValue(rast2, band2), ST_MinPossibleValue(ST_BandPixelType(rast2, band2)));
		
		_returnband := upper(returnband);
		rtn := NULL;
		CASE
			WHEN _returnband = 'BAND1' THEN
				rtn := ST_MapAlgebraExpr(rast1, band1, rast2, band2, '[rast1.val]', ST_BandPixelType(rast1, band1), 'INTERSECTION', newnodata1::text, newnodata1::text, newnodata1);
				rtn := ST_SetBandNodataValue(rtn, 1, newnodata1);
			WHEN _returnband = 'BAND2' THEN
				rtn := ST_MapAlgebraExpr(rast1, band1, rast2, band2, '[rast2.val]', ST_BandPixelType(rast2, band2), 'INTERSECTION', newnodata2::text, newnodata2::text, newnodata2);
				rtn := ST_SetBandNodataValue(rtn, 1, newnodata2);
			WHEN _returnband = 'BOTH' THEN
				rtn := ST_MapAlgebraExpr(rast1, band1, rast2, band2, '[rast1.val]', ST_BandPixelType(rast1, band1), 'INTERSECTION', newnodata1::text, newnodata1::text, newnodata1);
				rtn := ST_SetBandNodataValue(rtn, 1, newnodata1);
				rtn := ST_AddBand(rtn, ST_MapAlgebraExpr(rast1, band1, rast2, band2, '[rast2.val]', ST_BandPixelType(rast2, band2), 'INTERSECTION', newnodata2::text, newnodata2::text, newnodata2));
				rtn := ST_SetBandNodataValue(rtn, 2, newnodata2);
			ELSE
				RAISE EXCEPTION 'Unknown value provided for returnband: %', returnband;
				RETURN NULL;
		END CASE;
		RETURN rtn;
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, band1 integer, rast2 raster, band2 integer, returnband text, nodataval double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, $2, $3, $4, $5, ARRAY[$6, $6]) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, band1 integer, rast2 raster, band2 integer, nodataval double precision[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, $2, $3, $4, 'BOTH', $5) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, band1 integer, rast2 raster, band2 integer, nodataval double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, $2, $3, $4, 'BOTH', ARRAY[$5, $5]) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, rast2 raster, returnband text DEFAULT 'BOTH'::text, nodataval double precision[] DEFAULT NULL::double precision[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, 1, $2, 1, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, rast2 raster, returnband text, nodataval double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, 1, $2, 1, $3, ARRAY[$4, $4]) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, rast2 raster, nodataval double precision[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, 1, $2, 1, 'BOTH', $3) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, rast2 raster, nodataval double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, 1, $2, 1, 'BOTH', ARRAY[$3, $3]) $function$

CREATE OR REPLACE FUNCTION public.st_intersection(geom1 geometry, geom2 geometry)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT COST 100
AS '$libdir/postgis-2.2', $function$intersection$function$
CREATE OR REPLACE FUNCTION public.st_intersection(geography, geography)
 RETURNS geography
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT geography(ST_Transform(ST_Intersection(ST_Transform(geometry($1), _ST_BestSRID($1, $2)), ST_Transform(geometry($2), _ST_BestSRID($1, $2))), 4326))$function$
CREATE OR REPLACE FUNCTION public.st_intersection(text, text)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT ST_Intersection($1::geometry, $2::geometry);  $function$
CREATE OR REPLACE FUNCTION public.st_intersection(geomin geometry, rast raster, band integer DEFAULT 1)
 RETURNS SETOF geomval
 LANGUAGE plpgsql
 IMMUTABLE STRICT
AS $function$
	DECLARE
		intersects boolean := FALSE;
	BEGIN
		intersects := ST_Intersects(geomin, rast, band);
		IF intersects THEN
			-- Return the intersections of the geometry with the vectorized parts of
			-- the raster and the values associated with those parts, if really their
			-- intersection is not empty.
			RETURN QUERY
				SELECT
					intgeom,
					val
				FROM (
					SELECT
						ST_Intersection((gv).geom, geomin) AS intgeom,
						(gv).val
					FROM ST_DumpAsPolygons(rast, band) gv
					WHERE ST_Intersects((gv).geom, geomin)
				) foo
				WHERE NOT ST_IsEmpty(intgeom);
		ELSE
			-- If the geometry does not intersect with the raster, return an empty
			-- geometry and a null value
			RETURN QUERY
				SELECT
					emptygeom,
					NULL::float8
				FROM ST_GeomCollFromText('GEOMETRYCOLLECTION EMPTY', ST_SRID($1)) emptygeom;
		END IF;
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast raster, band integer, geomin geometry)
 RETURNS SETOF geomval
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($3, $1, $2) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast raster, geomin geometry)
 RETURNS SETOF geomval
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($2, $1, 1) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, band1 integer, rast2 raster, band2 integer, returnband text DEFAULT 'BOTH'::text, nodataval double precision[] DEFAULT NULL::double precision[])
 RETURNS raster
 LANGUAGE plpgsql
 STABLE
AS $function$
	DECLARE
		rtn raster;
		_returnband text;
		newnodata1 float8;
		newnodata2 float8;
	BEGIN
		IF ST_SRID(rast1) != ST_SRID(rast2) THEN
			RAISE EXCEPTION 'The two rasters do not have the same SRID';
		END IF;
		newnodata1 := coalesce(nodataval[1], ST_BandNodataValue(rast1, band1), ST_MinPossibleValue(ST_BandPixelType(rast1, band1)));
		newnodata2 := coalesce(nodataval[2], ST_BandNodataValue(rast2, band2), ST_MinPossibleValue(ST_BandPixelType(rast2, band2)));
		
		_returnband := upper(returnband);
		rtn := NULL;
		CASE
			WHEN _returnband = 'BAND1' THEN
				rtn := ST_MapAlgebraExpr(rast1, band1, rast2, band2, '[rast1.val]', ST_BandPixelType(rast1, band1), 'INTERSECTION', newnodata1::text, newnodata1::text, newnodata1);
				rtn := ST_SetBandNodataValue(rtn, 1, newnodata1);
			WHEN _returnband = 'BAND2' THEN
				rtn := ST_MapAlgebraExpr(rast1, band1, rast2, band2, '[rast2.val]', ST_BandPixelType(rast2, band2), 'INTERSECTION', newnodata2::text, newnodata2::text, newnodata2);
				rtn := ST_SetBandNodataValue(rtn, 1, newnodata2);
			WHEN _returnband = 'BOTH' THEN
				rtn := ST_MapAlgebraExpr(rast1, band1, rast2, band2, '[rast1.val]', ST_BandPixelType(rast1, band1), 'INTERSECTION', newnodata1::text, newnodata1::text, newnodata1);
				rtn := ST_SetBandNodataValue(rtn, 1, newnodata1);
				rtn := ST_AddBand(rtn, ST_MapAlgebraExpr(rast1, band1, rast2, band2, '[rast2.val]', ST_BandPixelType(rast2, band2), 'INTERSECTION', newnodata2::text, newnodata2::text, newnodata2));
				rtn := ST_SetBandNodataValue(rtn, 2, newnodata2);
			ELSE
				RAISE EXCEPTION 'Unknown value provided for returnband: %', returnband;
				RETURN NULL;
		END CASE;
		RETURN rtn;
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, band1 integer, rast2 raster, band2 integer, returnband text, nodataval double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, $2, $3, $4, $5, ARRAY[$6, $6]) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, band1 integer, rast2 raster, band2 integer, nodataval double precision[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, $2, $3, $4, 'BOTH', $5) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, band1 integer, rast2 raster, band2 integer, nodataval double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, $2, $3, $4, 'BOTH', ARRAY[$5, $5]) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, rast2 raster, returnband text DEFAULT 'BOTH'::text, nodataval double precision[] DEFAULT NULL::double precision[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, 1, $2, 1, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, rast2 raster, returnband text, nodataval double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, 1, $2, 1, $3, ARRAY[$4, $4]) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, rast2 raster, nodataval double precision[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, 1, $2, 1, 'BOTH', $3) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, rast2 raster, nodataval double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, 1, $2, 1, 'BOTH', ARRAY[$3, $3]) $function$

CREATE OR REPLACE FUNCTION public.st_intersection(geom1 geometry, geom2 geometry)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT COST 100
AS '$libdir/postgis-2.2', $function$intersection$function$
CREATE OR REPLACE FUNCTION public.st_intersection(geography, geography)
 RETURNS geography
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT geography(ST_Transform(ST_Intersection(ST_Transform(geometry($1), _ST_BestSRID($1, $2)), ST_Transform(geometry($2), _ST_BestSRID($1, $2))), 4326))$function$
CREATE OR REPLACE FUNCTION public.st_intersection(text, text)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT ST_Intersection($1::geometry, $2::geometry);  $function$
CREATE OR REPLACE FUNCTION public.st_intersection(geomin geometry, rast raster, band integer DEFAULT 1)
 RETURNS SETOF geomval
 LANGUAGE plpgsql
 IMMUTABLE STRICT
AS $function$
	DECLARE
		intersects boolean := FALSE;
	BEGIN
		intersects := ST_Intersects(geomin, rast, band);
		IF intersects THEN
			-- Return the intersections of the geometry with the vectorized parts of
			-- the raster and the values associated with those parts, if really their
			-- intersection is not empty.
			RETURN QUERY
				SELECT
					intgeom,
					val
				FROM (
					SELECT
						ST_Intersection((gv).geom, geomin) AS intgeom,
						(gv).val
					FROM ST_DumpAsPolygons(rast, band) gv
					WHERE ST_Intersects((gv).geom, geomin)
				) foo
				WHERE NOT ST_IsEmpty(intgeom);
		ELSE
			-- If the geometry does not intersect with the raster, return an empty
			-- geometry and a null value
			RETURN QUERY
				SELECT
					emptygeom,
					NULL::float8
				FROM ST_GeomCollFromText('GEOMETRYCOLLECTION EMPTY', ST_SRID($1)) emptygeom;
		END IF;
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast raster, band integer, geomin geometry)
 RETURNS SETOF geomval
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($3, $1, $2) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast raster, geomin geometry)
 RETURNS SETOF geomval
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($2, $1, 1) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, band1 integer, rast2 raster, band2 integer, returnband text DEFAULT 'BOTH'::text, nodataval double precision[] DEFAULT NULL::double precision[])
 RETURNS raster
 LANGUAGE plpgsql
 STABLE
AS $function$
	DECLARE
		rtn raster;
		_returnband text;
		newnodata1 float8;
		newnodata2 float8;
	BEGIN
		IF ST_SRID(rast1) != ST_SRID(rast2) THEN
			RAISE EXCEPTION 'The two rasters do not have the same SRID';
		END IF;
		newnodata1 := coalesce(nodataval[1], ST_BandNodataValue(rast1, band1), ST_MinPossibleValue(ST_BandPixelType(rast1, band1)));
		newnodata2 := coalesce(nodataval[2], ST_BandNodataValue(rast2, band2), ST_MinPossibleValue(ST_BandPixelType(rast2, band2)));
		
		_returnband := upper(returnband);
		rtn := NULL;
		CASE
			WHEN _returnband = 'BAND1' THEN
				rtn := ST_MapAlgebraExpr(rast1, band1, rast2, band2, '[rast1.val]', ST_BandPixelType(rast1, band1), 'INTERSECTION', newnodata1::text, newnodata1::text, newnodata1);
				rtn := ST_SetBandNodataValue(rtn, 1, newnodata1);
			WHEN _returnband = 'BAND2' THEN
				rtn := ST_MapAlgebraExpr(rast1, band1, rast2, band2, '[rast2.val]', ST_BandPixelType(rast2, band2), 'INTERSECTION', newnodata2::text, newnodata2::text, newnodata2);
				rtn := ST_SetBandNodataValue(rtn, 1, newnodata2);
			WHEN _returnband = 'BOTH' THEN
				rtn := ST_MapAlgebraExpr(rast1, band1, rast2, band2, '[rast1.val]', ST_BandPixelType(rast1, band1), 'INTERSECTION', newnodata1::text, newnodata1::text, newnodata1);
				rtn := ST_SetBandNodataValue(rtn, 1, newnodata1);
				rtn := ST_AddBand(rtn, ST_MapAlgebraExpr(rast1, band1, rast2, band2, '[rast2.val]', ST_BandPixelType(rast2, band2), 'INTERSECTION', newnodata2::text, newnodata2::text, newnodata2));
				rtn := ST_SetBandNodataValue(rtn, 2, newnodata2);
			ELSE
				RAISE EXCEPTION 'Unknown value provided for returnband: %', returnband;
				RETURN NULL;
		END CASE;
		RETURN rtn;
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, band1 integer, rast2 raster, band2 integer, returnband text, nodataval double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, $2, $3, $4, $5, ARRAY[$6, $6]) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, band1 integer, rast2 raster, band2 integer, nodataval double precision[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, $2, $3, $4, 'BOTH', $5) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, band1 integer, rast2 raster, band2 integer, nodataval double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, $2, $3, $4, 'BOTH', ARRAY[$5, $5]) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, rast2 raster, returnband text DEFAULT 'BOTH'::text, nodataval double precision[] DEFAULT NULL::double precision[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, 1, $2, 1, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, rast2 raster, returnband text, nodataval double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, 1, $2, 1, $3, ARRAY[$4, $4]) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, rast2 raster, nodataval double precision[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, 1, $2, 1, 'BOTH', $3) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, rast2 raster, nodataval double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, 1, $2, 1, 'BOTH', ARRAY[$3, $3]) $function$

CREATE OR REPLACE FUNCTION public.st_intersection(geom1 geometry, geom2 geometry)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT COST 100
AS '$libdir/postgis-2.2', $function$intersection$function$
CREATE OR REPLACE FUNCTION public.st_intersection(geography, geography)
 RETURNS geography
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT geography(ST_Transform(ST_Intersection(ST_Transform(geometry($1), _ST_BestSRID($1, $2)), ST_Transform(geometry($2), _ST_BestSRID($1, $2))), 4326))$function$
CREATE OR REPLACE FUNCTION public.st_intersection(text, text)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT ST_Intersection($1::geometry, $2::geometry);  $function$
CREATE OR REPLACE FUNCTION public.st_intersection(geomin geometry, rast raster, band integer DEFAULT 1)
 RETURNS SETOF geomval
 LANGUAGE plpgsql
 IMMUTABLE STRICT
AS $function$
	DECLARE
		intersects boolean := FALSE;
	BEGIN
		intersects := ST_Intersects(geomin, rast, band);
		IF intersects THEN
			-- Return the intersections of the geometry with the vectorized parts of
			-- the raster and the values associated with those parts, if really their
			-- intersection is not empty.
			RETURN QUERY
				SELECT
					intgeom,
					val
				FROM (
					SELECT
						ST_Intersection((gv).geom, geomin) AS intgeom,
						(gv).val
					FROM ST_DumpAsPolygons(rast, band) gv
					WHERE ST_Intersects((gv).geom, geomin)
				) foo
				WHERE NOT ST_IsEmpty(intgeom);
		ELSE
			-- If the geometry does not intersect with the raster, return an empty
			-- geometry and a null value
			RETURN QUERY
				SELECT
					emptygeom,
					NULL::float8
				FROM ST_GeomCollFromText('GEOMETRYCOLLECTION EMPTY', ST_SRID($1)) emptygeom;
		END IF;
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast raster, band integer, geomin geometry)
 RETURNS SETOF geomval
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($3, $1, $2) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast raster, geomin geometry)
 RETURNS SETOF geomval
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($2, $1, 1) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, band1 integer, rast2 raster, band2 integer, returnband text DEFAULT 'BOTH'::text, nodataval double precision[] DEFAULT NULL::double precision[])
 RETURNS raster
 LANGUAGE plpgsql
 STABLE
AS $function$
	DECLARE
		rtn raster;
		_returnband text;
		newnodata1 float8;
		newnodata2 float8;
	BEGIN
		IF ST_SRID(rast1) != ST_SRID(rast2) THEN
			RAISE EXCEPTION 'The two rasters do not have the same SRID';
		END IF;
		newnodata1 := coalesce(nodataval[1], ST_BandNodataValue(rast1, band1), ST_MinPossibleValue(ST_BandPixelType(rast1, band1)));
		newnodata2 := coalesce(nodataval[2], ST_BandNodataValue(rast2, band2), ST_MinPossibleValue(ST_BandPixelType(rast2, band2)));
		
		_returnband := upper(returnband);
		rtn := NULL;
		CASE
			WHEN _returnband = 'BAND1' THEN
				rtn := ST_MapAlgebraExpr(rast1, band1, rast2, band2, '[rast1.val]', ST_BandPixelType(rast1, band1), 'INTERSECTION', newnodata1::text, newnodata1::text, newnodata1);
				rtn := ST_SetBandNodataValue(rtn, 1, newnodata1);
			WHEN _returnband = 'BAND2' THEN
				rtn := ST_MapAlgebraExpr(rast1, band1, rast2, band2, '[rast2.val]', ST_BandPixelType(rast2, band2), 'INTERSECTION', newnodata2::text, newnodata2::text, newnodata2);
				rtn := ST_SetBandNodataValue(rtn, 1, newnodata2);
			WHEN _returnband = 'BOTH' THEN
				rtn := ST_MapAlgebraExpr(rast1, band1, rast2, band2, '[rast1.val]', ST_BandPixelType(rast1, band1), 'INTERSECTION', newnodata1::text, newnodata1::text, newnodata1);
				rtn := ST_SetBandNodataValue(rtn, 1, newnodata1);
				rtn := ST_AddBand(rtn, ST_MapAlgebraExpr(rast1, band1, rast2, band2, '[rast2.val]', ST_BandPixelType(rast2, band2), 'INTERSECTION', newnodata2::text, newnodata2::text, newnodata2));
				rtn := ST_SetBandNodataValue(rtn, 2, newnodata2);
			ELSE
				RAISE EXCEPTION 'Unknown value provided for returnband: %', returnband;
				RETURN NULL;
		END CASE;
		RETURN rtn;
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, band1 integer, rast2 raster, band2 integer, returnband text, nodataval double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, $2, $3, $4, $5, ARRAY[$6, $6]) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, band1 integer, rast2 raster, band2 integer, nodataval double precision[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, $2, $3, $4, 'BOTH', $5) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, band1 integer, rast2 raster, band2 integer, nodataval double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, $2, $3, $4, 'BOTH', ARRAY[$5, $5]) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, rast2 raster, returnband text DEFAULT 'BOTH'::text, nodataval double precision[] DEFAULT NULL::double precision[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, 1, $2, 1, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, rast2 raster, returnband text, nodataval double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, 1, $2, 1, $3, ARRAY[$4, $4]) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, rast2 raster, nodataval double precision[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, 1, $2, 1, 'BOTH', $3) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, rast2 raster, nodataval double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, 1, $2, 1, 'BOTH', ARRAY[$3, $3]) $function$

CREATE OR REPLACE FUNCTION public.st_intersection(geom1 geometry, geom2 geometry)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT COST 100
AS '$libdir/postgis-2.2', $function$intersection$function$
CREATE OR REPLACE FUNCTION public.st_intersection(geography, geography)
 RETURNS geography
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT geography(ST_Transform(ST_Intersection(ST_Transform(geometry($1), _ST_BestSRID($1, $2)), ST_Transform(geometry($2), _ST_BestSRID($1, $2))), 4326))$function$
CREATE OR REPLACE FUNCTION public.st_intersection(text, text)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT ST_Intersection($1::geometry, $2::geometry);  $function$
CREATE OR REPLACE FUNCTION public.st_intersection(geomin geometry, rast raster, band integer DEFAULT 1)
 RETURNS SETOF geomval
 LANGUAGE plpgsql
 IMMUTABLE STRICT
AS $function$
	DECLARE
		intersects boolean := FALSE;
	BEGIN
		intersects := ST_Intersects(geomin, rast, band);
		IF intersects THEN
			-- Return the intersections of the geometry with the vectorized parts of
			-- the raster and the values associated with those parts, if really their
			-- intersection is not empty.
			RETURN QUERY
				SELECT
					intgeom,
					val
				FROM (
					SELECT
						ST_Intersection((gv).geom, geomin) AS intgeom,
						(gv).val
					FROM ST_DumpAsPolygons(rast, band) gv
					WHERE ST_Intersects((gv).geom, geomin)
				) foo
				WHERE NOT ST_IsEmpty(intgeom);
		ELSE
			-- If the geometry does not intersect with the raster, return an empty
			-- geometry and a null value
			RETURN QUERY
				SELECT
					emptygeom,
					NULL::float8
				FROM ST_GeomCollFromText('GEOMETRYCOLLECTION EMPTY', ST_SRID($1)) emptygeom;
		END IF;
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast raster, band integer, geomin geometry)
 RETURNS SETOF geomval
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($3, $1, $2) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast raster, geomin geometry)
 RETURNS SETOF geomval
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($2, $1, 1) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, band1 integer, rast2 raster, band2 integer, returnband text DEFAULT 'BOTH'::text, nodataval double precision[] DEFAULT NULL::double precision[])
 RETURNS raster
 LANGUAGE plpgsql
 STABLE
AS $function$
	DECLARE
		rtn raster;
		_returnband text;
		newnodata1 float8;
		newnodata2 float8;
	BEGIN
		IF ST_SRID(rast1) != ST_SRID(rast2) THEN
			RAISE EXCEPTION 'The two rasters do not have the same SRID';
		END IF;
		newnodata1 := coalesce(nodataval[1], ST_BandNodataValue(rast1, band1), ST_MinPossibleValue(ST_BandPixelType(rast1, band1)));
		newnodata2 := coalesce(nodataval[2], ST_BandNodataValue(rast2, band2), ST_MinPossibleValue(ST_BandPixelType(rast2, band2)));
		
		_returnband := upper(returnband);
		rtn := NULL;
		CASE
			WHEN _returnband = 'BAND1' THEN
				rtn := ST_MapAlgebraExpr(rast1, band1, rast2, band2, '[rast1.val]', ST_BandPixelType(rast1, band1), 'INTERSECTION', newnodata1::text, newnodata1::text, newnodata1);
				rtn := ST_SetBandNodataValue(rtn, 1, newnodata1);
			WHEN _returnband = 'BAND2' THEN
				rtn := ST_MapAlgebraExpr(rast1, band1, rast2, band2, '[rast2.val]', ST_BandPixelType(rast2, band2), 'INTERSECTION', newnodata2::text, newnodata2::text, newnodata2);
				rtn := ST_SetBandNodataValue(rtn, 1, newnodata2);
			WHEN _returnband = 'BOTH' THEN
				rtn := ST_MapAlgebraExpr(rast1, band1, rast2, band2, '[rast1.val]', ST_BandPixelType(rast1, band1), 'INTERSECTION', newnodata1::text, newnodata1::text, newnodata1);
				rtn := ST_SetBandNodataValue(rtn, 1, newnodata1);
				rtn := ST_AddBand(rtn, ST_MapAlgebraExpr(rast1, band1, rast2, band2, '[rast2.val]', ST_BandPixelType(rast2, band2), 'INTERSECTION', newnodata2::text, newnodata2::text, newnodata2));
				rtn := ST_SetBandNodataValue(rtn, 2, newnodata2);
			ELSE
				RAISE EXCEPTION 'Unknown value provided for returnband: %', returnband;
				RETURN NULL;
		END CASE;
		RETURN rtn;
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, band1 integer, rast2 raster, band2 integer, returnband text, nodataval double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, $2, $3, $4, $5, ARRAY[$6, $6]) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, band1 integer, rast2 raster, band2 integer, nodataval double precision[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, $2, $3, $4, 'BOTH', $5) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, band1 integer, rast2 raster, band2 integer, nodataval double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, $2, $3, $4, 'BOTH', ARRAY[$5, $5]) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, rast2 raster, returnband text DEFAULT 'BOTH'::text, nodataval double precision[] DEFAULT NULL::double precision[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, 1, $2, 1, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, rast2 raster, returnband text, nodataval double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, 1, $2, 1, $3, ARRAY[$4, $4]) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, rast2 raster, nodataval double precision[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, 1, $2, 1, 'BOTH', $3) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, rast2 raster, nodataval double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, 1, $2, 1, 'BOTH', ARRAY[$3, $3]) $function$

CREATE OR REPLACE FUNCTION public.st_intersection(geom1 geometry, geom2 geometry)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT COST 100
AS '$libdir/postgis-2.2', $function$intersection$function$
CREATE OR REPLACE FUNCTION public.st_intersection(geography, geography)
 RETURNS geography
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT geography(ST_Transform(ST_Intersection(ST_Transform(geometry($1), _ST_BestSRID($1, $2)), ST_Transform(geometry($2), _ST_BestSRID($1, $2))), 4326))$function$
CREATE OR REPLACE FUNCTION public.st_intersection(text, text)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT ST_Intersection($1::geometry, $2::geometry);  $function$
CREATE OR REPLACE FUNCTION public.st_intersection(geomin geometry, rast raster, band integer DEFAULT 1)
 RETURNS SETOF geomval
 LANGUAGE plpgsql
 IMMUTABLE STRICT
AS $function$
	DECLARE
		intersects boolean := FALSE;
	BEGIN
		intersects := ST_Intersects(geomin, rast, band);
		IF intersects THEN
			-- Return the intersections of the geometry with the vectorized parts of
			-- the raster and the values associated with those parts, if really their
			-- intersection is not empty.
			RETURN QUERY
				SELECT
					intgeom,
					val
				FROM (
					SELECT
						ST_Intersection((gv).geom, geomin) AS intgeom,
						(gv).val
					FROM ST_DumpAsPolygons(rast, band) gv
					WHERE ST_Intersects((gv).geom, geomin)
				) foo
				WHERE NOT ST_IsEmpty(intgeom);
		ELSE
			-- If the geometry does not intersect with the raster, return an empty
			-- geometry and a null value
			RETURN QUERY
				SELECT
					emptygeom,
					NULL::float8
				FROM ST_GeomCollFromText('GEOMETRYCOLLECTION EMPTY', ST_SRID($1)) emptygeom;
		END IF;
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast raster, band integer, geomin geometry)
 RETURNS SETOF geomval
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($3, $1, $2) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast raster, geomin geometry)
 RETURNS SETOF geomval
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($2, $1, 1) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, band1 integer, rast2 raster, band2 integer, returnband text DEFAULT 'BOTH'::text, nodataval double precision[] DEFAULT NULL::double precision[])
 RETURNS raster
 LANGUAGE plpgsql
 STABLE
AS $function$
	DECLARE
		rtn raster;
		_returnband text;
		newnodata1 float8;
		newnodata2 float8;
	BEGIN
		IF ST_SRID(rast1) != ST_SRID(rast2) THEN
			RAISE EXCEPTION 'The two rasters do not have the same SRID';
		END IF;
		newnodata1 := coalesce(nodataval[1], ST_BandNodataValue(rast1, band1), ST_MinPossibleValue(ST_BandPixelType(rast1, band1)));
		newnodata2 := coalesce(nodataval[2], ST_BandNodataValue(rast2, band2), ST_MinPossibleValue(ST_BandPixelType(rast2, band2)));
		
		_returnband := upper(returnband);
		rtn := NULL;
		CASE
			WHEN _returnband = 'BAND1' THEN
				rtn := ST_MapAlgebraExpr(rast1, band1, rast2, band2, '[rast1.val]', ST_BandPixelType(rast1, band1), 'INTERSECTION', newnodata1::text, newnodata1::text, newnodata1);
				rtn := ST_SetBandNodataValue(rtn, 1, newnodata1);
			WHEN _returnband = 'BAND2' THEN
				rtn := ST_MapAlgebraExpr(rast1, band1, rast2, band2, '[rast2.val]', ST_BandPixelType(rast2, band2), 'INTERSECTION', newnodata2::text, newnodata2::text, newnodata2);
				rtn := ST_SetBandNodataValue(rtn, 1, newnodata2);
			WHEN _returnband = 'BOTH' THEN
				rtn := ST_MapAlgebraExpr(rast1, band1, rast2, band2, '[rast1.val]', ST_BandPixelType(rast1, band1), 'INTERSECTION', newnodata1::text, newnodata1::text, newnodata1);
				rtn := ST_SetBandNodataValue(rtn, 1, newnodata1);
				rtn := ST_AddBand(rtn, ST_MapAlgebraExpr(rast1, band1, rast2, band2, '[rast2.val]', ST_BandPixelType(rast2, band2), 'INTERSECTION', newnodata2::text, newnodata2::text, newnodata2));
				rtn := ST_SetBandNodataValue(rtn, 2, newnodata2);
			ELSE
				RAISE EXCEPTION 'Unknown value provided for returnband: %', returnband;
				RETURN NULL;
		END CASE;
		RETURN rtn;
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, band1 integer, rast2 raster, band2 integer, returnband text, nodataval double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, $2, $3, $4, $5, ARRAY[$6, $6]) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, band1 integer, rast2 raster, band2 integer, nodataval double precision[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, $2, $3, $4, 'BOTH', $5) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, band1 integer, rast2 raster, band2 integer, nodataval double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, $2, $3, $4, 'BOTH', ARRAY[$5, $5]) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, rast2 raster, returnband text DEFAULT 'BOTH'::text, nodataval double precision[] DEFAULT NULL::double precision[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, 1, $2, 1, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, rast2 raster, returnband text, nodataval double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, 1, $2, 1, $3, ARRAY[$4, $4]) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, rast2 raster, nodataval double precision[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, 1, $2, 1, 'BOTH', $3) $function$
CREATE OR REPLACE FUNCTION public.st_intersection(rast1 raster, rast2 raster, nodataval double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_intersection($1, 1, $2, 1, 'BOTH', ARRAY[$3, $3]) $function$

CREATE OR REPLACE FUNCTION public.st_intersects(geom1 geometry, geom2 geometry)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$SELECT $1 && $2 AND _ST_Intersects($1,$2)$function$
CREATE OR REPLACE FUNCTION public.st_intersects(geography, geography)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$SELECT $1 && $2 AND _ST_Distance($1, $2, 0.0, false) < 0.00001$function$
CREATE OR REPLACE FUNCTION public.st_intersects(text, text)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT ST_Intersects($1::geometry, $2::geometry);  $function$
CREATE OR REPLACE FUNCTION public.st_intersects(rast1 raster, nband1 integer, rast2 raster, nband2 integer)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT $1 && $3 AND CASE WHEN $2 IS NULL OR $4 IS NULL THEN _st_intersects(st_convexhull($1), st_convexhull($3)) ELSE _st_intersects($1, $2, $3, $4) END $function$
CREATE OR REPLACE FUNCTION public.st_intersects(rast1 raster, rast2 raster)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT st_intersects($1, NULL::integer, $2, NULL::integer) $function$
CREATE OR REPLACE FUNCTION public.st_intersects(geom geometry, rast raster, nband integer DEFAULT NULL::integer)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT $1 && $2::geometry AND _st_intersects($1, $2, $3); $function$
CREATE OR REPLACE FUNCTION public.st_intersects(rast raster, geom geometry, nband integer DEFAULT NULL::integer)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT $1::geometry && $2 AND _st_intersects($2, $1, $3) $function$
CREATE OR REPLACE FUNCTION public.st_intersects(rast raster, nband integer, geom geometry)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT $1::geometry && $3 AND _st_intersects($3, $1, $2) $function$

CREATE OR REPLACE FUNCTION public.st_intersects(geom1 geometry, geom2 geometry)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$SELECT $1 && $2 AND _ST_Intersects($1,$2)$function$
CREATE OR REPLACE FUNCTION public.st_intersects(geography, geography)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$SELECT $1 && $2 AND _ST_Distance($1, $2, 0.0, false) < 0.00001$function$
CREATE OR REPLACE FUNCTION public.st_intersects(text, text)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT ST_Intersects($1::geometry, $2::geometry);  $function$
CREATE OR REPLACE FUNCTION public.st_intersects(rast1 raster, nband1 integer, rast2 raster, nband2 integer)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT $1 && $3 AND CASE WHEN $2 IS NULL OR $4 IS NULL THEN _st_intersects(st_convexhull($1), st_convexhull($3)) ELSE _st_intersects($1, $2, $3, $4) END $function$
CREATE OR REPLACE FUNCTION public.st_intersects(rast1 raster, rast2 raster)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT st_intersects($1, NULL::integer, $2, NULL::integer) $function$
CREATE OR REPLACE FUNCTION public.st_intersects(geom geometry, rast raster, nband integer DEFAULT NULL::integer)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT $1 && $2::geometry AND _st_intersects($1, $2, $3); $function$
CREATE OR REPLACE FUNCTION public.st_intersects(rast raster, geom geometry, nband integer DEFAULT NULL::integer)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT $1::geometry && $2 AND _st_intersects($2, $1, $3) $function$
CREATE OR REPLACE FUNCTION public.st_intersects(rast raster, nband integer, geom geometry)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT $1::geometry && $3 AND _st_intersects($3, $1, $2) $function$

CREATE OR REPLACE FUNCTION public.st_intersects(geom1 geometry, geom2 geometry)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$SELECT $1 && $2 AND _ST_Intersects($1,$2)$function$
CREATE OR REPLACE FUNCTION public.st_intersects(geography, geography)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$SELECT $1 && $2 AND _ST_Distance($1, $2, 0.0, false) < 0.00001$function$
CREATE OR REPLACE FUNCTION public.st_intersects(text, text)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT ST_Intersects($1::geometry, $2::geometry);  $function$
CREATE OR REPLACE FUNCTION public.st_intersects(rast1 raster, nband1 integer, rast2 raster, nband2 integer)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT $1 && $3 AND CASE WHEN $2 IS NULL OR $4 IS NULL THEN _st_intersects(st_convexhull($1), st_convexhull($3)) ELSE _st_intersects($1, $2, $3, $4) END $function$
CREATE OR REPLACE FUNCTION public.st_intersects(rast1 raster, rast2 raster)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT st_intersects($1, NULL::integer, $2, NULL::integer) $function$
CREATE OR REPLACE FUNCTION public.st_intersects(geom geometry, rast raster, nband integer DEFAULT NULL::integer)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT $1 && $2::geometry AND _st_intersects($1, $2, $3); $function$
CREATE OR REPLACE FUNCTION public.st_intersects(rast raster, geom geometry, nband integer DEFAULT NULL::integer)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT $1::geometry && $2 AND _st_intersects($2, $1, $3) $function$
CREATE OR REPLACE FUNCTION public.st_intersects(rast raster, nband integer, geom geometry)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT $1::geometry && $3 AND _st_intersects($3, $1, $2) $function$

CREATE OR REPLACE FUNCTION public.st_intersects(geom1 geometry, geom2 geometry)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$SELECT $1 && $2 AND _ST_Intersects($1,$2)$function$
CREATE OR REPLACE FUNCTION public.st_intersects(geography, geography)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$SELECT $1 && $2 AND _ST_Distance($1, $2, 0.0, false) < 0.00001$function$
CREATE OR REPLACE FUNCTION public.st_intersects(text, text)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT ST_Intersects($1::geometry, $2::geometry);  $function$
CREATE OR REPLACE FUNCTION public.st_intersects(rast1 raster, nband1 integer, rast2 raster, nband2 integer)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT $1 && $3 AND CASE WHEN $2 IS NULL OR $4 IS NULL THEN _st_intersects(st_convexhull($1), st_convexhull($3)) ELSE _st_intersects($1, $2, $3, $4) END $function$
CREATE OR REPLACE FUNCTION public.st_intersects(rast1 raster, rast2 raster)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT st_intersects($1, NULL::integer, $2, NULL::integer) $function$
CREATE OR REPLACE FUNCTION public.st_intersects(geom geometry, rast raster, nband integer DEFAULT NULL::integer)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT $1 && $2::geometry AND _st_intersects($1, $2, $3); $function$
CREATE OR REPLACE FUNCTION public.st_intersects(rast raster, geom geometry, nband integer DEFAULT NULL::integer)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT $1::geometry && $2 AND _st_intersects($2, $1, $3) $function$
CREATE OR REPLACE FUNCTION public.st_intersects(rast raster, nband integer, geom geometry)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT $1::geometry && $3 AND _st_intersects($3, $1, $2) $function$

CREATE OR REPLACE FUNCTION public.st_intersects(geom1 geometry, geom2 geometry)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$SELECT $1 && $2 AND _ST_Intersects($1,$2)$function$
CREATE OR REPLACE FUNCTION public.st_intersects(geography, geography)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$SELECT $1 && $2 AND _ST_Distance($1, $2, 0.0, false) < 0.00001$function$
CREATE OR REPLACE FUNCTION public.st_intersects(text, text)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT ST_Intersects($1::geometry, $2::geometry);  $function$
CREATE OR REPLACE FUNCTION public.st_intersects(rast1 raster, nband1 integer, rast2 raster, nband2 integer)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT $1 && $3 AND CASE WHEN $2 IS NULL OR $4 IS NULL THEN _st_intersects(st_convexhull($1), st_convexhull($3)) ELSE _st_intersects($1, $2, $3, $4) END $function$
CREATE OR REPLACE FUNCTION public.st_intersects(rast1 raster, rast2 raster)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT st_intersects($1, NULL::integer, $2, NULL::integer) $function$
CREATE OR REPLACE FUNCTION public.st_intersects(geom geometry, rast raster, nband integer DEFAULT NULL::integer)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT $1 && $2::geometry AND _st_intersects($1, $2, $3); $function$
CREATE OR REPLACE FUNCTION public.st_intersects(rast raster, geom geometry, nband integer DEFAULT NULL::integer)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT $1::geometry && $2 AND _st_intersects($2, $1, $3) $function$
CREATE OR REPLACE FUNCTION public.st_intersects(rast raster, nband integer, geom geometry)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT $1::geometry && $3 AND _st_intersects($3, $1, $2) $function$

CREATE OR REPLACE FUNCTION public.st_intersects(geom1 geometry, geom2 geometry)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$SELECT $1 && $2 AND _ST_Intersects($1,$2)$function$
CREATE OR REPLACE FUNCTION public.st_intersects(geography, geography)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$SELECT $1 && $2 AND _ST_Distance($1, $2, 0.0, false) < 0.00001$function$
CREATE OR REPLACE FUNCTION public.st_intersects(text, text)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT ST_Intersects($1::geometry, $2::geometry);  $function$
CREATE OR REPLACE FUNCTION public.st_intersects(rast1 raster, nband1 integer, rast2 raster, nband2 integer)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT $1 && $3 AND CASE WHEN $2 IS NULL OR $4 IS NULL THEN _st_intersects(st_convexhull($1), st_convexhull($3)) ELSE _st_intersects($1, $2, $3, $4) END $function$
CREATE OR REPLACE FUNCTION public.st_intersects(rast1 raster, rast2 raster)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT st_intersects($1, NULL::integer, $2, NULL::integer) $function$
CREATE OR REPLACE FUNCTION public.st_intersects(geom geometry, rast raster, nband integer DEFAULT NULL::integer)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT $1 && $2::geometry AND _st_intersects($1, $2, $3); $function$
CREATE OR REPLACE FUNCTION public.st_intersects(rast raster, geom geometry, nband integer DEFAULT NULL::integer)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT $1::geometry && $2 AND _st_intersects($2, $1, $3) $function$
CREATE OR REPLACE FUNCTION public.st_intersects(rast raster, nband integer, geom geometry)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT $1::geometry && $3 AND _st_intersects($3, $1, $2) $function$

CREATE OR REPLACE FUNCTION public.st_intersects(geom1 geometry, geom2 geometry)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$SELECT $1 && $2 AND _ST_Intersects($1,$2)$function$
CREATE OR REPLACE FUNCTION public.st_intersects(geography, geography)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$SELECT $1 && $2 AND _ST_Distance($1, $2, 0.0, false) < 0.00001$function$
CREATE OR REPLACE FUNCTION public.st_intersects(text, text)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT ST_Intersects($1::geometry, $2::geometry);  $function$
CREATE OR REPLACE FUNCTION public.st_intersects(rast1 raster, nband1 integer, rast2 raster, nband2 integer)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT $1 && $3 AND CASE WHEN $2 IS NULL OR $4 IS NULL THEN _st_intersects(st_convexhull($1), st_convexhull($3)) ELSE _st_intersects($1, $2, $3, $4) END $function$
CREATE OR REPLACE FUNCTION public.st_intersects(rast1 raster, rast2 raster)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT st_intersects($1, NULL::integer, $2, NULL::integer) $function$
CREATE OR REPLACE FUNCTION public.st_intersects(geom geometry, rast raster, nband integer DEFAULT NULL::integer)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT $1 && $2::geometry AND _st_intersects($1, $2, $3); $function$
CREATE OR REPLACE FUNCTION public.st_intersects(rast raster, geom geometry, nband integer DEFAULT NULL::integer)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT $1::geometry && $2 AND _st_intersects($2, $1, $3) $function$
CREATE OR REPLACE FUNCTION public.st_intersects(rast raster, nband integer, geom geometry)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT $1::geometry && $3 AND _st_intersects($3, $1, $2) $function$

CREATE OR REPLACE FUNCTION public.st_isempty(geometry)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_isempty$function$
CREATE OR REPLACE FUNCTION public.st_isempty(rast raster)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/rtpostgis-2.2', $function$RASTER_isEmpty$function$

CREATE OR REPLACE FUNCTION public.st_isvalid(geometry)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT COST 100
AS '$libdir/postgis-2.2', $function$isvalid$function$
CREATE OR REPLACE FUNCTION public.st_isvalid(geometry, integer)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT (ST_isValidDetail($1, $2)).valid$function$

CREATE OR REPLACE FUNCTION public.st_isvaliddetail(geometry)
 RETURNS valid_detail
 LANGUAGE c
 IMMUTABLE STRICT COST 100
AS '$libdir/postgis-2.2', $function$isvaliddetail$function$
CREATE OR REPLACE FUNCTION public.st_isvaliddetail(geometry, integer)
 RETURNS valid_detail
 LANGUAGE c
 IMMUTABLE STRICT COST 100
AS '$libdir/postgis-2.2', $function$isvaliddetail$function$

CREATE OR REPLACE FUNCTION public.st_isvalidreason(geometry)
 RETURNS text
 LANGUAGE c
 IMMUTABLE STRICT COST 100
AS '$libdir/postgis-2.2', $function$isvalidreason$function$
CREATE OR REPLACE FUNCTION public.st_isvalidreason(geometry, integer)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
SELECT CASE WHEN valid THEN 'Valid Geometry' ELSE reason END FROM (
	SELECT (ST_isValidDetail($1, $2)).*
) foo
	$function$

CREATE OR REPLACE FUNCTION public.st_length(text)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT ST_Length($1::geometry);  $function$
CREATE OR REPLACE FUNCTION public.st_length(geometry)
 RETURNS double precision
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_length2d_linestring$function$
CREATE OR REPLACE FUNCTION public.st_length(geog geography, use_spheroid boolean DEFAULT true)
 RETURNS double precision
 LANGUAGE c
 IMMUTABLE STRICT COST 100
AS '$libdir/postgis-2.2', $function$geography_length$function$

CREATE OR REPLACE FUNCTION public.st_length(text)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT ST_Length($1::geometry);  $function$
CREATE OR REPLACE FUNCTION public.st_length(geometry)
 RETURNS double precision
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_length2d_linestring$function$
CREATE OR REPLACE FUNCTION public.st_length(geog geography, use_spheroid boolean DEFAULT true)
 RETURNS double precision
 LANGUAGE c
 IMMUTABLE STRICT COST 100
AS '$libdir/postgis-2.2', $function$geography_length$function$

CREATE OR REPLACE FUNCTION public.st_linefromtext(text)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
	SELECT CASE WHEN geometrytype(ST_GeomFromText($1)) = 'LINESTRING'
	THEN ST_GeomFromText($1)
	ELSE NULL END
	$function$
CREATE OR REPLACE FUNCTION public.st_linefromtext(text, integer)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
	SELECT CASE WHEN geometrytype(ST_GeomFromText($1, $2)) = 'LINESTRING'
	THEN ST_GeomFromText($1,$2)
	ELSE NULL END
	$function$

CREATE OR REPLACE FUNCTION public.st_linefromwkb(bytea)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
	SELECT CASE WHEN geometrytype(ST_GeomFromWKB($1)) = 'LINESTRING'
	THEN ST_GeomFromWKB($1)
	ELSE NULL END
	$function$
CREATE OR REPLACE FUNCTION public.st_linefromwkb(bytea, integer)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
	SELECT CASE WHEN geometrytype(ST_GeomFromWKB($1, $2)) = 'LINESTRING'
	THEN ST_GeomFromWKB($1, $2)
	ELSE NULL END
	$function$

CREATE OR REPLACE FUNCTION public.st_linestringfromwkb(bytea)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
	SELECT CASE WHEN geometrytype(ST_GeomFromWKB($1)) = 'LINESTRING'
	THEN ST_GeomFromWKB($1)
	ELSE NULL END
	$function$
CREATE OR REPLACE FUNCTION public.st_linestringfromwkb(bytea, integer)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
	SELECT CASE WHEN geometrytype(ST_GeomFromWKB($1, $2)) = 'LINESTRING'
	THEN ST_GeomFromWKB($1, $2)
	ELSE NULL END
	$function$

CREATE OR REPLACE FUNCTION public.st_makeemptyraster(rast raster)
 RETURNS raster
 LANGUAGE plpgsql
 IMMUTABLE STRICT
AS $function$
		DECLARE
			w int;
			h int;
			ul_x double precision;
			ul_y double precision;
			scale_x double precision;
			scale_y double precision;
			skew_x double precision;
			skew_y double precision;
			sr_id int;
		BEGIN
			SELECT width, height, upperleftx, upperlefty, scalex, scaley, skewx, skewy, srid INTO w, h, ul_x, ul_y, scale_x, scale_y, skew_x, skew_y, sr_id FROM ST_Metadata(rast);
			RETURN st_makeemptyraster(w, h, ul_x, ul_y, scale_x, scale_y, skew_x, skew_y, sr_id);
		END;
    $function$
CREATE OR REPLACE FUNCTION public.st_makeemptyraster(width integer, height integer, upperleftx double precision, upperlefty double precision, pixelsize double precision)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT st_makeemptyraster($1, $2, $3, $4, $5, -($5), 0, 0, ST_SRID('POINT(0 0)'::geometry)) $function$
CREATE OR REPLACE FUNCTION public.st_makeemptyraster(width integer, height integer, upperleftx double precision, upperlefty double precision, scalex double precision, scaley double precision, skewx double precision, skewy double precision, srid integer DEFAULT 0)
 RETURNS raster
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/rtpostgis-2.2', $function$RASTER_makeEmpty$function$

CREATE OR REPLACE FUNCTION public.st_makeemptyraster(rast raster)
 RETURNS raster
 LANGUAGE plpgsql
 IMMUTABLE STRICT
AS $function$
		DECLARE
			w int;
			h int;
			ul_x double precision;
			ul_y double precision;
			scale_x double precision;
			scale_y double precision;
			skew_x double precision;
			skew_y double precision;
			sr_id int;
		BEGIN
			SELECT width, height, upperleftx, upperlefty, scalex, scaley, skewx, skewy, srid INTO w, h, ul_x, ul_y, scale_x, scale_y, skew_x, skew_y, sr_id FROM ST_Metadata(rast);
			RETURN st_makeemptyraster(w, h, ul_x, ul_y, scale_x, scale_y, skew_x, skew_y, sr_id);
		END;
    $function$
CREATE OR REPLACE FUNCTION public.st_makeemptyraster(width integer, height integer, upperleftx double precision, upperlefty double precision, pixelsize double precision)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT st_makeemptyraster($1, $2, $3, $4, $5, -($5), 0, 0, ST_SRID('POINT(0 0)'::geometry)) $function$
CREATE OR REPLACE FUNCTION public.st_makeemptyraster(width integer, height integer, upperleftx double precision, upperlefty double precision, scalex double precision, scaley double precision, skewx double precision, skewy double precision, srid integer DEFAULT 0)
 RETURNS raster
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/rtpostgis-2.2', $function$RASTER_makeEmpty$function$

CREATE OR REPLACE FUNCTION public.st_makeline(geometry[])
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_makeline_garray$function$
CREATE OR REPLACE FUNCTION public.st_makeline(geom1 geometry, geom2 geometry)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_makeline$function$

CREATE OR REPLACE FUNCTION public.st_makeline(geometry[])
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_makeline_garray$function$
CREATE OR REPLACE FUNCTION public.st_makeline(geom1 geometry, geom2 geometry)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_makeline$function$

CREATE OR REPLACE FUNCTION public.st_makepoint(double precision, double precision)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_makepoint$function$
CREATE OR REPLACE FUNCTION public.st_makepoint(double precision, double precision, double precision)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_makepoint$function$
CREATE OR REPLACE FUNCTION public.st_makepoint(double precision, double precision, double precision, double precision)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_makepoint$function$

CREATE OR REPLACE FUNCTION public.st_makepoint(double precision, double precision)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_makepoint$function$
CREATE OR REPLACE FUNCTION public.st_makepoint(double precision, double precision, double precision)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_makepoint$function$
CREATE OR REPLACE FUNCTION public.st_makepoint(double precision, double precision, double precision, double precision)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_makepoint$function$

CREATE OR REPLACE FUNCTION public.st_makepolygon(geometry)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_makepoly$function$
CREATE OR REPLACE FUNCTION public.st_makepolygon(geometry, geometry[])
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_makepoly$function$

CREATE OR REPLACE FUNCTION public.st_mapalgebra(rast raster, pixeltype text, expression text, nodataval double precision DEFAULT NULL::double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_mapalgebra($1, 1, $2, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebra(rastbandargset rastbandarg[], callbackfunc regprocedure, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'INTERSECTION'::text, customextent raster DEFAULT NULL::raster, distancex integer DEFAULT 0, distancey integer DEFAULT 0, VARIADIC userargs text[] DEFAULT NULL::text[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _ST_MapAlgebra($1, $2, $3, $6, $7, $4, $5,NULL::double precision [],NULL::boolean, VARIADIC $8) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebra(rast1 raster, band1 integer, rast2 raster, band2 integer, expression text, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'INTERSECTION'::text, nodata1expr text DEFAULT NULL::text, nodata2expr text DEFAULT NULL::text, nodatanodataval double precision DEFAULT NULL::double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_mapalgebra(ARRAY[ROW($1, $2), ROW($3, $4)]::rastbandarg[], $5, $6, $7, $8, $9, $10) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebra(rast raster, nband integer[], callbackfunc regprocedure, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'FIRST'::text, customextent raster DEFAULT NULL::raster, distancex integer DEFAULT 0, distancey integer DEFAULT 0, VARIADIC userargs text[] DEFAULT NULL::text[])
 RETURNS raster
 LANGUAGE plpgsql
 STABLE
AS $function$
	DECLARE
		x int;
		argset rastbandarg[];
	BEGIN
		IF $2 IS NULL OR array_ndims($2) < 1 OR array_length($2, 1) < 1 THEN
			RAISE EXCEPTION 'Populated 1D array must be provided for nband';
			RETURN NULL;
		END IF;
		FOR x IN array_lower($2, 1)..array_upper($2, 1) LOOP
			IF $2[x] IS NULL THEN
				CONTINUE;
			END IF;
			argset := argset || ROW($1, $2[x])::rastbandarg;
		END LOOP;
		IF array_length(argset, 1) < 1 THEN
			RAISE EXCEPTION 'Populated 1D array must be provided for nband';
			RETURN NULL;
		END IF;
		RETURN _ST_MapAlgebra(argset, $3, $4, $7, $8, $5, $6,NULL::double precision [],NULL::boolean, VARIADIC $9);
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_mapalgebra(rast raster, nband integer, callbackfunc regprocedure, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'FIRST'::text, customextent raster DEFAULT NULL::raster, distancex integer DEFAULT 0, distancey integer DEFAULT 0, VARIADIC userargs text[] DEFAULT NULL::text[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _ST_MapAlgebra(ARRAY[ROW($1, $2)]::rastbandarg[], $3, $4, $7, $8, $5, $6,NULL::double precision [],NULL::boolean, VARIADIC $9) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebra(rast1 raster, nband1 integer, rast2 raster, nband2 integer, callbackfunc regprocedure, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'INTERSECTION'::text, customextent raster DEFAULT NULL::raster, distancex integer DEFAULT 0, distancey integer DEFAULT 0, VARIADIC userargs text[] DEFAULT NULL::text[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _ST_MapAlgebra(ARRAY[ROW($1, $2), ROW($3, $4)]::rastbandarg[], $5, $6, $9, $10, $7, $8,NULL::double precision [],NULL::boolean, VARIADIC $11) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebra(rast raster, nband integer, callbackfunc regprocedure, mask double precision[], weighted boolean, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'INTERSECTION'::text, customextent raster DEFAULT NULL::raster, VARIADIC userargs text[] DEFAULT NULL::text[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$
	select _st_mapalgebra(ARRAY[ROW($1,$2)]::rastbandarg[],$3,$6,NULL::integer,NULL::integer,$7,$8,$4,$5,VARIADIC $9)
	$function$
CREATE OR REPLACE FUNCTION public.st_mapalgebra(rast raster, nband integer, pixeltype text, expression text, nodataval double precision DEFAULT NULL::double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_mapalgebra(ARRAY[ROW($1, $2)]::rastbandarg[], $4, $3, 'FIRST', $5::text) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebra(rast1 raster, rast2 raster, expression text, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'INTERSECTION'::text, nodata1expr text DEFAULT NULL::text, nodata2expr text DEFAULT NULL::text, nodatanodataval double precision DEFAULT NULL::double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_mapalgebra($1, 1, $2, 1, $3, $4, $5, $6, $7, $8) $function$

CREATE OR REPLACE FUNCTION public.st_mapalgebra(rast raster, pixeltype text, expression text, nodataval double precision DEFAULT NULL::double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_mapalgebra($1, 1, $2, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebra(rastbandargset rastbandarg[], callbackfunc regprocedure, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'INTERSECTION'::text, customextent raster DEFAULT NULL::raster, distancex integer DEFAULT 0, distancey integer DEFAULT 0, VARIADIC userargs text[] DEFAULT NULL::text[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _ST_MapAlgebra($1, $2, $3, $6, $7, $4, $5,NULL::double precision [],NULL::boolean, VARIADIC $8) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebra(rast1 raster, band1 integer, rast2 raster, band2 integer, expression text, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'INTERSECTION'::text, nodata1expr text DEFAULT NULL::text, nodata2expr text DEFAULT NULL::text, nodatanodataval double precision DEFAULT NULL::double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_mapalgebra(ARRAY[ROW($1, $2), ROW($3, $4)]::rastbandarg[], $5, $6, $7, $8, $9, $10) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebra(rast raster, nband integer[], callbackfunc regprocedure, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'FIRST'::text, customextent raster DEFAULT NULL::raster, distancex integer DEFAULT 0, distancey integer DEFAULT 0, VARIADIC userargs text[] DEFAULT NULL::text[])
 RETURNS raster
 LANGUAGE plpgsql
 STABLE
AS $function$
	DECLARE
		x int;
		argset rastbandarg[];
	BEGIN
		IF $2 IS NULL OR array_ndims($2) < 1 OR array_length($2, 1) < 1 THEN
			RAISE EXCEPTION 'Populated 1D array must be provided for nband';
			RETURN NULL;
		END IF;
		FOR x IN array_lower($2, 1)..array_upper($2, 1) LOOP
			IF $2[x] IS NULL THEN
				CONTINUE;
			END IF;
			argset := argset || ROW($1, $2[x])::rastbandarg;
		END LOOP;
		IF array_length(argset, 1) < 1 THEN
			RAISE EXCEPTION 'Populated 1D array must be provided for nband';
			RETURN NULL;
		END IF;
		RETURN _ST_MapAlgebra(argset, $3, $4, $7, $8, $5, $6,NULL::double precision [],NULL::boolean, VARIADIC $9);
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_mapalgebra(rast raster, nband integer, callbackfunc regprocedure, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'FIRST'::text, customextent raster DEFAULT NULL::raster, distancex integer DEFAULT 0, distancey integer DEFAULT 0, VARIADIC userargs text[] DEFAULT NULL::text[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _ST_MapAlgebra(ARRAY[ROW($1, $2)]::rastbandarg[], $3, $4, $7, $8, $5, $6,NULL::double precision [],NULL::boolean, VARIADIC $9) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebra(rast1 raster, nband1 integer, rast2 raster, nband2 integer, callbackfunc regprocedure, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'INTERSECTION'::text, customextent raster DEFAULT NULL::raster, distancex integer DEFAULT 0, distancey integer DEFAULT 0, VARIADIC userargs text[] DEFAULT NULL::text[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _ST_MapAlgebra(ARRAY[ROW($1, $2), ROW($3, $4)]::rastbandarg[], $5, $6, $9, $10, $7, $8,NULL::double precision [],NULL::boolean, VARIADIC $11) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebra(rast raster, nband integer, callbackfunc regprocedure, mask double precision[], weighted boolean, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'INTERSECTION'::text, customextent raster DEFAULT NULL::raster, VARIADIC userargs text[] DEFAULT NULL::text[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$
	select _st_mapalgebra(ARRAY[ROW($1,$2)]::rastbandarg[],$3,$6,NULL::integer,NULL::integer,$7,$8,$4,$5,VARIADIC $9)
	$function$
CREATE OR REPLACE FUNCTION public.st_mapalgebra(rast raster, nband integer, pixeltype text, expression text, nodataval double precision DEFAULT NULL::double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_mapalgebra(ARRAY[ROW($1, $2)]::rastbandarg[], $4, $3, 'FIRST', $5::text) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebra(rast1 raster, rast2 raster, expression text, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'INTERSECTION'::text, nodata1expr text DEFAULT NULL::text, nodata2expr text DEFAULT NULL::text, nodatanodataval double precision DEFAULT NULL::double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_mapalgebra($1, 1, $2, 1, $3, $4, $5, $6, $7, $8) $function$

CREATE OR REPLACE FUNCTION public.st_mapalgebra(rast raster, pixeltype text, expression text, nodataval double precision DEFAULT NULL::double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_mapalgebra($1, 1, $2, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebra(rastbandargset rastbandarg[], callbackfunc regprocedure, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'INTERSECTION'::text, customextent raster DEFAULT NULL::raster, distancex integer DEFAULT 0, distancey integer DEFAULT 0, VARIADIC userargs text[] DEFAULT NULL::text[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _ST_MapAlgebra($1, $2, $3, $6, $7, $4, $5,NULL::double precision [],NULL::boolean, VARIADIC $8) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebra(rast1 raster, band1 integer, rast2 raster, band2 integer, expression text, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'INTERSECTION'::text, nodata1expr text DEFAULT NULL::text, nodata2expr text DEFAULT NULL::text, nodatanodataval double precision DEFAULT NULL::double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_mapalgebra(ARRAY[ROW($1, $2), ROW($3, $4)]::rastbandarg[], $5, $6, $7, $8, $9, $10) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebra(rast raster, nband integer[], callbackfunc regprocedure, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'FIRST'::text, customextent raster DEFAULT NULL::raster, distancex integer DEFAULT 0, distancey integer DEFAULT 0, VARIADIC userargs text[] DEFAULT NULL::text[])
 RETURNS raster
 LANGUAGE plpgsql
 STABLE
AS $function$
	DECLARE
		x int;
		argset rastbandarg[];
	BEGIN
		IF $2 IS NULL OR array_ndims($2) < 1 OR array_length($2, 1) < 1 THEN
			RAISE EXCEPTION 'Populated 1D array must be provided for nband';
			RETURN NULL;
		END IF;
		FOR x IN array_lower($2, 1)..array_upper($2, 1) LOOP
			IF $2[x] IS NULL THEN
				CONTINUE;
			END IF;
			argset := argset || ROW($1, $2[x])::rastbandarg;
		END LOOP;
		IF array_length(argset, 1) < 1 THEN
			RAISE EXCEPTION 'Populated 1D array must be provided for nband';
			RETURN NULL;
		END IF;
		RETURN _ST_MapAlgebra(argset, $3, $4, $7, $8, $5, $6,NULL::double precision [],NULL::boolean, VARIADIC $9);
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_mapalgebra(rast raster, nband integer, callbackfunc regprocedure, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'FIRST'::text, customextent raster DEFAULT NULL::raster, distancex integer DEFAULT 0, distancey integer DEFAULT 0, VARIADIC userargs text[] DEFAULT NULL::text[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _ST_MapAlgebra(ARRAY[ROW($1, $2)]::rastbandarg[], $3, $4, $7, $8, $5, $6,NULL::double precision [],NULL::boolean, VARIADIC $9) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebra(rast1 raster, nband1 integer, rast2 raster, nband2 integer, callbackfunc regprocedure, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'INTERSECTION'::text, customextent raster DEFAULT NULL::raster, distancex integer DEFAULT 0, distancey integer DEFAULT 0, VARIADIC userargs text[] DEFAULT NULL::text[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _ST_MapAlgebra(ARRAY[ROW($1, $2), ROW($3, $4)]::rastbandarg[], $5, $6, $9, $10, $7, $8,NULL::double precision [],NULL::boolean, VARIADIC $11) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebra(rast raster, nband integer, callbackfunc regprocedure, mask double precision[], weighted boolean, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'INTERSECTION'::text, customextent raster DEFAULT NULL::raster, VARIADIC userargs text[] DEFAULT NULL::text[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$
	select _st_mapalgebra(ARRAY[ROW($1,$2)]::rastbandarg[],$3,$6,NULL::integer,NULL::integer,$7,$8,$4,$5,VARIADIC $9)
	$function$
CREATE OR REPLACE FUNCTION public.st_mapalgebra(rast raster, nband integer, pixeltype text, expression text, nodataval double precision DEFAULT NULL::double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_mapalgebra(ARRAY[ROW($1, $2)]::rastbandarg[], $4, $3, 'FIRST', $5::text) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebra(rast1 raster, rast2 raster, expression text, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'INTERSECTION'::text, nodata1expr text DEFAULT NULL::text, nodata2expr text DEFAULT NULL::text, nodatanodataval double precision DEFAULT NULL::double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_mapalgebra($1, 1, $2, 1, $3, $4, $5, $6, $7, $8) $function$

CREATE OR REPLACE FUNCTION public.st_mapalgebra(rast raster, pixeltype text, expression text, nodataval double precision DEFAULT NULL::double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_mapalgebra($1, 1, $2, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebra(rastbandargset rastbandarg[], callbackfunc regprocedure, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'INTERSECTION'::text, customextent raster DEFAULT NULL::raster, distancex integer DEFAULT 0, distancey integer DEFAULT 0, VARIADIC userargs text[] DEFAULT NULL::text[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _ST_MapAlgebra($1, $2, $3, $6, $7, $4, $5,NULL::double precision [],NULL::boolean, VARIADIC $8) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebra(rast1 raster, band1 integer, rast2 raster, band2 integer, expression text, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'INTERSECTION'::text, nodata1expr text DEFAULT NULL::text, nodata2expr text DEFAULT NULL::text, nodatanodataval double precision DEFAULT NULL::double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_mapalgebra(ARRAY[ROW($1, $2), ROW($3, $4)]::rastbandarg[], $5, $6, $7, $8, $9, $10) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebra(rast raster, nband integer[], callbackfunc regprocedure, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'FIRST'::text, customextent raster DEFAULT NULL::raster, distancex integer DEFAULT 0, distancey integer DEFAULT 0, VARIADIC userargs text[] DEFAULT NULL::text[])
 RETURNS raster
 LANGUAGE plpgsql
 STABLE
AS $function$
	DECLARE
		x int;
		argset rastbandarg[];
	BEGIN
		IF $2 IS NULL OR array_ndims($2) < 1 OR array_length($2, 1) < 1 THEN
			RAISE EXCEPTION 'Populated 1D array must be provided for nband';
			RETURN NULL;
		END IF;
		FOR x IN array_lower($2, 1)..array_upper($2, 1) LOOP
			IF $2[x] IS NULL THEN
				CONTINUE;
			END IF;
			argset := argset || ROW($1, $2[x])::rastbandarg;
		END LOOP;
		IF array_length(argset, 1) < 1 THEN
			RAISE EXCEPTION 'Populated 1D array must be provided for nband';
			RETURN NULL;
		END IF;
		RETURN _ST_MapAlgebra(argset, $3, $4, $7, $8, $5, $6,NULL::double precision [],NULL::boolean, VARIADIC $9);
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_mapalgebra(rast raster, nband integer, callbackfunc regprocedure, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'FIRST'::text, customextent raster DEFAULT NULL::raster, distancex integer DEFAULT 0, distancey integer DEFAULT 0, VARIADIC userargs text[] DEFAULT NULL::text[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _ST_MapAlgebra(ARRAY[ROW($1, $2)]::rastbandarg[], $3, $4, $7, $8, $5, $6,NULL::double precision [],NULL::boolean, VARIADIC $9) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebra(rast1 raster, nband1 integer, rast2 raster, nband2 integer, callbackfunc regprocedure, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'INTERSECTION'::text, customextent raster DEFAULT NULL::raster, distancex integer DEFAULT 0, distancey integer DEFAULT 0, VARIADIC userargs text[] DEFAULT NULL::text[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _ST_MapAlgebra(ARRAY[ROW($1, $2), ROW($3, $4)]::rastbandarg[], $5, $6, $9, $10, $7, $8,NULL::double precision [],NULL::boolean, VARIADIC $11) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebra(rast raster, nband integer, callbackfunc regprocedure, mask double precision[], weighted boolean, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'INTERSECTION'::text, customextent raster DEFAULT NULL::raster, VARIADIC userargs text[] DEFAULT NULL::text[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$
	select _st_mapalgebra(ARRAY[ROW($1,$2)]::rastbandarg[],$3,$6,NULL::integer,NULL::integer,$7,$8,$4,$5,VARIADIC $9)
	$function$
CREATE OR REPLACE FUNCTION public.st_mapalgebra(rast raster, nband integer, pixeltype text, expression text, nodataval double precision DEFAULT NULL::double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_mapalgebra(ARRAY[ROW($1, $2)]::rastbandarg[], $4, $3, 'FIRST', $5::text) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebra(rast1 raster, rast2 raster, expression text, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'INTERSECTION'::text, nodata1expr text DEFAULT NULL::text, nodata2expr text DEFAULT NULL::text, nodatanodataval double precision DEFAULT NULL::double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_mapalgebra($1, 1, $2, 1, $3, $4, $5, $6, $7, $8) $function$

CREATE OR REPLACE FUNCTION public.st_mapalgebra(rast raster, pixeltype text, expression text, nodataval double precision DEFAULT NULL::double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_mapalgebra($1, 1, $2, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebra(rastbandargset rastbandarg[], callbackfunc regprocedure, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'INTERSECTION'::text, customextent raster DEFAULT NULL::raster, distancex integer DEFAULT 0, distancey integer DEFAULT 0, VARIADIC userargs text[] DEFAULT NULL::text[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _ST_MapAlgebra($1, $2, $3, $6, $7, $4, $5,NULL::double precision [],NULL::boolean, VARIADIC $8) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebra(rast1 raster, band1 integer, rast2 raster, band2 integer, expression text, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'INTERSECTION'::text, nodata1expr text DEFAULT NULL::text, nodata2expr text DEFAULT NULL::text, nodatanodataval double precision DEFAULT NULL::double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_mapalgebra(ARRAY[ROW($1, $2), ROW($3, $4)]::rastbandarg[], $5, $6, $7, $8, $9, $10) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebra(rast raster, nband integer[], callbackfunc regprocedure, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'FIRST'::text, customextent raster DEFAULT NULL::raster, distancex integer DEFAULT 0, distancey integer DEFAULT 0, VARIADIC userargs text[] DEFAULT NULL::text[])
 RETURNS raster
 LANGUAGE plpgsql
 STABLE
AS $function$
	DECLARE
		x int;
		argset rastbandarg[];
	BEGIN
		IF $2 IS NULL OR array_ndims($2) < 1 OR array_length($2, 1) < 1 THEN
			RAISE EXCEPTION 'Populated 1D array must be provided for nband';
			RETURN NULL;
		END IF;
		FOR x IN array_lower($2, 1)..array_upper($2, 1) LOOP
			IF $2[x] IS NULL THEN
				CONTINUE;
			END IF;
			argset := argset || ROW($1, $2[x])::rastbandarg;
		END LOOP;
		IF array_length(argset, 1) < 1 THEN
			RAISE EXCEPTION 'Populated 1D array must be provided for nband';
			RETURN NULL;
		END IF;
		RETURN _ST_MapAlgebra(argset, $3, $4, $7, $8, $5, $6,NULL::double precision [],NULL::boolean, VARIADIC $9);
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_mapalgebra(rast raster, nband integer, callbackfunc regprocedure, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'FIRST'::text, customextent raster DEFAULT NULL::raster, distancex integer DEFAULT 0, distancey integer DEFAULT 0, VARIADIC userargs text[] DEFAULT NULL::text[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _ST_MapAlgebra(ARRAY[ROW($1, $2)]::rastbandarg[], $3, $4, $7, $8, $5, $6,NULL::double precision [],NULL::boolean, VARIADIC $9) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebra(rast1 raster, nband1 integer, rast2 raster, nband2 integer, callbackfunc regprocedure, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'INTERSECTION'::text, customextent raster DEFAULT NULL::raster, distancex integer DEFAULT 0, distancey integer DEFAULT 0, VARIADIC userargs text[] DEFAULT NULL::text[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _ST_MapAlgebra(ARRAY[ROW($1, $2), ROW($3, $4)]::rastbandarg[], $5, $6, $9, $10, $7, $8,NULL::double precision [],NULL::boolean, VARIADIC $11) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebra(rast raster, nband integer, callbackfunc regprocedure, mask double precision[], weighted boolean, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'INTERSECTION'::text, customextent raster DEFAULT NULL::raster, VARIADIC userargs text[] DEFAULT NULL::text[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$
	select _st_mapalgebra(ARRAY[ROW($1,$2)]::rastbandarg[],$3,$6,NULL::integer,NULL::integer,$7,$8,$4,$5,VARIADIC $9)
	$function$
CREATE OR REPLACE FUNCTION public.st_mapalgebra(rast raster, nband integer, pixeltype text, expression text, nodataval double precision DEFAULT NULL::double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_mapalgebra(ARRAY[ROW($1, $2)]::rastbandarg[], $4, $3, 'FIRST', $5::text) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebra(rast1 raster, rast2 raster, expression text, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'INTERSECTION'::text, nodata1expr text DEFAULT NULL::text, nodata2expr text DEFAULT NULL::text, nodatanodataval double precision DEFAULT NULL::double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_mapalgebra($1, 1, $2, 1, $3, $4, $5, $6, $7, $8) $function$

CREATE OR REPLACE FUNCTION public.st_mapalgebra(rast raster, pixeltype text, expression text, nodataval double precision DEFAULT NULL::double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_mapalgebra($1, 1, $2, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebra(rastbandargset rastbandarg[], callbackfunc regprocedure, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'INTERSECTION'::text, customextent raster DEFAULT NULL::raster, distancex integer DEFAULT 0, distancey integer DEFAULT 0, VARIADIC userargs text[] DEFAULT NULL::text[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _ST_MapAlgebra($1, $2, $3, $6, $7, $4, $5,NULL::double precision [],NULL::boolean, VARIADIC $8) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebra(rast1 raster, band1 integer, rast2 raster, band2 integer, expression text, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'INTERSECTION'::text, nodata1expr text DEFAULT NULL::text, nodata2expr text DEFAULT NULL::text, nodatanodataval double precision DEFAULT NULL::double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_mapalgebra(ARRAY[ROW($1, $2), ROW($3, $4)]::rastbandarg[], $5, $6, $7, $8, $9, $10) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebra(rast raster, nband integer[], callbackfunc regprocedure, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'FIRST'::text, customextent raster DEFAULT NULL::raster, distancex integer DEFAULT 0, distancey integer DEFAULT 0, VARIADIC userargs text[] DEFAULT NULL::text[])
 RETURNS raster
 LANGUAGE plpgsql
 STABLE
AS $function$
	DECLARE
		x int;
		argset rastbandarg[];
	BEGIN
		IF $2 IS NULL OR array_ndims($2) < 1 OR array_length($2, 1) < 1 THEN
			RAISE EXCEPTION 'Populated 1D array must be provided for nband';
			RETURN NULL;
		END IF;
		FOR x IN array_lower($2, 1)..array_upper($2, 1) LOOP
			IF $2[x] IS NULL THEN
				CONTINUE;
			END IF;
			argset := argset || ROW($1, $2[x])::rastbandarg;
		END LOOP;
		IF array_length(argset, 1) < 1 THEN
			RAISE EXCEPTION 'Populated 1D array must be provided for nband';
			RETURN NULL;
		END IF;
		RETURN _ST_MapAlgebra(argset, $3, $4, $7, $8, $5, $6,NULL::double precision [],NULL::boolean, VARIADIC $9);
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_mapalgebra(rast raster, nband integer, callbackfunc regprocedure, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'FIRST'::text, customextent raster DEFAULT NULL::raster, distancex integer DEFAULT 0, distancey integer DEFAULT 0, VARIADIC userargs text[] DEFAULT NULL::text[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _ST_MapAlgebra(ARRAY[ROW($1, $2)]::rastbandarg[], $3, $4, $7, $8, $5, $6,NULL::double precision [],NULL::boolean, VARIADIC $9) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebra(rast1 raster, nband1 integer, rast2 raster, nband2 integer, callbackfunc regprocedure, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'INTERSECTION'::text, customextent raster DEFAULT NULL::raster, distancex integer DEFAULT 0, distancey integer DEFAULT 0, VARIADIC userargs text[] DEFAULT NULL::text[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _ST_MapAlgebra(ARRAY[ROW($1, $2), ROW($3, $4)]::rastbandarg[], $5, $6, $9, $10, $7, $8,NULL::double precision [],NULL::boolean, VARIADIC $11) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebra(rast raster, nband integer, callbackfunc regprocedure, mask double precision[], weighted boolean, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'INTERSECTION'::text, customextent raster DEFAULT NULL::raster, VARIADIC userargs text[] DEFAULT NULL::text[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$
	select _st_mapalgebra(ARRAY[ROW($1,$2)]::rastbandarg[],$3,$6,NULL::integer,NULL::integer,$7,$8,$4,$5,VARIADIC $9)
	$function$
CREATE OR REPLACE FUNCTION public.st_mapalgebra(rast raster, nband integer, pixeltype text, expression text, nodataval double precision DEFAULT NULL::double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_mapalgebra(ARRAY[ROW($1, $2)]::rastbandarg[], $4, $3, 'FIRST', $5::text) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebra(rast1 raster, rast2 raster, expression text, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'INTERSECTION'::text, nodata1expr text DEFAULT NULL::text, nodata2expr text DEFAULT NULL::text, nodatanodataval double precision DEFAULT NULL::double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_mapalgebra($1, 1, $2, 1, $3, $4, $5, $6, $7, $8) $function$

CREATE OR REPLACE FUNCTION public.st_mapalgebra(rast raster, pixeltype text, expression text, nodataval double precision DEFAULT NULL::double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_mapalgebra($1, 1, $2, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebra(rastbandargset rastbandarg[], callbackfunc regprocedure, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'INTERSECTION'::text, customextent raster DEFAULT NULL::raster, distancex integer DEFAULT 0, distancey integer DEFAULT 0, VARIADIC userargs text[] DEFAULT NULL::text[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _ST_MapAlgebra($1, $2, $3, $6, $7, $4, $5,NULL::double precision [],NULL::boolean, VARIADIC $8) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebra(rast1 raster, band1 integer, rast2 raster, band2 integer, expression text, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'INTERSECTION'::text, nodata1expr text DEFAULT NULL::text, nodata2expr text DEFAULT NULL::text, nodatanodataval double precision DEFAULT NULL::double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_mapalgebra(ARRAY[ROW($1, $2), ROW($3, $4)]::rastbandarg[], $5, $6, $7, $8, $9, $10) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebra(rast raster, nband integer[], callbackfunc regprocedure, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'FIRST'::text, customextent raster DEFAULT NULL::raster, distancex integer DEFAULT 0, distancey integer DEFAULT 0, VARIADIC userargs text[] DEFAULT NULL::text[])
 RETURNS raster
 LANGUAGE plpgsql
 STABLE
AS $function$
	DECLARE
		x int;
		argset rastbandarg[];
	BEGIN
		IF $2 IS NULL OR array_ndims($2) < 1 OR array_length($2, 1) < 1 THEN
			RAISE EXCEPTION 'Populated 1D array must be provided for nband';
			RETURN NULL;
		END IF;
		FOR x IN array_lower($2, 1)..array_upper($2, 1) LOOP
			IF $2[x] IS NULL THEN
				CONTINUE;
			END IF;
			argset := argset || ROW($1, $2[x])::rastbandarg;
		END LOOP;
		IF array_length(argset, 1) < 1 THEN
			RAISE EXCEPTION 'Populated 1D array must be provided for nband';
			RETURN NULL;
		END IF;
		RETURN _ST_MapAlgebra(argset, $3, $4, $7, $8, $5, $6,NULL::double precision [],NULL::boolean, VARIADIC $9);
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_mapalgebra(rast raster, nband integer, callbackfunc regprocedure, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'FIRST'::text, customextent raster DEFAULT NULL::raster, distancex integer DEFAULT 0, distancey integer DEFAULT 0, VARIADIC userargs text[] DEFAULT NULL::text[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _ST_MapAlgebra(ARRAY[ROW($1, $2)]::rastbandarg[], $3, $4, $7, $8, $5, $6,NULL::double precision [],NULL::boolean, VARIADIC $9) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebra(rast1 raster, nband1 integer, rast2 raster, nband2 integer, callbackfunc regprocedure, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'INTERSECTION'::text, customextent raster DEFAULT NULL::raster, distancex integer DEFAULT 0, distancey integer DEFAULT 0, VARIADIC userargs text[] DEFAULT NULL::text[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _ST_MapAlgebra(ARRAY[ROW($1, $2), ROW($3, $4)]::rastbandarg[], $5, $6, $9, $10, $7, $8,NULL::double precision [],NULL::boolean, VARIADIC $11) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebra(rast raster, nband integer, callbackfunc regprocedure, mask double precision[], weighted boolean, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'INTERSECTION'::text, customextent raster DEFAULT NULL::raster, VARIADIC userargs text[] DEFAULT NULL::text[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$
	select _st_mapalgebra(ARRAY[ROW($1,$2)]::rastbandarg[],$3,$6,NULL::integer,NULL::integer,$7,$8,$4,$5,VARIADIC $9)
	$function$
CREATE OR REPLACE FUNCTION public.st_mapalgebra(rast raster, nband integer, pixeltype text, expression text, nodataval double precision DEFAULT NULL::double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_mapalgebra(ARRAY[ROW($1, $2)]::rastbandarg[], $4, $3, 'FIRST', $5::text) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebra(rast1 raster, rast2 raster, expression text, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'INTERSECTION'::text, nodata1expr text DEFAULT NULL::text, nodata2expr text DEFAULT NULL::text, nodatanodataval double precision DEFAULT NULL::double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_mapalgebra($1, 1, $2, 1, $3, $4, $5, $6, $7, $8) $function$

CREATE OR REPLACE FUNCTION public.st_mapalgebra(rast raster, pixeltype text, expression text, nodataval double precision DEFAULT NULL::double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_mapalgebra($1, 1, $2, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebra(rastbandargset rastbandarg[], callbackfunc regprocedure, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'INTERSECTION'::text, customextent raster DEFAULT NULL::raster, distancex integer DEFAULT 0, distancey integer DEFAULT 0, VARIADIC userargs text[] DEFAULT NULL::text[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _ST_MapAlgebra($1, $2, $3, $6, $7, $4, $5,NULL::double precision [],NULL::boolean, VARIADIC $8) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebra(rast1 raster, band1 integer, rast2 raster, band2 integer, expression text, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'INTERSECTION'::text, nodata1expr text DEFAULT NULL::text, nodata2expr text DEFAULT NULL::text, nodatanodataval double precision DEFAULT NULL::double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_mapalgebra(ARRAY[ROW($1, $2), ROW($3, $4)]::rastbandarg[], $5, $6, $7, $8, $9, $10) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebra(rast raster, nband integer[], callbackfunc regprocedure, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'FIRST'::text, customextent raster DEFAULT NULL::raster, distancex integer DEFAULT 0, distancey integer DEFAULT 0, VARIADIC userargs text[] DEFAULT NULL::text[])
 RETURNS raster
 LANGUAGE plpgsql
 STABLE
AS $function$
	DECLARE
		x int;
		argset rastbandarg[];
	BEGIN
		IF $2 IS NULL OR array_ndims($2) < 1 OR array_length($2, 1) < 1 THEN
			RAISE EXCEPTION 'Populated 1D array must be provided for nband';
			RETURN NULL;
		END IF;
		FOR x IN array_lower($2, 1)..array_upper($2, 1) LOOP
			IF $2[x] IS NULL THEN
				CONTINUE;
			END IF;
			argset := argset || ROW($1, $2[x])::rastbandarg;
		END LOOP;
		IF array_length(argset, 1) < 1 THEN
			RAISE EXCEPTION 'Populated 1D array must be provided for nband';
			RETURN NULL;
		END IF;
		RETURN _ST_MapAlgebra(argset, $3, $4, $7, $8, $5, $6,NULL::double precision [],NULL::boolean, VARIADIC $9);
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_mapalgebra(rast raster, nband integer, callbackfunc regprocedure, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'FIRST'::text, customextent raster DEFAULT NULL::raster, distancex integer DEFAULT 0, distancey integer DEFAULT 0, VARIADIC userargs text[] DEFAULT NULL::text[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _ST_MapAlgebra(ARRAY[ROW($1, $2)]::rastbandarg[], $3, $4, $7, $8, $5, $6,NULL::double precision [],NULL::boolean, VARIADIC $9) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebra(rast1 raster, nband1 integer, rast2 raster, nband2 integer, callbackfunc regprocedure, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'INTERSECTION'::text, customextent raster DEFAULT NULL::raster, distancex integer DEFAULT 0, distancey integer DEFAULT 0, VARIADIC userargs text[] DEFAULT NULL::text[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _ST_MapAlgebra(ARRAY[ROW($1, $2), ROW($3, $4)]::rastbandarg[], $5, $6, $9, $10, $7, $8,NULL::double precision [],NULL::boolean, VARIADIC $11) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebra(rast raster, nband integer, callbackfunc regprocedure, mask double precision[], weighted boolean, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'INTERSECTION'::text, customextent raster DEFAULT NULL::raster, VARIADIC userargs text[] DEFAULT NULL::text[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$
	select _st_mapalgebra(ARRAY[ROW($1,$2)]::rastbandarg[],$3,$6,NULL::integer,NULL::integer,$7,$8,$4,$5,VARIADIC $9)
	$function$
CREATE OR REPLACE FUNCTION public.st_mapalgebra(rast raster, nband integer, pixeltype text, expression text, nodataval double precision DEFAULT NULL::double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_mapalgebra(ARRAY[ROW($1, $2)]::rastbandarg[], $4, $3, 'FIRST', $5::text) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebra(rast1 raster, rast2 raster, expression text, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'INTERSECTION'::text, nodata1expr text DEFAULT NULL::text, nodata2expr text DEFAULT NULL::text, nodatanodataval double precision DEFAULT NULL::double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_mapalgebra($1, 1, $2, 1, $3, $4, $5, $6, $7, $8) $function$

CREATE OR REPLACE FUNCTION public.st_mapalgebraexpr(rast raster, pixeltype text, expression text, nodataval double precision DEFAULT NULL::double precision)
 RETURNS raster
 LANGUAGE sql
AS $function$ SELECT st_mapalgebraexpr($1, 1, $2, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebraexpr(rast raster, band integer, pixeltype text, expression text, nodataval double precision DEFAULT NULL::double precision)
 RETURNS raster
 LANGUAGE c
 IMMUTABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_mapAlgebraExpr$function$
CREATE OR REPLACE FUNCTION public.st_mapalgebraexpr(rast1 raster, rast2 raster, expression text, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'INTERSECTION'::text, nodata1expr text DEFAULT NULL::text, nodata2expr text DEFAULT NULL::text, nodatanodataval double precision DEFAULT NULL::double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_mapalgebraexpr($1, 1, $2, 1, $3, $4, $5, $6, $7, $8) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebraexpr(rast1 raster, band1 integer, rast2 raster, band2 integer, expression text, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'INTERSECTION'::text, nodata1expr text DEFAULT NULL::text, nodata2expr text DEFAULT NULL::text, nodatanodataval double precision DEFAULT NULL::double precision)
 RETURNS raster
 LANGUAGE c
 STABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_mapAlgebra2$function$

CREATE OR REPLACE FUNCTION public.st_mapalgebraexpr(rast raster, pixeltype text, expression text, nodataval double precision DEFAULT NULL::double precision)
 RETURNS raster
 LANGUAGE sql
AS $function$ SELECT st_mapalgebraexpr($1, 1, $2, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebraexpr(rast raster, band integer, pixeltype text, expression text, nodataval double precision DEFAULT NULL::double precision)
 RETURNS raster
 LANGUAGE c
 IMMUTABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_mapAlgebraExpr$function$
CREATE OR REPLACE FUNCTION public.st_mapalgebraexpr(rast1 raster, rast2 raster, expression text, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'INTERSECTION'::text, nodata1expr text DEFAULT NULL::text, nodata2expr text DEFAULT NULL::text, nodatanodataval double precision DEFAULT NULL::double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_mapalgebraexpr($1, 1, $2, 1, $3, $4, $5, $6, $7, $8) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebraexpr(rast1 raster, band1 integer, rast2 raster, band2 integer, expression text, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'INTERSECTION'::text, nodata1expr text DEFAULT NULL::text, nodata2expr text DEFAULT NULL::text, nodatanodataval double precision DEFAULT NULL::double precision)
 RETURNS raster
 LANGUAGE c
 STABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_mapAlgebra2$function$

CREATE OR REPLACE FUNCTION public.st_mapalgebraexpr(rast raster, pixeltype text, expression text, nodataval double precision DEFAULT NULL::double precision)
 RETURNS raster
 LANGUAGE sql
AS $function$ SELECT st_mapalgebraexpr($1, 1, $2, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebraexpr(rast raster, band integer, pixeltype text, expression text, nodataval double precision DEFAULT NULL::double precision)
 RETURNS raster
 LANGUAGE c
 IMMUTABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_mapAlgebraExpr$function$
CREATE OR REPLACE FUNCTION public.st_mapalgebraexpr(rast1 raster, rast2 raster, expression text, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'INTERSECTION'::text, nodata1expr text DEFAULT NULL::text, nodata2expr text DEFAULT NULL::text, nodatanodataval double precision DEFAULT NULL::double precision)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_mapalgebraexpr($1, 1, $2, 1, $3, $4, $5, $6, $7, $8) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebraexpr(rast1 raster, band1 integer, rast2 raster, band2 integer, expression text, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'INTERSECTION'::text, nodata1expr text DEFAULT NULL::text, nodata2expr text DEFAULT NULL::text, nodatanodataval double precision DEFAULT NULL::double precision)
 RETURNS raster
 LANGUAGE c
 STABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_mapAlgebra2$function$

CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, band integer, pixeltype text, onerastuserfunc regprocedure, VARIADIC args text[])
 RETURNS raster
 LANGUAGE c
 IMMUTABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_mapAlgebraFct$function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, band integer, pixeltype text, onerastuserfunc regprocedure)
 RETURNS raster
 LANGUAGE sql
AS $function$ SELECT st_mapalgebrafct($1, $2, $3, $4, NULL) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, band integer, onerastuserfunc regprocedure, VARIADIC args text[])
 RETURNS raster
 LANGUAGE sql
AS $function$ SELECT st_mapalgebrafct($1, $2, NULL, $3, VARIADIC $4) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, band integer, onerastuserfunc regprocedure)
 RETURNS raster
 LANGUAGE sql
AS $function$ SELECT st_mapalgebrafct($1, $2, NULL, $3, NULL) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, pixeltype text, onerastuserfunc regprocedure, VARIADIC args text[])
 RETURNS raster
 LANGUAGE sql
AS $function$ SELECT st_mapalgebrafct($1, 1, $2, $3, VARIADIC $4) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, pixeltype text, onerastuserfunc regprocedure)
 RETURNS raster
 LANGUAGE sql
AS $function$ SELECT st_mapalgebrafct($1, 1, $2, $3, NULL) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, onerastuserfunc regprocedure, VARIADIC args text[])
 RETURNS raster
 LANGUAGE sql
AS $function$ SELECT st_mapalgebrafct($1, 1, NULL, $2, VARIADIC $3) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, onerastuserfunc regprocedure)
 RETURNS raster
 LANGUAGE sql
AS $function$ SELECT st_mapalgebrafct($1, 1, NULL, $2, NULL) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast1 raster, band1 integer, rast2 raster, band2 integer, tworastuserfunc regprocedure, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'INTERSECTION'::text, VARIADIC userargs text[] DEFAULT NULL::text[])
 RETURNS raster
 LANGUAGE c
 STABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_mapAlgebra2$function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast1 raster, rast2 raster, tworastuserfunc regprocedure, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'INTERSECTION'::text, VARIADIC userargs text[] DEFAULT NULL::text[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_mapalgebrafct($1, 1, $2, 1, $3, $4, $5, VARIADIC $6) $function$

CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, band integer, pixeltype text, onerastuserfunc regprocedure, VARIADIC args text[])
 RETURNS raster
 LANGUAGE c
 IMMUTABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_mapAlgebraFct$function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, band integer, pixeltype text, onerastuserfunc regprocedure)
 RETURNS raster
 LANGUAGE sql
AS $function$ SELECT st_mapalgebrafct($1, $2, $3, $4, NULL) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, band integer, onerastuserfunc regprocedure, VARIADIC args text[])
 RETURNS raster
 LANGUAGE sql
AS $function$ SELECT st_mapalgebrafct($1, $2, NULL, $3, VARIADIC $4) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, band integer, onerastuserfunc regprocedure)
 RETURNS raster
 LANGUAGE sql
AS $function$ SELECT st_mapalgebrafct($1, $2, NULL, $3, NULL) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, pixeltype text, onerastuserfunc regprocedure, VARIADIC args text[])
 RETURNS raster
 LANGUAGE sql
AS $function$ SELECT st_mapalgebrafct($1, 1, $2, $3, VARIADIC $4) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, pixeltype text, onerastuserfunc regprocedure)
 RETURNS raster
 LANGUAGE sql
AS $function$ SELECT st_mapalgebrafct($1, 1, $2, $3, NULL) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, onerastuserfunc regprocedure, VARIADIC args text[])
 RETURNS raster
 LANGUAGE sql
AS $function$ SELECT st_mapalgebrafct($1, 1, NULL, $2, VARIADIC $3) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, onerastuserfunc regprocedure)
 RETURNS raster
 LANGUAGE sql
AS $function$ SELECT st_mapalgebrafct($1, 1, NULL, $2, NULL) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast1 raster, band1 integer, rast2 raster, band2 integer, tworastuserfunc regprocedure, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'INTERSECTION'::text, VARIADIC userargs text[] DEFAULT NULL::text[])
 RETURNS raster
 LANGUAGE c
 STABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_mapAlgebra2$function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast1 raster, rast2 raster, tworastuserfunc regprocedure, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'INTERSECTION'::text, VARIADIC userargs text[] DEFAULT NULL::text[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_mapalgebrafct($1, 1, $2, 1, $3, $4, $5, VARIADIC $6) $function$

CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, band integer, pixeltype text, onerastuserfunc regprocedure, VARIADIC args text[])
 RETURNS raster
 LANGUAGE c
 IMMUTABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_mapAlgebraFct$function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, band integer, pixeltype text, onerastuserfunc regprocedure)
 RETURNS raster
 LANGUAGE sql
AS $function$ SELECT st_mapalgebrafct($1, $2, $3, $4, NULL) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, band integer, onerastuserfunc regprocedure, VARIADIC args text[])
 RETURNS raster
 LANGUAGE sql
AS $function$ SELECT st_mapalgebrafct($1, $2, NULL, $3, VARIADIC $4) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, band integer, onerastuserfunc regprocedure)
 RETURNS raster
 LANGUAGE sql
AS $function$ SELECT st_mapalgebrafct($1, $2, NULL, $3, NULL) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, pixeltype text, onerastuserfunc regprocedure, VARIADIC args text[])
 RETURNS raster
 LANGUAGE sql
AS $function$ SELECT st_mapalgebrafct($1, 1, $2, $3, VARIADIC $4) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, pixeltype text, onerastuserfunc regprocedure)
 RETURNS raster
 LANGUAGE sql
AS $function$ SELECT st_mapalgebrafct($1, 1, $2, $3, NULL) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, onerastuserfunc regprocedure, VARIADIC args text[])
 RETURNS raster
 LANGUAGE sql
AS $function$ SELECT st_mapalgebrafct($1, 1, NULL, $2, VARIADIC $3) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, onerastuserfunc regprocedure)
 RETURNS raster
 LANGUAGE sql
AS $function$ SELECT st_mapalgebrafct($1, 1, NULL, $2, NULL) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast1 raster, band1 integer, rast2 raster, band2 integer, tworastuserfunc regprocedure, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'INTERSECTION'::text, VARIADIC userargs text[] DEFAULT NULL::text[])
 RETURNS raster
 LANGUAGE c
 STABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_mapAlgebra2$function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast1 raster, rast2 raster, tworastuserfunc regprocedure, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'INTERSECTION'::text, VARIADIC userargs text[] DEFAULT NULL::text[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_mapalgebrafct($1, 1, $2, 1, $3, $4, $5, VARIADIC $6) $function$

CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, band integer, pixeltype text, onerastuserfunc regprocedure, VARIADIC args text[])
 RETURNS raster
 LANGUAGE c
 IMMUTABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_mapAlgebraFct$function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, band integer, pixeltype text, onerastuserfunc regprocedure)
 RETURNS raster
 LANGUAGE sql
AS $function$ SELECT st_mapalgebrafct($1, $2, $3, $4, NULL) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, band integer, onerastuserfunc regprocedure, VARIADIC args text[])
 RETURNS raster
 LANGUAGE sql
AS $function$ SELECT st_mapalgebrafct($1, $2, NULL, $3, VARIADIC $4) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, band integer, onerastuserfunc regprocedure)
 RETURNS raster
 LANGUAGE sql
AS $function$ SELECT st_mapalgebrafct($1, $2, NULL, $3, NULL) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, pixeltype text, onerastuserfunc regprocedure, VARIADIC args text[])
 RETURNS raster
 LANGUAGE sql
AS $function$ SELECT st_mapalgebrafct($1, 1, $2, $3, VARIADIC $4) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, pixeltype text, onerastuserfunc regprocedure)
 RETURNS raster
 LANGUAGE sql
AS $function$ SELECT st_mapalgebrafct($1, 1, $2, $3, NULL) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, onerastuserfunc regprocedure, VARIADIC args text[])
 RETURNS raster
 LANGUAGE sql
AS $function$ SELECT st_mapalgebrafct($1, 1, NULL, $2, VARIADIC $3) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, onerastuserfunc regprocedure)
 RETURNS raster
 LANGUAGE sql
AS $function$ SELECT st_mapalgebrafct($1, 1, NULL, $2, NULL) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast1 raster, band1 integer, rast2 raster, band2 integer, tworastuserfunc regprocedure, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'INTERSECTION'::text, VARIADIC userargs text[] DEFAULT NULL::text[])
 RETURNS raster
 LANGUAGE c
 STABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_mapAlgebra2$function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast1 raster, rast2 raster, tworastuserfunc regprocedure, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'INTERSECTION'::text, VARIADIC userargs text[] DEFAULT NULL::text[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_mapalgebrafct($1, 1, $2, 1, $3, $4, $5, VARIADIC $6) $function$

CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, band integer, pixeltype text, onerastuserfunc regprocedure, VARIADIC args text[])
 RETURNS raster
 LANGUAGE c
 IMMUTABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_mapAlgebraFct$function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, band integer, pixeltype text, onerastuserfunc regprocedure)
 RETURNS raster
 LANGUAGE sql
AS $function$ SELECT st_mapalgebrafct($1, $2, $3, $4, NULL) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, band integer, onerastuserfunc regprocedure, VARIADIC args text[])
 RETURNS raster
 LANGUAGE sql
AS $function$ SELECT st_mapalgebrafct($1, $2, NULL, $3, VARIADIC $4) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, band integer, onerastuserfunc regprocedure)
 RETURNS raster
 LANGUAGE sql
AS $function$ SELECT st_mapalgebrafct($1, $2, NULL, $3, NULL) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, pixeltype text, onerastuserfunc regprocedure, VARIADIC args text[])
 RETURNS raster
 LANGUAGE sql
AS $function$ SELECT st_mapalgebrafct($1, 1, $2, $3, VARIADIC $4) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, pixeltype text, onerastuserfunc regprocedure)
 RETURNS raster
 LANGUAGE sql
AS $function$ SELECT st_mapalgebrafct($1, 1, $2, $3, NULL) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, onerastuserfunc regprocedure, VARIADIC args text[])
 RETURNS raster
 LANGUAGE sql
AS $function$ SELECT st_mapalgebrafct($1, 1, NULL, $2, VARIADIC $3) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, onerastuserfunc regprocedure)
 RETURNS raster
 LANGUAGE sql
AS $function$ SELECT st_mapalgebrafct($1, 1, NULL, $2, NULL) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast1 raster, band1 integer, rast2 raster, band2 integer, tworastuserfunc regprocedure, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'INTERSECTION'::text, VARIADIC userargs text[] DEFAULT NULL::text[])
 RETURNS raster
 LANGUAGE c
 STABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_mapAlgebra2$function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast1 raster, rast2 raster, tworastuserfunc regprocedure, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'INTERSECTION'::text, VARIADIC userargs text[] DEFAULT NULL::text[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_mapalgebrafct($1, 1, $2, 1, $3, $4, $5, VARIADIC $6) $function$

CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, band integer, pixeltype text, onerastuserfunc regprocedure, VARIADIC args text[])
 RETURNS raster
 LANGUAGE c
 IMMUTABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_mapAlgebraFct$function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, band integer, pixeltype text, onerastuserfunc regprocedure)
 RETURNS raster
 LANGUAGE sql
AS $function$ SELECT st_mapalgebrafct($1, $2, $3, $4, NULL) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, band integer, onerastuserfunc regprocedure, VARIADIC args text[])
 RETURNS raster
 LANGUAGE sql
AS $function$ SELECT st_mapalgebrafct($1, $2, NULL, $3, VARIADIC $4) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, band integer, onerastuserfunc regprocedure)
 RETURNS raster
 LANGUAGE sql
AS $function$ SELECT st_mapalgebrafct($1, $2, NULL, $3, NULL) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, pixeltype text, onerastuserfunc regprocedure, VARIADIC args text[])
 RETURNS raster
 LANGUAGE sql
AS $function$ SELECT st_mapalgebrafct($1, 1, $2, $3, VARIADIC $4) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, pixeltype text, onerastuserfunc regprocedure)
 RETURNS raster
 LANGUAGE sql
AS $function$ SELECT st_mapalgebrafct($1, 1, $2, $3, NULL) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, onerastuserfunc regprocedure, VARIADIC args text[])
 RETURNS raster
 LANGUAGE sql
AS $function$ SELECT st_mapalgebrafct($1, 1, NULL, $2, VARIADIC $3) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, onerastuserfunc regprocedure)
 RETURNS raster
 LANGUAGE sql
AS $function$ SELECT st_mapalgebrafct($1, 1, NULL, $2, NULL) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast1 raster, band1 integer, rast2 raster, band2 integer, tworastuserfunc regprocedure, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'INTERSECTION'::text, VARIADIC userargs text[] DEFAULT NULL::text[])
 RETURNS raster
 LANGUAGE c
 STABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_mapAlgebra2$function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast1 raster, rast2 raster, tworastuserfunc regprocedure, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'INTERSECTION'::text, VARIADIC userargs text[] DEFAULT NULL::text[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_mapalgebrafct($1, 1, $2, 1, $3, $4, $5, VARIADIC $6) $function$

CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, band integer, pixeltype text, onerastuserfunc regprocedure, VARIADIC args text[])
 RETURNS raster
 LANGUAGE c
 IMMUTABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_mapAlgebraFct$function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, band integer, pixeltype text, onerastuserfunc regprocedure)
 RETURNS raster
 LANGUAGE sql
AS $function$ SELECT st_mapalgebrafct($1, $2, $3, $4, NULL) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, band integer, onerastuserfunc regprocedure, VARIADIC args text[])
 RETURNS raster
 LANGUAGE sql
AS $function$ SELECT st_mapalgebrafct($1, $2, NULL, $3, VARIADIC $4) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, band integer, onerastuserfunc regprocedure)
 RETURNS raster
 LANGUAGE sql
AS $function$ SELECT st_mapalgebrafct($1, $2, NULL, $3, NULL) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, pixeltype text, onerastuserfunc regprocedure, VARIADIC args text[])
 RETURNS raster
 LANGUAGE sql
AS $function$ SELECT st_mapalgebrafct($1, 1, $2, $3, VARIADIC $4) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, pixeltype text, onerastuserfunc regprocedure)
 RETURNS raster
 LANGUAGE sql
AS $function$ SELECT st_mapalgebrafct($1, 1, $2, $3, NULL) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, onerastuserfunc regprocedure, VARIADIC args text[])
 RETURNS raster
 LANGUAGE sql
AS $function$ SELECT st_mapalgebrafct($1, 1, NULL, $2, VARIADIC $3) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, onerastuserfunc regprocedure)
 RETURNS raster
 LANGUAGE sql
AS $function$ SELECT st_mapalgebrafct($1, 1, NULL, $2, NULL) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast1 raster, band1 integer, rast2 raster, band2 integer, tworastuserfunc regprocedure, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'INTERSECTION'::text, VARIADIC userargs text[] DEFAULT NULL::text[])
 RETURNS raster
 LANGUAGE c
 STABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_mapAlgebra2$function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast1 raster, rast2 raster, tworastuserfunc regprocedure, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'INTERSECTION'::text, VARIADIC userargs text[] DEFAULT NULL::text[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_mapalgebrafct($1, 1, $2, 1, $3, $4, $5, VARIADIC $6) $function$

CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, band integer, pixeltype text, onerastuserfunc regprocedure, VARIADIC args text[])
 RETURNS raster
 LANGUAGE c
 IMMUTABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_mapAlgebraFct$function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, band integer, pixeltype text, onerastuserfunc regprocedure)
 RETURNS raster
 LANGUAGE sql
AS $function$ SELECT st_mapalgebrafct($1, $2, $3, $4, NULL) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, band integer, onerastuserfunc regprocedure, VARIADIC args text[])
 RETURNS raster
 LANGUAGE sql
AS $function$ SELECT st_mapalgebrafct($1, $2, NULL, $3, VARIADIC $4) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, band integer, onerastuserfunc regprocedure)
 RETURNS raster
 LANGUAGE sql
AS $function$ SELECT st_mapalgebrafct($1, $2, NULL, $3, NULL) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, pixeltype text, onerastuserfunc regprocedure, VARIADIC args text[])
 RETURNS raster
 LANGUAGE sql
AS $function$ SELECT st_mapalgebrafct($1, 1, $2, $3, VARIADIC $4) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, pixeltype text, onerastuserfunc regprocedure)
 RETURNS raster
 LANGUAGE sql
AS $function$ SELECT st_mapalgebrafct($1, 1, $2, $3, NULL) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, onerastuserfunc regprocedure, VARIADIC args text[])
 RETURNS raster
 LANGUAGE sql
AS $function$ SELECT st_mapalgebrafct($1, 1, NULL, $2, VARIADIC $3) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, onerastuserfunc regprocedure)
 RETURNS raster
 LANGUAGE sql
AS $function$ SELECT st_mapalgebrafct($1, 1, NULL, $2, NULL) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast1 raster, band1 integer, rast2 raster, band2 integer, tworastuserfunc regprocedure, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'INTERSECTION'::text, VARIADIC userargs text[] DEFAULT NULL::text[])
 RETURNS raster
 LANGUAGE c
 STABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_mapAlgebra2$function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast1 raster, rast2 raster, tworastuserfunc regprocedure, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'INTERSECTION'::text, VARIADIC userargs text[] DEFAULT NULL::text[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_mapalgebrafct($1, 1, $2, 1, $3, $4, $5, VARIADIC $6) $function$

CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, band integer, pixeltype text, onerastuserfunc regprocedure, VARIADIC args text[])
 RETURNS raster
 LANGUAGE c
 IMMUTABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_mapAlgebraFct$function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, band integer, pixeltype text, onerastuserfunc regprocedure)
 RETURNS raster
 LANGUAGE sql
AS $function$ SELECT st_mapalgebrafct($1, $2, $3, $4, NULL) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, band integer, onerastuserfunc regprocedure, VARIADIC args text[])
 RETURNS raster
 LANGUAGE sql
AS $function$ SELECT st_mapalgebrafct($1, $2, NULL, $3, VARIADIC $4) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, band integer, onerastuserfunc regprocedure)
 RETURNS raster
 LANGUAGE sql
AS $function$ SELECT st_mapalgebrafct($1, $2, NULL, $3, NULL) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, pixeltype text, onerastuserfunc regprocedure, VARIADIC args text[])
 RETURNS raster
 LANGUAGE sql
AS $function$ SELECT st_mapalgebrafct($1, 1, $2, $3, VARIADIC $4) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, pixeltype text, onerastuserfunc regprocedure)
 RETURNS raster
 LANGUAGE sql
AS $function$ SELECT st_mapalgebrafct($1, 1, $2, $3, NULL) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, onerastuserfunc regprocedure, VARIADIC args text[])
 RETURNS raster
 LANGUAGE sql
AS $function$ SELECT st_mapalgebrafct($1, 1, NULL, $2, VARIADIC $3) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast raster, onerastuserfunc regprocedure)
 RETURNS raster
 LANGUAGE sql
AS $function$ SELECT st_mapalgebrafct($1, 1, NULL, $2, NULL) $function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast1 raster, band1 integer, rast2 raster, band2 integer, tworastuserfunc regprocedure, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'INTERSECTION'::text, VARIADIC userargs text[] DEFAULT NULL::text[])
 RETURNS raster
 LANGUAGE c
 STABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_mapAlgebra2$function$
CREATE OR REPLACE FUNCTION public.st_mapalgebrafct(rast1 raster, rast2 raster, tworastuserfunc regprocedure, pixeltype text DEFAULT NULL::text, extenttype text DEFAULT 'INTERSECTION'::text, VARIADIC userargs text[] DEFAULT NULL::text[])
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT st_mapalgebrafct($1, 1, $2, 1, $3, $4, $5, VARIADIC $6) $function$

CREATE OR REPLACE FUNCTION public.st_max4ma(matrix double precision[], nodatamode text, VARIADIC args text[])
 RETURNS double precision
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
    DECLARE
        _matrix float[][];
        max float;
    BEGIN
        _matrix := matrix;
        max := '-Infinity'::float;
        FOR x in array_lower(_matrix, 1)..array_upper(_matrix, 1) LOOP
            FOR y in array_lower(_matrix, 2)..array_upper(_matrix, 2) LOOP
                IF _matrix[x][y] IS NULL THEN
                    IF NOT nodatamode = 'ignore' THEN
                        _matrix[x][y] := nodatamode::float;
                    END IF;
                END IF;
                IF max < _matrix[x][y] THEN
                    max := _matrix[x][y];
                END IF;
            END LOOP;
        END LOOP;
        RETURN max;
    END;
    $function$
CREATE OR REPLACE FUNCTION public.st_max4ma(value double precision[], pos integer[], VARIADIC userargs text[] DEFAULT NULL::text[])
 RETURNS double precision
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
	DECLARE
		_value double precision[][][];
		max double precision;
		x int;
		y int;
		z int;
		ndims int;
	BEGIN
		max := '-Infinity'::double precision;
		ndims := array_ndims(value);
		-- add a third dimension if 2-dimension
		IF ndims = 2 THEN
			_value := _st_convertarray4ma(value);
		ELSEIF ndims != 3 THEN
			RAISE EXCEPTION 'First parameter of function must be a 3-dimension array';
		ELSE
			_value := value;
		END IF;
		-- raster
		FOR z IN array_lower(_value, 1)..array_upper(_value, 1) LOOP
			-- row
			FOR y IN array_lower(_value, 2)..array_upper(_value, 2) LOOP
				-- column
				FOR x IN array_lower(_value, 3)..array_upper(_value, 3) LOOP
					IF _value[z][y][x] IS NULL THEN
						IF array_length(userargs, 1) > 0 THEN
							_value[z][y][x] = userargs[array_lower(userargs, 1)]::double precision;
						ELSE
							CONTINUE;
						END IF;
					END IF;
					IF _value[z][y][x] > max THEN
						max := _value[z][y][x];
					END IF;
				END LOOP;
			END LOOP;
		END LOOP;
		IF max = '-Infinity'::double precision THEN
			RETURN NULL;
		END IF;
		RETURN max;
	END;
	$function$

CREATE OR REPLACE FUNCTION public.st_mean4ma(matrix double precision[], nodatamode text, VARIADIC args text[])
 RETURNS double precision
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
    DECLARE
        _matrix float[][];
        sum float;
        count float;
    BEGIN
        _matrix := matrix;
        sum := 0;
        count := 0;
        FOR x in array_lower(matrix, 1)..array_upper(matrix, 1) LOOP
            FOR y in array_lower(matrix, 2)..array_upper(matrix, 2) LOOP
                IF _matrix[x][y] IS NULL THEN
                    IF nodatamode = 'ignore' THEN
                        _matrix[x][y] := 0;
                    ELSE
                        _matrix[x][y] := nodatamode::float;
                        count := count + 1;
                    END IF;
                ELSE
                    count := count + 1;
                END IF;
                sum := sum + _matrix[x][y];
            END LOOP;
        END LOOP;
        IF count = 0 THEN
            RETURN NULL;
        END IF;
        RETURN sum / count;
    END;
    $function$
CREATE OR REPLACE FUNCTION public.st_mean4ma(value double precision[], pos integer[], VARIADIC userargs text[] DEFAULT NULL::text[])
 RETURNS double precision
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
	DECLARE
		_value double precision[][][];
		sum double precision;
		count int;
		x int;
		y int;
		z int;
		ndims int;
	BEGIN
		sum := 0;
		count := 0;
		ndims := array_ndims(value);
		-- add a third dimension if 2-dimension
		IF ndims = 2 THEN
			_value := _st_convertarray4ma(value);
		ELSEIF ndims != 3 THEN
			RAISE EXCEPTION 'First parameter of function must be a 3-dimension array';
		ELSE
			_value := value;
		END IF;
		-- raster
		FOR z IN array_lower(_value, 1)..array_upper(_value, 1) LOOP
			-- row
			FOR y IN array_lower(_value, 2)..array_upper(_value, 2) LOOP
				-- column
				FOR x IN array_lower(_value, 3)..array_upper(_value, 3) LOOP
					IF _value[z][y][x] IS NULL THEN
						IF array_length(userargs, 1) > 0 THEN
							_value[z][y][x] = userargs[array_lower(userargs, 1)]::double precision;
						ELSE
							CONTINUE;
						END IF;
					END IF;
					sum := sum + _value[z][y][x];
					count := count + 1;
				END LOOP;
			END LOOP;
		END LOOP;
		IF count < 1 THEN
			RETURN NULL;
		END IF;
		RETURN sum / count::double precision;
	END;
	$function$

CREATE OR REPLACE FUNCTION public.st_memsize(geometry)
 RETURNS integer
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_mem_size$function$
CREATE OR REPLACE FUNCTION public.st_memsize(raster)
 RETURNS integer
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/rtpostgis-2.2', $function$RASTER_memsize$function$

CREATE OR REPLACE FUNCTION public.st_min4ma(matrix double precision[], nodatamode text, VARIADIC args text[])
 RETURNS double precision
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
    DECLARE
        _matrix float[][];
        min float;
    BEGIN
        _matrix := matrix;
        min := 'Infinity'::float;
        FOR x in array_lower(_matrix, 1)..array_upper(_matrix, 1) LOOP
            FOR y in array_lower(_matrix, 2)..array_upper(_matrix, 2) LOOP
                IF _matrix[x][y] IS NULL THEN
                    IF NOT nodatamode = 'ignore' THEN
                        _matrix[x][y] := nodatamode::float;
                    END IF;
                END IF;
                IF min > _matrix[x][y] THEN
                    min := _matrix[x][y];
                END IF;
            END LOOP;
        END LOOP;
        RETURN min;
    END;
    $function$
CREATE OR REPLACE FUNCTION public.st_min4ma(value double precision[], pos integer[], VARIADIC userargs text[] DEFAULT NULL::text[])
 RETURNS double precision
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
	DECLARE
		_value double precision[][][];
		min double precision;
		x int;
		y int;
		z int;
		ndims int;
	BEGIN
		min := 'Infinity'::double precision;
		ndims := array_ndims(value);
		-- add a third dimension if 2-dimension
		IF ndims = 2 THEN
			_value := _st_convertarray4ma(value);
		ELSEIF ndims != 3 THEN
			RAISE EXCEPTION 'First parameter of function must be a 3-dimension array';
		ELSE
			_value := value;
		END IF;
		-- raster
		FOR z IN array_lower(_value, 1)..array_upper(_value, 1) LOOP
			-- row
			FOR y IN array_lower(_value, 2)..array_upper(_value, 2) LOOP
				-- column
				FOR x IN array_lower(_value, 3)..array_upper(_value, 3) LOOP
					IF _value[z][y][x] IS NULL THEN
						IF array_length(userargs, 1) > 0 THEN
							_value[z][y][x] = userargs[array_lower(userargs, 1)]::double precision;
						ELSE
							CONTINUE;
						END IF;
					END IF;
					IF _value[z][y][x] < min THEN
						min := _value[z][y][x];
					END IF;
				END LOOP;
			END LOOP;
		END LOOP;
		IF min = 'Infinity'::double precision THEN
			RETURN NULL;
		END IF;
		RETURN min;
	END;
	$function$

CREATE OR REPLACE FUNCTION public.st_mlinefromtext(text)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
	SELECT CASE WHEN geometrytype(ST_GeomFromText($1)) = 'MULTILINESTRING'
	THEN ST_GeomFromText($1)
	ELSE NULL END
	$function$
CREATE OR REPLACE FUNCTION public.st_mlinefromtext(text, integer)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
	SELECT CASE
	WHEN geometrytype(ST_GeomFromText($1, $2)) = 'MULTILINESTRING'
	THEN ST_GeomFromText($1,$2)
	ELSE NULL END
	$function$

CREATE OR REPLACE FUNCTION public.st_mlinefromwkb(bytea)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
	SELECT CASE WHEN geometrytype(ST_GeomFromWKB($1)) = 'MULTILINESTRING'
	THEN ST_GeomFromWKB($1)
	ELSE NULL END
	$function$
CREATE OR REPLACE FUNCTION public.st_mlinefromwkb(bytea, integer)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
	SELECT CASE WHEN geometrytype(ST_GeomFromWKB($1, $2)) = 'MULTILINESTRING'
	THEN ST_GeomFromWKB($1, $2)
	ELSE NULL END
	$function$

CREATE OR REPLACE FUNCTION public.st_mpointfromtext(text)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
	SELECT CASE WHEN geometrytype(ST_GeomFromText($1)) = 'MULTIPOINT'
	THEN ST_GeomFromText($1)
	ELSE NULL END
	$function$
CREATE OR REPLACE FUNCTION public.st_mpointfromtext(text, integer)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
	SELECT CASE WHEN geometrytype(ST_GeomFromText($1, $2)) = 'MULTIPOINT'
	THEN ST_GeomFromText($1, $2)
	ELSE NULL END
	$function$

CREATE OR REPLACE FUNCTION public.st_mpointfromwkb(bytea)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
	SELECT CASE WHEN geometrytype(ST_GeomFromWKB($1)) = 'MULTIPOINT'
	THEN ST_GeomFromWKB($1)
	ELSE NULL END
	$function$
CREATE OR REPLACE FUNCTION public.st_mpointfromwkb(bytea, integer)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
	SELECT CASE WHEN geometrytype(ST_GeomFromWKB($1, $2)) = 'MULTIPOINT'
	THEN ST_GeomFromWKB($1, $2)
	ELSE NULL END
	$function$

CREATE OR REPLACE FUNCTION public.st_mpolyfromtext(text)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
	SELECT CASE WHEN geometrytype(ST_GeomFromText($1)) = 'MULTIPOLYGON'
	THEN ST_GeomFromText($1)
	ELSE NULL END
	$function$
CREATE OR REPLACE FUNCTION public.st_mpolyfromtext(text, integer)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
	SELECT CASE WHEN geometrytype(ST_GeomFromText($1, $2)) = 'MULTIPOLYGON'
	THEN ST_GeomFromText($1,$2)
	ELSE NULL END
	$function$

CREATE OR REPLACE FUNCTION public.st_mpolyfromwkb(bytea)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
	SELECT CASE WHEN geometrytype(ST_GeomFromWKB($1)) = 'MULTIPOLYGON'
	THEN ST_GeomFromWKB($1)
	ELSE NULL END
	$function$
CREATE OR REPLACE FUNCTION public.st_mpolyfromwkb(bytea, integer)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
	SELECT CASE WHEN geometrytype(ST_GeomFromWKB($1, $2)) = 'MULTIPOLYGON'
	THEN ST_GeomFromWKB($1, $2)
	ELSE NULL END
	$function$

CREATE OR REPLACE FUNCTION public.st_multilinestringfromtext(text)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT ST_MLineFromText($1)$function$
CREATE OR REPLACE FUNCTION public.st_multilinestringfromtext(text, integer)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT ST_MLineFromText($1, $2)$function$

CREATE OR REPLACE FUNCTION public.st_multipointfromwkb(bytea)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
	SELECT CASE WHEN geometrytype(ST_GeomFromWKB($1)) = 'MULTIPOINT'
	THEN ST_GeomFromWKB($1)
	ELSE NULL END
	$function$
CREATE OR REPLACE FUNCTION public.st_multipointfromwkb(bytea, integer)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
	SELECT CASE WHEN geometrytype(ST_GeomFromWKB($1,$2)) = 'MULTIPOINT'
	THEN ST_GeomFromWKB($1, $2)
	ELSE NULL END
	$function$

CREATE OR REPLACE FUNCTION public.st_multipolyfromwkb(bytea)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
	SELECT CASE WHEN geometrytype(ST_GeomFromWKB($1)) = 'MULTIPOLYGON'
	THEN ST_GeomFromWKB($1)
	ELSE NULL END
	$function$
CREATE OR REPLACE FUNCTION public.st_multipolyfromwkb(bytea, integer)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
	SELECT CASE WHEN geometrytype(ST_GeomFromWKB($1, $2)) = 'MULTIPOLYGON'
	THEN ST_GeomFromWKB($1, $2)
	ELSE NULL END
	$function$

CREATE OR REPLACE FUNCTION public.st_multipolygonfromtext(text)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT ST_MPolyFromText($1)$function$
CREATE OR REPLACE FUNCTION public.st_multipolygonfromtext(text, integer)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT ST_MPolyFromText($1, $2)$function$

CREATE OR REPLACE FUNCTION public.st_nearestvalue(rast raster, pt geometry, exclude_nodata_value boolean DEFAULT true)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT st_nearestvalue($1, 1, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_nearestvalue(rast raster, columnx integer, rowy integer, exclude_nodata_value boolean DEFAULT true)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT st_nearestvalue($1, 1, st_setsrid(st_makepoint(st_rastertoworldcoordx($1, $2, $3), st_rastertoworldcoordy($1, $2, $3)), st_srid($1)), $4) $function$
CREATE OR REPLACE FUNCTION public.st_nearestvalue(rast raster, band integer, pt geometry, exclude_nodata_value boolean DEFAULT true)
 RETURNS double precision
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/rtpostgis-2.2', $function$RASTER_nearestValue$function$
CREATE OR REPLACE FUNCTION public.st_nearestvalue(rast raster, band integer, columnx integer, rowy integer, exclude_nodata_value boolean DEFAULT true)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT st_nearestvalue($1, $2, st_setsrid(st_makepoint(st_rastertoworldcoordx($1, $3, $4), st_rastertoworldcoordy($1, $3, $4)), st_srid($1)), $5) $function$

CREATE OR REPLACE FUNCTION public.st_nearestvalue(rast raster, pt geometry, exclude_nodata_value boolean DEFAULT true)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT st_nearestvalue($1, 1, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_nearestvalue(rast raster, columnx integer, rowy integer, exclude_nodata_value boolean DEFAULT true)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT st_nearestvalue($1, 1, st_setsrid(st_makepoint(st_rastertoworldcoordx($1, $2, $3), st_rastertoworldcoordy($1, $2, $3)), st_srid($1)), $4) $function$
CREATE OR REPLACE FUNCTION public.st_nearestvalue(rast raster, band integer, pt geometry, exclude_nodata_value boolean DEFAULT true)
 RETURNS double precision
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/rtpostgis-2.2', $function$RASTER_nearestValue$function$
CREATE OR REPLACE FUNCTION public.st_nearestvalue(rast raster, band integer, columnx integer, rowy integer, exclude_nodata_value boolean DEFAULT true)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT st_nearestvalue($1, $2, st_setsrid(st_makepoint(st_rastertoworldcoordx($1, $3, $4), st_rastertoworldcoordy($1, $3, $4)), st_srid($1)), $5) $function$

CREATE OR REPLACE FUNCTION public.st_nearestvalue(rast raster, pt geometry, exclude_nodata_value boolean DEFAULT true)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT st_nearestvalue($1, 1, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_nearestvalue(rast raster, columnx integer, rowy integer, exclude_nodata_value boolean DEFAULT true)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT st_nearestvalue($1, 1, st_setsrid(st_makepoint(st_rastertoworldcoordx($1, $2, $3), st_rastertoworldcoordy($1, $2, $3)), st_srid($1)), $4) $function$
CREATE OR REPLACE FUNCTION public.st_nearestvalue(rast raster, band integer, pt geometry, exclude_nodata_value boolean DEFAULT true)
 RETURNS double precision
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/rtpostgis-2.2', $function$RASTER_nearestValue$function$
CREATE OR REPLACE FUNCTION public.st_nearestvalue(rast raster, band integer, columnx integer, rowy integer, exclude_nodata_value boolean DEFAULT true)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT st_nearestvalue($1, $2, st_setsrid(st_makepoint(st_rastertoworldcoordx($1, $3, $4), st_rastertoworldcoordy($1, $3, $4)), st_srid($1)), $5) $function$

CREATE OR REPLACE FUNCTION public.st_neighborhood(rast raster, pt geometry, distancex integer, distancey integer, exclude_nodata_value boolean DEFAULT true)
 RETURNS double precision[]
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT st_neighborhood($1, 1, $2, $3, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_neighborhood(rast raster, columnx integer, rowy integer, distancex integer, distancey integer, exclude_nodata_value boolean DEFAULT true)
 RETURNS double precision[]
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_neighborhood($1, 1, $2, $3, $4, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_neighborhood(rast raster, band integer, pt geometry, distancex integer, distancey integer, exclude_nodata_value boolean DEFAULT true)
 RETURNS double precision[]
 LANGUAGE plpgsql
 IMMUTABLE STRICT
AS $function$
	DECLARE
		wx double precision;
		wy double precision;
		rtn double precision[][];
	BEGIN
		IF (st_geometrytype($3) != 'ST_Point') THEN
			RAISE EXCEPTION 'Attempting to get the neighbor of a pixel with a non-point geometry';
		END IF;
		IF ST_SRID(rast) != ST_SRID(pt) THEN
			RAISE EXCEPTION 'Raster and geometry do not have the same SRID';
		END IF;
		wx := st_x($3);
		wy := st_y($3);
		SELECT _st_neighborhood(
			$1, $2,
			st_worldtorastercoordx(rast, wx, wy),
			st_worldtorastercoordy(rast, wx, wy),
			$4, $5,
			$6
		) INTO rtn;
		RETURN rtn;
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_neighborhood(rast raster, band integer, columnx integer, rowy integer, distancex integer, distancey integer, exclude_nodata_value boolean DEFAULT true)
 RETURNS double precision[]
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_neighborhood($1, $2, $3, $4, $5, $6, $7) $function$

CREATE OR REPLACE FUNCTION public.st_neighborhood(rast raster, pt geometry, distancex integer, distancey integer, exclude_nodata_value boolean DEFAULT true)
 RETURNS double precision[]
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT st_neighborhood($1, 1, $2, $3, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_neighborhood(rast raster, columnx integer, rowy integer, distancex integer, distancey integer, exclude_nodata_value boolean DEFAULT true)
 RETURNS double precision[]
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_neighborhood($1, 1, $2, $3, $4, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_neighborhood(rast raster, band integer, pt geometry, distancex integer, distancey integer, exclude_nodata_value boolean DEFAULT true)
 RETURNS double precision[]
 LANGUAGE plpgsql
 IMMUTABLE STRICT
AS $function$
	DECLARE
		wx double precision;
		wy double precision;
		rtn double precision[][];
	BEGIN
		IF (st_geometrytype($3) != 'ST_Point') THEN
			RAISE EXCEPTION 'Attempting to get the neighbor of a pixel with a non-point geometry';
		END IF;
		IF ST_SRID(rast) != ST_SRID(pt) THEN
			RAISE EXCEPTION 'Raster and geometry do not have the same SRID';
		END IF;
		wx := st_x($3);
		wy := st_y($3);
		SELECT _st_neighborhood(
			$1, $2,
			st_worldtorastercoordx(rast, wx, wy),
			st_worldtorastercoordy(rast, wx, wy),
			$4, $5,
			$6
		) INTO rtn;
		RETURN rtn;
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_neighborhood(rast raster, band integer, columnx integer, rowy integer, distancex integer, distancey integer, exclude_nodata_value boolean DEFAULT true)
 RETURNS double precision[]
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_neighborhood($1, $2, $3, $4, $5, $6, $7) $function$

CREATE OR REPLACE FUNCTION public.st_neighborhood(rast raster, pt geometry, distancex integer, distancey integer, exclude_nodata_value boolean DEFAULT true)
 RETURNS double precision[]
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT st_neighborhood($1, 1, $2, $3, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_neighborhood(rast raster, columnx integer, rowy integer, distancex integer, distancey integer, exclude_nodata_value boolean DEFAULT true)
 RETURNS double precision[]
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_neighborhood($1, 1, $2, $3, $4, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_neighborhood(rast raster, band integer, pt geometry, distancex integer, distancey integer, exclude_nodata_value boolean DEFAULT true)
 RETURNS double precision[]
 LANGUAGE plpgsql
 IMMUTABLE STRICT
AS $function$
	DECLARE
		wx double precision;
		wy double precision;
		rtn double precision[][];
	BEGIN
		IF (st_geometrytype($3) != 'ST_Point') THEN
			RAISE EXCEPTION 'Attempting to get the neighbor of a pixel with a non-point geometry';
		END IF;
		IF ST_SRID(rast) != ST_SRID(pt) THEN
			RAISE EXCEPTION 'Raster and geometry do not have the same SRID';
		END IF;
		wx := st_x($3);
		wy := st_y($3);
		SELECT _st_neighborhood(
			$1, $2,
			st_worldtorastercoordx(rast, wx, wy),
			st_worldtorastercoordy(rast, wx, wy),
			$4, $5,
			$6
		) INTO rtn;
		RETURN rtn;
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_neighborhood(rast raster, band integer, columnx integer, rowy integer, distancex integer, distancey integer, exclude_nodata_value boolean DEFAULT true)
 RETURNS double precision[]
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_neighborhood($1, $2, $3, $4, $5, $6, $7) $function$

CREATE OR REPLACE FUNCTION public.st_overlaps(geom1 geometry, geom2 geometry)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$SELECT $1 && $2 AND _ST_Overlaps($1,$2)$function$
CREATE OR REPLACE FUNCTION public.st_overlaps(rast1 raster, rast2 raster)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT st_overlaps($1, NULL::integer, $2, NULL::integer) $function$
CREATE OR REPLACE FUNCTION public.st_overlaps(rast1 raster, nband1 integer, rast2 raster, nband2 integer)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT $1 && $3 AND CASE WHEN $2 IS NULL OR $4 IS NULL THEN _st_overlaps(st_convexhull($1), st_convexhull($3)) ELSE _st_overlaps($1, $2, $3, $4) END $function$

CREATE OR REPLACE FUNCTION public.st_overlaps(geom1 geometry, geom2 geometry)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$SELECT $1 && $2 AND _ST_Overlaps($1,$2)$function$
CREATE OR REPLACE FUNCTION public.st_overlaps(rast1 raster, rast2 raster)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT st_overlaps($1, NULL::integer, $2, NULL::integer) $function$
CREATE OR REPLACE FUNCTION public.st_overlaps(rast1 raster, nband1 integer, rast2 raster, nband2 integer)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT $1 && $3 AND CASE WHEN $2 IS NULL OR $4 IS NULL THEN _st_overlaps(st_convexhull($1), st_convexhull($3)) ELSE _st_overlaps($1, $2, $3, $4) END $function$

CREATE OR REPLACE FUNCTION public.st_perimeter(geometry)
 RETURNS double precision
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_perimeter2d_poly$function$
CREATE OR REPLACE FUNCTION public.st_perimeter(geog geography, use_spheroid boolean DEFAULT true)
 RETURNS double precision
 LANGUAGE c
 IMMUTABLE STRICT COST 100
AS '$libdir/postgis-2.2', $function$geography_perimeter$function$

CREATE OR REPLACE FUNCTION public.st_pixelofvalue(rast raster, search double precision, exclude_nodata_value boolean DEFAULT true, OUT x integer, OUT y integer)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT x, y FROM st_pixelofvalue($1, 1, ARRAY[$2], $3) $function$
CREATE OR REPLACE FUNCTION public.st_pixelofvalue(rast raster, search double precision[], exclude_nodata_value boolean DEFAULT true, OUT val double precision, OUT x integer, OUT y integer)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT val, x, y FROM st_pixelofvalue($1, 1, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_pixelofvalue(rast raster, nband integer, search double precision, exclude_nodata_value boolean DEFAULT true, OUT x integer, OUT y integer)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT x, y FROM st_pixelofvalue($1, $2, ARRAY[$3], $4) $function$
CREATE OR REPLACE FUNCTION public.st_pixelofvalue(rast raster, nband integer, search double precision[], exclude_nodata_value boolean DEFAULT true, OUT val double precision, OUT x integer, OUT y integer)
 RETURNS SETOF record
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/rtpostgis-2.2', $function$RASTER_pixelOfValue$function$

CREATE OR REPLACE FUNCTION public.st_pixelofvalue(rast raster, search double precision, exclude_nodata_value boolean DEFAULT true, OUT x integer, OUT y integer)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT x, y FROM st_pixelofvalue($1, 1, ARRAY[$2], $3) $function$
CREATE OR REPLACE FUNCTION public.st_pixelofvalue(rast raster, search double precision[], exclude_nodata_value boolean DEFAULT true, OUT val double precision, OUT x integer, OUT y integer)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT val, x, y FROM st_pixelofvalue($1, 1, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_pixelofvalue(rast raster, nband integer, search double precision, exclude_nodata_value boolean DEFAULT true, OUT x integer, OUT y integer)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT x, y FROM st_pixelofvalue($1, $2, ARRAY[$3], $4) $function$
CREATE OR REPLACE FUNCTION public.st_pixelofvalue(rast raster, nband integer, search double precision[], exclude_nodata_value boolean DEFAULT true, OUT val double precision, OUT x integer, OUT y integer)
 RETURNS SETOF record
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/rtpostgis-2.2', $function$RASTER_pixelOfValue$function$

CREATE OR REPLACE FUNCTION public.st_pixelofvalue(rast raster, search double precision, exclude_nodata_value boolean DEFAULT true, OUT x integer, OUT y integer)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT x, y FROM st_pixelofvalue($1, 1, ARRAY[$2], $3) $function$
CREATE OR REPLACE FUNCTION public.st_pixelofvalue(rast raster, search double precision[], exclude_nodata_value boolean DEFAULT true, OUT val double precision, OUT x integer, OUT y integer)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT val, x, y FROM st_pixelofvalue($1, 1, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_pixelofvalue(rast raster, nband integer, search double precision, exclude_nodata_value boolean DEFAULT true, OUT x integer, OUT y integer)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT x, y FROM st_pixelofvalue($1, $2, ARRAY[$3], $4) $function$
CREATE OR REPLACE FUNCTION public.st_pixelofvalue(rast raster, nband integer, search double precision[], exclude_nodata_value boolean DEFAULT true, OUT val double precision, OUT x integer, OUT y integer)
 RETURNS SETOF record
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/rtpostgis-2.2', $function$RASTER_pixelOfValue$function$

CREATE OR REPLACE FUNCTION public.st_pointfromtext(text)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
	SELECT CASE WHEN geometrytype(ST_GeomFromText($1)) = 'POINT'
	THEN ST_GeomFromText($1)
	ELSE NULL END
	$function$
CREATE OR REPLACE FUNCTION public.st_pointfromtext(text, integer)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
	SELECT CASE WHEN geometrytype(ST_GeomFromText($1, $2)) = 'POINT'
	THEN ST_GeomFromText($1, $2)
	ELSE NULL END
	$function$

CREATE OR REPLACE FUNCTION public.st_pointfromwkb(bytea)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
	SELECT CASE WHEN geometrytype(ST_GeomFromWKB($1)) = 'POINT'
	THEN ST_GeomFromWKB($1)
	ELSE NULL END
	$function$
CREATE OR REPLACE FUNCTION public.st_pointfromwkb(bytea, integer)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
	SELECT CASE WHEN geometrytype(ST_GeomFromWKB($1, $2)) = 'POINT'
	THEN ST_GeomFromWKB($1, $2)
	ELSE NULL END
	$function$

CREATE OR REPLACE FUNCTION public.st_polyfromtext(text)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
	SELECT CASE WHEN geometrytype(ST_GeomFromText($1)) = 'POLYGON'
	THEN ST_GeomFromText($1)
	ELSE NULL END
	$function$
CREATE OR REPLACE FUNCTION public.st_polyfromtext(text, integer)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
	SELECT CASE WHEN geometrytype(ST_GeomFromText($1, $2)) = 'POLYGON'
	THEN ST_GeomFromText($1, $2)
	ELSE NULL END
	$function$

CREATE OR REPLACE FUNCTION public.st_polyfromwkb(bytea)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
	SELECT CASE WHEN geometrytype(ST_GeomFromWKB($1)) = 'POLYGON'
	THEN ST_GeomFromWKB($1)
	ELSE NULL END
	$function$
CREATE OR REPLACE FUNCTION public.st_polyfromwkb(bytea, integer)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
	SELECT CASE WHEN geometrytype(ST_GeomFromWKB($1, $2)) = 'POLYGON'
	THEN ST_GeomFromWKB($1, $2)
	ELSE NULL END
	$function$

CREATE OR REPLACE FUNCTION public.st_polygon(geometry, integer)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ 
	SELECT ST_SetSRID(ST_MakePolygon($1), $2)
	$function$
CREATE OR REPLACE FUNCTION public.st_polygon(rast raster, band integer DEFAULT 1)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/rtpostgis-2.2', $function$RASTER_getPolygon$function$

CREATE OR REPLACE FUNCTION public.st_polygonfromtext(text)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT ST_PolyFromText($1)$function$
CREATE OR REPLACE FUNCTION public.st_polygonfromtext(text, integer)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT ST_PolyFromText($1, $2)$function$

CREATE OR REPLACE FUNCTION public.st_polygonfromwkb(bytea)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
	SELECT CASE WHEN geometrytype(ST_GeomFromWKB($1)) = 'POLYGON'
	THEN ST_GeomFromWKB($1)
	ELSE NULL END
	$function$
CREATE OR REPLACE FUNCTION public.st_polygonfromwkb(bytea, integer)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
	SELECT CASE WHEN geometrytype(ST_GeomFromWKB($1,$2)) = 'POLYGON'
	THEN ST_GeomFromWKB($1, $2)
	ELSE NULL END
	$function$

CREATE OR REPLACE FUNCTION public.st_polygonize(geometry[])
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT COST 100
AS '$libdir/postgis-2.2', $function$polygonize_garray$function$

CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_quantile($1, $2, $3, 1, $4) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, nband integer, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_quantile($1, $2, TRUE, 1, $3) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_quantile($1, 1, TRUE, 1, $2) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, nband integer, exclude_nodata_value boolean, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, 1, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, nband integer, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, TRUE, 1, ARRAY[$3]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, exclude_nodata_value boolean, quantile double precision DEFAULT NULL::double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT (_st_quantile($1, 1, $2, 1, ARRAY[$3]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, 1, TRUE, 1, ARRAY[$2]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_quantile($1, $2, $3, $4, 1, $5) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, nband integer, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_quantile($1, $2, $3, TRUE, 1, $4) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_quantile($1, $2, 1, TRUE, 1, $3) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, $4, 1, ARRAY[$5]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, nband integer, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, TRUE, 1, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, exclude_nodata_value boolean, quantile double precision DEFAULT NULL::double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE
AS $function$ SELECT (_st_quantile($1, $2, 1, $3, 1, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, 1, TRUE, 1, ARRAY[$3]::double precision[])).value $function$

CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_quantile($1, $2, $3, 1, $4) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, nband integer, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_quantile($1, $2, TRUE, 1, $3) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_quantile($1, 1, TRUE, 1, $2) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, nband integer, exclude_nodata_value boolean, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, 1, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, nband integer, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, TRUE, 1, ARRAY[$3]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, exclude_nodata_value boolean, quantile double precision DEFAULT NULL::double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT (_st_quantile($1, 1, $2, 1, ARRAY[$3]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, 1, TRUE, 1, ARRAY[$2]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_quantile($1, $2, $3, $4, 1, $5) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, nband integer, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_quantile($1, $2, $3, TRUE, 1, $4) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_quantile($1, $2, 1, TRUE, 1, $3) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, $4, 1, ARRAY[$5]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, nband integer, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, TRUE, 1, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, exclude_nodata_value boolean, quantile double precision DEFAULT NULL::double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE
AS $function$ SELECT (_st_quantile($1, $2, 1, $3, 1, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, 1, TRUE, 1, ARRAY[$3]::double precision[])).value $function$

CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_quantile($1, $2, $3, 1, $4) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, nband integer, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_quantile($1, $2, TRUE, 1, $3) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_quantile($1, 1, TRUE, 1, $2) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, nband integer, exclude_nodata_value boolean, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, 1, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, nband integer, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, TRUE, 1, ARRAY[$3]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, exclude_nodata_value boolean, quantile double precision DEFAULT NULL::double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT (_st_quantile($1, 1, $2, 1, ARRAY[$3]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, 1, TRUE, 1, ARRAY[$2]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_quantile($1, $2, $3, $4, 1, $5) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, nband integer, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_quantile($1, $2, $3, TRUE, 1, $4) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_quantile($1, $2, 1, TRUE, 1, $3) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, $4, 1, ARRAY[$5]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, nband integer, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, TRUE, 1, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, exclude_nodata_value boolean, quantile double precision DEFAULT NULL::double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE
AS $function$ SELECT (_st_quantile($1, $2, 1, $3, 1, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, 1, TRUE, 1, ARRAY[$3]::double precision[])).value $function$

CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_quantile($1, $2, $3, 1, $4) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, nband integer, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_quantile($1, $2, TRUE, 1, $3) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_quantile($1, 1, TRUE, 1, $2) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, nband integer, exclude_nodata_value boolean, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, 1, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, nband integer, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, TRUE, 1, ARRAY[$3]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, exclude_nodata_value boolean, quantile double precision DEFAULT NULL::double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT (_st_quantile($1, 1, $2, 1, ARRAY[$3]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, 1, TRUE, 1, ARRAY[$2]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_quantile($1, $2, $3, $4, 1, $5) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, nband integer, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_quantile($1, $2, $3, TRUE, 1, $4) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_quantile($1, $2, 1, TRUE, 1, $3) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, $4, 1, ARRAY[$5]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, nband integer, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, TRUE, 1, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, exclude_nodata_value boolean, quantile double precision DEFAULT NULL::double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE
AS $function$ SELECT (_st_quantile($1, $2, 1, $3, 1, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, 1, TRUE, 1, ARRAY[$3]::double precision[])).value $function$

CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_quantile($1, $2, $3, 1, $4) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, nband integer, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_quantile($1, $2, TRUE, 1, $3) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_quantile($1, 1, TRUE, 1, $2) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, nband integer, exclude_nodata_value boolean, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, 1, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, nband integer, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, TRUE, 1, ARRAY[$3]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, exclude_nodata_value boolean, quantile double precision DEFAULT NULL::double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT (_st_quantile($1, 1, $2, 1, ARRAY[$3]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, 1, TRUE, 1, ARRAY[$2]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_quantile($1, $2, $3, $4, 1, $5) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, nband integer, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_quantile($1, $2, $3, TRUE, 1, $4) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_quantile($1, $2, 1, TRUE, 1, $3) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, $4, 1, ARRAY[$5]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, nband integer, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, TRUE, 1, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, exclude_nodata_value boolean, quantile double precision DEFAULT NULL::double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE
AS $function$ SELECT (_st_quantile($1, $2, 1, $3, 1, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, 1, TRUE, 1, ARRAY[$3]::double precision[])).value $function$

CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_quantile($1, $2, $3, 1, $4) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, nband integer, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_quantile($1, $2, TRUE, 1, $3) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_quantile($1, 1, TRUE, 1, $2) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, nband integer, exclude_nodata_value boolean, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, 1, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, nband integer, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, TRUE, 1, ARRAY[$3]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, exclude_nodata_value boolean, quantile double precision DEFAULT NULL::double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT (_st_quantile($1, 1, $2, 1, ARRAY[$3]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, 1, TRUE, 1, ARRAY[$2]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_quantile($1, $2, $3, $4, 1, $5) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, nband integer, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_quantile($1, $2, $3, TRUE, 1, $4) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_quantile($1, $2, 1, TRUE, 1, $3) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, $4, 1, ARRAY[$5]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, nband integer, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, TRUE, 1, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, exclude_nodata_value boolean, quantile double precision DEFAULT NULL::double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE
AS $function$ SELECT (_st_quantile($1, $2, 1, $3, 1, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, 1, TRUE, 1, ARRAY[$3]::double precision[])).value $function$

CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_quantile($1, $2, $3, 1, $4) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, nband integer, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_quantile($1, $2, TRUE, 1, $3) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_quantile($1, 1, TRUE, 1, $2) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, nband integer, exclude_nodata_value boolean, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, 1, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, nband integer, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, TRUE, 1, ARRAY[$3]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, exclude_nodata_value boolean, quantile double precision DEFAULT NULL::double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT (_st_quantile($1, 1, $2, 1, ARRAY[$3]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, 1, TRUE, 1, ARRAY[$2]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_quantile($1, $2, $3, $4, 1, $5) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, nband integer, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_quantile($1, $2, $3, TRUE, 1, $4) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_quantile($1, $2, 1, TRUE, 1, $3) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, $4, 1, ARRAY[$5]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, nband integer, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, TRUE, 1, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, exclude_nodata_value boolean, quantile double precision DEFAULT NULL::double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE
AS $function$ SELECT (_st_quantile($1, $2, 1, $3, 1, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, 1, TRUE, 1, ARRAY[$3]::double precision[])).value $function$

CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_quantile($1, $2, $3, 1, $4) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, nband integer, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_quantile($1, $2, TRUE, 1, $3) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_quantile($1, 1, TRUE, 1, $2) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, nband integer, exclude_nodata_value boolean, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, 1, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, nband integer, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, TRUE, 1, ARRAY[$3]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, exclude_nodata_value boolean, quantile double precision DEFAULT NULL::double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT (_st_quantile($1, 1, $2, 1, ARRAY[$3]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, 1, TRUE, 1, ARRAY[$2]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_quantile($1, $2, $3, $4, 1, $5) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, nband integer, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_quantile($1, $2, $3, TRUE, 1, $4) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_quantile($1, $2, 1, TRUE, 1, $3) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, $4, 1, ARRAY[$5]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, nband integer, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, TRUE, 1, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, exclude_nodata_value boolean, quantile double precision DEFAULT NULL::double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE
AS $function$ SELECT (_st_quantile($1, $2, 1, $3, 1, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, 1, TRUE, 1, ARRAY[$3]::double precision[])).value $function$

CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_quantile($1, $2, $3, 1, $4) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, nband integer, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_quantile($1, $2, TRUE, 1, $3) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_quantile($1, 1, TRUE, 1, $2) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, nband integer, exclude_nodata_value boolean, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, 1, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, nband integer, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, TRUE, 1, ARRAY[$3]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, exclude_nodata_value boolean, quantile double precision DEFAULT NULL::double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT (_st_quantile($1, 1, $2, 1, ARRAY[$3]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, 1, TRUE, 1, ARRAY[$2]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_quantile($1, $2, $3, $4, 1, $5) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, nband integer, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_quantile($1, $2, $3, TRUE, 1, $4) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_quantile($1, $2, 1, TRUE, 1, $3) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, $4, 1, ARRAY[$5]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, nband integer, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, TRUE, 1, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, exclude_nodata_value boolean, quantile double precision DEFAULT NULL::double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE
AS $function$ SELECT (_st_quantile($1, $2, 1, $3, 1, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, 1, TRUE, 1, ARRAY[$3]::double precision[])).value $function$

CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_quantile($1, $2, $3, 1, $4) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, nband integer, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_quantile($1, $2, TRUE, 1, $3) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_quantile($1, 1, TRUE, 1, $2) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, nband integer, exclude_nodata_value boolean, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, 1, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, nband integer, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, TRUE, 1, ARRAY[$3]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, exclude_nodata_value boolean, quantile double precision DEFAULT NULL::double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT (_st_quantile($1, 1, $2, 1, ARRAY[$3]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, 1, TRUE, 1, ARRAY[$2]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_quantile($1, $2, $3, $4, 1, $5) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, nband integer, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_quantile($1, $2, $3, TRUE, 1, $4) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_quantile($1, $2, 1, TRUE, 1, $3) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, $4, 1, ARRAY[$5]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, nband integer, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, TRUE, 1, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, exclude_nodata_value boolean, quantile double precision DEFAULT NULL::double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE
AS $function$ SELECT (_st_quantile($1, $2, 1, $3, 1, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, 1, TRUE, 1, ARRAY[$3]::double precision[])).value $function$

CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_quantile($1, $2, $3, 1, $4) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, nband integer, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_quantile($1, $2, TRUE, 1, $3) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_quantile($1, 1, TRUE, 1, $2) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, nband integer, exclude_nodata_value boolean, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, 1, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, nband integer, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, TRUE, 1, ARRAY[$3]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, exclude_nodata_value boolean, quantile double precision DEFAULT NULL::double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT (_st_quantile($1, 1, $2, 1, ARRAY[$3]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, 1, TRUE, 1, ARRAY[$2]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_quantile($1, $2, $3, $4, 1, $5) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, nband integer, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_quantile($1, $2, $3, TRUE, 1, $4) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_quantile($1, $2, 1, TRUE, 1, $3) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, $4, 1, ARRAY[$5]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, nband integer, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, TRUE, 1, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, exclude_nodata_value boolean, quantile double precision DEFAULT NULL::double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE
AS $function$ SELECT (_st_quantile($1, $2, 1, $3, 1, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, 1, TRUE, 1, ARRAY[$3]::double precision[])).value $function$

CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_quantile($1, $2, $3, 1, $4) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, nband integer, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_quantile($1, $2, TRUE, 1, $3) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_quantile($1, 1, TRUE, 1, $2) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, nband integer, exclude_nodata_value boolean, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, 1, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, nband integer, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, TRUE, 1, ARRAY[$3]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, exclude_nodata_value boolean, quantile double precision DEFAULT NULL::double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT (_st_quantile($1, 1, $2, 1, ARRAY[$3]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, 1, TRUE, 1, ARRAY[$2]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_quantile($1, $2, $3, $4, 1, $5) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, nband integer, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_quantile($1, $2, $3, TRUE, 1, $4) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_quantile($1, $2, 1, TRUE, 1, $3) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, $4, 1, ARRAY[$5]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, nband integer, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, TRUE, 1, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, exclude_nodata_value boolean, quantile double precision DEFAULT NULL::double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE
AS $function$ SELECT (_st_quantile($1, $2, 1, $3, 1, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, 1, TRUE, 1, ARRAY[$3]::double precision[])).value $function$

CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_quantile($1, $2, $3, 1, $4) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, nband integer, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_quantile($1, $2, TRUE, 1, $3) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_quantile($1, 1, TRUE, 1, $2) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, nband integer, exclude_nodata_value boolean, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, 1, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, nband integer, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, TRUE, 1, ARRAY[$3]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, exclude_nodata_value boolean, quantile double precision DEFAULT NULL::double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT (_st_quantile($1, 1, $2, 1, ARRAY[$3]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rast raster, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_quantile($1, 1, TRUE, 1, ARRAY[$2]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, quantiles double precision[] DEFAULT NULL::double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_quantile($1, $2, $3, $4, 1, $5) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, nband integer, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_quantile($1, $2, $3, TRUE, 1, $4) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, quantiles double precision[], OUT quantile double precision, OUT value double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_quantile($1, $2, 1, TRUE, 1, $3) $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, $4, 1, ARRAY[$5]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, nband integer, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, $3, TRUE, 1, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, exclude_nodata_value boolean, quantile double precision DEFAULT NULL::double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE
AS $function$ SELECT (_st_quantile($1, $2, 1, $3, 1, ARRAY[$4]::double precision[])).value $function$
CREATE OR REPLACE FUNCTION public.st_quantile(rastertable text, rastercolumn text, quantile double precision)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_quantile($1, $2, 1, TRUE, 1, ARRAY[$3]::double precision[])).value $function$

CREATE OR REPLACE FUNCTION public.st_range4ma(matrix double precision[], nodatamode text, VARIADIC args text[])
 RETURNS double precision
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
    DECLARE
        _matrix float[][];
        min float;
        max float;
    BEGIN
        _matrix := matrix;
        min := 'Infinity'::float;
        max := '-Infinity'::float;
        FOR x in array_lower(matrix, 1)..array_upper(matrix, 1) LOOP
            FOR y in array_lower(matrix, 2)..array_upper(matrix, 2) LOOP
                IF _matrix[x][y] IS NULL THEN
                    IF NOT nodatamode = 'ignore' THEN
                        _matrix[x][y] := nodatamode::float;
                    END IF;
                END IF;
                IF min > _matrix[x][y] THEN
                    min = _matrix[x][y];
                END IF;
                IF max < _matrix[x][y] THEN
                    max = _matrix[x][y];
                END IF;
            END LOOP;
        END LOOP;
        IF max = '-Infinity'::float OR min = 'Infinity'::float THEN
            RETURN NULL;
        END IF;
        RETURN max - min;
    END;
    $function$
CREATE OR REPLACE FUNCTION public.st_range4ma(value double precision[], pos integer[], VARIADIC userargs text[] DEFAULT NULL::text[])
 RETURNS double precision
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
	DECLARE
		_value double precision[][][];
		min double precision;
		max double precision;
		x int;
		y int;
		z int;
		ndims int;
	BEGIN
		min := 'Infinity'::double precision;
		max := '-Infinity'::double precision;
		ndims := array_ndims(value);
		-- add a third dimension if 2-dimension
		IF ndims = 2 THEN
			_value := _st_convertarray4ma(value);
		ELSEIF ndims != 3 THEN
			RAISE EXCEPTION 'First parameter of function must be a 3-dimension array';
		ELSE
			_value := value;
		END IF;
		-- raster
		FOR z IN array_lower(_value, 1)..array_upper(_value, 1) LOOP
			-- row
			FOR y IN array_lower(_value, 2)..array_upper(_value, 2) LOOP
				-- column
				FOR x IN array_lower(_value, 3)..array_upper(_value, 3) LOOP
					IF _value[z][y][x] IS NULL THEN
						IF array_length(userargs, 1) > 0 THEN
							_value[z][y][x] = userargs[array_lower(userargs, 1)]::double precision;
						ELSE
							CONTINUE;
						END IF;
					END IF;
					IF _value[z][y][x] < min THEN
						min := _value[z][y][x];
					END IF;
					IF _value[z][y][x] > max THEN
						max := _value[z][y][x];
					END IF;
				END LOOP;
			END LOOP;
		END LOOP;
		IF max = '-Infinity'::double precision OR min = 'Infinity'::double precision THEN
			RETURN NULL;
		END IF;
		RETURN max - min;
	END;
	$function$

CREATE OR REPLACE FUNCTION public.st_rastertoworldcoordx(rast raster, xr integer)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT longitude FROM _st_rastertoworldcoord($1, $2, NULL) $function$
CREATE OR REPLACE FUNCTION public.st_rastertoworldcoordx(rast raster, xr integer, yr integer)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT longitude FROM _st_rastertoworldcoord($1, $2, $3) $function$

CREATE OR REPLACE FUNCTION public.st_rastertoworldcoordy(rast raster, yr integer)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT latitude FROM _st_rastertoworldcoord($1, NULL, $2) $function$
CREATE OR REPLACE FUNCTION public.st_rastertoworldcoordy(rast raster, xr integer, yr integer)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT latitude FROM _st_rastertoworldcoord($1, $2, $3) $function$

CREATE OR REPLACE FUNCTION public.st_reclass(rast raster, VARIADIC reclassargset reclassarg[])
 RETURNS raster
 LANGUAGE plpgsql
 IMMUTABLE STRICT
AS $function$
	DECLARE
		i int;
		expr text;
	BEGIN
		-- for each reclassarg, validate elements as all except nodataval cannot be NULL
		FOR i IN SELECT * FROM generate_subscripts($2, 1) LOOP
			IF $2[i].nband IS NULL OR $2[i].reclassexpr IS NULL OR $2[i].pixeltype IS NULL THEN
				RAISE WARNING 'Values are required for the nband, reclassexpr and pixeltype attributes.';
				RETURN rast;
			END IF;
		END LOOP;
		RETURN _st_reclass($1, VARIADIC $2);
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_reclass(rast raster, reclassexpr text, pixeltype text)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT st_reclass($1, ROW(1, $2, $3, NULL)) $function$
CREATE OR REPLACE FUNCTION public.st_reclass(rast raster, nband integer, reclassexpr text, pixeltype text, nodataval double precision DEFAULT NULL::double precision)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT st_reclass($1, ROW($2, $3, $4, $5)) $function$

CREATE OR REPLACE FUNCTION public.st_reclass(rast raster, VARIADIC reclassargset reclassarg[])
 RETURNS raster
 LANGUAGE plpgsql
 IMMUTABLE STRICT
AS $function$
	DECLARE
		i int;
		expr text;
	BEGIN
		-- for each reclassarg, validate elements as all except nodataval cannot be NULL
		FOR i IN SELECT * FROM generate_subscripts($2, 1) LOOP
			IF $2[i].nband IS NULL OR $2[i].reclassexpr IS NULL OR $2[i].pixeltype IS NULL THEN
				RAISE WARNING 'Values are required for the nband, reclassexpr and pixeltype attributes.';
				RETURN rast;
			END IF;
		END LOOP;
		RETURN _st_reclass($1, VARIADIC $2);
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_reclass(rast raster, reclassexpr text, pixeltype text)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT st_reclass($1, ROW(1, $2, $3, NULL)) $function$
CREATE OR REPLACE FUNCTION public.st_reclass(rast raster, nband integer, reclassexpr text, pixeltype text, nodataval double precision DEFAULT NULL::double precision)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT st_reclass($1, ROW($2, $3, $4, $5)) $function$

CREATE OR REPLACE FUNCTION public.st_relate(geom1 geometry, geom2 geometry)
 RETURNS text
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$relate_full$function$
CREATE OR REPLACE FUNCTION public.st_relate(geom1 geometry, geom2 geometry, integer)
 RETURNS text
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$relate_full$function$
CREATE OR REPLACE FUNCTION public.st_relate(geom1 geometry, geom2 geometry, text)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$relate_pattern$function$

CREATE OR REPLACE FUNCTION public.st_relate(geom1 geometry, geom2 geometry)
 RETURNS text
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$relate_full$function$
CREATE OR REPLACE FUNCTION public.st_relate(geom1 geometry, geom2 geometry, integer)
 RETURNS text
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$relate_full$function$
CREATE OR REPLACE FUNCTION public.st_relate(geom1 geometry, geom2 geometry, text)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$relate_pattern$function$

CREATE OR REPLACE FUNCTION public.st_resample(rast raster, ref raster, usescale boolean, algorithm text DEFAULT 'NearestNeighbour'::text, maxerr double precision DEFAULT 0.125)
 RETURNS raster
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT st_resample($1, $2, $4, $5, $3) $function$
CREATE OR REPLACE FUNCTION public.st_resample(rast raster, ref raster, algorithm text DEFAULT 'NearestNeighbour'::text, maxerr double precision DEFAULT 0.125, usescale boolean DEFAULT true)
 RETURNS raster
 LANGUAGE plpgsql
 STABLE STRICT
AS $function$
	DECLARE
		rastsrid int;
		_srid int;
		_dimx int;
		_dimy int;
		_scalex double precision;
		_scaley double precision;
		_gridx double precision;
		_gridy double precision;
		_skewx double precision;
		_skewy double precision;
	BEGIN
		SELECT srid, width, height, scalex, scaley, upperleftx, upperlefty, skewx, skewy INTO _srid, _dimx, _dimy, _scalex, _scaley, _gridx, _gridy, _skewx, _skewy FROM st_metadata($2);
		rastsrid := ST_SRID($1);
		-- both rasters must have the same SRID
		IF (rastsrid != _srid) THEN
			RAISE EXCEPTION 'The raster to be resampled has a different SRID from the reference raster';
			RETURN NULL;
		END IF;
		IF usescale IS TRUE THEN
			_dimx := NULL;
			_dimy := NULL;
		ELSE
			_scalex := NULL;
			_scaley := NULL;
		END IF;
		RETURN _st_gdalwarp($1, $3, $4, NULL, _scalex, _scaley, _gridx, _gridy, _skewx, _skewy, _dimx, _dimy);
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_resample(rast raster, width integer, height integer, gridx double precision DEFAULT NULL::double precision, gridy double precision DEFAULT NULL::double precision, skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, algorithm text DEFAULT 'NearestNeighbour'::text, maxerr double precision DEFAULT 0.125)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_gdalwarp($1, $8,	$9, NULL, NULL, NULL, $4, $5, $6, $7, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_resample(rast raster, scalex double precision DEFAULT 0, scaley double precision DEFAULT 0, gridx double precision DEFAULT NULL::double precision, gridy double precision DEFAULT NULL::double precision, skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, algorithm text DEFAULT 'NearestNeighbour'::text, maxerr double precision DEFAULT 0.125)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_gdalwarp($1, $8,	$9, NULL, $2, $3, $4, $5, $6, $7) $function$

CREATE OR REPLACE FUNCTION public.st_resample(rast raster, ref raster, usescale boolean, algorithm text DEFAULT 'NearestNeighbour'::text, maxerr double precision DEFAULT 0.125)
 RETURNS raster
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT st_resample($1, $2, $4, $5, $3) $function$
CREATE OR REPLACE FUNCTION public.st_resample(rast raster, ref raster, algorithm text DEFAULT 'NearestNeighbour'::text, maxerr double precision DEFAULT 0.125, usescale boolean DEFAULT true)
 RETURNS raster
 LANGUAGE plpgsql
 STABLE STRICT
AS $function$
	DECLARE
		rastsrid int;
		_srid int;
		_dimx int;
		_dimy int;
		_scalex double precision;
		_scaley double precision;
		_gridx double precision;
		_gridy double precision;
		_skewx double precision;
		_skewy double precision;
	BEGIN
		SELECT srid, width, height, scalex, scaley, upperleftx, upperlefty, skewx, skewy INTO _srid, _dimx, _dimy, _scalex, _scaley, _gridx, _gridy, _skewx, _skewy FROM st_metadata($2);
		rastsrid := ST_SRID($1);
		-- both rasters must have the same SRID
		IF (rastsrid != _srid) THEN
			RAISE EXCEPTION 'The raster to be resampled has a different SRID from the reference raster';
			RETURN NULL;
		END IF;
		IF usescale IS TRUE THEN
			_dimx := NULL;
			_dimy := NULL;
		ELSE
			_scalex := NULL;
			_scaley := NULL;
		END IF;
		RETURN _st_gdalwarp($1, $3, $4, NULL, _scalex, _scaley, _gridx, _gridy, _skewx, _skewy, _dimx, _dimy);
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_resample(rast raster, width integer, height integer, gridx double precision DEFAULT NULL::double precision, gridy double precision DEFAULT NULL::double precision, skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, algorithm text DEFAULT 'NearestNeighbour'::text, maxerr double precision DEFAULT 0.125)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_gdalwarp($1, $8,	$9, NULL, NULL, NULL, $4, $5, $6, $7, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_resample(rast raster, scalex double precision DEFAULT 0, scaley double precision DEFAULT 0, gridx double precision DEFAULT NULL::double precision, gridy double precision DEFAULT NULL::double precision, skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, algorithm text DEFAULT 'NearestNeighbour'::text, maxerr double precision DEFAULT 0.125)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_gdalwarp($1, $8,	$9, NULL, $2, $3, $4, $5, $6, $7) $function$

CREATE OR REPLACE FUNCTION public.st_resample(rast raster, ref raster, usescale boolean, algorithm text DEFAULT 'NearestNeighbour'::text, maxerr double precision DEFAULT 0.125)
 RETURNS raster
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT st_resample($1, $2, $4, $5, $3) $function$
CREATE OR REPLACE FUNCTION public.st_resample(rast raster, ref raster, algorithm text DEFAULT 'NearestNeighbour'::text, maxerr double precision DEFAULT 0.125, usescale boolean DEFAULT true)
 RETURNS raster
 LANGUAGE plpgsql
 STABLE STRICT
AS $function$
	DECLARE
		rastsrid int;
		_srid int;
		_dimx int;
		_dimy int;
		_scalex double precision;
		_scaley double precision;
		_gridx double precision;
		_gridy double precision;
		_skewx double precision;
		_skewy double precision;
	BEGIN
		SELECT srid, width, height, scalex, scaley, upperleftx, upperlefty, skewx, skewy INTO _srid, _dimx, _dimy, _scalex, _scaley, _gridx, _gridy, _skewx, _skewy FROM st_metadata($2);
		rastsrid := ST_SRID($1);
		-- both rasters must have the same SRID
		IF (rastsrid != _srid) THEN
			RAISE EXCEPTION 'The raster to be resampled has a different SRID from the reference raster';
			RETURN NULL;
		END IF;
		IF usescale IS TRUE THEN
			_dimx := NULL;
			_dimy := NULL;
		ELSE
			_scalex := NULL;
			_scaley := NULL;
		END IF;
		RETURN _st_gdalwarp($1, $3, $4, NULL, _scalex, _scaley, _gridx, _gridy, _skewx, _skewy, _dimx, _dimy);
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_resample(rast raster, width integer, height integer, gridx double precision DEFAULT NULL::double precision, gridy double precision DEFAULT NULL::double precision, skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, algorithm text DEFAULT 'NearestNeighbour'::text, maxerr double precision DEFAULT 0.125)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_gdalwarp($1, $8,	$9, NULL, NULL, NULL, $4, $5, $6, $7, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_resample(rast raster, scalex double precision DEFAULT 0, scaley double precision DEFAULT 0, gridx double precision DEFAULT NULL::double precision, gridy double precision DEFAULT NULL::double precision, skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, algorithm text DEFAULT 'NearestNeighbour'::text, maxerr double precision DEFAULT 0.125)
 RETURNS raster
 LANGUAGE sql
 STABLE
AS $function$ SELECT _st_gdalwarp($1, $8,	$9, NULL, $2, $3, $4, $5, $6, $7) $function$

CREATE OR REPLACE FUNCTION public.st_rescale(rast raster, scalexy double precision, algorithm text DEFAULT 'NearestNeighbour'::text, maxerr double precision DEFAULT 0.125)
 RETURNS raster
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_gdalwarp($1, $3, $4, NULL, $2, $2) $function$
CREATE OR REPLACE FUNCTION public.st_rescale(rast raster, scalex double precision, scaley double precision, algorithm text DEFAULT 'NearestNeighbour'::text, maxerr double precision DEFAULT 0.125)
 RETURNS raster
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_gdalwarp($1, $4, $5, NULL, $2, $3) $function$

CREATE OR REPLACE FUNCTION public.st_resize(rast raster, width integer, height integer, algorithm text DEFAULT 'NearestNeighbour'::text, maxerr double precision DEFAULT 0.125)
 RETURNS raster
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_gdalwarp($1, $4, $5, NULL, NULL, NULL, NULL, NULL, NULL, NULL, abs($2), abs($3)) $function$
CREATE OR REPLACE FUNCTION public.st_resize(rast raster, width text, height text, algorithm text DEFAULT 'NearestNeighbour'::text, maxerr double precision DEFAULT 0.125)
 RETURNS raster
 LANGUAGE plpgsql
 STABLE STRICT
AS $function$
	DECLARE
		i integer;
		wh text[2];
		whi integer[2];
		whd double precision[2];
		_width integer;
		_height integer;
	BEGIN
		wh[1] := trim(both from $2);
		wh[2] := trim(both from $3);
		-- see if width and height are percentages
		FOR i IN 1..2 LOOP
			IF position('%' in wh[i]) > 0 THEN
				BEGIN
					wh[i] := (regexp_matches(wh[i], E'^(\\d*.?\\d*)%{1}$'))[1];
					IF length(wh[i]) < 1 THEN
						RAISE invalid_parameter_value;
					END IF;
					whd[i] := wh[i]::double precision * 0.01;
				EXCEPTION WHEN OTHERS THEN -- TODO: WHEN invalid_parameter_value !
					RAISE EXCEPTION 'Invalid percentage value provided for width/height';
					RETURN NULL;
				END;
			ELSE
				BEGIN
					whi[i] := abs(wh[i]::integer);
				EXCEPTION WHEN OTHERS THEN -- TODO: only handle appropriate SQLSTATE
					RAISE EXCEPTION 'Non-integer value provided for width/height';
					RETURN NULL;
				END;
			END IF;
		END LOOP;
		IF whd[1] IS NOT NULL OR whd[2] IS NOT NULL THEN
			SELECT foo.width, foo.height INTO _width, _height FROM ST_Metadata($1) AS foo;
			IF whd[1] IS NOT NULL THEN
				whi[1] := round(_width::double precision * whd[1])::integer;
			END IF;
			IF whd[2] IS NOT NULL THEN
				whi[2] := round(_height::double precision * whd[2])::integer;
			END IF;
		END IF;
		-- should NEVER be here
		IF whi[1] IS NULL OR whi[2] IS NULL THEN
			RAISE EXCEPTION 'Unable to determine appropriate width or height';
			RETURN NULL;
		END IF;
		FOR i IN 1..2 LOOP
			IF whi[i] < 1 THEN
				whi[i] = 1;
			END IF;
		END LOOP;
		RETURN _st_gdalwarp(
			$1,
			$4, $5,
			NULL,
			NULL, NULL,
			NULL, NULL,
			NULL, NULL,
			whi[1], whi[2]
		);
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_resize(rast raster, percentwidth double precision, percentheight double precision, algorithm text DEFAULT 'NearestNeighbour'::text, maxerr double precision DEFAULT 0.125)
 RETURNS raster
 LANGUAGE plpgsql
 STABLE STRICT
AS $function$
	DECLARE
		_width integer;
		_height integer;
	BEGIN
		-- range check
		IF $2 <= 0. OR $2 > 1. OR $3 <= 0. OR $3 > 1. THEN
			RAISE EXCEPTION 'Percentages must be a value greater than zero and less than or equal to one, e.g. 0.5 for 50%%';
		END IF;
		SELECT width, height INTO _width, _height FROM ST_Metadata($1);
		_width := round(_width::double precision * $2)::integer;
		_height:= round(_height::double precision * $3)::integer;
		IF _width < 1 THEN
			_width := 1;
		END IF;
		IF _height < 1 THEN
			_height := 1;
		END IF;
		RETURN _st_gdalwarp(
			$1,
			$4, $5,
			NULL,
			NULL, NULL,
			NULL, NULL,
			NULL, NULL,
			_width, _height
		);
	END;
	$function$

CREATE OR REPLACE FUNCTION public.st_resize(rast raster, width integer, height integer, algorithm text DEFAULT 'NearestNeighbour'::text, maxerr double precision DEFAULT 0.125)
 RETURNS raster
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_gdalwarp($1, $4, $5, NULL, NULL, NULL, NULL, NULL, NULL, NULL, abs($2), abs($3)) $function$
CREATE OR REPLACE FUNCTION public.st_resize(rast raster, width text, height text, algorithm text DEFAULT 'NearestNeighbour'::text, maxerr double precision DEFAULT 0.125)
 RETURNS raster
 LANGUAGE plpgsql
 STABLE STRICT
AS $function$
	DECLARE
		i integer;
		wh text[2];
		whi integer[2];
		whd double precision[2];
		_width integer;
		_height integer;
	BEGIN
		wh[1] := trim(both from $2);
		wh[2] := trim(both from $3);
		-- see if width and height are percentages
		FOR i IN 1..2 LOOP
			IF position('%' in wh[i]) > 0 THEN
				BEGIN
					wh[i] := (regexp_matches(wh[i], E'^(\\d*.?\\d*)%{1}$'))[1];
					IF length(wh[i]) < 1 THEN
						RAISE invalid_parameter_value;
					END IF;
					whd[i] := wh[i]::double precision * 0.01;
				EXCEPTION WHEN OTHERS THEN -- TODO: WHEN invalid_parameter_value !
					RAISE EXCEPTION 'Invalid percentage value provided for width/height';
					RETURN NULL;
				END;
			ELSE
				BEGIN
					whi[i] := abs(wh[i]::integer);
				EXCEPTION WHEN OTHERS THEN -- TODO: only handle appropriate SQLSTATE
					RAISE EXCEPTION 'Non-integer value provided for width/height';
					RETURN NULL;
				END;
			END IF;
		END LOOP;
		IF whd[1] IS NOT NULL OR whd[2] IS NOT NULL THEN
			SELECT foo.width, foo.height INTO _width, _height FROM ST_Metadata($1) AS foo;
			IF whd[1] IS NOT NULL THEN
				whi[1] := round(_width::double precision * whd[1])::integer;
			END IF;
			IF whd[2] IS NOT NULL THEN
				whi[2] := round(_height::double precision * whd[2])::integer;
			END IF;
		END IF;
		-- should NEVER be here
		IF whi[1] IS NULL OR whi[2] IS NULL THEN
			RAISE EXCEPTION 'Unable to determine appropriate width or height';
			RETURN NULL;
		END IF;
		FOR i IN 1..2 LOOP
			IF whi[i] < 1 THEN
				whi[i] = 1;
			END IF;
		END LOOP;
		RETURN _st_gdalwarp(
			$1,
			$4, $5,
			NULL,
			NULL, NULL,
			NULL, NULL,
			NULL, NULL,
			whi[1], whi[2]
		);
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_resize(rast raster, percentwidth double precision, percentheight double precision, algorithm text DEFAULT 'NearestNeighbour'::text, maxerr double precision DEFAULT 0.125)
 RETURNS raster
 LANGUAGE plpgsql
 STABLE STRICT
AS $function$
	DECLARE
		_width integer;
		_height integer;
	BEGIN
		-- range check
		IF $2 <= 0. OR $2 > 1. OR $3 <= 0. OR $3 > 1. THEN
			RAISE EXCEPTION 'Percentages must be a value greater than zero and less than or equal to one, e.g. 0.5 for 50%%';
		END IF;
		SELECT width, height INTO _width, _height FROM ST_Metadata($1);
		_width := round(_width::double precision * $2)::integer;
		_height:= round(_height::double precision * $3)::integer;
		IF _width < 1 THEN
			_width := 1;
		END IF;
		IF _height < 1 THEN
			_height := 1;
		END IF;
		RETURN _st_gdalwarp(
			$1,
			$4, $5,
			NULL,
			NULL, NULL,
			NULL, NULL,
			NULL, NULL,
			_width, _height
		);
	END;
	$function$

CREATE OR REPLACE FUNCTION public.st_reskew(rast raster, skewxy double precision, algorithm text DEFAULT 'NearestNeighbour'::text, maxerr double precision DEFAULT 0.125)
 RETURNS raster
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_gdalwarp($1, $3, $4, NULL, 0, 0, NULL, NULL, $2, $2) $function$
CREATE OR REPLACE FUNCTION public.st_reskew(rast raster, skewx double precision, skewy double precision, algorithm text DEFAULT 'NearestNeighbour'::text, maxerr double precision DEFAULT 0.125)
 RETURNS raster
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_gdalwarp($1, $4, $5, NULL, 0, 0, NULL, NULL, $2, $3) $function$

CREATE OR REPLACE FUNCTION public.st_rotate(geometry, double precision)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT ST_Affine($1,  cos($2), -sin($2), 0,  sin($2), cos($2), 0,  0, 0, 1,  0, 0, 0)$function$
CREATE OR REPLACE FUNCTION public.st_rotate(geometry, double precision, geometry)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT ST_Affine($1,  cos($2), -sin($2), 0,  sin($2),  cos($2), 0, 0, 0, 1, ST_X($3) - cos($2) * ST_X($3) + sin($2) * ST_Y($3), ST_Y($3) - sin($2) * ST_X($3) - cos($2) * ST_Y($3), 0)$function$
CREATE OR REPLACE FUNCTION public.st_rotate(geometry, double precision, double precision, double precision)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT ST_Affine($1,  cos($2), -sin($2), 0,  sin($2),  cos($2), 0, 0, 0, 1,	$3 - cos($2) * $3 + sin($2) * $4, $4 - sin($2) * $3 - cos($2) * $4, 0)$function$

CREATE OR REPLACE FUNCTION public.st_rotate(geometry, double precision)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT ST_Affine($1,  cos($2), -sin($2), 0,  sin($2), cos($2), 0,  0, 0, 1,  0, 0, 0)$function$
CREATE OR REPLACE FUNCTION public.st_rotate(geometry, double precision, geometry)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT ST_Affine($1,  cos($2), -sin($2), 0,  sin($2),  cos($2), 0, 0, 0, 1, ST_X($3) - cos($2) * ST_X($3) + sin($2) * ST_Y($3), ST_Y($3) - sin($2) * ST_X($3) - cos($2) * ST_Y($3), 0)$function$
CREATE OR REPLACE FUNCTION public.st_rotate(geometry, double precision, double precision, double precision)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT ST_Affine($1,  cos($2), -sin($2), 0,  sin($2),  cos($2), 0, 0, 0, 1,	$3 - cos($2) * $3 + sin($2) * $4, $4 - sin($2) * $3 - cos($2) * $4, 0)$function$

CREATE OR REPLACE FUNCTION public.st_roughness(rast raster, nband integer DEFAULT 1, pixeltype text DEFAULT '32BF'::text, interpolate_nodata boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT st_roughness($1, $2, NULL::raster, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_roughness(rast raster, nband integer, customextent raster, pixeltype text DEFAULT '32BF'::text, interpolate_nodata boolean DEFAULT false)
 RETURNS raster
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
	DECLARE
		_rast raster;
		_nband integer;
		_pixtype text;
		_pixwidth double precision;
		_pixheight double precision;
		_width integer;
		_height integer;
		_customextent raster;
		_extenttype text;
	BEGIN
		_customextent := customextent;
		IF _customextent IS NULL THEN
			_extenttype := 'FIRST';
		ELSE
			_extenttype := 'CUSTOM';
		END IF;
		IF interpolate_nodata IS TRUE THEN
			_rast := ST_MapAlgebra(
				ARRAY[ROW(rast, nband)]::rastbandarg[],
				'st_invdistweight4ma(double precision[][][], integer[][], text[])'::regprocedure,
				pixeltype,
				'FIRST', NULL,
				1, 1
			);
			_nband := 1;
			_pixtype := NULL;
		ELSE
			_rast := rast;
			_nband := nband;
			_pixtype := pixeltype;
		END IF;
		RETURN ST_MapAlgebra(
			ARRAY[ROW(_rast, _nband)]::rastbandarg[],
			'_st_roughness4ma(double precision[][][], integer[][], text[])'::regprocedure,
			_pixtype,
			_extenttype, _customextent,
			1, 1);
	END;
	$function$

CREATE OR REPLACE FUNCTION public.st_samealignment(rast1 raster, rast2 raster)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/rtpostgis-2.2', $function$RASTER_sameAlignment$function$
CREATE OR REPLACE FUNCTION public.st_samealignment(ulx1 double precision, uly1 double precision, scalex1 double precision, scaley1 double precision, skewx1 double precision, skewy1 double precision, ulx2 double precision, uly2 double precision, scalex2 double precision, scaley2 double precision, skewx2 double precision, skewy2 double precision)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT st_samealignment(st_makeemptyraster(1, 1, $1, $2, $3, $4, $5, $6), st_makeemptyraster(1, 1, $7, $8, $9, $10, $11, $12)) $function$

CREATE OR REPLACE FUNCTION public.st_samealignment(rast1 raster, rast2 raster)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/rtpostgis-2.2', $function$RASTER_sameAlignment$function$
CREATE OR REPLACE FUNCTION public.st_samealignment(ulx1 double precision, uly1 double precision, scalex1 double precision, scaley1 double precision, skewx1 double precision, skewy1 double precision, ulx2 double precision, uly2 double precision, scalex2 double precision, scaley2 double precision, skewx2 double precision, skewy2 double precision)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT st_samealignment(st_makeemptyraster(1, 1, $1, $2, $3, $4, $5, $6), st_makeemptyraster(1, 1, $7, $8, $9, $10, $11, $12)) $function$

CREATE OR REPLACE FUNCTION public.st_scale(geometry, geometry)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$ST_Scale$function$
CREATE OR REPLACE FUNCTION public.st_scale(geometry, double precision, double precision)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT ST_Scale($1, $2, $3, 1)$function$
CREATE OR REPLACE FUNCTION public.st_scale(geometry, double precision, double precision, double precision)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT ST_Scale($1, ST_MakePoint($2, $3, $4))$function$

CREATE OR REPLACE FUNCTION public.st_scale(geometry, geometry)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$ST_Scale$function$
CREATE OR REPLACE FUNCTION public.st_scale(geometry, double precision, double precision)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT ST_Scale($1, $2, $3, 1)$function$
CREATE OR REPLACE FUNCTION public.st_scale(geometry, double precision, double precision, double precision)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT ST_Scale($1, ST_MakePoint($2, $3, $4))$function$

CREATE OR REPLACE FUNCTION public.st_segmentize(geometry, double precision)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_segmentize2d$function$
CREATE OR REPLACE FUNCTION public.st_segmentize(geog geography, max_segment_length double precision)
 RETURNS geography
 LANGUAGE c
 IMMUTABLE STRICT COST 100
AS '$libdir/postgis-2.2', $function$geography_segmentize$function$

CREATE OR REPLACE FUNCTION public.st_setbandnodatavalue(rast raster, nodatavalue double precision)
 RETURNS raster
 LANGUAGE sql
AS $function$ SELECT st_setbandnodatavalue($1, 1, $2, FALSE) $function$
CREATE OR REPLACE FUNCTION public.st_setbandnodatavalue(rast raster, band integer, nodatavalue double precision, forcechecking boolean DEFAULT false)
 RETURNS raster
 LANGUAGE c
 IMMUTABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_setBandNoDataValue$function$

CREATE OR REPLACE FUNCTION public.st_setgeoreference(rast raster, georef text, format text DEFAULT 'GDAL'::text)
 RETURNS raster
 LANGUAGE plpgsql
 IMMUTABLE STRICT
AS $function$
    DECLARE
        params text[];
        rastout raster;
    BEGIN
        IF rast IS NULL THEN
            RAISE WARNING 'Cannot set georeferencing on a null raster in st_setgeoreference.';
            RETURN rastout;
        END IF;
        SELECT regexp_matches(georef,
            E'(-?\\d+(?:\\.\\d+)?)\\s(-?\\d+(?:\\.\\d+)?)\\s(-?\\d+(?:\\.\\d+)?)\\s' ||
            E'(-?\\d+(?:\\.\\d+)?)\\s(-?\\d+(?:\\.\\d+)?)\\s(-?\\d+(?:\\.\\d+)?)') INTO params;
        IF NOT FOUND THEN
            RAISE EXCEPTION 'st_setgeoreference requires a string with 6 floating point values.';
        END IF;
        IF format = 'ESRI' THEN
            -- params array is now:
            -- {scalex, skewy, skewx, scaley, upperleftx, upperlefty}
            rastout := st_setscale(rast, params[1]::float8, params[4]::float8);
            rastout := st_setskew(rastout, params[3]::float8, params[2]::float8);
            rastout := st_setupperleft(rastout,
                                   params[5]::float8 - (params[1]::float8 * 0.5),
                                   params[6]::float8 - (params[4]::float8 * 0.5));
        ELSE
            IF format != 'GDAL' THEN
                RAISE WARNING 'Format ''%'' is not recognized, defaulting to GDAL format.', format;
            END IF;
            -- params array is now:
            -- {scalex, skewy, skewx, scaley, upperleftx, upperlefty}
            rastout := st_setscale(rast, params[1]::float8, params[4]::float8);
            rastout := st_setskew( rastout, params[3]::float8, params[2]::float8);
            rastout := st_setupperleft(rastout, params[5]::float8, params[6]::float8);
        END IF;
        RETURN rastout;
    END;
    $function$
CREATE OR REPLACE FUNCTION public.st_setgeoreference(rast raster, upperleftx double precision, upperlefty double precision, scalex double precision, scaley double precision, skewx double precision, skewy double precision)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT st_setgeoreference($1, array_to_string(ARRAY[$4, $7, $6, $5, $2, $3], ' ')) $function$

CREATE OR REPLACE FUNCTION public.st_setscale(rast raster, scale double precision)
 RETURNS raster
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/rtpostgis-2.2', $function$RASTER_setScale$function$
CREATE OR REPLACE FUNCTION public.st_setscale(rast raster, scalex double precision, scaley double precision)
 RETURNS raster
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/rtpostgis-2.2', $function$RASTER_setScaleXY$function$

CREATE OR REPLACE FUNCTION public.st_setskew(rast raster, skew double precision)
 RETURNS raster
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/rtpostgis-2.2', $function$RASTER_setSkew$function$
CREATE OR REPLACE FUNCTION public.st_setskew(rast raster, skewx double precision, skewy double precision)
 RETURNS raster
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/rtpostgis-2.2', $function$RASTER_setSkewXY$function$

CREATE OR REPLACE FUNCTION public.st_setsrid(geometry, integer)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_set_srid$function$
CREATE OR REPLACE FUNCTION public.st_setsrid(geog geography, srid integer)
 RETURNS geography
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_set_srid$function$
CREATE OR REPLACE FUNCTION public.st_setsrid(rast raster, srid integer)
 RETURNS raster
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/rtpostgis-2.2', $function$RASTER_setSRID$function$

CREATE OR REPLACE FUNCTION public.st_setsrid(geometry, integer)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_set_srid$function$
CREATE OR REPLACE FUNCTION public.st_setsrid(geog geography, srid integer)
 RETURNS geography
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_set_srid$function$
CREATE OR REPLACE FUNCTION public.st_setsrid(rast raster, srid integer)
 RETURNS raster
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/rtpostgis-2.2', $function$RASTER_setSRID$function$

CREATE OR REPLACE FUNCTION public.st_setvalue(rast raster, geom geometry, newvalue double precision)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT st_setvalues($1, 1, ARRAY[ROW($2, $3)]::geomval[], FALSE) $function$
CREATE OR REPLACE FUNCTION public.st_setvalue(rast raster, x integer, y integer, newvalue double precision)
 RETURNS raster
 LANGUAGE sql
AS $function$ SELECT st_setvalue($1, 1, $2, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_setvalue(rast raster, nband integer, geom geometry, newvalue double precision)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT st_setvalues($1, $2, ARRAY[ROW($3, $4)]::geomval[], FALSE) $function$
CREATE OR REPLACE FUNCTION public.st_setvalue(rast raster, band integer, x integer, y integer, newvalue double precision)
 RETURNS raster
 LANGUAGE c
 IMMUTABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_setPixelValue$function$

CREATE OR REPLACE FUNCTION public.st_setvalue(rast raster, geom geometry, newvalue double precision)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT st_setvalues($1, 1, ARRAY[ROW($2, $3)]::geomval[], FALSE) $function$
CREATE OR REPLACE FUNCTION public.st_setvalue(rast raster, x integer, y integer, newvalue double precision)
 RETURNS raster
 LANGUAGE sql
AS $function$ SELECT st_setvalue($1, 1, $2, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_setvalue(rast raster, nband integer, geom geometry, newvalue double precision)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT st_setvalues($1, $2, ARRAY[ROW($3, $4)]::geomval[], FALSE) $function$
CREATE OR REPLACE FUNCTION public.st_setvalue(rast raster, band integer, x integer, y integer, newvalue double precision)
 RETURNS raster
 LANGUAGE c
 IMMUTABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_setPixelValue$function$

CREATE OR REPLACE FUNCTION public.st_setvalue(rast raster, geom geometry, newvalue double precision)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT st_setvalues($1, 1, ARRAY[ROW($2, $3)]::geomval[], FALSE) $function$
CREATE OR REPLACE FUNCTION public.st_setvalue(rast raster, x integer, y integer, newvalue double precision)
 RETURNS raster
 LANGUAGE sql
AS $function$ SELECT st_setvalue($1, 1, $2, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_setvalue(rast raster, nband integer, geom geometry, newvalue double precision)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT st_setvalues($1, $2, ARRAY[ROW($3, $4)]::geomval[], FALSE) $function$
CREATE OR REPLACE FUNCTION public.st_setvalue(rast raster, band integer, x integer, y integer, newvalue double precision)
 RETURNS raster
 LANGUAGE c
 IMMUTABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_setPixelValue$function$

CREATE OR REPLACE FUNCTION public.st_setvalues(rast raster, nband integer, geomvalset geomval[], keepnodata boolean DEFAULT false)
 RETURNS raster
 LANGUAGE c
 IMMUTABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_setPixelValuesGeomval$function$
CREATE OR REPLACE FUNCTION public.st_setvalues(rast raster, x integer, y integer, width integer, height integer, newvalue double precision, keepnodata boolean DEFAULT false)
 RETURNS raster
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
	BEGIN
		IF width <= 0 OR height <= 0 THEN
			RAISE EXCEPTION 'Values for width and height must be greater than zero';
			RETURN NULL;
		END IF;
		RETURN _st_setvalues($1, 1, $2, $3, array_fill($6, ARRAY[$5, $4]::int[]), NULL, FALSE, NULL, $7);
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_setvalues(rast raster, nband integer, x integer, y integer, newvalueset double precision[], nosetvalue double precision, keepnodata boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_setvalues($1, $2, $3, $4, $5, NULL, TRUE, $6, $7) $function$
CREATE OR REPLACE FUNCTION public.st_setvalues(rast raster, nband integer, x integer, y integer, newvalueset double precision[], noset boolean[] DEFAULT NULL::boolean[], keepnodata boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_setvalues($1, $2, $3, $4, $5, $6, FALSE, NULL, $7) $function$
CREATE OR REPLACE FUNCTION public.st_setvalues(rast raster, nband integer, x integer, y integer, width integer, height integer, newvalue double precision, keepnodata boolean DEFAULT false)
 RETURNS raster
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
	BEGIN
		IF width <= 0 OR height <= 0 THEN
			RAISE EXCEPTION 'Values for width and height must be greater than zero';
			RETURN NULL;
		END IF;
		RETURN _st_setvalues($1, $2, $3, $4, array_fill($7, ARRAY[$6, $5]::int[]), NULL, FALSE, NULL, $8);
	END;
	$function$

CREATE OR REPLACE FUNCTION public.st_setvalues(rast raster, nband integer, geomvalset geomval[], keepnodata boolean DEFAULT false)
 RETURNS raster
 LANGUAGE c
 IMMUTABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_setPixelValuesGeomval$function$
CREATE OR REPLACE FUNCTION public.st_setvalues(rast raster, x integer, y integer, width integer, height integer, newvalue double precision, keepnodata boolean DEFAULT false)
 RETURNS raster
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
	BEGIN
		IF width <= 0 OR height <= 0 THEN
			RAISE EXCEPTION 'Values for width and height must be greater than zero';
			RETURN NULL;
		END IF;
		RETURN _st_setvalues($1, 1, $2, $3, array_fill($6, ARRAY[$5, $4]::int[]), NULL, FALSE, NULL, $7);
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_setvalues(rast raster, nband integer, x integer, y integer, newvalueset double precision[], nosetvalue double precision, keepnodata boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_setvalues($1, $2, $3, $4, $5, NULL, TRUE, $6, $7) $function$
CREATE OR REPLACE FUNCTION public.st_setvalues(rast raster, nband integer, x integer, y integer, newvalueset double precision[], noset boolean[] DEFAULT NULL::boolean[], keepnodata boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_setvalues($1, $2, $3, $4, $5, $6, FALSE, NULL, $7) $function$
CREATE OR REPLACE FUNCTION public.st_setvalues(rast raster, nband integer, x integer, y integer, width integer, height integer, newvalue double precision, keepnodata boolean DEFAULT false)
 RETURNS raster
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
	BEGIN
		IF width <= 0 OR height <= 0 THEN
			RAISE EXCEPTION 'Values for width and height must be greater than zero';
			RETURN NULL;
		END IF;
		RETURN _st_setvalues($1, $2, $3, $4, array_fill($7, ARRAY[$6, $5]::int[]), NULL, FALSE, NULL, $8);
	END;
	$function$

CREATE OR REPLACE FUNCTION public.st_setvalues(rast raster, nband integer, geomvalset geomval[], keepnodata boolean DEFAULT false)
 RETURNS raster
 LANGUAGE c
 IMMUTABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_setPixelValuesGeomval$function$
CREATE OR REPLACE FUNCTION public.st_setvalues(rast raster, x integer, y integer, width integer, height integer, newvalue double precision, keepnodata boolean DEFAULT false)
 RETURNS raster
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
	BEGIN
		IF width <= 0 OR height <= 0 THEN
			RAISE EXCEPTION 'Values for width and height must be greater than zero';
			RETURN NULL;
		END IF;
		RETURN _st_setvalues($1, 1, $2, $3, array_fill($6, ARRAY[$5, $4]::int[]), NULL, FALSE, NULL, $7);
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_setvalues(rast raster, nband integer, x integer, y integer, newvalueset double precision[], nosetvalue double precision, keepnodata boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_setvalues($1, $2, $3, $4, $5, NULL, TRUE, $6, $7) $function$
CREATE OR REPLACE FUNCTION public.st_setvalues(rast raster, nband integer, x integer, y integer, newvalueset double precision[], noset boolean[] DEFAULT NULL::boolean[], keepnodata boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_setvalues($1, $2, $3, $4, $5, $6, FALSE, NULL, $7) $function$
CREATE OR REPLACE FUNCTION public.st_setvalues(rast raster, nband integer, x integer, y integer, width integer, height integer, newvalue double precision, keepnodata boolean DEFAULT false)
 RETURNS raster
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
	BEGIN
		IF width <= 0 OR height <= 0 THEN
			RAISE EXCEPTION 'Values for width and height must be greater than zero';
			RETURN NULL;
		END IF;
		RETURN _st_setvalues($1, $2, $3, $4, array_fill($7, ARRAY[$6, $5]::int[]), NULL, FALSE, NULL, $8);
	END;
	$function$

CREATE OR REPLACE FUNCTION public.st_setvalues(rast raster, nband integer, geomvalset geomval[], keepnodata boolean DEFAULT false)
 RETURNS raster
 LANGUAGE c
 IMMUTABLE
AS '$libdir/rtpostgis-2.2', $function$RASTER_setPixelValuesGeomval$function$
CREATE OR REPLACE FUNCTION public.st_setvalues(rast raster, x integer, y integer, width integer, height integer, newvalue double precision, keepnodata boolean DEFAULT false)
 RETURNS raster
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
	BEGIN
		IF width <= 0 OR height <= 0 THEN
			RAISE EXCEPTION 'Values for width and height must be greater than zero';
			RETURN NULL;
		END IF;
		RETURN _st_setvalues($1, 1, $2, $3, array_fill($6, ARRAY[$5, $4]::int[]), NULL, FALSE, NULL, $7);
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_setvalues(rast raster, nband integer, x integer, y integer, newvalueset double precision[], nosetvalue double precision, keepnodata boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_setvalues($1, $2, $3, $4, $5, NULL, TRUE, $6, $7) $function$
CREATE OR REPLACE FUNCTION public.st_setvalues(rast raster, nband integer, x integer, y integer, newvalueset double precision[], noset boolean[] DEFAULT NULL::boolean[], keepnodata boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_setvalues($1, $2, $3, $4, $5, $6, FALSE, NULL, $7) $function$
CREATE OR REPLACE FUNCTION public.st_setvalues(rast raster, nband integer, x integer, y integer, width integer, height integer, newvalue double precision, keepnodata boolean DEFAULT false)
 RETURNS raster
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
	BEGIN
		IF width <= 0 OR height <= 0 THEN
			RAISE EXCEPTION 'Values for width and height must be greater than zero';
			RETURN NULL;
		END IF;
		RETURN _st_setvalues($1, $2, $3, $4, array_fill($7, ARRAY[$6, $5]::int[]), NULL, FALSE, NULL, $8);
	END;
	$function$

CREATE OR REPLACE FUNCTION public.st_simplify(geometry, double precision)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_simplify2d$function$
CREATE OR REPLACE FUNCTION public.st_simplify(geometry, double precision, boolean)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_simplify2d$function$

CREATE OR REPLACE FUNCTION public.st_slope(rast raster, nband integer DEFAULT 1, pixeltype text DEFAULT '32BF'::text, units text DEFAULT 'DEGREES'::text, scale double precision DEFAULT 1.0, interpolate_nodata boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT st_slope($1, $2, NULL::raster, $3, $4, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_slope(rast raster, nband integer, customextent raster, pixeltype text DEFAULT '32BF'::text, units text DEFAULT 'DEGREES'::text, scale double precision DEFAULT 1.0, interpolate_nodata boolean DEFAULT false)
 RETURNS raster
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
	DECLARE
		_rast raster;
		_nband integer;
		_pixtype text;
		_pixwidth double precision;
		_pixheight double precision;
		_width integer;
		_height integer;
		_customextent raster;
		_extenttype text;
	BEGIN
		_customextent := customextent;
		IF _customextent IS NULL THEN
			_extenttype := 'FIRST';
		ELSE
			_extenttype := 'CUSTOM';
		END IF;
		IF interpolate_nodata IS TRUE THEN
			_rast := ST_MapAlgebra(
				ARRAY[ROW(rast, nband)]::rastbandarg[],
				'st_invdistweight4ma(double precision[][][], integer[][], text[])'::regprocedure,
				pixeltype,
				'FIRST', NULL,
				1, 1
			);
			_nband := 1;
			_pixtype := NULL;
		ELSE
			_rast := rast;
			_nband := nband;
			_pixtype := pixeltype;
		END IF;
		-- get properties
		_pixwidth := ST_PixelWidth(_rast);
		_pixheight := ST_PixelHeight(_rast);
		SELECT width, height INTO _width, _height FROM ST_Metadata(_rast);
		RETURN ST_MapAlgebra(
			ARRAY[ROW(_rast, _nband)]::rastbandarg[],
			'_st_slope4ma(double precision[][][], integer[][], text[])'::regprocedure,
			_pixtype,
			_extenttype, _customextent,
			1, 1,
			_pixwidth::text, _pixheight::text,
			_width::text, _height::text,
			units::text, scale::text
		);
	END;
	$function$

CREATE OR REPLACE FUNCTION public.st_snaptogrid(geometry, double precision, double precision, double precision, double precision)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_snaptogrid$function$
CREATE OR REPLACE FUNCTION public.st_snaptogrid(geometry, double precision, double precision)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT ST_SnapToGrid($1, 0, 0, $2, $3)$function$
CREATE OR REPLACE FUNCTION public.st_snaptogrid(geometry, double precision)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT ST_SnapToGrid($1, 0, 0, $2, $2)$function$
CREATE OR REPLACE FUNCTION public.st_snaptogrid(geom1 geometry, geom2 geometry, double precision, double precision, double precision, double precision)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_snaptogrid_pointoff$function$
CREATE OR REPLACE FUNCTION public.st_snaptogrid(rast raster, gridx double precision, gridy double precision, algorithm text DEFAULT 'NearestNeighbour'::text, maxerr double precision DEFAULT 0.125, scalex double precision DEFAULT 0, scaley double precision DEFAULT 0)
 RETURNS raster
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_gdalwarp($1, $4, $5, NULL, $6, $7, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_snaptogrid(rast raster, gridx double precision, gridy double precision, scalex double precision, scaley double precision, algorithm text DEFAULT 'NearestNeighbour'::text, maxerr double precision DEFAULT 0.125)
 RETURNS raster
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_gdalwarp($1, $6, $7, NULL, $4, $5, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_snaptogrid(rast raster, gridx double precision, gridy double precision, scalexy double precision, algorithm text DEFAULT 'NearestNeighbour'::text, maxerr double precision DEFAULT 0.125)
 RETURNS raster
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_gdalwarp($1, $5, $6, NULL, $4, $4, $2, $3) $function$

CREATE OR REPLACE FUNCTION public.st_snaptogrid(geometry, double precision, double precision, double precision, double precision)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_snaptogrid$function$
CREATE OR REPLACE FUNCTION public.st_snaptogrid(geometry, double precision, double precision)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT ST_SnapToGrid($1, 0, 0, $2, $3)$function$
CREATE OR REPLACE FUNCTION public.st_snaptogrid(geometry, double precision)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT ST_SnapToGrid($1, 0, 0, $2, $2)$function$
CREATE OR REPLACE FUNCTION public.st_snaptogrid(geom1 geometry, geom2 geometry, double precision, double precision, double precision, double precision)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_snaptogrid_pointoff$function$
CREATE OR REPLACE FUNCTION public.st_snaptogrid(rast raster, gridx double precision, gridy double precision, algorithm text DEFAULT 'NearestNeighbour'::text, maxerr double precision DEFAULT 0.125, scalex double precision DEFAULT 0, scaley double precision DEFAULT 0)
 RETURNS raster
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_gdalwarp($1, $4, $5, NULL, $6, $7, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_snaptogrid(rast raster, gridx double precision, gridy double precision, scalex double precision, scaley double precision, algorithm text DEFAULT 'NearestNeighbour'::text, maxerr double precision DEFAULT 0.125)
 RETURNS raster
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_gdalwarp($1, $6, $7, NULL, $4, $5, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_snaptogrid(rast raster, gridx double precision, gridy double precision, scalexy double precision, algorithm text DEFAULT 'NearestNeighbour'::text, maxerr double precision DEFAULT 0.125)
 RETURNS raster
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_gdalwarp($1, $5, $6, NULL, $4, $4, $2, $3) $function$

CREATE OR REPLACE FUNCTION public.st_snaptogrid(geometry, double precision, double precision, double precision, double precision)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_snaptogrid$function$
CREATE OR REPLACE FUNCTION public.st_snaptogrid(geometry, double precision, double precision)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT ST_SnapToGrid($1, 0, 0, $2, $3)$function$
CREATE OR REPLACE FUNCTION public.st_snaptogrid(geometry, double precision)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT ST_SnapToGrid($1, 0, 0, $2, $2)$function$
CREATE OR REPLACE FUNCTION public.st_snaptogrid(geom1 geometry, geom2 geometry, double precision, double precision, double precision, double precision)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_snaptogrid_pointoff$function$
CREATE OR REPLACE FUNCTION public.st_snaptogrid(rast raster, gridx double precision, gridy double precision, algorithm text DEFAULT 'NearestNeighbour'::text, maxerr double precision DEFAULT 0.125, scalex double precision DEFAULT 0, scaley double precision DEFAULT 0)
 RETURNS raster
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_gdalwarp($1, $4, $5, NULL, $6, $7, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_snaptogrid(rast raster, gridx double precision, gridy double precision, scalex double precision, scaley double precision, algorithm text DEFAULT 'NearestNeighbour'::text, maxerr double precision DEFAULT 0.125)
 RETURNS raster
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_gdalwarp($1, $6, $7, NULL, $4, $5, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_snaptogrid(rast raster, gridx double precision, gridy double precision, scalexy double precision, algorithm text DEFAULT 'NearestNeighbour'::text, maxerr double precision DEFAULT 0.125)
 RETURNS raster
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_gdalwarp($1, $5, $6, NULL, $4, $4, $2, $3) $function$

CREATE OR REPLACE FUNCTION public.st_snaptogrid(geometry, double precision, double precision, double precision, double precision)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_snaptogrid$function$
CREATE OR REPLACE FUNCTION public.st_snaptogrid(geometry, double precision, double precision)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT ST_SnapToGrid($1, 0, 0, $2, $3)$function$
CREATE OR REPLACE FUNCTION public.st_snaptogrid(geometry, double precision)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT ST_SnapToGrid($1, 0, 0, $2, $2)$function$
CREATE OR REPLACE FUNCTION public.st_snaptogrid(geom1 geometry, geom2 geometry, double precision, double precision, double precision, double precision)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_snaptogrid_pointoff$function$
CREATE OR REPLACE FUNCTION public.st_snaptogrid(rast raster, gridx double precision, gridy double precision, algorithm text DEFAULT 'NearestNeighbour'::text, maxerr double precision DEFAULT 0.125, scalex double precision DEFAULT 0, scaley double precision DEFAULT 0)
 RETURNS raster
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_gdalwarp($1, $4, $5, NULL, $6, $7, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_snaptogrid(rast raster, gridx double precision, gridy double precision, scalex double precision, scaley double precision, algorithm text DEFAULT 'NearestNeighbour'::text, maxerr double precision DEFAULT 0.125)
 RETURNS raster
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_gdalwarp($1, $6, $7, NULL, $4, $5, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_snaptogrid(rast raster, gridx double precision, gridy double precision, scalexy double precision, algorithm text DEFAULT 'NearestNeighbour'::text, maxerr double precision DEFAULT 0.125)
 RETURNS raster
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_gdalwarp($1, $5, $6, NULL, $4, $4, $2, $3) $function$

CREATE OR REPLACE FUNCTION public.st_snaptogrid(geometry, double precision, double precision, double precision, double precision)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_snaptogrid$function$
CREATE OR REPLACE FUNCTION public.st_snaptogrid(geometry, double precision, double precision)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT ST_SnapToGrid($1, 0, 0, $2, $3)$function$
CREATE OR REPLACE FUNCTION public.st_snaptogrid(geometry, double precision)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT ST_SnapToGrid($1, 0, 0, $2, $2)$function$
CREATE OR REPLACE FUNCTION public.st_snaptogrid(geom1 geometry, geom2 geometry, double precision, double precision, double precision, double precision)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_snaptogrid_pointoff$function$
CREATE OR REPLACE FUNCTION public.st_snaptogrid(rast raster, gridx double precision, gridy double precision, algorithm text DEFAULT 'NearestNeighbour'::text, maxerr double precision DEFAULT 0.125, scalex double precision DEFAULT 0, scaley double precision DEFAULT 0)
 RETURNS raster
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_gdalwarp($1, $4, $5, NULL, $6, $7, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_snaptogrid(rast raster, gridx double precision, gridy double precision, scalex double precision, scaley double precision, algorithm text DEFAULT 'NearestNeighbour'::text, maxerr double precision DEFAULT 0.125)
 RETURNS raster
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_gdalwarp($1, $6, $7, NULL, $4, $5, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_snaptogrid(rast raster, gridx double precision, gridy double precision, scalexy double precision, algorithm text DEFAULT 'NearestNeighbour'::text, maxerr double precision DEFAULT 0.125)
 RETURNS raster
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_gdalwarp($1, $5, $6, NULL, $4, $4, $2, $3) $function$

CREATE OR REPLACE FUNCTION public.st_snaptogrid(geometry, double precision, double precision, double precision, double precision)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_snaptogrid$function$
CREATE OR REPLACE FUNCTION public.st_snaptogrid(geometry, double precision, double precision)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT ST_SnapToGrid($1, 0, 0, $2, $3)$function$
CREATE OR REPLACE FUNCTION public.st_snaptogrid(geometry, double precision)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT ST_SnapToGrid($1, 0, 0, $2, $2)$function$
CREATE OR REPLACE FUNCTION public.st_snaptogrid(geom1 geometry, geom2 geometry, double precision, double precision, double precision, double precision)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_snaptogrid_pointoff$function$
CREATE OR REPLACE FUNCTION public.st_snaptogrid(rast raster, gridx double precision, gridy double precision, algorithm text DEFAULT 'NearestNeighbour'::text, maxerr double precision DEFAULT 0.125, scalex double precision DEFAULT 0, scaley double precision DEFAULT 0)
 RETURNS raster
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_gdalwarp($1, $4, $5, NULL, $6, $7, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_snaptogrid(rast raster, gridx double precision, gridy double precision, scalex double precision, scaley double precision, algorithm text DEFAULT 'NearestNeighbour'::text, maxerr double precision DEFAULT 0.125)
 RETURNS raster
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_gdalwarp($1, $6, $7, NULL, $4, $5, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_snaptogrid(rast raster, gridx double precision, gridy double precision, scalexy double precision, algorithm text DEFAULT 'NearestNeighbour'::text, maxerr double precision DEFAULT 0.125)
 RETURNS raster
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_gdalwarp($1, $5, $6, NULL, $4, $4, $2, $3) $function$

CREATE OR REPLACE FUNCTION public.st_srid(geometry)
 RETURNS integer
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_get_srid$function$
CREATE OR REPLACE FUNCTION public.st_srid(geog geography)
 RETURNS integer
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_get_srid$function$
CREATE OR REPLACE FUNCTION public.st_srid(raster)
 RETURNS integer
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/rtpostgis-2.2', $function$RASTER_getSRID$function$

CREATE OR REPLACE FUNCTION public.st_srid(geometry)
 RETURNS integer
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_get_srid$function$
CREATE OR REPLACE FUNCTION public.st_srid(geog geography)
 RETURNS integer
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_get_srid$function$
CREATE OR REPLACE FUNCTION public.st_srid(raster)
 RETURNS integer
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/rtpostgis-2.2', $function$RASTER_getSRID$function$

CREATE OR REPLACE FUNCTION public.st_stddev4ma(matrix double precision[], nodatamode text, VARIADIC args text[])
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT stddev(unnest) FROM unnest($1) $function$
CREATE OR REPLACE FUNCTION public.st_stddev4ma(value double precision[], pos integer[], VARIADIC userargs text[] DEFAULT NULL::text[])
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT stddev(unnest) FROM unnest($1) $function$

CREATE OR REPLACE FUNCTION public.st_sum4ma(matrix double precision[], nodatamode text, VARIADIC args text[])
 RETURNS double precision
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
    DECLARE
        _matrix float[][];
        sum float;
    BEGIN
        _matrix := matrix;
        sum := 0;
        FOR x in array_lower(matrix, 1)..array_upper(matrix, 1) LOOP
            FOR y in array_lower(matrix, 2)..array_upper(matrix, 2) LOOP
                IF _matrix[x][y] IS NULL THEN
                    IF nodatamode = 'ignore' THEN
                        _matrix[x][y] := 0;
                    ELSE
                        _matrix[x][y] := nodatamode::float;
                    END IF;
                END IF;
                sum := sum + _matrix[x][y];
            END LOOP;
        END LOOP;
        RETURN sum;
    END;
    $function$
CREATE OR REPLACE FUNCTION public.st_sum4ma(value double precision[], pos integer[], VARIADIC userargs text[] DEFAULT NULL::text[])
 RETURNS double precision
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
	DECLARE
		_value double precision[][][];
		sum double precision;
		x int;
		y int;
		z int;
		ndims int;
	BEGIN
		sum := 0;
		ndims := array_ndims(value);
		-- add a third dimension if 2-dimension
		IF ndims = 2 THEN
			_value := _st_convertarray4ma(value);
		ELSEIF ndims != 3 THEN
			RAISE EXCEPTION 'First parameter of function must be a 3-dimension array';
		ELSE
			_value := value;
		END IF;
		-- raster
		FOR z IN array_lower(_value, 1)..array_upper(_value, 1) LOOP
			-- row
			FOR y IN array_lower(_value, 2)..array_upper(_value, 2) LOOP
				-- column
				FOR x IN array_lower(_value, 3)..array_upper(_value, 3) LOOP
					IF _value[z][y][x] IS NULL THEN
						IF array_length(userargs, 1) > 0 THEN
							_value[z][y][x] = userargs[array_lower(userargs, 1)]::double precision;
						ELSE
							CONTINUE;
						END IF;
					END IF;
					sum := sum + _value[z][y][x];
				END LOOP;
			END LOOP;
		END LOOP;
		RETURN sum;
	END;
	$function$

CREATE OR REPLACE FUNCTION public.st_summary(geometry)
 RETURNS text
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_summary$function$
CREATE OR REPLACE FUNCTION public.st_summary(geography)
 RETURNS text
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_summary$function$
CREATE OR REPLACE FUNCTION public.st_summary(rast raster)
 RETURNS text
 LANGUAGE plpgsql
 STABLE STRICT
AS $function$
	DECLARE
		extent box2d;
		metadata record;
		bandmetadata record;
		msg text;
		msgset text[];
	BEGIN
		extent := ST_Extent(rast::geometry);
		metadata := ST_Metadata(rast);
		msg := 'Raster of ' || metadata.width || 'x' || metadata.height || ' pixels has ' || metadata.numbands || ' ';
		IF metadata.numbands = 1 THEN
			msg := msg || 'band ';
		ELSE
			msg := msg || 'bands ';
		END IF;
		msg := msg || 'and extent of ' || extent;
		IF
			round(metadata.skewx::numeric, 10) <> round(0::numeric, 10) OR 
			round(metadata.skewy::numeric, 10) <> round(0::numeric, 10)
		THEN
			msg := 'Skewed ' || overlay(msg placing 'r' from 1 for 1);
		END IF;
		msgset := Array[]::text[] || msg;
		FOR bandmetadata IN SELECT * FROM ST_BandMetadata(rast, ARRAY[]::int[]) LOOP
			msg := 'band ' || bandmetadata.bandnum || ' of pixtype ' || bandmetadata.pixeltype || ' is ';
			IF bandmetadata.isoutdb IS FALSE THEN
				msg := msg || 'in-db ';
			ELSE
				msg := msg || 'out-db ';
			END IF;
			msg := msg || 'with ';
			IF bandmetadata.nodatavalue IS NOT NULL THEN
				msg := msg || 'NODATA value of ' || bandmetadata.nodatavalue;
			ELSE
				msg := msg || 'no NODATA value';
			END IF;
			msgset := msgset || ('    ' || msg);
		END LOOP;
		RETURN array_to_string(msgset, E'\n');
	END;
	$function$

CREATE OR REPLACE FUNCTION public.st_summary(geometry)
 RETURNS text
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_summary$function$
CREATE OR REPLACE FUNCTION public.st_summary(geography)
 RETURNS text
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$LWGEOM_summary$function$
CREATE OR REPLACE FUNCTION public.st_summary(rast raster)
 RETURNS text
 LANGUAGE plpgsql
 STABLE STRICT
AS $function$
	DECLARE
		extent box2d;
		metadata record;
		bandmetadata record;
		msg text;
		msgset text[];
	BEGIN
		extent := ST_Extent(rast::geometry);
		metadata := ST_Metadata(rast);
		msg := 'Raster of ' || metadata.width || 'x' || metadata.height || ' pixels has ' || metadata.numbands || ' ';
		IF metadata.numbands = 1 THEN
			msg := msg || 'band ';
		ELSE
			msg := msg || 'bands ';
		END IF;
		msg := msg || 'and extent of ' || extent;
		IF
			round(metadata.skewx::numeric, 10) <> round(0::numeric, 10) OR 
			round(metadata.skewy::numeric, 10) <> round(0::numeric, 10)
		THEN
			msg := 'Skewed ' || overlay(msg placing 'r' from 1 for 1);
		END IF;
		msgset := Array[]::text[] || msg;
		FOR bandmetadata IN SELECT * FROM ST_BandMetadata(rast, ARRAY[]::int[]) LOOP
			msg := 'band ' || bandmetadata.bandnum || ' of pixtype ' || bandmetadata.pixeltype || ' is ';
			IF bandmetadata.isoutdb IS FALSE THEN
				msg := msg || 'in-db ';
			ELSE
				msg := msg || 'out-db ';
			END IF;
			msg := msg || 'with ';
			IF bandmetadata.nodatavalue IS NOT NULL THEN
				msg := msg || 'NODATA value of ' || bandmetadata.nodatavalue;
			ELSE
				msg := msg || 'no NODATA value';
			END IF;
			msgset := msgset || ('    ' || msg);
		END LOOP;
		RETURN array_to_string(msgset, E'\n');
	END;
	$function$

CREATE OR REPLACE FUNCTION public.st_summarystats(rast raster, exclude_nodata_value boolean)
 RETURNS summarystats
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_summarystats($1, 1, $2, 1) $function$
CREATE OR REPLACE FUNCTION public.st_summarystats(rastertable text, rastercolumn text, exclude_nodata_value boolean)
 RETURNS summarystats
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_summarystats($1, $2, 1, $3, 1) $function$
CREATE OR REPLACE FUNCTION public.st_summarystats(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true)
 RETURNS summarystats
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_summarystats($1, $2, $3, 1) $function$
CREATE OR REPLACE FUNCTION public.st_summarystats(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true)
 RETURNS summarystats
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_summarystats($1, $2, $3, $4, 1) $function$

CREATE OR REPLACE FUNCTION public.st_summarystats(rast raster, exclude_nodata_value boolean)
 RETURNS summarystats
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_summarystats($1, 1, $2, 1) $function$
CREATE OR REPLACE FUNCTION public.st_summarystats(rastertable text, rastercolumn text, exclude_nodata_value boolean)
 RETURNS summarystats
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_summarystats($1, $2, 1, $3, 1) $function$
CREATE OR REPLACE FUNCTION public.st_summarystats(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true)
 RETURNS summarystats
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_summarystats($1, $2, $3, 1) $function$
CREATE OR REPLACE FUNCTION public.st_summarystats(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true)
 RETURNS summarystats
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_summarystats($1, $2, $3, $4, 1) $function$

CREATE OR REPLACE FUNCTION public.st_summarystats(rast raster, exclude_nodata_value boolean)
 RETURNS summarystats
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_summarystats($1, 1, $2, 1) $function$
CREATE OR REPLACE FUNCTION public.st_summarystats(rastertable text, rastercolumn text, exclude_nodata_value boolean)
 RETURNS summarystats
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_summarystats($1, $2, 1, $3, 1) $function$
CREATE OR REPLACE FUNCTION public.st_summarystats(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true)
 RETURNS summarystats
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT _st_summarystats($1, $2, $3, 1) $function$
CREATE OR REPLACE FUNCTION public.st_summarystats(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true)
 RETURNS summarystats
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_summarystats($1, $2, $3, $4, 1) $function$

CREATE OR REPLACE FUNCTION public.st_tile(rast raster, width integer, height integer, padwithnodata boolean DEFAULT false, nodataval double precision DEFAULT NULL::double precision)
 RETURNS SETOF raster
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_tile($1, $2, $3, NULL::integer[], $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_tile(rast raster, nband integer, width integer, height integer, padwithnodata boolean DEFAULT false, nodataval double precision DEFAULT NULL::double precision)
 RETURNS SETOF raster
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_tile($1, $3, $4, ARRAY[$2]::integer[], $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_tile(rast raster, nband integer[], width integer, height integer, padwithnodata boolean DEFAULT false, nodataval double precision DEFAULT NULL::double precision)
 RETURNS SETOF raster
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_tile($1, $3, $4, $2, $5, $6) $function$

CREATE OR REPLACE FUNCTION public.st_tile(rast raster, width integer, height integer, padwithnodata boolean DEFAULT false, nodataval double precision DEFAULT NULL::double precision)
 RETURNS SETOF raster
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_tile($1, $2, $3, NULL::integer[], $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_tile(rast raster, nband integer, width integer, height integer, padwithnodata boolean DEFAULT false, nodataval double precision DEFAULT NULL::double precision)
 RETURNS SETOF raster
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_tile($1, $3, $4, ARRAY[$2]::integer[], $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_tile(rast raster, nband integer[], width integer, height integer, padwithnodata boolean DEFAULT false, nodataval double precision DEFAULT NULL::double precision)
 RETURNS SETOF raster
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT _st_tile($1, $3, $4, $2, $5, $6) $function$

CREATE OR REPLACE FUNCTION public.st_touches(geom1 geometry, geom2 geometry)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$SELECT $1 && $2 AND _ST_Touches($1,$2)$function$
CREATE OR REPLACE FUNCTION public.st_touches(rast1 raster, rast2 raster)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT st_touches($1, NULL::integer, $2, NULL::integer) $function$
CREATE OR REPLACE FUNCTION public.st_touches(rast1 raster, nband1 integer, rast2 raster, nband2 integer)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT $1 && $3 AND CASE WHEN $2 IS NULL OR $4 IS NULL THEN _st_touches(st_convexhull($1), st_convexhull($3)) ELSE _st_touches($1, $2, $3, $4) END $function$

CREATE OR REPLACE FUNCTION public.st_touches(geom1 geometry, geom2 geometry)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$SELECT $1 && $2 AND _ST_Touches($1,$2)$function$
CREATE OR REPLACE FUNCTION public.st_touches(rast1 raster, rast2 raster)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT st_touches($1, NULL::integer, $2, NULL::integer) $function$
CREATE OR REPLACE FUNCTION public.st_touches(rast1 raster, nband1 integer, rast2 raster, nband2 integer)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT $1 && $3 AND CASE WHEN $2 IS NULL OR $4 IS NULL THEN _st_touches(st_convexhull($1), st_convexhull($3)) ELSE _st_touches($1, $2, $3, $4) END $function$

CREATE OR REPLACE FUNCTION public.st_tpi(rast raster, nband integer DEFAULT 1, pixeltype text DEFAULT '32BF'::text, interpolate_nodata boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT st_tpi($1, $2, NULL::raster, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_tpi(rast raster, nband integer, customextent raster, pixeltype text DEFAULT '32BF'::text, interpolate_nodata boolean DEFAULT false)
 RETURNS raster
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
	DECLARE
		_rast raster;
		_nband integer;
		_pixtype text;
		_pixwidth double precision;
		_pixheight double precision;
		_width integer;
		_height integer;
		_customextent raster;
		_extenttype text;
	BEGIN
		_customextent := customextent;
		IF _customextent IS NULL THEN
			_extenttype := 'FIRST';
		ELSE
			_extenttype := 'CUSTOM';
		END IF;
		IF interpolate_nodata IS TRUE THEN
			_rast := ST_MapAlgebra(
				ARRAY[ROW(rast, nband)]::rastbandarg[],
				'st_invdistweight4ma(double precision[][][], integer[][], text[])'::regprocedure,
				pixeltype,
				'FIRST', NULL,
				1, 1
			);
			_nband := 1;
			_pixtype := NULL;
		ELSE
			_rast := rast;
			_nband := nband;
			_pixtype := pixeltype;
		END IF;
		-- get properties
		_pixwidth := ST_PixelWidth(_rast);
		_pixheight := ST_PixelHeight(_rast);
		SELECT width, height INTO _width, _height FROM ST_Metadata(_rast);
		RETURN ST_MapAlgebra(
			ARRAY[ROW(_rast, _nband)]::rastbandarg[],
			'_st_tpi4ma(double precision[][][], integer[][], text[])'::regprocedure,
			_pixtype,
			_extenttype, _customextent,
			1, 1);
	END;
	$function$

CREATE OR REPLACE FUNCTION public.st_transform(geometry, integer)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$transform$function$
CREATE OR REPLACE FUNCTION public.st_transform(rast raster, alignto raster, algorithm text DEFAULT 'NearestNeighbour'::text, maxerr double precision DEFAULT 0.125)
 RETURNS raster
 LANGUAGE plpgsql
 STABLE STRICT
AS $function$
	DECLARE
		_srid integer;
		_scalex double precision;
		_scaley double precision;
		_gridx double precision;
		_gridy double precision;
		_skewx double precision;
		_skewy double precision;
	BEGIN
		SELECT srid, scalex, scaley, upperleftx, upperlefty, skewx, skewy INTO _srid, _scalex, _scaley, _gridx, _gridy, _skewx, _skewy FROM st_metadata($2);
		RETURN _st_gdalwarp($1, $3, $4, _srid, _scalex, _scaley, _gridx, _gridy, _skewx, _skewy, NULL, NULL);
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_transform(rast raster, srid integer, scalexy double precision, algorithm text DEFAULT 'NearestNeighbour'::text, maxerr double precision DEFAULT 0.125)
 RETURNS raster
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_gdalwarp($1, $4, $5, $2, $3, $3) $function$
CREATE OR REPLACE FUNCTION public.st_transform(rast raster, srid integer, algorithm text DEFAULT 'NearestNeighbour'::text, maxerr double precision DEFAULT 0.125, scalex double precision DEFAULT 0, scaley double precision DEFAULT 0)
 RETURNS raster
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_gdalwarp($1, $3, $4, $2, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_transform(rast raster, srid integer, scalex double precision, scaley double precision, algorithm text DEFAULT 'NearestNeighbour'::text, maxerr double precision DEFAULT 0.125)
 RETURNS raster
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_gdalwarp($1, $5, $6, $2, $3, $4) $function$

CREATE OR REPLACE FUNCTION public.st_transform(geometry, integer)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$transform$function$
CREATE OR REPLACE FUNCTION public.st_transform(rast raster, alignto raster, algorithm text DEFAULT 'NearestNeighbour'::text, maxerr double precision DEFAULT 0.125)
 RETURNS raster
 LANGUAGE plpgsql
 STABLE STRICT
AS $function$
	DECLARE
		_srid integer;
		_scalex double precision;
		_scaley double precision;
		_gridx double precision;
		_gridy double precision;
		_skewx double precision;
		_skewy double precision;
	BEGIN
		SELECT srid, scalex, scaley, upperleftx, upperlefty, skewx, skewy INTO _srid, _scalex, _scaley, _gridx, _gridy, _skewx, _skewy FROM st_metadata($2);
		RETURN _st_gdalwarp($1, $3, $4, _srid, _scalex, _scaley, _gridx, _gridy, _skewx, _skewy, NULL, NULL);
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_transform(rast raster, srid integer, scalexy double precision, algorithm text DEFAULT 'NearestNeighbour'::text, maxerr double precision DEFAULT 0.125)
 RETURNS raster
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_gdalwarp($1, $4, $5, $2, $3, $3) $function$
CREATE OR REPLACE FUNCTION public.st_transform(rast raster, srid integer, algorithm text DEFAULT 'NearestNeighbour'::text, maxerr double precision DEFAULT 0.125, scalex double precision DEFAULT 0, scaley double precision DEFAULT 0)
 RETURNS raster
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_gdalwarp($1, $3, $4, $2, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_transform(rast raster, srid integer, scalex double precision, scaley double precision, algorithm text DEFAULT 'NearestNeighbour'::text, maxerr double precision DEFAULT 0.125)
 RETURNS raster
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_gdalwarp($1, $5, $6, $2, $3, $4) $function$

CREATE OR REPLACE FUNCTION public.st_transform(geometry, integer)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$transform$function$
CREATE OR REPLACE FUNCTION public.st_transform(rast raster, alignto raster, algorithm text DEFAULT 'NearestNeighbour'::text, maxerr double precision DEFAULT 0.125)
 RETURNS raster
 LANGUAGE plpgsql
 STABLE STRICT
AS $function$
	DECLARE
		_srid integer;
		_scalex double precision;
		_scaley double precision;
		_gridx double precision;
		_gridy double precision;
		_skewx double precision;
		_skewy double precision;
	BEGIN
		SELECT srid, scalex, scaley, upperleftx, upperlefty, skewx, skewy INTO _srid, _scalex, _scaley, _gridx, _gridy, _skewx, _skewy FROM st_metadata($2);
		RETURN _st_gdalwarp($1, $3, $4, _srid, _scalex, _scaley, _gridx, _gridy, _skewx, _skewy, NULL, NULL);
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_transform(rast raster, srid integer, scalexy double precision, algorithm text DEFAULT 'NearestNeighbour'::text, maxerr double precision DEFAULT 0.125)
 RETURNS raster
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_gdalwarp($1, $4, $5, $2, $3, $3) $function$
CREATE OR REPLACE FUNCTION public.st_transform(rast raster, srid integer, algorithm text DEFAULT 'NearestNeighbour'::text, maxerr double precision DEFAULT 0.125, scalex double precision DEFAULT 0, scaley double precision DEFAULT 0)
 RETURNS raster
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_gdalwarp($1, $3, $4, $2, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_transform(rast raster, srid integer, scalex double precision, scaley double precision, algorithm text DEFAULT 'NearestNeighbour'::text, maxerr double precision DEFAULT 0.125)
 RETURNS raster
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_gdalwarp($1, $5, $6, $2, $3, $4) $function$

CREATE OR REPLACE FUNCTION public.st_transform(geometry, integer)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$transform$function$
CREATE OR REPLACE FUNCTION public.st_transform(rast raster, alignto raster, algorithm text DEFAULT 'NearestNeighbour'::text, maxerr double precision DEFAULT 0.125)
 RETURNS raster
 LANGUAGE plpgsql
 STABLE STRICT
AS $function$
	DECLARE
		_srid integer;
		_scalex double precision;
		_scaley double precision;
		_gridx double precision;
		_gridy double precision;
		_skewx double precision;
		_skewy double precision;
	BEGIN
		SELECT srid, scalex, scaley, upperleftx, upperlefty, skewx, skewy INTO _srid, _scalex, _scaley, _gridx, _gridy, _skewx, _skewy FROM st_metadata($2);
		RETURN _st_gdalwarp($1, $3, $4, _srid, _scalex, _scaley, _gridx, _gridy, _skewx, _skewy, NULL, NULL);
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_transform(rast raster, srid integer, scalexy double precision, algorithm text DEFAULT 'NearestNeighbour'::text, maxerr double precision DEFAULT 0.125)
 RETURNS raster
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_gdalwarp($1, $4, $5, $2, $3, $3) $function$
CREATE OR REPLACE FUNCTION public.st_transform(rast raster, srid integer, algorithm text DEFAULT 'NearestNeighbour'::text, maxerr double precision DEFAULT 0.125, scalex double precision DEFAULT 0, scaley double precision DEFAULT 0)
 RETURNS raster
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_gdalwarp($1, $3, $4, $2, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_transform(rast raster, srid integer, scalex double precision, scaley double precision, algorithm text DEFAULT 'NearestNeighbour'::text, maxerr double precision DEFAULT 0.125)
 RETURNS raster
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT _st_gdalwarp($1, $5, $6, $2, $3, $4) $function$

CREATE OR REPLACE FUNCTION public.st_translate(geometry, double precision, double precision)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT ST_Translate($1, $2, $3, 0)$function$
CREATE OR REPLACE FUNCTION public.st_translate(geometry, double precision, double precision, double precision)
 RETURNS geometry
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT ST_Affine($1, 1, 0, 0, 0, 1, 0, 0, 0, 1, $2, $3, $4)$function$

CREATE OR REPLACE FUNCTION public.st_tri(rast raster, nband integer DEFAULT 1, pixeltype text DEFAULT '32BF'::text, interpolate_nodata boolean DEFAULT false)
 RETURNS raster
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT st_tri($1, $2, NULL::raster, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_tri(rast raster, nband integer, customextent raster, pixeltype text DEFAULT '32BF'::text, interpolate_nodata boolean DEFAULT false)
 RETURNS raster
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
	DECLARE
		_rast raster;
		_nband integer;
		_pixtype text;
		_pixwidth double precision;
		_pixheight double precision;
		_width integer;
		_height integer;
		_customextent raster;
		_extenttype text;
	BEGIN
		_customextent := customextent;
		IF _customextent IS NULL THEN
			_extenttype := 'FIRST';
		ELSE
			_extenttype := 'CUSTOM';
		END IF;
		IF interpolate_nodata IS TRUE THEN
			_rast := ST_MapAlgebra(
				ARRAY[ROW(rast, nband)]::rastbandarg[],
				'st_invdistweight4ma(double precision[][][], integer[][], text[])'::regprocedure,
				pixeltype,
				'FIRST', NULL,
				1, 1
			);
			_nband := 1;
			_pixtype := NULL;
		ELSE
			_rast := rast;
			_nband := nband;
			_pixtype := pixeltype;
		END IF;
		-- get properties
		_pixwidth := ST_PixelWidth(_rast);
		_pixheight := ST_PixelHeight(_rast);
		SELECT width, height INTO _width, _height FROM ST_Metadata(_rast);
		RETURN ST_MapAlgebra(
			ARRAY[ROW(_rast, _nband)]::rastbandarg[],
			'_st_tri4ma(double precision[][][], integer[][], text[])'::regprocedure,
			_pixtype,
			_extenttype, _customextent,
			1, 1);
	END;
	$function$

CREATE OR REPLACE FUNCTION public.st_union(geom1 geometry, geom2 geometry)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$geomunion$function$
CREATE OR REPLACE FUNCTION public.st_union(geometry[])
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$pgis_union_geometry_array$function$

CREATE OR REPLACE FUNCTION public.st_union(geom1 geometry, geom2 geometry)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$geomunion$function$
CREATE OR REPLACE FUNCTION public.st_union(geometry[])
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$pgis_union_geometry_array$function$

CREATE OR REPLACE FUNCTION public.st_union(geom1 geometry, geom2 geometry)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$geomunion$function$
CREATE OR REPLACE FUNCTION public.st_union(geometry[])
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$pgis_union_geometry_array$function$

CREATE OR REPLACE FUNCTION public.st_union(geom1 geometry, geom2 geometry)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$geomunion$function$
CREATE OR REPLACE FUNCTION public.st_union(geometry[])
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$pgis_union_geometry_array$function$

CREATE OR REPLACE FUNCTION public.st_union(geom1 geometry, geom2 geometry)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$geomunion$function$
CREATE OR REPLACE FUNCTION public.st_union(geometry[])
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$pgis_union_geometry_array$function$

CREATE OR REPLACE FUNCTION public.st_union(geom1 geometry, geom2 geometry)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$geomunion$function$
CREATE OR REPLACE FUNCTION public.st_union(geometry[])
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$pgis_union_geometry_array$function$

CREATE OR REPLACE FUNCTION public.st_union(geom1 geometry, geom2 geometry)
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$geomunion$function$
CREATE OR REPLACE FUNCTION public.st_union(geometry[])
 RETURNS geometry
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/postgis-2.2', $function$pgis_union_geometry_array$function$

CREATE OR REPLACE FUNCTION public.st_value(rast raster, pt geometry, exclude_nodata_value boolean DEFAULT true)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT st_value($1, 1, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_value(rast raster, x integer, y integer, exclude_nodata_value boolean DEFAULT true)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT st_value($1, 1, $2, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_value(rast raster, band integer, pt geometry, exclude_nodata_value boolean DEFAULT true)
 RETURNS double precision
 LANGUAGE plpgsql
 IMMUTABLE STRICT
AS $function$
    DECLARE
        x float8;
        y float8;
        gtype text;
    BEGIN
        gtype := st_geometrytype(pt);
        IF ( gtype != 'ST_Point' ) THEN
            RAISE EXCEPTION 'Attempting to get the value of a pixel with a non-point geometry';
        END IF;
				IF ST_SRID(pt) != ST_SRID(rast) THEN
            RAISE EXCEPTION 'Raster and geometry do not have the same SRID';
				END IF;
        x := st_x(pt);
        y := st_y(pt);
        RETURN st_value(rast,
                        band,
                        st_worldtorastercoordx(rast, x, y),
                        st_worldtorastercoordy(rast, x, y),
                        exclude_nodata_value);
    END;
    $function$
CREATE OR REPLACE FUNCTION public.st_value(rast raster, band integer, x integer, y integer, exclude_nodata_value boolean DEFAULT true)
 RETURNS double precision
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/rtpostgis-2.2', $function$RASTER_getPixelValue$function$

CREATE OR REPLACE FUNCTION public.st_value(rast raster, pt geometry, exclude_nodata_value boolean DEFAULT true)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT st_value($1, 1, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_value(rast raster, x integer, y integer, exclude_nodata_value boolean DEFAULT true)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT st_value($1, 1, $2, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_value(rast raster, band integer, pt geometry, exclude_nodata_value boolean DEFAULT true)
 RETURNS double precision
 LANGUAGE plpgsql
 IMMUTABLE STRICT
AS $function$
    DECLARE
        x float8;
        y float8;
        gtype text;
    BEGIN
        gtype := st_geometrytype(pt);
        IF ( gtype != 'ST_Point' ) THEN
            RAISE EXCEPTION 'Attempting to get the value of a pixel with a non-point geometry';
        END IF;
				IF ST_SRID(pt) != ST_SRID(rast) THEN
            RAISE EXCEPTION 'Raster and geometry do not have the same SRID';
				END IF;
        x := st_x(pt);
        y := st_y(pt);
        RETURN st_value(rast,
                        band,
                        st_worldtorastercoordx(rast, x, y),
                        st_worldtorastercoordy(rast, x, y),
                        exclude_nodata_value);
    END;
    $function$
CREATE OR REPLACE FUNCTION public.st_value(rast raster, band integer, x integer, y integer, exclude_nodata_value boolean DEFAULT true)
 RETURNS double precision
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/rtpostgis-2.2', $function$RASTER_getPixelValue$function$

CREATE OR REPLACE FUNCTION public.st_value(rast raster, pt geometry, exclude_nodata_value boolean DEFAULT true)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT st_value($1, 1, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_value(rast raster, x integer, y integer, exclude_nodata_value boolean DEFAULT true)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT st_value($1, 1, $2, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_value(rast raster, band integer, pt geometry, exclude_nodata_value boolean DEFAULT true)
 RETURNS double precision
 LANGUAGE plpgsql
 IMMUTABLE STRICT
AS $function$
    DECLARE
        x float8;
        y float8;
        gtype text;
    BEGIN
        gtype := st_geometrytype(pt);
        IF ( gtype != 'ST_Point' ) THEN
            RAISE EXCEPTION 'Attempting to get the value of a pixel with a non-point geometry';
        END IF;
				IF ST_SRID(pt) != ST_SRID(rast) THEN
            RAISE EXCEPTION 'Raster and geometry do not have the same SRID';
				END IF;
        x := st_x(pt);
        y := st_y(pt);
        RETURN st_value(rast,
                        band,
                        st_worldtorastercoordx(rast, x, y),
                        st_worldtorastercoordy(rast, x, y),
                        exclude_nodata_value);
    END;
    $function$
CREATE OR REPLACE FUNCTION public.st_value(rast raster, band integer, x integer, y integer, exclude_nodata_value boolean DEFAULT true)
 RETURNS double precision
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/rtpostgis-2.2', $function$RASTER_getPixelValue$function$

CREATE OR REPLACE FUNCTION public.st_valuecount(rast raster, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT value, count FROM _st_valuecount($1, 1, TRUE, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, searchvalues double precision[] DEFAULT NULL::double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT value, count FROM _st_valuecount($1, $2, $3, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rast raster, nband integer, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT value, count FROM _st_valuecount($1, $2, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rast raster, nband integer, exclude_nodata_value boolean, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS integer
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, $3, ARRAY[$4]::double precision[], $5)).count $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rast raster, nband integer, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS integer
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, TRUE, ARRAY[$3]::double precision[], $4)).count $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rast raster, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS integer
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_valuecount($1, 1, TRUE, ARRAY[$2]::double precision[], $3)).count $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, searchvalues double precision[] DEFAULT NULL::double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT value, count FROM _st_valuecount($1, $2, $3, $4, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rastertable text, rastercolumn text, nband integer, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT value, count FROM _st_valuecount($1, $2, $3, TRUE, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rastertable text, rastercolumn text, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT value, count FROM _st_valuecount($1, $2, 1, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS integer
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, $3, $4, ARRAY[$5]::double precision[], $6)).count $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rastertable text, rastercolumn text, nband integer, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS integer
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, $3, TRUE, ARRAY[$4]::double precision[], $5)).count $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rastertable text, rastercolumn text, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS integer
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, 1, TRUE, ARRAY[$3]::double precision[], $4)).count $function$

CREATE OR REPLACE FUNCTION public.st_valuecount(rast raster, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT value, count FROM _st_valuecount($1, 1, TRUE, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, searchvalues double precision[] DEFAULT NULL::double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT value, count FROM _st_valuecount($1, $2, $3, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rast raster, nband integer, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT value, count FROM _st_valuecount($1, $2, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rast raster, nband integer, exclude_nodata_value boolean, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS integer
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, $3, ARRAY[$4]::double precision[], $5)).count $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rast raster, nband integer, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS integer
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, TRUE, ARRAY[$3]::double precision[], $4)).count $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rast raster, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS integer
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_valuecount($1, 1, TRUE, ARRAY[$2]::double precision[], $3)).count $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, searchvalues double precision[] DEFAULT NULL::double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT value, count FROM _st_valuecount($1, $2, $3, $4, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rastertable text, rastercolumn text, nband integer, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT value, count FROM _st_valuecount($1, $2, $3, TRUE, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rastertable text, rastercolumn text, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT value, count FROM _st_valuecount($1, $2, 1, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS integer
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, $3, $4, ARRAY[$5]::double precision[], $6)).count $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rastertable text, rastercolumn text, nband integer, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS integer
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, $3, TRUE, ARRAY[$4]::double precision[], $5)).count $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rastertable text, rastercolumn text, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS integer
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, 1, TRUE, ARRAY[$3]::double precision[], $4)).count $function$

CREATE OR REPLACE FUNCTION public.st_valuecount(rast raster, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT value, count FROM _st_valuecount($1, 1, TRUE, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, searchvalues double precision[] DEFAULT NULL::double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT value, count FROM _st_valuecount($1, $2, $3, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rast raster, nband integer, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT value, count FROM _st_valuecount($1, $2, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rast raster, nband integer, exclude_nodata_value boolean, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS integer
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, $3, ARRAY[$4]::double precision[], $5)).count $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rast raster, nband integer, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS integer
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, TRUE, ARRAY[$3]::double precision[], $4)).count $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rast raster, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS integer
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_valuecount($1, 1, TRUE, ARRAY[$2]::double precision[], $3)).count $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, searchvalues double precision[] DEFAULT NULL::double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT value, count FROM _st_valuecount($1, $2, $3, $4, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rastertable text, rastercolumn text, nband integer, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT value, count FROM _st_valuecount($1, $2, $3, TRUE, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rastertable text, rastercolumn text, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT value, count FROM _st_valuecount($1, $2, 1, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS integer
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, $3, $4, ARRAY[$5]::double precision[], $6)).count $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rastertable text, rastercolumn text, nband integer, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS integer
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, $3, TRUE, ARRAY[$4]::double precision[], $5)).count $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rastertable text, rastercolumn text, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS integer
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, 1, TRUE, ARRAY[$3]::double precision[], $4)).count $function$

CREATE OR REPLACE FUNCTION public.st_valuecount(rast raster, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT value, count FROM _st_valuecount($1, 1, TRUE, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, searchvalues double precision[] DEFAULT NULL::double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT value, count FROM _st_valuecount($1, $2, $3, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rast raster, nband integer, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT value, count FROM _st_valuecount($1, $2, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rast raster, nband integer, exclude_nodata_value boolean, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS integer
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, $3, ARRAY[$4]::double precision[], $5)).count $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rast raster, nband integer, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS integer
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, TRUE, ARRAY[$3]::double precision[], $4)).count $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rast raster, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS integer
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_valuecount($1, 1, TRUE, ARRAY[$2]::double precision[], $3)).count $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, searchvalues double precision[] DEFAULT NULL::double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT value, count FROM _st_valuecount($1, $2, $3, $4, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rastertable text, rastercolumn text, nband integer, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT value, count FROM _st_valuecount($1, $2, $3, TRUE, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rastertable text, rastercolumn text, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT value, count FROM _st_valuecount($1, $2, 1, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS integer
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, $3, $4, ARRAY[$5]::double precision[], $6)).count $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rastertable text, rastercolumn text, nband integer, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS integer
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, $3, TRUE, ARRAY[$4]::double precision[], $5)).count $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rastertable text, rastercolumn text, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS integer
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, 1, TRUE, ARRAY[$3]::double precision[], $4)).count $function$

CREATE OR REPLACE FUNCTION public.st_valuecount(rast raster, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT value, count FROM _st_valuecount($1, 1, TRUE, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, searchvalues double precision[] DEFAULT NULL::double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT value, count FROM _st_valuecount($1, $2, $3, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rast raster, nband integer, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT value, count FROM _st_valuecount($1, $2, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rast raster, nband integer, exclude_nodata_value boolean, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS integer
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, $3, ARRAY[$4]::double precision[], $5)).count $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rast raster, nband integer, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS integer
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, TRUE, ARRAY[$3]::double precision[], $4)).count $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rast raster, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS integer
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_valuecount($1, 1, TRUE, ARRAY[$2]::double precision[], $3)).count $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, searchvalues double precision[] DEFAULT NULL::double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT value, count FROM _st_valuecount($1, $2, $3, $4, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rastertable text, rastercolumn text, nband integer, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT value, count FROM _st_valuecount($1, $2, $3, TRUE, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rastertable text, rastercolumn text, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT value, count FROM _st_valuecount($1, $2, 1, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS integer
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, $3, $4, ARRAY[$5]::double precision[], $6)).count $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rastertable text, rastercolumn text, nband integer, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS integer
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, $3, TRUE, ARRAY[$4]::double precision[], $5)).count $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rastertable text, rastercolumn text, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS integer
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, 1, TRUE, ARRAY[$3]::double precision[], $4)).count $function$

CREATE OR REPLACE FUNCTION public.st_valuecount(rast raster, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT value, count FROM _st_valuecount($1, 1, TRUE, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, searchvalues double precision[] DEFAULT NULL::double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT value, count FROM _st_valuecount($1, $2, $3, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rast raster, nband integer, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT value, count FROM _st_valuecount($1, $2, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rast raster, nband integer, exclude_nodata_value boolean, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS integer
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, $3, ARRAY[$4]::double precision[], $5)).count $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rast raster, nband integer, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS integer
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, TRUE, ARRAY[$3]::double precision[], $4)).count $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rast raster, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS integer
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_valuecount($1, 1, TRUE, ARRAY[$2]::double precision[], $3)).count $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, searchvalues double precision[] DEFAULT NULL::double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT value, count FROM _st_valuecount($1, $2, $3, $4, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rastertable text, rastercolumn text, nband integer, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT value, count FROM _st_valuecount($1, $2, $3, TRUE, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rastertable text, rastercolumn text, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT value, count FROM _st_valuecount($1, $2, 1, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS integer
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, $3, $4, ARRAY[$5]::double precision[], $6)).count $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rastertable text, rastercolumn text, nband integer, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS integer
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, $3, TRUE, ARRAY[$4]::double precision[], $5)).count $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rastertable text, rastercolumn text, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS integer
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, 1, TRUE, ARRAY[$3]::double precision[], $4)).count $function$

CREATE OR REPLACE FUNCTION public.st_valuecount(rast raster, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT value, count FROM _st_valuecount($1, 1, TRUE, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, searchvalues double precision[] DEFAULT NULL::double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT value, count FROM _st_valuecount($1, $2, $3, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rast raster, nband integer, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT value, count FROM _st_valuecount($1, $2, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rast raster, nband integer, exclude_nodata_value boolean, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS integer
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, $3, ARRAY[$4]::double precision[], $5)).count $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rast raster, nband integer, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS integer
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, TRUE, ARRAY[$3]::double precision[], $4)).count $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rast raster, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS integer
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_valuecount($1, 1, TRUE, ARRAY[$2]::double precision[], $3)).count $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, searchvalues double precision[] DEFAULT NULL::double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT value, count FROM _st_valuecount($1, $2, $3, $4, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rastertable text, rastercolumn text, nband integer, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT value, count FROM _st_valuecount($1, $2, $3, TRUE, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rastertable text, rastercolumn text, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT value, count FROM _st_valuecount($1, $2, 1, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS integer
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, $3, $4, ARRAY[$5]::double precision[], $6)).count $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rastertable text, rastercolumn text, nband integer, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS integer
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, $3, TRUE, ARRAY[$4]::double precision[], $5)).count $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rastertable text, rastercolumn text, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS integer
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, 1, TRUE, ARRAY[$3]::double precision[], $4)).count $function$

CREATE OR REPLACE FUNCTION public.st_valuecount(rast raster, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT value, count FROM _st_valuecount($1, 1, TRUE, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, searchvalues double precision[] DEFAULT NULL::double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT value, count FROM _st_valuecount($1, $2, $3, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rast raster, nband integer, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT value, count FROM _st_valuecount($1, $2, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rast raster, nband integer, exclude_nodata_value boolean, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS integer
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, $3, ARRAY[$4]::double precision[], $5)).count $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rast raster, nband integer, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS integer
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, TRUE, ARRAY[$3]::double precision[], $4)).count $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rast raster, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS integer
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_valuecount($1, 1, TRUE, ARRAY[$2]::double precision[], $3)).count $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, searchvalues double precision[] DEFAULT NULL::double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT value, count FROM _st_valuecount($1, $2, $3, $4, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rastertable text, rastercolumn text, nband integer, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT value, count FROM _st_valuecount($1, $2, $3, TRUE, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rastertable text, rastercolumn text, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT value, count FROM _st_valuecount($1, $2, 1, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS integer
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, $3, $4, ARRAY[$5]::double precision[], $6)).count $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rastertable text, rastercolumn text, nband integer, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS integer
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, $3, TRUE, ARRAY[$4]::double precision[], $5)).count $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rastertable text, rastercolumn text, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS integer
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, 1, TRUE, ARRAY[$3]::double precision[], $4)).count $function$

CREATE OR REPLACE FUNCTION public.st_valuecount(rast raster, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT value, count FROM _st_valuecount($1, 1, TRUE, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, searchvalues double precision[] DEFAULT NULL::double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT value, count FROM _st_valuecount($1, $2, $3, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rast raster, nband integer, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT value, count FROM _st_valuecount($1, $2, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rast raster, nband integer, exclude_nodata_value boolean, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS integer
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, $3, ARRAY[$4]::double precision[], $5)).count $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rast raster, nband integer, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS integer
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, TRUE, ARRAY[$3]::double precision[], $4)).count $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rast raster, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS integer
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_valuecount($1, 1, TRUE, ARRAY[$2]::double precision[], $3)).count $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, searchvalues double precision[] DEFAULT NULL::double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT value, count FROM _st_valuecount($1, $2, $3, $4, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rastertable text, rastercolumn text, nband integer, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT value, count FROM _st_valuecount($1, $2, $3, TRUE, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rastertable text, rastercolumn text, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT value, count FROM _st_valuecount($1, $2, 1, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS integer
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, $3, $4, ARRAY[$5]::double precision[], $6)).count $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rastertable text, rastercolumn text, nband integer, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS integer
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, $3, TRUE, ARRAY[$4]::double precision[], $5)).count $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rastertable text, rastercolumn text, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS integer
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, 1, TRUE, ARRAY[$3]::double precision[], $4)).count $function$

CREATE OR REPLACE FUNCTION public.st_valuecount(rast raster, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT value, count FROM _st_valuecount($1, 1, TRUE, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, searchvalues double precision[] DEFAULT NULL::double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT value, count FROM _st_valuecount($1, $2, $3, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rast raster, nband integer, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT value, count FROM _st_valuecount($1, $2, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rast raster, nband integer, exclude_nodata_value boolean, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS integer
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, $3, ARRAY[$4]::double precision[], $5)).count $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rast raster, nband integer, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS integer
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, TRUE, ARRAY[$3]::double precision[], $4)).count $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rast raster, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS integer
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_valuecount($1, 1, TRUE, ARRAY[$2]::double precision[], $3)).count $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, searchvalues double precision[] DEFAULT NULL::double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT value, count FROM _st_valuecount($1, $2, $3, $4, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rastertable text, rastercolumn text, nband integer, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT value, count FROM _st_valuecount($1, $2, $3, TRUE, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rastertable text, rastercolumn text, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT value, count FROM _st_valuecount($1, $2, 1, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS integer
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, $3, $4, ARRAY[$5]::double precision[], $6)).count $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rastertable text, rastercolumn text, nband integer, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS integer
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, $3, TRUE, ARRAY[$4]::double precision[], $5)).count $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rastertable text, rastercolumn text, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS integer
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, 1, TRUE, ARRAY[$3]::double precision[], $4)).count $function$

CREATE OR REPLACE FUNCTION public.st_valuecount(rast raster, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT value, count FROM _st_valuecount($1, 1, TRUE, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, searchvalues double precision[] DEFAULT NULL::double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT value, count FROM _st_valuecount($1, $2, $3, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rast raster, nband integer, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT value, count FROM _st_valuecount($1, $2, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rast raster, nband integer, exclude_nodata_value boolean, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS integer
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, $3, ARRAY[$4]::double precision[], $5)).count $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rast raster, nband integer, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS integer
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, TRUE, ARRAY[$3]::double precision[], $4)).count $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rast raster, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS integer
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_valuecount($1, 1, TRUE, ARRAY[$2]::double precision[], $3)).count $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, searchvalues double precision[] DEFAULT NULL::double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT value, count FROM _st_valuecount($1, $2, $3, $4, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rastertable text, rastercolumn text, nband integer, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT value, count FROM _st_valuecount($1, $2, $3, TRUE, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rastertable text, rastercolumn text, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT value, count FROM _st_valuecount($1, $2, 1, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS integer
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, $3, $4, ARRAY[$5]::double precision[], $6)).count $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rastertable text, rastercolumn text, nband integer, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS integer
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, $3, TRUE, ARRAY[$4]::double precision[], $5)).count $function$
CREATE OR REPLACE FUNCTION public.st_valuecount(rastertable text, rastercolumn text, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS integer
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, 1, TRUE, ARRAY[$3]::double precision[], $4)).count $function$

CREATE OR REPLACE FUNCTION public.st_valuepercent(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, searchvalues double precision[] DEFAULT NULL::double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT value, percent FROM _st_valuecount($1, $2, $3, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rast raster, nband integer, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT value, percent FROM _st_valuecount($1, $2, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rast raster, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT value, percent FROM _st_valuecount($1, 1, TRUE, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rast raster, nband integer, exclude_nodata_value boolean, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, $3, ARRAY[$4]::double precision[], $5)).percent $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rast raster, nband integer, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, TRUE, ARRAY[$3]::double precision[], $4)).percent $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rast raster, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_valuecount($1, 1, TRUE, ARRAY[$2]::double precision[], $3)).percent $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, searchvalues double precision[] DEFAULT NULL::double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT value, percent FROM _st_valuecount($1, $2, $3, $4, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rastertable text, rastercolumn text, nband integer, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT value, percent FROM _st_valuecount($1, $2, $3, TRUE, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rastertable text, rastercolumn text, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT value, percent FROM _st_valuecount($1, $2, 1, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, $3, $4, ARRAY[$5]::double precision[], $6)).percent $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rastertable text, rastercolumn text, nband integer, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, $3, TRUE, ARRAY[$4]::double precision[], $5)).percent $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rastertable text, rastercolumn text, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, 1, TRUE, ARRAY[$3]::double precision[], $4)).percent $function$

CREATE OR REPLACE FUNCTION public.st_valuepercent(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, searchvalues double precision[] DEFAULT NULL::double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT value, percent FROM _st_valuecount($1, $2, $3, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rast raster, nband integer, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT value, percent FROM _st_valuecount($1, $2, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rast raster, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT value, percent FROM _st_valuecount($1, 1, TRUE, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rast raster, nband integer, exclude_nodata_value boolean, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, $3, ARRAY[$4]::double precision[], $5)).percent $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rast raster, nband integer, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, TRUE, ARRAY[$3]::double precision[], $4)).percent $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rast raster, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_valuecount($1, 1, TRUE, ARRAY[$2]::double precision[], $3)).percent $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, searchvalues double precision[] DEFAULT NULL::double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT value, percent FROM _st_valuecount($1, $2, $3, $4, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rastertable text, rastercolumn text, nband integer, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT value, percent FROM _st_valuecount($1, $2, $3, TRUE, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rastertable text, rastercolumn text, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT value, percent FROM _st_valuecount($1, $2, 1, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, $3, $4, ARRAY[$5]::double precision[], $6)).percent $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rastertable text, rastercolumn text, nband integer, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, $3, TRUE, ARRAY[$4]::double precision[], $5)).percent $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rastertable text, rastercolumn text, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, 1, TRUE, ARRAY[$3]::double precision[], $4)).percent $function$

CREATE OR REPLACE FUNCTION public.st_valuepercent(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, searchvalues double precision[] DEFAULT NULL::double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT value, percent FROM _st_valuecount($1, $2, $3, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rast raster, nband integer, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT value, percent FROM _st_valuecount($1, $2, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rast raster, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT value, percent FROM _st_valuecount($1, 1, TRUE, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rast raster, nband integer, exclude_nodata_value boolean, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, $3, ARRAY[$4]::double precision[], $5)).percent $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rast raster, nband integer, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, TRUE, ARRAY[$3]::double precision[], $4)).percent $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rast raster, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_valuecount($1, 1, TRUE, ARRAY[$2]::double precision[], $3)).percent $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, searchvalues double precision[] DEFAULT NULL::double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT value, percent FROM _st_valuecount($1, $2, $3, $4, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rastertable text, rastercolumn text, nband integer, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT value, percent FROM _st_valuecount($1, $2, $3, TRUE, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rastertable text, rastercolumn text, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT value, percent FROM _st_valuecount($1, $2, 1, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, $3, $4, ARRAY[$5]::double precision[], $6)).percent $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rastertable text, rastercolumn text, nband integer, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, $3, TRUE, ARRAY[$4]::double precision[], $5)).percent $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rastertable text, rastercolumn text, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, 1, TRUE, ARRAY[$3]::double precision[], $4)).percent $function$

CREATE OR REPLACE FUNCTION public.st_valuepercent(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, searchvalues double precision[] DEFAULT NULL::double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT value, percent FROM _st_valuecount($1, $2, $3, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rast raster, nband integer, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT value, percent FROM _st_valuecount($1, $2, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rast raster, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT value, percent FROM _st_valuecount($1, 1, TRUE, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rast raster, nband integer, exclude_nodata_value boolean, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, $3, ARRAY[$4]::double precision[], $5)).percent $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rast raster, nband integer, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, TRUE, ARRAY[$3]::double precision[], $4)).percent $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rast raster, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_valuecount($1, 1, TRUE, ARRAY[$2]::double precision[], $3)).percent $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, searchvalues double precision[] DEFAULT NULL::double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT value, percent FROM _st_valuecount($1, $2, $3, $4, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rastertable text, rastercolumn text, nband integer, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT value, percent FROM _st_valuecount($1, $2, $3, TRUE, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rastertable text, rastercolumn text, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT value, percent FROM _st_valuecount($1, $2, 1, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, $3, $4, ARRAY[$5]::double precision[], $6)).percent $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rastertable text, rastercolumn text, nband integer, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, $3, TRUE, ARRAY[$4]::double precision[], $5)).percent $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rastertable text, rastercolumn text, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, 1, TRUE, ARRAY[$3]::double precision[], $4)).percent $function$

CREATE OR REPLACE FUNCTION public.st_valuepercent(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, searchvalues double precision[] DEFAULT NULL::double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT value, percent FROM _st_valuecount($1, $2, $3, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rast raster, nband integer, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT value, percent FROM _st_valuecount($1, $2, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rast raster, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT value, percent FROM _st_valuecount($1, 1, TRUE, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rast raster, nband integer, exclude_nodata_value boolean, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, $3, ARRAY[$4]::double precision[], $5)).percent $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rast raster, nband integer, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, TRUE, ARRAY[$3]::double precision[], $4)).percent $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rast raster, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_valuecount($1, 1, TRUE, ARRAY[$2]::double precision[], $3)).percent $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, searchvalues double precision[] DEFAULT NULL::double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT value, percent FROM _st_valuecount($1, $2, $3, $4, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rastertable text, rastercolumn text, nband integer, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT value, percent FROM _st_valuecount($1, $2, $3, TRUE, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rastertable text, rastercolumn text, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT value, percent FROM _st_valuecount($1, $2, 1, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, $3, $4, ARRAY[$5]::double precision[], $6)).percent $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rastertable text, rastercolumn text, nband integer, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, $3, TRUE, ARRAY[$4]::double precision[], $5)).percent $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rastertable text, rastercolumn text, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, 1, TRUE, ARRAY[$3]::double precision[], $4)).percent $function$

CREATE OR REPLACE FUNCTION public.st_valuepercent(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, searchvalues double precision[] DEFAULT NULL::double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT value, percent FROM _st_valuecount($1, $2, $3, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rast raster, nband integer, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT value, percent FROM _st_valuecount($1, $2, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rast raster, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT value, percent FROM _st_valuecount($1, 1, TRUE, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rast raster, nband integer, exclude_nodata_value boolean, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, $3, ARRAY[$4]::double precision[], $5)).percent $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rast raster, nband integer, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, TRUE, ARRAY[$3]::double precision[], $4)).percent $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rast raster, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_valuecount($1, 1, TRUE, ARRAY[$2]::double precision[], $3)).percent $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, searchvalues double precision[] DEFAULT NULL::double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT value, percent FROM _st_valuecount($1, $2, $3, $4, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rastertable text, rastercolumn text, nband integer, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT value, percent FROM _st_valuecount($1, $2, $3, TRUE, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rastertable text, rastercolumn text, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT value, percent FROM _st_valuecount($1, $2, 1, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, $3, $4, ARRAY[$5]::double precision[], $6)).percent $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rastertable text, rastercolumn text, nband integer, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, $3, TRUE, ARRAY[$4]::double precision[], $5)).percent $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rastertable text, rastercolumn text, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, 1, TRUE, ARRAY[$3]::double precision[], $4)).percent $function$

CREATE OR REPLACE FUNCTION public.st_valuepercent(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, searchvalues double precision[] DEFAULT NULL::double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT value, percent FROM _st_valuecount($1, $2, $3, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rast raster, nband integer, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT value, percent FROM _st_valuecount($1, $2, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rast raster, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT value, percent FROM _st_valuecount($1, 1, TRUE, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rast raster, nband integer, exclude_nodata_value boolean, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, $3, ARRAY[$4]::double precision[], $5)).percent $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rast raster, nband integer, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, TRUE, ARRAY[$3]::double precision[], $4)).percent $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rast raster, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_valuecount($1, 1, TRUE, ARRAY[$2]::double precision[], $3)).percent $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, searchvalues double precision[] DEFAULT NULL::double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT value, percent FROM _st_valuecount($1, $2, $3, $4, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rastertable text, rastercolumn text, nband integer, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT value, percent FROM _st_valuecount($1, $2, $3, TRUE, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rastertable text, rastercolumn text, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT value, percent FROM _st_valuecount($1, $2, 1, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, $3, $4, ARRAY[$5]::double precision[], $6)).percent $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rastertable text, rastercolumn text, nband integer, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, $3, TRUE, ARRAY[$4]::double precision[], $5)).percent $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rastertable text, rastercolumn text, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, 1, TRUE, ARRAY[$3]::double precision[], $4)).percent $function$

CREATE OR REPLACE FUNCTION public.st_valuepercent(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, searchvalues double precision[] DEFAULT NULL::double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT value, percent FROM _st_valuecount($1, $2, $3, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rast raster, nband integer, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT value, percent FROM _st_valuecount($1, $2, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rast raster, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT value, percent FROM _st_valuecount($1, 1, TRUE, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rast raster, nband integer, exclude_nodata_value boolean, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, $3, ARRAY[$4]::double precision[], $5)).percent $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rast raster, nband integer, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, TRUE, ARRAY[$3]::double precision[], $4)).percent $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rast raster, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_valuecount($1, 1, TRUE, ARRAY[$2]::double precision[], $3)).percent $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, searchvalues double precision[] DEFAULT NULL::double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT value, percent FROM _st_valuecount($1, $2, $3, $4, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rastertable text, rastercolumn text, nband integer, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT value, percent FROM _st_valuecount($1, $2, $3, TRUE, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rastertable text, rastercolumn text, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT value, percent FROM _st_valuecount($1, $2, 1, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, $3, $4, ARRAY[$5]::double precision[], $6)).percent $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rastertable text, rastercolumn text, nband integer, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, $3, TRUE, ARRAY[$4]::double precision[], $5)).percent $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rastertable text, rastercolumn text, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, 1, TRUE, ARRAY[$3]::double precision[], $4)).percent $function$

CREATE OR REPLACE FUNCTION public.st_valuepercent(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, searchvalues double precision[] DEFAULT NULL::double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT value, percent FROM _st_valuecount($1, $2, $3, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rast raster, nband integer, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT value, percent FROM _st_valuecount($1, $2, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rast raster, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT value, percent FROM _st_valuecount($1, 1, TRUE, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rast raster, nband integer, exclude_nodata_value boolean, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, $3, ARRAY[$4]::double precision[], $5)).percent $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rast raster, nband integer, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, TRUE, ARRAY[$3]::double precision[], $4)).percent $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rast raster, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_valuecount($1, 1, TRUE, ARRAY[$2]::double precision[], $3)).percent $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, searchvalues double precision[] DEFAULT NULL::double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT value, percent FROM _st_valuecount($1, $2, $3, $4, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rastertable text, rastercolumn text, nband integer, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT value, percent FROM _st_valuecount($1, $2, $3, TRUE, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rastertable text, rastercolumn text, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT value, percent FROM _st_valuecount($1, $2, 1, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, $3, $4, ARRAY[$5]::double precision[], $6)).percent $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rastertable text, rastercolumn text, nband integer, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, $3, TRUE, ARRAY[$4]::double precision[], $5)).percent $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rastertable text, rastercolumn text, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, 1, TRUE, ARRAY[$3]::double precision[], $4)).percent $function$

CREATE OR REPLACE FUNCTION public.st_valuepercent(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, searchvalues double precision[] DEFAULT NULL::double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT value, percent FROM _st_valuecount($1, $2, $3, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rast raster, nband integer, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT value, percent FROM _st_valuecount($1, $2, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rast raster, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT value, percent FROM _st_valuecount($1, 1, TRUE, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rast raster, nband integer, exclude_nodata_value boolean, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, $3, ARRAY[$4]::double precision[], $5)).percent $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rast raster, nband integer, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, TRUE, ARRAY[$3]::double precision[], $4)).percent $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rast raster, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_valuecount($1, 1, TRUE, ARRAY[$2]::double precision[], $3)).percent $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, searchvalues double precision[] DEFAULT NULL::double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT value, percent FROM _st_valuecount($1, $2, $3, $4, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rastertable text, rastercolumn text, nband integer, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT value, percent FROM _st_valuecount($1, $2, $3, TRUE, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rastertable text, rastercolumn text, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT value, percent FROM _st_valuecount($1, $2, 1, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, $3, $4, ARRAY[$5]::double precision[], $6)).percent $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rastertable text, rastercolumn text, nband integer, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, $3, TRUE, ARRAY[$4]::double precision[], $5)).percent $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rastertable text, rastercolumn text, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, 1, TRUE, ARRAY[$3]::double precision[], $4)).percent $function$

CREATE OR REPLACE FUNCTION public.st_valuepercent(rast raster, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, searchvalues double precision[] DEFAULT NULL::double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT value, percent FROM _st_valuecount($1, $2, $3, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rast raster, nband integer, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT value, percent FROM _st_valuecount($1, $2, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rast raster, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT value, percent FROM _st_valuecount($1, 1, TRUE, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rast raster, nband integer, exclude_nodata_value boolean, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, $3, ARRAY[$4]::double precision[], $5)).percent $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rast raster, nband integer, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, TRUE, ARRAY[$3]::double precision[], $4)).percent $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rast raster, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS double precision
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT (_st_valuecount($1, 1, TRUE, ARRAY[$2]::double precision[], $3)).percent $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT true, searchvalues double precision[] DEFAULT NULL::double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT value, percent FROM _st_valuecount($1, $2, $3, $4, $5, $6) $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rastertable text, rastercolumn text, nband integer, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT value, percent FROM _st_valuecount($1, $2, $3, TRUE, $4, $5) $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rastertable text, rastercolumn text, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT percent double precision)
 RETURNS SETOF record
 LANGUAGE sql
 STABLE
AS $function$ SELECT value, percent FROM _st_valuecount($1, $2, 1, TRUE, $3, $4) $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, $3, $4, ARRAY[$5]::double precision[], $6)).percent $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rastertable text, rastercolumn text, nband integer, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, $3, TRUE, ARRAY[$4]::double precision[], $5)).percent $function$
CREATE OR REPLACE FUNCTION public.st_valuepercent(rastertable text, rastercolumn text, searchvalue double precision, roundto double precision DEFAULT 0)
 RETURNS double precision
 LANGUAGE sql
 STABLE STRICT
AS $function$ SELECT (_st_valuecount($1, $2, 1, TRUE, ARRAY[$3]::double precision[], $4)).percent $function$

CREATE OR REPLACE FUNCTION public.st_within(geom1 geometry, geom2 geometry)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$SELECT $2 ~ $1 AND _ST_Contains($2,$1)$function$
CREATE OR REPLACE FUNCTION public.st_within(rast1 raster, rast2 raster)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT st_within($1, NULL::integer, $2, NULL::integer) $function$
CREATE OR REPLACE FUNCTION public.st_within(rast1 raster, nband1 integer, rast2 raster, nband2 integer)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT $1 && $3 AND CASE WHEN $2 IS NULL OR $4 IS NULL THEN _st_within(st_convexhull($1), st_convexhull($3)) ELSE _st_contains($3, $4, $1, $2) END $function$

CREATE OR REPLACE FUNCTION public.st_within(geom1 geometry, geom2 geometry)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$SELECT $2 ~ $1 AND _ST_Contains($2,$1)$function$
CREATE OR REPLACE FUNCTION public.st_within(rast1 raster, rast2 raster)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT st_within($1, NULL::integer, $2, NULL::integer) $function$
CREATE OR REPLACE FUNCTION public.st_within(rast1 raster, nband1 integer, rast2 raster, nband2 integer)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE COST 1000
AS $function$ SELECT $1 && $3 AND CASE WHEN $2 IS NULL OR $4 IS NULL THEN _st_within(st_convexhull($1), st_convexhull($3)) ELSE _st_contains($3, $4, $1, $2) END $function$

CREATE OR REPLACE FUNCTION public.st_worldtorastercoord(rast raster, pt geometry, OUT columnx integer, OUT rowy integer)
 RETURNS record
 LANGUAGE plpgsql
 IMMUTABLE STRICT
AS $function$
	DECLARE
		rx integer;
		ry integer;
	BEGIN
		IF st_geometrytype(pt) != 'ST_Point' THEN
			RAISE EXCEPTION 'Attempting to compute raster coordinate with a non-point geometry';
		END IF;
		IF ST_SRID(rast) != ST_SRID(pt) THEN
			RAISE EXCEPTION 'Raster and geometry do not have the same SRID';
		END IF;
		SELECT rc.columnx AS x, rc.rowy AS y INTO columnx, rowy FROM _st_worldtorastercoord($1, st_x(pt), st_y(pt)) AS rc;
		RETURN;
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_worldtorastercoord(rast raster, longitude double precision, latitude double precision, OUT columnx integer, OUT rowy integer)
 RETURNS record
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT columnx, rowy FROM _st_worldtorastercoord($1, $2, $3) $function$

CREATE OR REPLACE FUNCTION public.st_worldtorastercoordx(rast raster, xw double precision)
 RETURNS integer
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT columnx FROM _st_worldtorastercoord($1, $2, NULL) $function$
CREATE OR REPLACE FUNCTION public.st_worldtorastercoordx(rast raster, pt geometry)
 RETURNS integer
 LANGUAGE plpgsql
 IMMUTABLE STRICT
AS $function$
	DECLARE
		xr integer;
	BEGIN
		IF ( st_geometrytype(pt) != 'ST_Point' ) THEN
			RAISE EXCEPTION 'Attempting to compute raster coordinate with a non-point geometry';
		END IF;
		IF ST_SRID(rast) != ST_SRID(pt) THEN
			RAISE EXCEPTION 'Raster and geometry do not have the same SRID';
		END IF;
		SELECT columnx INTO xr FROM _st_worldtorastercoord($1, st_x(pt), st_y(pt));
		RETURN xr;
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_worldtorastercoordx(rast raster, xw double precision, yw double precision)
 RETURNS integer
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT columnx FROM _st_worldtorastercoord($1, $2, $3) $function$

CREATE OR REPLACE FUNCTION public.st_worldtorastercoordx(rast raster, xw double precision)
 RETURNS integer
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT columnx FROM _st_worldtorastercoord($1, $2, NULL) $function$
CREATE OR REPLACE FUNCTION public.st_worldtorastercoordx(rast raster, pt geometry)
 RETURNS integer
 LANGUAGE plpgsql
 IMMUTABLE STRICT
AS $function$
	DECLARE
		xr integer;
	BEGIN
		IF ( st_geometrytype(pt) != 'ST_Point' ) THEN
			RAISE EXCEPTION 'Attempting to compute raster coordinate with a non-point geometry';
		END IF;
		IF ST_SRID(rast) != ST_SRID(pt) THEN
			RAISE EXCEPTION 'Raster and geometry do not have the same SRID';
		END IF;
		SELECT columnx INTO xr FROM _st_worldtorastercoord($1, st_x(pt), st_y(pt));
		RETURN xr;
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_worldtorastercoordx(rast raster, xw double precision, yw double precision)
 RETURNS integer
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT columnx FROM _st_worldtorastercoord($1, $2, $3) $function$

CREATE OR REPLACE FUNCTION public.st_worldtorastercoordy(rast raster, yw double precision)
 RETURNS integer
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT rowy FROM _st_worldtorastercoord($1, NULL, $2) $function$
CREATE OR REPLACE FUNCTION public.st_worldtorastercoordy(rast raster, pt geometry)
 RETURNS integer
 LANGUAGE plpgsql
 IMMUTABLE STRICT
AS $function$
	DECLARE
		yr integer;
	BEGIN
		IF ( st_geometrytype(pt) != 'ST_Point' ) THEN
			RAISE EXCEPTION 'Attempting to compute raster coordinate with a non-point geometry';
		END IF;
		IF ST_SRID(rast) != ST_SRID(pt) THEN
			RAISE EXCEPTION 'Raster and geometry do not have the same SRID';
		END IF;
		SELECT rowy INTO yr FROM _st_worldtorastercoord($1, st_x(pt), st_y(pt));
		RETURN yr;
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_worldtorastercoordy(rast raster, xw double precision, yw double precision)
 RETURNS integer
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT rowy FROM _st_worldtorastercoord($1, $2, $3) $function$

CREATE OR REPLACE FUNCTION public.st_worldtorastercoordy(rast raster, yw double precision)
 RETURNS integer
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT rowy FROM _st_worldtorastercoord($1, NULL, $2) $function$
CREATE OR REPLACE FUNCTION public.st_worldtorastercoordy(rast raster, pt geometry)
 RETURNS integer
 LANGUAGE plpgsql
 IMMUTABLE STRICT
AS $function$
	DECLARE
		yr integer;
	BEGIN
		IF ( st_geometrytype(pt) != 'ST_Point' ) THEN
			RAISE EXCEPTION 'Attempting to compute raster coordinate with a non-point geometry';
		END IF;
		IF ST_SRID(rast) != ST_SRID(pt) THEN
			RAISE EXCEPTION 'Raster and geometry do not have the same SRID';
		END IF;
		SELECT rowy INTO yr FROM _st_worldtorastercoord($1, st_x(pt), st_y(pt));
		RETURN yr;
	END;
	$function$
CREATE OR REPLACE FUNCTION public.st_worldtorastercoordy(rast raster, xw double precision, yw double precision)
 RETURNS integer
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$ SELECT rowy FROM _st_worldtorastercoord($1, $2, $3) $function$

CREATE OR REPLACE FUNCTION public.updategeometrysrid(character varying, character varying, integer)
 RETURNS text
 LANGUAGE plpgsql
 STRICT
AS $function$
DECLARE
	ret  text;
BEGIN
	SELECT UpdateGeometrySRID('','',$1,$2,$3) into ret;
	RETURN ret;
END;
$function$
CREATE OR REPLACE FUNCTION public.updategeometrysrid(character varying, character varying, character varying, integer)
 RETURNS text
 LANGUAGE plpgsql
 STRICT
AS $function$
DECLARE
	ret  text;
BEGIN
	SELECT UpdateGeometrySRID('',$1,$2,$3,$4) into ret;
	RETURN ret;
END;
$function$
CREATE OR REPLACE FUNCTION public.updategeometrysrid(catalogn_name character varying, schema_name character varying, table_name character varying, column_name character varying, new_srid_in integer)
 RETURNS text
 LANGUAGE plpgsql
 STRICT
AS $function$
DECLARE
	myrec RECORD;
	okay boolean;
	cname varchar;
	real_schema name;
	unknown_srid integer;
	new_srid integer := new_srid_in;
BEGIN

	-- Find, check or fix schema_name
	IF ( schema_name != '' ) THEN
		okay = false;
		FOR myrec IN SELECT nspname FROM pg_namespace WHERE text(nspname) = schema_name LOOP
			okay := true;
		END LOOP;
		IF ( okay <> true ) THEN
			RAISE EXCEPTION 'Invalid schema name';
		ELSE
			real_schema = schema_name;
		END IF;
	ELSE
		SELECT INTO real_schema current_schema()::text;
	END IF;
	-- Ensure that column_name is in geometry_columns
	okay = false;
	FOR myrec IN SELECT type, coord_dimension FROM geometry_columns WHERE f_table_schema = text(real_schema) and f_table_name = table_name and f_geometry_column = column_name LOOP
		okay := true;
	END LOOP;
	IF (NOT okay) THEN
		RAISE EXCEPTION 'column not found in geometry_columns table';
		RETURN false;
	END IF;
	-- Ensure that new_srid is valid
	IF ( new_srid > 0 ) THEN
		IF ( SELECT count(*) = 0 from spatial_ref_sys where srid = new_srid ) THEN
			RAISE EXCEPTION 'invalid SRID: % not found in spatial_ref_sys', new_srid;
			RETURN false;
		END IF;
	ELSE
		unknown_srid := ST_SRID('POINT EMPTY'::geometry);
		IF ( new_srid != unknown_srid ) THEN
			new_srid := unknown_srid;
			RAISE NOTICE 'SRID value % converted to the officially unknown SRID value %', new_srid_in, new_srid;
		END IF;
	END IF;
	IF postgis_constraint_srid(real_schema, table_name, column_name) IS NOT NULL THEN 
	-- srid was enforced with constraints before, keep it that way.
        -- Make up constraint name
        cname = 'enforce_srid_'  || column_name;
    
        -- Drop enforce_srid constraint
        EXECUTE 'ALTER TABLE ' || quote_ident(real_schema) ||
            '.' || quote_ident(table_name) ||
            ' DROP constraint ' || quote_ident(cname);
    
        -- Update geometries SRID
        EXECUTE 'UPDATE ' || quote_ident(real_schema) ||
            '.' || quote_ident(table_name) ||
            ' SET ' || quote_ident(column_name) ||
            ' = ST_SetSRID(' || quote_ident(column_name) ||
            ', ' || new_srid::text || ')';
            
        -- Reset enforce_srid constraint
        EXECUTE 'ALTER TABLE ' || quote_ident(real_schema) ||
            '.' || quote_ident(table_name) ||
            ' ADD constraint ' || quote_ident(cname) ||
            ' CHECK (st_srid(' || quote_ident(column_name) ||
            ') = ' || new_srid::text || ')';
    ELSE 
        -- We will use typmod to enforce if no srid constraints
        -- We are using postgis_type_name to lookup the new name 
        -- (in case Paul changes his mind and flips geometry_columns to return old upper case name) 
        EXECUTE 'ALTER TABLE ' || quote_ident(real_schema) || '.' || quote_ident(table_name) || 
        ' ALTER COLUMN ' || quote_ident(column_name) || ' TYPE  geometry(' || postgis_type_name(myrec.type, myrec.coord_dimension, true) || ', ' || new_srid::text || ') USING ST_SetSRID(' || quote_ident(column_name) || ',' || new_srid::text || ');' ;
    END IF;
	RETURN real_schema || '.' || table_name || '.' || column_name ||' SRID changed to ' || new_srid::text;
END;
$function$

CREATE OR REPLACE FUNCTION public.updategeometrysrid(character varying, character varying, integer)
 RETURNS text
 LANGUAGE plpgsql
 STRICT
AS $function$
DECLARE
	ret  text;
BEGIN
	SELECT UpdateGeometrySRID('','',$1,$2,$3) into ret;
	RETURN ret;
END;
$function$
CREATE OR REPLACE FUNCTION public.updategeometrysrid(character varying, character varying, character varying, integer)
 RETURNS text
 LANGUAGE plpgsql
 STRICT
AS $function$
DECLARE
	ret  text;
BEGIN
	SELECT UpdateGeometrySRID('',$1,$2,$3,$4) into ret;
	RETURN ret;
END;
$function$
CREATE OR REPLACE FUNCTION public.updategeometrysrid(catalogn_name character varying, schema_name character varying, table_name character varying, column_name character varying, new_srid_in integer)
 RETURNS text
 LANGUAGE plpgsql
 STRICT
AS $function$
DECLARE
	myrec RECORD;
	okay boolean;
	cname varchar;
	real_schema name;
	unknown_srid integer;
	new_srid integer := new_srid_in;
BEGIN

	-- Find, check or fix schema_name
	IF ( schema_name != '' ) THEN
		okay = false;
		FOR myrec IN SELECT nspname FROM pg_namespace WHERE text(nspname) = schema_name LOOP
			okay := true;
		END LOOP;
		IF ( okay <> true ) THEN
			RAISE EXCEPTION 'Invalid schema name';
		ELSE
			real_schema = schema_name;
		END IF;
	ELSE
		SELECT INTO real_schema current_schema()::text;
	END IF;
	-- Ensure that column_name is in geometry_columns
	okay = false;
	FOR myrec IN SELECT type, coord_dimension FROM geometry_columns WHERE f_table_schema = text(real_schema) and f_table_name = table_name and f_geometry_column = column_name LOOP
		okay := true;
	END LOOP;
	IF (NOT okay) THEN
		RAISE EXCEPTION 'column not found in geometry_columns table';
		RETURN false;
	END IF;
	-- Ensure that new_srid is valid
	IF ( new_srid > 0 ) THEN
		IF ( SELECT count(*) = 0 from spatial_ref_sys where srid = new_srid ) THEN
			RAISE EXCEPTION 'invalid SRID: % not found in spatial_ref_sys', new_srid;
			RETURN false;
		END IF;
	ELSE
		unknown_srid := ST_SRID('POINT EMPTY'::geometry);
		IF ( new_srid != unknown_srid ) THEN
			new_srid := unknown_srid;
			RAISE NOTICE 'SRID value % converted to the officially unknown SRID value %', new_srid_in, new_srid;
		END IF;
	END IF;
	IF postgis_constraint_srid(real_schema, table_name, column_name) IS NOT NULL THEN 
	-- srid was enforced with constraints before, keep it that way.
        -- Make up constraint name
        cname = 'enforce_srid_'  || column_name;
    
        -- Drop enforce_srid constraint
        EXECUTE 'ALTER TABLE ' || quote_ident(real_schema) ||
            '.' || quote_ident(table_name) ||
            ' DROP constraint ' || quote_ident(cname);
    
        -- Update geometries SRID
        EXECUTE 'UPDATE ' || quote_ident(real_schema) ||
            '.' || quote_ident(table_name) ||
            ' SET ' || quote_ident(column_name) ||
            ' = ST_SetSRID(' || quote_ident(column_name) ||
            ', ' || new_srid::text || ')';
            
        -- Reset enforce_srid constraint
        EXECUTE 'ALTER TABLE ' || quote_ident(real_schema) ||
            '.' || quote_ident(table_name) ||
            ' ADD constraint ' || quote_ident(cname) ||
            ' CHECK (st_srid(' || quote_ident(column_name) ||
            ') = ' || new_srid::text || ')';
    ELSE 
        -- We will use typmod to enforce if no srid constraints
        -- We are using postgis_type_name to lookup the new name 
        -- (in case Paul changes his mind and flips geometry_columns to return old upper case name) 
        EXECUTE 'ALTER TABLE ' || quote_ident(real_schema) || '.' || quote_ident(table_name) || 
        ' ALTER COLUMN ' || quote_ident(column_name) || ' TYPE  geometry(' || postgis_type_name(myrec.type, myrec.coord_dimension, true) || ', ' || new_srid::text || ') USING ST_SetSRID(' || quote_ident(column_name) || ',' || new_srid::text || ');' ;
    END IF;
	RETURN real_schema || '.' || table_name || '.' || column_name ||' SRID changed to ' || new_srid::text;
END;
$function$

CREATE OR REPLACE FUNCTION public.updaterastersrid(table_name name, column_name name, new_srid integer)
 RETURNS boolean
 LANGUAGE sql
 STRICT
AS $function$ SELECT _UpdateRasterSRID('', $1, $2, $3) $function$
CREATE OR REPLACE FUNCTION public.updaterastersrid(schema_name name, table_name name, column_name name, new_srid integer)
 RETURNS boolean
 LANGUAGE sql
 STRICT
AS $function$ SELECT _UpdateRasterSRID($1, $2, $3, $4) $function$

