
\c address_api
CREATE EXTENSION postgres_fdw;
CREATE EXTENSION file_fdw;

CREATE TABLE other_attributes (
                                       id                   integer  NOT NULL,
                                       approximate_building_area_in_feet        NUMERIC(10,2)  ,
                                       CONSTRAINT idx_other_attributes UNIQUE ( id )
);

COMMENT ON COLUMN other_attributes.id IS 'KIVA pin for KCMO';
COMMENT ON COLUMN other_attributes.approximate_building_area_in_feet IS 'Combined building area from Microsoft US Building Outlines';

ALTER TABLE public.other_attributes OWNER TO c4kc;



