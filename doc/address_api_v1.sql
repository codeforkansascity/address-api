CREATE SCHEMA "public";

CREATE SEQUENCE  address_seq START WITH 1;
CREATE SEQUENCE  attribute_types_seq START WITH 1;
CREATE SEQUENCE  organizations_seq START WITH 1;
CREATE SEQUENCE  source_file_types_seq START WITH 1;
CREATE SEQUENCE  spatial_ref_sys_seq START WITH 1;
CREATE SEQUENCE  source_file_seq START WITH 1;
CREATE SEQUENCE  datas_seq START WITH 1;
CREATE SEQUENCE  loads_seq START WITH 1;
CREATE SEQUENCE  source_fields_seq START WITH 1;
CREATE SEQUENCE  spatial_obj_seq START WITH 1;
CREATE SEQUENCE  address_attributes_seq START WITH 1;

CREATE TABLE address ( 
	id                   integer DEFAULT nextval('address_seq') NOT NULL,
	single_line_address  varchar(255)  ,
	street_address       varchar(255)  ,
	street_number        varchar(10)  ,
	pre_direction        varchar(120)  ,
	street_name          varchar(100)  ,
	street_type          varchar(24)  ,
	post_direction       varchar(10)  ,
	internal             varchar(10)  ,
	city                 varchar(120)  ,
	state_abbr           varchar(2)  ,
	zip                  varchar(5)  ,
	zip4                 varchar(4)  ,
	longitude            numeric(13,10)  ,
	latitude             numeric(13,10)  ,
	CONSTRAINT pk_address PRIMARY KEY ( id )
 );

COMMENT ON COLUMN address.single_line_address IS '210 W 19th TERR, Kansas City, MO 64108';

COMMENT ON COLUMN address.street_address IS '210 W 19th TERR';

CREATE TABLE attribute_types ( 
	id                   integer DEFAULT nextval('attribute_types_seq') NOT NULL,
	name                 varchar(100)  ,
	attribute_name       varchar(100)  ,
	CONSTRAINT pk_area_types PRIMARY KEY ( id )
 );

COMMENT ON TABLE attribute_types IS 'Change to Source_File';

COMMENT ON COLUMN attribute_types.id IS 'Auto Incroment';

COMMENT ON COLUMN attribute_types.name IS 'Name of area type.  Example Neighborhood, TIFF, School District, Council District';

COMMENT ON COLUMN attribute_types.attribute_name IS 'councel_district';

CREATE TABLE organizations ( 
	id                   integer DEFAULT nextval('organizations_seq') NOT NULL,
	name                 varchar(100)  ,
	url                  varchar(255)  ,
	CONSTRAINT pk_organizations PRIMARY KEY ( id )
 );

COMMENT ON COLUMN organizations.url IS 'URL for organization, not their data repository';

CREATE TABLE source_file_types ( 
	id                   integer DEFAULT nextval('source_file_types_seq') NOT NULL,
	name                 varchar(100)  ,
	source_type          varchar(42)  ,
	description          text  ,
	created              timestamp  ,
	CONSTRAINT pk_source_file_types PRIMARY KEY ( id )
 );

COMMENT ON TABLE source_file_types IS 'JSON, XML, Manual Download';

COMMENT ON COLUMN source_file_types.source_type IS 'For internal lookup';

CREATE TABLE source_file ( 
	id                   integer DEFAULT nextval('source_file_seq') NOT NULL,
	name                 varchar(100)  ,
	organization_id      integer  ,
	source_file_type_id  integer  ,
	url                  varchar(255)  ,
	CONSTRAINT pk_source_file PRIMARY KEY ( id ),
	CONSTRAINT fk_source_file_organizations FOREIGN KEY ( organization_id ) REFERENCES organizations( id )    ,
	CONSTRAINT fk_source_file FOREIGN KEY ( source_file_type_id ) REFERENCES source_file_types( id )    
 );

CREATE INDEX idx_source_file_org ON source_file ( organization_id );

CREATE INDEX idx_source_file_type ON source_file ( source_file_type_id );

CREATE TABLE datas ( 
	id                   integer DEFAULT nextval('datas_seq') NOT NULL,
	name                 varchar(255)  ,
	source_name          varchar(255)  ,
	organization_id      integer  ,
	source_file_id       integer  ,
	spatial_field_name   varchar(100)  ,
	projection           varchar(100)  ,
	CONSTRAINT pk_data PRIMARY KEY ( id ),
	CONSTRAINT fk_data_source_file FOREIGN KEY ( source_file_id ) REFERENCES source_file( id )    
 );


CREATE INDEX idx_datas_0 ON datas ( organization_id );

CREATE INDEX idx_sources ON datas ( source_file_id );

COMMENT ON TABLE datas IS 'This is to support source files with multiple datasets.
In GIS sources this would be layers, for an Excel spread sheet it would be tabs.
In the case of a csv, this is not realy needed.';

COMMENT ON COLUMN datas.name IS 'Source name of the layer, tab, ...';

COMMENT ON COLUMN datas.source_name IS 'Name of the layer if it is a GDB';

CREATE TABLE loads ( 
	id                   integer DEFAULT nextval('loads_seq') NOT NULL,
	load_date            date  ,
	url_used             varchar(255)  ,
	data_id              integer  ,
	CONSTRAINT pk_loads PRIMARY KEY ( id ),
	CONSTRAINT fk_loads_data FOREIGN KEY ( data_id ) REFERENCES datas( id )    
 );

CREATE INDEX idx_loads ON loads ( data_id );

CREATE TABLE source_fields ( 
	id                   integer DEFAULT nextval('source_fields_seq') NOT NULL,
	data_id              integer  ,
	name                 varchar(100)  ,
	attribute_type_id    integer  ,
	column_no            integer  ,
	CONSTRAINT pk_source_fields PRIMARY KEY ( id ),
	CONSTRAINT fk_source_fields FOREIGN KEY ( attribute_type_id ) REFERENCES attribute_types( id )    ,
	CONSTRAINT fk_source_fields_data FOREIGN KEY ( data_id ) REFERENCES datas( id )    
 );

CREATE INDEX idx_source_fields ON source_fields ( data_id );

CREATE INDEX idx_source_fields_0 ON source_fields ( attribute_type_id );

COMMENT ON COLUMN source_fields.column_no IS 'Column number if used';

CREATE TABLE spatial_obj ( 
	id                   integer DEFAULT nextval('spatial_obj_seq') NOT NULL,
	data_id              integer  ,
	attribute_type_id    integer  ,
	jurisdiction_id      integer  ,
	effective_date       date  ,
	name                 varchar(100)  ,
	polygon              json  ,
	load_id              integer  ,
	CONSTRAINT pk_areas PRIMARY KEY ( id ),
	CONSTRAINT fk_spatial_obj_attribute_types FOREIGN KEY ( attribute_type_id ) REFERENCES attribute_types( id )    ,
	CONSTRAINT fk_spatial_obj_data FOREIGN KEY ( data_id ) REFERENCES datas( id )    ,
	CONSTRAINT fk_spatial_obj_loads FOREIGN KEY ( load_id ) REFERENCES loads( id )    
 );

CREATE INDEX idx_areas ON spatial_obj ( attribute_type_id );

CREATE INDEX idx_areas_0 ON spatial_obj ( jurisdiction_id );

CREATE INDEX idx_spatial_obj ON spatial_obj ( load_id );

CREATE INDEX idx_spatial_obj_0 ON spatial_obj ( data_id );

COMMENT ON TABLE spatial_obj IS 'Geographic areas that represent attributes.';

COMMENT ON COLUMN spatial_obj.id IS 'Auto Incroment';

COMMENT ON COLUMN spatial_obj.effective_date IS 'Date that this data became effective.  Unless load data has an effedtive date, it will be the date loaded.  (This may have an issue)';

COMMENT ON COLUMN spatial_obj.name IS 'Name of area.';

COMMENT ON COLUMN spatial_obj.polygon IS 'The graphical representation of the area.';

CREATE TABLE address_attributes ( 
	id                   integer DEFAULT nextval('address_attributes_seq') NOT NULL,
	attribute_type_id    integer  ,
	address_id           integer  ,
	load_id              integer  ,
	attribute_value      varchar(255)  ,
	CONSTRAINT pk_address_attributes PRIMARY KEY ( id ),
	CONSTRAINT fk_address_attributes_address FOREIGN KEY ( address_id ) REFERENCES address( id )    ,
	CONSTRAINT fk_address_attributes FOREIGN KEY ( attribute_type_id ) REFERENCES attribute_types( id )    ,
	CONSTRAINT fk_address_attributes_loads FOREIGN KEY ( load_id ) REFERENCES loads( id )    
 );

CREATE INDEX idx_address_attributes ON address_attributes ( address_id );

CREATE INDEX idx_address_attributes_0 ON address_attributes ( load_id );

CREATE INDEX idx_address_attributes_types ON address_attributes ( attribute_type_id );

