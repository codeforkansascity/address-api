\c address_api

DROP TABLE IF EXISTS land_use_codes ;
DROP SEQUENCE IF EXISTS land_use_codes_id_seq;



CREATE SEQUENCE land_use_codes_id_seq
    START WITH 2001
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.land_use_codes_id_seq OWNER TO c4kc;

SET default_tablespace = '';

SET default_with_oids = false;

CREATE TABLE land_use_codes (
      id integer DEFAULT nextval('land_use_codes_id_seq'::regclass) NOT NULL,
      land_use_code character varying(10) DEFAULT NULL::character varying,
      land_use_description character varying(80) DEFAULT NULL::character varying,
      active integer DEFAULT 1,
      added timestamp without time zone DEFAULT now(),
      changed timestamp without time zone DEFAULT now()
);  

ALTER TABLE public.land_use_codes OWNER TO c4kc;
