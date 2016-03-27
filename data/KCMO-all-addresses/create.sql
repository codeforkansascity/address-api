SET search_path = public, pg_catalog;

--
-- Name: hud_addresses_id_seq_02; Type: SEQUENCE; Schema: public; Owner: c4kc
--

DROP SEQUENCE IF EXISTS hud_addresses_id_seq_02;
CREATE SEQUENCE hud_addresses_id_seq_02
    START WITH 2001
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.hud_addresses_id_seq_02 OWNER TO c4kc;

SET default_tablespace = '';

SET default_with_oids = false;

DROP TABLE IF EXISTS hud_addresses ;
CREATE TABLE hud_addresses (
      id integer DEFAULT nextval('hud_addresses_id_seq_02'::regclass) NOT NULL,
      address_api_id integer,
      kiva_pin integer,
      city_apn character varying(20) DEFAULT NULL::character varying,
      addr character varying(20) DEFAULT NULL::character varying,
      fraction character varying(20) DEFAULT NULL::character varying,
      prefix character varying(20) DEFAULT NULL::character varying,
      street character varying(50) DEFAULT NULL::character varying,
      street_type character varying(10) DEFAULT NULL::character varying,
      suite character varying(20) DEFAULT NULL::character varying,
      city character varying(20) DEFAULT 'Kansas City',
      state character varying(20) DEFAULT 'MO',
      zip character varying(20) DEFAULT NULL::character varying,
    added timestamp without time zone DEFAULT now(),
    changed timestamp without time zone DEFAULT now()
);

ALTER TABLE public.hud_addresses OWNER TO c4kc;

