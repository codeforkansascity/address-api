SET search_path = public, pg_catalog;

--
-- Name: hud_addresses_id_seq_02; Type: SEQUENCE; Schema: public; Owner: c4kc
--

DROP TABLE IF EXISTS hud_addresses ;
DROP SEQUENCE IF EXISTS hud_addresses_id_seq_02;


DROP TABLE IF EXISTS kcmo_all_addresses ;
DROP SEQUENCE IF EXISTS kcmo_all_addresses_id_seq;

DROP TABLE IF EXISTS tmp_kcmo_all_addresses ;
DROP SEQUENCE IF EXISTS tmp_kcmo_all_addresses_id_seq;



CREATE SEQUENCE tmp_kcmo_all_addresses_id_seq
    START WITH 2001
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tmp_kcmo_all_addresses_id_seq OWNER TO c4kc;

SET default_tablespace = '';

SET default_with_oids = false;

CREATE TABLE tmp_kcmo_all_addresses (
      id integer DEFAULT nextval('tmp_kcmo_all_addresses_id_seq'::regclass) NOT NULL,
      address_api_id integer,
      kiva_pin integer,
      city_apn character varying(30) DEFAULT NULL::character varying,
      addr character varying(20) DEFAULT NULL::character varying,
      fraction character varying(20) DEFAULT NULL::character varying,
      prefix character varying(20) DEFAULT NULL::character varying,
      street character varying(50) DEFAULT NULL::character varying,
      street_type character varying(10) DEFAULT NULL::character varying,
      suite character varying(20) DEFAULT NULL::character varying,
      city character varying(20) DEFAULT 'KANSAS CITY',
      state character varying(20) DEFAULT 'MO',
      zip character varying(20) DEFAULT NULL::character varying,
    added timestamp without time zone DEFAULT now(),
    changed timestamp without time zone DEFAULT now()
);

ALTER TABLE public.tmp_kcmo_all_addresses OWNER TO c4kc;

