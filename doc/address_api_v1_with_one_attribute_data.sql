--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: topology; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA topology;


--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: fuzzystrmatch; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS fuzzystrmatch WITH SCHEMA public;


--
-- Name: EXTENSION fuzzystrmatch; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION fuzzystrmatch IS 'determine similarities and distance between strings';


--
-- Name: ogr_fdw; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS ogr_fdw WITH SCHEMA public;


--
-- Name: EXTENSION ogr_fdw; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION ogr_fdw IS 'foreign-data wrapper for GIS data access';


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry, geography, and raster spatial types and functions';


--
-- Name: postgis_topology; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis_topology WITH SCHEMA topology;


--
-- Name: EXTENSION postgis_topology; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION postgis_topology IS 'PostGIS topology spatial types and functions';


--
-- Name: postgres_fdw; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgres_fdw WITH SCHEMA public;


--
-- Name: EXTENSION postgres_fdw; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION postgres_fdw IS 'foreign-data wrapper for remote PostgreSQL servers';


SET search_path = public, pg_catalog;

--
-- Name: address_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE address_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: address; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE address (
    id integer DEFAULT nextval('address_seq'::regclass) NOT NULL,
    single_line_address character varying(255),
    street_address character varying(255),
    street_number character varying(10),
    pre_direction character varying(120),
    street_name character varying(100),
    street_type character varying(24),
    post_direction character varying(10),
    internal character varying(10),
    city character varying(120),
    state_abbr character varying(2),
    zip character varying(5),
    zip4 character varying(4),
    longitude numeric(13,10),
    latitude numeric(13,10)
);


--
-- Name: COLUMN address.single_line_address; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN address.single_line_address IS '210 W 19th TERR, Kansas City, MO 64108';


--
-- Name: COLUMN address.street_address; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN address.street_address IS '210 W 19th TERR';


--
-- Name: address_attributes_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE address_attributes_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: address_attributes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE address_attributes (
    id integer DEFAULT nextval('address_attributes_seq'::regclass) NOT NULL,
    attribute_type_id integer,
    address_id integer,
    load_id integer,
    attribute_value character varying(255)
);


--
-- Name: attribute_types_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE attribute_types_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: attribute_types; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE attribute_types (
    id integer DEFAULT nextval('attribute_types_seq'::regclass) NOT NULL,
    name character varying(100),
    attribute_name character varying(100)
);


--
-- Name: TABLE attribute_types; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE attribute_types IS 'Change to Source_File';


--
-- Name: COLUMN attribute_types.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN attribute_types.id IS 'Auto Incroment';


--
-- Name: COLUMN attribute_types.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN attribute_types.name IS 'Name of area type.  Example Neighborhood, TIFF, School District, Council District';


--
-- Name: COLUMN attribute_types.attribute_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN attribute_types.attribute_name IS 'councel_district';


--
-- Name: datas_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE datas_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: datas; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE datas (
    id integer DEFAULT nextval('datas_seq'::regclass) NOT NULL,
    name character varying(255),
    source_name character varying(255),
    organization_id integer,
    source_file_id integer,
    spatial_field_name character varying(100),
    projection character varying(100)
);


--
-- Name: TABLE datas; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE datas IS 'This is to support source files with multiple datasets.
In GIS sources this would be layers, for an Excel spread sheet it would be tabs.
In the case of a csv, this is not realy needed.';


--
-- Name: COLUMN datas.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN datas.name IS 'Source name of the layer, tab, ...';


--
-- Name: COLUMN datas.source_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN datas.source_name IS 'Name of the layer if it is a GDB';


--
-- Name: loads_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE loads_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: loads; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE loads (
    id integer DEFAULT nextval('loads_seq'::regclass) NOT NULL,
    load_date date,
    url_used character varying(255),
    data_id integer
);


--
-- Name: organizations_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE organizations_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: organizations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE organizations (
    id integer DEFAULT nextval('organizations_seq'::regclass) NOT NULL,
    name character varying(100),
    url character varying(255)
);


--
-- Name: COLUMN organizations.url; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN organizations.url IS 'URL for organization, not their data repository';


--
-- Name: source_fields_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE source_fields_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: source_fields; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE source_fields (
    id integer DEFAULT nextval('source_fields_seq'::regclass) NOT NULL,
    data_id integer,
    name character varying(100),
    attribute_type_id integer,
    column_no integer
);


--
-- Name: COLUMN source_fields.column_no; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN source_fields.column_no IS 'Column number if used';


--
-- Name: source_file_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE source_file_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: source_file; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE source_file (
    id integer DEFAULT nextval('source_file_seq'::regclass) NOT NULL,
    name character varying(100),
    organization_id integer,
    source_file_type_id integer,
    url character varying(255)
);


--
-- Name: source_file_types_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE source_file_types_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: source_file_types; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE source_file_types (
    id integer DEFAULT nextval('source_file_types_seq'::regclass) NOT NULL,
    name character varying(100),
    source_type character varying(42),
    description text,
    created timestamp without time zone
);


--
-- Name: TABLE source_file_types; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE source_file_types IS 'JSON, XML, Manual Download';


--
-- Name: COLUMN source_file_types.source_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN source_file_types.source_type IS 'For internal lookup';


--
-- Name: spatial_obj_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE spatial_obj_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: spatial_obj; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE spatial_obj (
    id integer DEFAULT nextval('spatial_obj_seq'::regclass) NOT NULL,
    data_id integer,
    attribute_type_id integer,
    jurisdiction_id integer,
    effective_date date,
    name character varying(100),
    polygon json,
    load_id integer
);


--
-- Name: TABLE spatial_obj; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE spatial_obj IS 'Geographic areas that represent attributes.';


--
-- Name: COLUMN spatial_obj.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN spatial_obj.id IS 'Auto Incroment';


--
-- Name: COLUMN spatial_obj.effective_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN spatial_obj.effective_date IS 'Date that this data became effective.  Unless load data has an effedtive date, it will be the date loaded.  (This may have an issue)';


--
-- Name: COLUMN spatial_obj.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN spatial_obj.name IS 'Name of area.';


--
-- Name: COLUMN spatial_obj.polygon; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN spatial_obj.polygon IS 'The graphical representation of the area.';


--
-- Name: spatial_ref_sys_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE spatial_ref_sys_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Data for Name: address; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO address (id, single_line_address, street_address, street_number, pre_direction, street_name, street_type, post_direction, internal, city, state_abbr, zip, zip4, longitude, latitude) VALUES (1, '210 W 19th Terr KCMO`', NULL, '210', 'w', '19th', 'TER', NULL, NULL, 'Kansas City', 'MO', '64106', NULL, NULL, NULL);


--
-- Data for Name: address_attributes; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO address_attributes (id, attribute_type_id, address_id, load_id, attribute_value) VALUES (1, 1, 1, 1, 'River Market');


--
-- Name: address_attributes_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('address_attributes_seq', 1, true);


--
-- Name: address_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('address_seq', 1, true);


--
-- Data for Name: attribute_types; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO attribute_types (id, name, attribute_name) VALUES (1, 'councel_district_name', 'councel_sistrict_name');


--
-- Name: attribute_types_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('attribute_types_seq', 1, true);


--
-- Data for Name: datas; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO datas (id, name, source_name, organization_id, source_file_id, spatial_field_name, projection) VALUES (1, 'counceldistrict_2001', NULL, 1, 1, 'wkb_geometry', NULL);


--
-- Name: datas_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('datas_seq', 1, true);


--
-- Data for Name: loads; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO loads (id, load_date, url_used, data_id) VALUES (1, '2017-01-20', 'http://', 1);


--
-- Name: loads_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('loads_seq', 1, true);


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO organizations (id, name, url) VALUES (1, 'KCMO', 'kcmo.org');


--
-- Name: organizations_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('organizations_seq', 1, true);


--
-- Data for Name: source_fields; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO source_fields (id, data_id, name, attribute_type_id, column_no) VALUES (1, 1, 'district', 1, 3);


--
-- Name: source_fields_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('source_fields_seq', 1, true);


--
-- Data for Name: source_file; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO source_file (id, name, organization_id, source_file_type_id, url) VALUES (1, 'Other.GDB', 1, 1, 'http://maps.kcmo.org/apps/download/GisDataDownload/Other.gdb.zip');


--
-- Name: source_file_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('source_file_seq', 1, true);


--
-- Data for Name: source_file_types; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO source_file_types (id, name, source_type, description, created) VALUES (1, 'GDB', 'GDB', 'GDB', NULL);


--
-- Name: source_file_types_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('source_file_types_seq', 1, true);


--
-- Data for Name: spatial_obj; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Name: spatial_obj_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('spatial_obj_seq', 1, false);


--
-- Data for Name: spatial_ref_sys; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Name: spatial_ref_sys_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('spatial_ref_sys_seq', 1, false);


SET search_path = topology, pg_catalog;

--
-- Data for Name: topology; Type: TABLE DATA; Schema: topology; Owner: -
--



--
-- Data for Name: layer; Type: TABLE DATA; Schema: topology; Owner: -
--



SET search_path = public, pg_catalog;

--
-- Name: pk_address; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY address
    ADD CONSTRAINT pk_address PRIMARY KEY (id);


--
-- Name: pk_address_attributes; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY address_attributes
    ADD CONSTRAINT pk_address_attributes PRIMARY KEY (id);


--
-- Name: pk_area_types; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY attribute_types
    ADD CONSTRAINT pk_area_types PRIMARY KEY (id);


--
-- Name: pk_areas; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY spatial_obj
    ADD CONSTRAINT pk_areas PRIMARY KEY (id);


--
-- Name: pk_data; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY datas
    ADD CONSTRAINT pk_data PRIMARY KEY (id);


--
-- Name: pk_loads; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY loads
    ADD CONSTRAINT pk_loads PRIMARY KEY (id);


--
-- Name: pk_organizations; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY organizations
    ADD CONSTRAINT pk_organizations PRIMARY KEY (id);


--
-- Name: pk_source_fields; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY source_fields
    ADD CONSTRAINT pk_source_fields PRIMARY KEY (id);


--
-- Name: pk_source_file; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY source_file
    ADD CONSTRAINT pk_source_file PRIMARY KEY (id);


--
-- Name: pk_source_file_types; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY source_file_types
    ADD CONSTRAINT pk_source_file_types PRIMARY KEY (id);


--
-- Name: idx_address_attributes; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_address_attributes ON address_attributes USING btree (address_id);


--
-- Name: idx_address_attributes_0; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_address_attributes_0 ON address_attributes USING btree (load_id);


--
-- Name: idx_address_attributes_types; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_address_attributes_types ON address_attributes USING btree (attribute_type_id);


--
-- Name: idx_areas; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_areas ON spatial_obj USING btree (attribute_type_id);


--
-- Name: idx_areas_0; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_areas_0 ON spatial_obj USING btree (jurisdiction_id);


--
-- Name: idx_datas_0; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_datas_0 ON datas USING btree (organization_id);


--
-- Name: idx_loads; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_loads ON loads USING btree (data_id);


--
-- Name: idx_source_fields; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_source_fields ON source_fields USING btree (data_id);


--
-- Name: idx_source_fields_0; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_source_fields_0 ON source_fields USING btree (attribute_type_id);


--
-- Name: idx_source_file_org; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_source_file_org ON source_file USING btree (organization_id);


--
-- Name: idx_source_file_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_source_file_type ON source_file USING btree (source_file_type_id);


--
-- Name: idx_sources; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_sources ON datas USING btree (source_file_id);


--
-- Name: idx_spatial_obj; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_spatial_obj ON spatial_obj USING btree (load_id);


--
-- Name: idx_spatial_obj_0; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_spatial_obj_0 ON spatial_obj USING btree (data_id);


--
-- Name: fk_address_attributes; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY address_attributes
    ADD CONSTRAINT fk_address_attributes FOREIGN KEY (attribute_type_id) REFERENCES attribute_types(id);


--
-- Name: fk_address_attributes_address; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY address_attributes
    ADD CONSTRAINT fk_address_attributes_address FOREIGN KEY (address_id) REFERENCES address(id);


--
-- Name: fk_address_attributes_loads; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY address_attributes
    ADD CONSTRAINT fk_address_attributes_loads FOREIGN KEY (load_id) REFERENCES loads(id);


--
-- Name: fk_data_source_file; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY datas
    ADD CONSTRAINT fk_data_source_file FOREIGN KEY (source_file_id) REFERENCES source_file(id);


--
-- Name: fk_loads_data; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY loads
    ADD CONSTRAINT fk_loads_data FOREIGN KEY (data_id) REFERENCES datas(id);


--
-- Name: fk_source_fields; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY source_fields
    ADD CONSTRAINT fk_source_fields FOREIGN KEY (attribute_type_id) REFERENCES attribute_types(id);


--
-- Name: fk_source_fields_data; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY source_fields
    ADD CONSTRAINT fk_source_fields_data FOREIGN KEY (data_id) REFERENCES datas(id);


--
-- Name: fk_source_file; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY source_file
    ADD CONSTRAINT fk_source_file FOREIGN KEY (source_file_type_id) REFERENCES source_file_types(id);


--
-- Name: fk_source_file_organizations; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY source_file
    ADD CONSTRAINT fk_source_file_organizations FOREIGN KEY (organization_id) REFERENCES organizations(id);


--
-- Name: fk_spatial_obj_attribute_types; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY spatial_obj
    ADD CONSTRAINT fk_spatial_obj_attribute_types FOREIGN KEY (attribute_type_id) REFERENCES attribute_types(id);


--
-- Name: fk_spatial_obj_data; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY spatial_obj
    ADD CONSTRAINT fk_spatial_obj_data FOREIGN KEY (data_id) REFERENCES datas(id);


--
-- Name: fk_spatial_obj_loads; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY spatial_obj
    ADD CONSTRAINT fk_spatial_obj_loads FOREIGN KEY (load_id) REFERENCES loads(id);


--
-- Name: public; Type: ACL; Schema: -; Owner: -
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

