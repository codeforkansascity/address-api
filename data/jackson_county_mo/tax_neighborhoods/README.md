This file was found at  Tax Neighborhoods on http://opendata.arcgis.com/datasets/365f8fc86fb744c9a300abc4fefd3daa_0
The County's endpoint is
http://arcgisweb.jacksongov.org/arcgis/rest/services/AssessmentInformation/TaxNeighborhoods/MapServer/0/query



````
OBJECTID ( type: esriFieldTypeOID , alias: OBJECTID )
ComplexName ( type: esriFieldTypeString , alias: Complex Name , length: 100 )
CID ( type: esriFieldTypeString , alias: Cid , length: 100 )
Shape_STArea__ ( type: esriFieldTypeDouble , alias: Shape_STArea__ )
Shape_STLength__ ( type: esriFieldTypeDouble , alias: Shape_STLength__ )
parcel_number ( type: esriFieldTypeString , alias: parcel_number , length: 30 )
eff_from_date ( type: esriFieldTypeDate , alias: eff_from_date , length: 36 )
eff_to_date ( type: esriFieldTypeDate , alias: eff_to_date , length: 36 )
owner ( type: esriFieldTypeString , alias: owner , length: 40 )
owneraddress ( type: esriFieldTypeString , alias: owneraddress , length: 50 )
ownercity ( type: esriFieldTypeString , alias: ownercity , length: 40 )
ownerstate ( type: esriFieldTypeString , alias: ownerstate , length: 10 )
ownerzipcode ( type: esriFieldTypeString , alias: ownerzipcode , length: 10 )
MtgCo ( type: esriFieldTypeString , alias: MtgCo , length: 40 )
MtgCoaddress ( type: esriFieldTypeString , alias: MtgCoaddress , length: 50 )
MtgCocity ( type: esriFieldTypeString , alias: MtgCocity , length: 40 )
MtgCostate ( type: esriFieldTypeString , alias: MtgCostate , length: 10 )
MtgCozipcode ( type: esriFieldTypeString , alias: MtgCozipcode , length: 10 )
legaldesc ( type: esriFieldTypeString , alias: legaldesc , length: 200 )
exempt ( type: esriFieldTypeString , alias: exempt , length: 5 )
neighborhoodcode ( type: esriFieldTypeString , alias: neighborhoodcode , length: 5 )
pcacode ( type: esriFieldTypeString , alias: pcacode , length: 10 )
landusecode ( type: esriFieldTypeString , alias: landusecode , length: 5 )
year_built ( type: esriFieldTypeInteger , alias: year_built )
tot_sqf_l_area ( type: esriFieldTypeInteger , alias: tot_sqf_l_area )
SitusAddress ( type: esriFieldTypeString , alias: SitusAddress , length: 50 )
SitusCity ( type: esriFieldTypeString , alias: SitusCity , length: 40 )
SitusState ( type: esriFieldTypeString , alias: SitusState , length: 10 )
SitusZipCode ( type: esriFieldTypeString , alias: SitusZipCode , length: 10 )
TCACode ( type: esriFieldTypeString , alias: TCACode , length: 10 )
PropertyReport ( type: esriFieldTypeString , alias: Property Report , length: 255 )
PropertyPicture ( type: esriFieldTypeString , alias: Property Picture , length: 255 )
PropertyArea ( type: esriFieldTypeDouble , alias: Property Area )
AssessedImprovement ( type: esriFieldTypeDouble , alias: Assessed Improvement )
AssessedLand ( type: esriFieldTypeDouble , alias: Assessed Land )
AssessedValue ( type: esriFieldTypeDouble , alias: Assessed Value )
MarketValue ( type: esriFieldTypeDouble , alias: Market Value )
TaxableValue ( type: esriFieldTypeDouble , alias: Taxable Value )
TaxYear ( type: esriFieldTypeSmallInteger , alias: Tax Year )
Shape ( type: esriFieldTypeGeometry , alias: Shape )
Shape.STArea() ( type: esriFieldTypeDouble , alias: Shape.STArea() )
Shape.STLength() ( type: esriFieldTypeDouble , alias: Shape.STLength() )
Shape_STArea_1 ( type: esriFieldTypeDouble , alias: Shape_STArea_1 )
Shape_STLength_1 ( type: esriFieldTypeDouble , alias: Shape_STLength_1 )
Name ( type: esriFieldTypeString , alias: Name , length: 50 )
Type ( type: esriFieldTypeInteger , alias: Type , Coded Values: [3: PLSS Quarter Section] , [4: Special Survey] , [5: Simultaneous Conveyance] , ...8 more... )
StatedArea ( type: esriFieldTypeString , alias: Stated Area , length: 50 )
ConveyanceType ( type: esriFieldTypeString , alias: Sub or Condo Type , length: 50 , Coded Values: [Subdivision: Subdivision] , [Sequence Conveyance: Sequence Conveyance] , [Assessor Plat: Assessor Plat] , ...16 more... )
ConveyanceDesignator ( type: esriFieldTypeString , alias: Sub or Condo Number , length: 10 )
SimConDivType ( type: esriFieldTypeString , alias: Lot or Unit Type , length: 50 , Coded Values: [Lot: Lot] , [Park: Park] , [Outlot: Outlot] , ...11 more... )
FloorDesignator ( type: esriFieldTypeSmallInteger , alias: Floor Number , Range: [-10, 100] )
BookNumber ( type: esriFieldTypeSmallInteger , alias: BookNumber )
PageNumber ( type: esriFieldTypeSmallInteger , alias: PageNumber )
CommonArea ( type: esriFieldTypeInteger , alias: CommonArea , Coded Values: [0: No] , [1: Yes] )
ZDesignator ( type: esriFieldTypeDouble , alias: ZDesignator )
FloorNameDesignator ( type: esriFieldTypeString , alias: FloorName , length: 50 )
TIFProject ( type: esriFieldTypeString , alias: TIFProject , length: 100 )
TIFDistrict ( type: esriFieldTypeString , alias: TIFDistrict , length: 100 )
DocumentNumber ( type: esriFieldTypeString , alias: DocumentNumber , length: 20 )
ExtractDate ( type: esriFieldTypeDate , alias: Extract Date , length: 36 )
````

- [X] Get shape file 
    
- [X] Load shape file into temporary table `address_spatial.jackson_cnt_mo_1_tmp`

    ````
    shp2pgsql -g geom \
     -I /var/wwwsites/dev-api.codeforkc.org/data/jackson_county_mo/set-1/Parcels_and_Addresses_::_Jackson_County_MO.shp \
     address_spatial.jackson_cnt_mo_1_tmp | psql  -d code4kc
    ````



    this results in 307,252 rows
    ````
                                       Table "address_spatial.jackson_cnt_mo_1_tmp"
   Column   |          Type          |                                     Modifiers                                      
------------+------------------------+------------------------------------------------------------------------------------
 gid        | integer                | not null default nextval('address_spatial.jackson_cnt_mo_1_tmp_gid_seq'::regclass)
 name       | character varying(80)  | 
 situsaddre | character varying(80)  | 
 situscity  | character varying(80)  | 
 situsstate | character varying(80)  | 
 situszipco | character varying(80)  | 
 parcel_num | character varying(80)  | 
 owner      | character varying(80)  | 
 owneraddre | character varying(80)  | 
 ownercity  | character varying(80)  | 
 ownerstate | character varying(80)  | 
 ownerzipco | character varying(80)  | 
 statedarea | character varying(80)  | 
 tot_sqf_l_ | numeric(10,0)          | 
 year_built | numeric(10,0)          | 
 propertyar | numeric                | 
 propertypi | character varying(101) | 
 propertyre | character varying(92)  | 
 marketvalu | numeric(10,0)          | 
 assessedva | numeric(10,0)          | 
 assessedim | character varying(80)  | 
 assessedla | character varying(80)  | 
 taxableval | numeric(10,0)          | 
 mtgco      | character varying(80)  | 
 mtgcoaddre | character varying(80)  | 
 mtgcocity  | character varying(80)  | 
 mtgcostate | character varying(80)  | 
 mtgcozipco | character varying(80)  | 
 commonarea | character varying(80)  | 
 floordesig | character varying(80)  | 
 floornamed | character varying(80)  | 
 exempt     | character varying(80)  | 
 complexnam | character varying(100) | 
 cid        | character varying(80)  | 
 tifdistric | character varying(80)  | 
 tifproject | character varying(80)  | 
 neighborho | character varying(80)  | 
 pcacode    | character varying(80)  | 
 landusecod | character varying(80)  | 
 tcacode    | character varying(80)  | 
 documentnu | character varying(80)  | 
 booknumber | character varying(80)  | 
 conveyance | character varying(80)  | 
 conveyan_1 | character varying(80)  | 
 eff_from_d | character varying(80)  | 
 eff_to_dat | character varying(80)  | 
 extractdat | character varying(80)  | 
 legaldesc  | character varying(200) | 
 objectid   | numeric(10,0)          | 
 pagenumber | character varying(80)  | 
 shapestare | numeric                | 
 shapestlen | numeric                | 
 shape_star | numeric                | 
 shape_st_1 | numeric                | 
 shape_stle | numeric                | 
 shape_st_2 | numeric                | 
 simcondivt | character varying(80)  | 
 taxyear    | numeric(10,0)          | 
 type       | numeric(10,0)          | 
 zdesignato | character varying(80)  | 
 geom       | geometry(MultiPolygon) | 
Indexes:
    "jackson_cnt_mo_1_tmp_pkey" PRIMARY KEY, btree (gid)
    "jackson_cnt_mo_1_tmp_geom_gist" gist (geom)
    ````

    ````
select gid, affgeoid, cbsafp, geoid, name from address_spatial.census_metro_area_tmp limit 10;
-[ RECORD 1 ]-----------------------------------------------------------------------------------------
gid        | 47260
name       | 29-520-25-08-00-0-00-000
situsaddre | 210 W 19TH TER
situscity  | KANSAS CITY
situsstate | MO
situszipco | 64108
parcel_num | 29-520-25-08-00-0-00-000
owner      | KC-STUDIO LLC
owneraddre | 1614 15TH STREET STE 300
ownercity  | DENVER
ownerstate | CO
ownerzipco | 80202
statedarea | 0.2870 a
tot_sqf_l_ | 0
year_built | 0
propertyar | 12500.000000000000000
propertypi | http://maps.jacksongov.org/AscendPics/Pictures/29-520/29-520-25-08-00-0-00-000_AA.jpg
propertyre | http://maps.jacksongov.org/PropertyReport/PropertyReport.cfm?pid=29-520-25-08-00-0-00-000
marketvalu | 1855000
assessedva | 593600
assessedim | 513600
assessedla | 80000
taxableval | 593600
mtgco      | 
mtgcoaddre | 
mtgcocity  | 
mtgcostate | 
mtgcozipco | 
commonarea | 
floordesig | 
floornamed | 
exempt     | N
complexnam | 
cid        | Crossroads CID
tifdistric | 
tifproject | 
neighborho | 9937
pcacode    | 3010
landusecod | 2240
tcacode    | 001
documentnu | 
booknumber | 
conveyance | 
conveyan_1 | 
eff_from_d | 1980-01-01T00:00:00.000Z
eff_to_dat | 1753-01-01T00:00:00.000Z
extractdat | 2015-09-17T13:30:42.000Z
legaldesc  | 
objectid   | 41260
pagenumber | 
shapestare | 12500.002876000000470
shapestlen | 450.000073999999984
shape_star | 12500.002876000000470
shape_st_1 | 12500.002876000000470
shape_stle | 450.000073999999984
shape_st_2 | 450.000073999999984
simcondivt | 
taxyear    | 2015
type       | 7
zdesignato | 
    ````
   Looked at the number of cities in the file.

    ````
select situscity, count(*) from address_spatial.jackson_cnt_mo_1_tmp group by situscity;
   situscity    | count  
----------------+--------
                |    468
 UNINCORPORATED |  12488
 LAKE TAPAWINGO |    503
 LEVASY         |     76
 SUGAR CREEK    |   1957
 UNKNOWN CITY   |   5941
 LONE JACK      |    925
 OAK GROVE      |   3091
 BLUE SPRINGS   |  20653
 UNITY VILLAGE  |     37
 KANSAS CITY    | 142513
 GRAIN VALLEY   |   5278
 LAKE LOTAWANA  |   2199
 GRANDVIEW      |   9123
 RIVER BEND     |     77
 UNKNOWN        |   1759
 SIBLEY         |    211
 GREENWOOD      |   2079
 RAYTOWN        |  12584
 BLANK          |     29
 INDEPENDENCE   |  49598
 LEES SUMMIT    |  34501
 BUCKNER        |   1160
 PLEASANT HILL  |      2
(24 rows)
````

- [X] Create permanent table `address_spatial.census_metro_areas`

    ````
--
-- Name: address_spatial.jackson_county_mo_tax_neighborhoods; Type: TABLE; Schema: address_spatial; Owner: postgres; Tablespace:
--

CREATE TABLE address_spatial.jackson_county_mo_tax_neighborhoods (

    gid integer NOT NULL,
    name character varying(50),
    situs_address character varying(80),
    situs_city character varying(80),
    situs_state character varying(80),
    situs_zip character varying(80),
    parcel_number character varying(30),
    owner character varying(40),
    owner_address character varying(50),
    owner_city character varying(40),
    owner_state character varying(10),
    owner_zip character varying(10),
    stated_area character varying(50),
    tot_sqf_l_area numeric(10,0),
    year_built numeric(10,0),
    property_area numeric,
    property_picture character varying(255),
    property_report character varying(255),
    market_value numeric(10,0),
    assessed_value numeric(10,0),
    assessed_improvement character varying(10),
    assessed_land character varying(10),
    taxable_value numeric(10,0),
    mtg_co character varying(40),
    mtg_co_address character varying(50),
    mtg_co_city character varying(40),
    mtg_co_state character varying(10),
    mtg_co_zip character varying(10),
    common_area character varying(1),
    floor_designator character varying(80),
    floor_name_designator character varying(25),
    exempt character varying(5),
    complex_name character varying(100),
    cid character varying(100),
    tif_district character varying(40),
    tif_project character varying(60),
    neighborhood_code character varying(5),
    pca_code character varying(10),
    land_use_code character varying(5),
    tca_code character varying(10),
    document_number character varying(15),
    book_number character varying(8),
    conveyance_area character varying(12),
    conveyance_designator character varying(20),
    eff_from_date character varying(80),
    eff_to_date character varying(80),
    extract_date character varying(80),
    legal_description character varying(200),
    object_id numeric(10,0),
    page_number character varying(80),
    shape_st_area numeric,
    shape_st_lenght numeric,
    shape_st_area_1 numeric,
    shape_st_length_1 numeric,
    shape_st_legnth_2 numeric,
    shape_st_area_2 numeric,
    sim_con_div_type character varying(10),
    tax_year numeric(10,0),
    type numeric(10,0),
    z_designator character varying(20),
geom public.geometry(MultiPolygon)

);


ALTER TABLE address_spatial.jackson_county_mo_tax_neighborhoods OWNER TO postgres;

--
-- Name: jackson_county_mo_tax_neighborhoods_gid_seq; Type: SEQUENCE; Schema: address_spatial; Owner: postgres
--

CREATE SEQUENCE address_spatial.jackson_county_mo_tax_neighborhoods_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE address_spatial.jackson_county_mo_tax_neighborhoods_gid_seq OWNER TO postgres;

--
-- Name: address_spatial.jackson_county_mo_tax_neighborhoods_gid_seq; Type: SEQUENCE OWNED BY; Schema: address_spatial; Owner: postgres
--

ALTER SEQUENCE address_spatial.jackson_county_mo_tax_neighborhoods_gid_seq OWNED BY address_spatial.jackson_county_mo_tax_neighborhoods.gid;
    ````

- [X] Copy tmp table into permanent spatial table

    ````
    INSERT INTO address_spatial.jackson_county_mo_tax_neighborhoods 
       (gid, name, situs_address, situs_city, situs_state, situs_zip, parcel_number, owner, owner_address, owner_city,
owner_state, owner_zip, stated_area, tot_sqf_l_area, year_built, property_area, property_picture, property_report,
market_value, assessed_value, assessed_improvement, assessed_land, taxable_value, mtg_co, mtg_co_address, mtg_co_city,
mtg_co_state, mtg_co_zip, common_area, floor_designator, floor_name_designator, exempt, complex_name, cid,
tif_district, tif_project, neighborhood_code, pca_code, land_use_code, tca_code, document_number, book_number,
conveyance_area, conveyance_designator, eff_from_date, eff_to_date, extract_date, legal_description, object_id, page_number,
shape_st_area, shape_st_lenght, shape_st_area_1, shape_st_length_1, shape_st_legnth_2, shape_st_area_2, sim_con_div_type, tax_year,
type, z_designator, geom) 
            SELECT gid, name, situsaddre, situscity, situsstate, situszipco, parcel_num, owner, owneraddre, ownercity,
ownerstate, ownerzipco, statedarea, tot_sqf_l_, year_built, propertyar, propertypi, propertyre,
marketvalu, assessedva, assessedim, assessedla, taxableval, mtgco, mtgcoaddre, mtgcocity, mtgcostate,
mtgcozipco, commonarea, floordesig, floornamed, exempt, complexnam, cid, tifdistric, tifproject,
neighborho, pcacode, landusecod, tcacode, documentnu, booknumber, conveyance, conveyan_1, eff_from_d,
eff_to_dat, extractdat, legaldesc, objectid, pagenumber, shapestare, shapestlen, shape_star,
shape_st_1, shape_stle, shape_st_2, simcondivt, taxyear, type, zdesignato, geom
                FROM address_spatial.jackson_cnt_mo_1_tmp;
    ````
- [ ] Test 

    ````
    SELECT name FROM address_spatial.jackson_county_mo_tax_neighborhoods
    WHERE ST_Intersects( ST_MakePoint( -94.5867908690, 39.0903343205), geom);
    ````

- [ ] Create county tables

    ````
    \c address_api
    CREATE TABLE county_address_attributes (
        id character varying(30),
        gid integer NOT NULL,
        parcel_number character varying(30),
        name character varying(50),
        tif_district character varying(40),
        tif_project character varying(60),
        neighborhood_code character varying(5),
        pca_code character varying(10),
        land_use_code character varying(5),
        tca_code character varying(10),
        document_number character varying(15),
        book_number character varying(8),
        conveyance_area character varying(12),
        conveyance_designator character varying(20),
        legal_description character varying(200),
        object_id numeric(10,0),
        page_number character varying(80)
    );  

    ALTER TABLE county_address_attributes OWNER TO postgres;

    CREATE TABLE county_address_data (
        id character varying(30),
        situs_address character varying(80),
        situs_city character varying(80),
        situs_state character varying(80),
        situs_zip character varying(80),
        owner character varying(40),
        owner_address character varying(50),
        owner_city character varying(40),
        owner_state character varying(10),
        owner_zip character varying(10),
        stated_area character varying(50),
        tot_sqf_l_area numeric(10,0),
        year_built numeric(10,0),
        property_area numeric,
        property_picture character varying(255),
        property_report character varying(255),
        market_value numeric(10,0),
        assessed_value numeric(10,0),
        assessed_improvement character varying(10),
        assessed_land character varying(10),
        taxable_value numeric(10,0),
        mtg_co character varying(40),
        mtg_co_address character varying(50),
        mtg_co_city character varying(40),
        mtg_co_state character varying(10),
        mtg_co_zip character varying(10),
        common_area character varying(1),
        floor_designator character varying(80),
        floor_name_designator character varying(25),
        exempt character varying(5),
        complex_name character varying(100),
        cid character varying(100),
        eff_from_date character varying(80),
        eff_to_date character varying(80),
        extract_date character varying(80),
        shape_st_area numeric,
        shape_st_lenght numeric,
        shape_st_area_1 numeric,
        shape_st_length_1 numeric,
        shape_st_legnth_2 numeric,
        shape_st_area_2 numeric,
        sim_con_div_type character varying(10),
        tax_year numeric(10,0),
        type numeric(10,0),
        z_designator character varying(20)
    );  

    ALTER TABLE county_address_data OWNER TO postgres;

    ````

- [X]  Create query for GEOJSON based off of http://www.postgresonline.com/journal/archives/267-Creating-GeoJSON-Feature-Collections-with-JSON-and-PostGIS-functions.html

````
SELECT row_to_json(fc)
 FROM ( SELECT 'FeatureCollection' As type, array_to_json(array_agg(f)) As features
 FROM (SELECT 'Feature' As type
    , ST_AsGeoJSON(lg.geom)::json As geometry
    , row_to_json(lp) As properties
   FROM address_spatial.jackson_county_mo_tax_neighborhoods As lg
         INNER JOIN (SELECT gid, name FROM address_spatial.jackson_county_mo_tax_neighborhoods) As lp      
       ON lg.gid = lp.gid  ORDER BY lg.name) As f )  As fc;
````

ISSUE
* City stores county APN as JA30830180100000000
  * two letter county id
  * county identifier
* Jackson County stores its parcel id as 308- .....

- [ ]  Rename address_keys.county_address_id to address_keys.city_county_address_id
     - [ ] Rename in table
     - [ ] Rename in programs

- [ ] Create models
  * CountyAddressAttributes.php
  * CountyAddressData.php

- [ ] Create load_attributes.php
- [ ] Create load_data.php

- [ ] Run load_attributes.php
- [ ] Run load_data.php

- [ ] Update index.php, the api program

- [ ] Backup

    ````
pg_dump address_api | gzip > address_api-20150925.sql.gz
pg_dump census | gzip > census-20150925.sql.gz
pg_dump code4kc | gzip > code4kc-20150925.sql.gz

    ````

- [ ] Add field to  Model `CensusAttributes.php`
- [ ] Add field to `Address.php` queries.
- [ ] Create Load and run
- [ ] Update `webroot/index.php` if nessary

