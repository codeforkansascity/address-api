# How we build from Other.zip from KCMO

cd /tmp
curl
unzip Other.zip

# Determain layers

````
ogrinfo Other.gdb
````

````
Had to open data source read-only.
INFO: Open of `Other.gdb'
      using driver `OpenFileGDB' successful.
1: Annexations (Multi Polygon)
2: AreaPlanBoundaries (Multi Polygon)
3: CityLimit (Multi Polygon)
4: CouncilDistricts (Multi Polygon)
5: CouncilDistricts_2001 (Multi Polygon)
6: CouncilDistricts_2010 (Multi Polygon)
7: CountyBoundary (Multi Polygon)
8: MaintenanceDistricts_PW (Multi Polygon)
9: NeighborhoodCensus (Multi Polygon)
10: InspectionAreas (Multi Polygon)
11: PoliceDistricts (Multi Polygon)
12: PoliceDivisions (Multi Polygon)
13: PoliceSectors (Multi Polygon)
14: SolidWasteCollectionZones (Multi Polygon)
15: FederalHomeLoanBankAreas (Multi Polygon)
16: GreenImpactZone (Multi Polygon)
17: IncentiveCommunityImprove (Multi Polygon)
18: IncentiveEnterpriseZones (Multi Polygon)
19: IncentiveNbhdImproveDistrict (Multi Polygon)
20: IncentiveNbhdImproveProgram (Multi Polygon)
21: IncentivePlannedIndustrialExp (Multi Polygon)
22: IncentiveTaxIncrementFinancing (Multi Polygon)
23: IncentiveTransDevelopDistrict (Multi Polygon)
24: IncentiveUrbanRedevelopment353 (Multi Polygon)
25: IncentiveUrbanRenewal (Multi Polygon)
26: LandmarkKCRegister (Multi Polygon)
27: LandmarkNationalRegister (Multi Polygon)
28: LandUsePlanningAreas (Multi Polygon)
29: MinorHomeRepairProgramTargets (Multi Polygon)
30: NeighborhoodActionPlanAreas (Multi Polygon)
31: NeighborhoodOrganizationsNCSD (Multi Polygon)
32: SpecialReviewDistricts (Multi Polygon)
33: StreetImpactFeeDistricts (Multi Polygon)
34: Zoning (Multi Polygon)
35: ZoningOverlayDistricts (Multi Polygon)
36: PointsOfInterest (Point)
37: Streetlights (Point)
38: RiversLakes (Multi Polygon)
39: sweWatershedBoundary (Multi Polygon)
40: VacantParcels (Multi Polygon)  vacant_parcels
41: Parks (Multi Polygon)
42: CapitalProjects (Multi Polygon)
43: CapitalProjects__ATTACH (None)
````

# Lets look at a layer

````
ogrinfo -ro -so Other.gdb VacantParcels
````

````
INFO: Open of `Other.gdb'
      using driver `OpenFileGDB' successful.

Layer name: VacantParcels
Geometry: Multi Polygon
Feature Count: 27717
Extent: (2713525.138478, 967821.563479) - (2821300.080080, 1160965.950811)
Layer SRS WKT:
PROJCS["NAD_1983_StatePlane_Missouri_West_FIPS_2403_Feet",
    GEOGCS["GCS_North_American_1983",
        DATUM["North_American_Datum_1983",
            SPHEROID["GRS_1980",6378137.0,298.257222101]],
        PRIMEM["Greenwich",0.0],
        UNIT["Degree",0.0174532925199433]],
    PROJECTION["Transverse_Mercator"],
    PARAMETER["False_Easting",2788708.333333333],
    PARAMETER["False_Northing",0.0],
    PARAMETER["Central_Meridian",-94.5],
    PARAMETER["Scale_Factor",0.9999411764705882],
    PARAMETER["Latitude_Of_Origin",36.16666666666666],
    UNIT["Foot_US",0.3048006096012192],
    AUTHORITY["ESRI","102698"]]
FID Column = OBJECTID
Geometry Column = SHAPE
KIVAPIN: String (0.0)
APN: String (0.0)
ADDRESS: String (0.0)
ADDR: Integer (0.0)
FRACTION: String (0.0)
PREFIX: String (0.0)
STREET: String (0.0)
STREET_TYPE: String (0.0)
SUITE: String (0.0)
OWN_NAME: String (0.0)
OWN_ADDR: String (0.0)
OWN_CITY: String (0.0)
OWN_STATE: String (0.0)
OWN_ZIP: String (0.0)
ZONING: String (0.0)
SHAPE_Length: Real (0.0)
SHAPE_Area: Real (0.0)
````

Forgin Data Wrapers gives us some interesting information

````
ogr_fdw_info -s Other.gdb -l VacantParcels
````

We are only intrested in the `CREATE FOREIGN TABLE` section

````
CREATE SERVER myserver
  FOREIGN DATA WRAPPER ogr_fdw
  OPTIONS (
    datasource 'Other.gdb',
    format 'OpenFileGDB' );

CREATE FOREIGN TABLE vacantparcels (
  fid bigint,
  shape Geometry(MultiPolygon),
  kivapin varchar,
  apn varchar,
  address varchar,
  addr integer,
  fraction varchar,
  prefix varchar,
  street varchar,
  street_type varchar,
  suite varchar,
  own_name varchar,
  own_addr varchar,
  own_city varchar,
  own_state varchar,
  own_zip varchar,
  zoning varchar,
  shape_length real,
  shape_area real
) SERVER myserver
OPTIONS (layer 'VacantParcels');
````

# Load data into postgres

````
ogr2ogr -f "PostgreSQL" PG:"dbname=code4kc user=postgres" Other.gdb VacantParcels
````

# See what was created in postgres

Start psql

````
psql code4kc
````

Now list what is in t

````
\d
````

````
                     List of relations
  Schema  |           Name            |   Type   |  Owner   
----------+---------------------------+----------+----------
 public   | geography_columns         | view     | postgres
 public   | geometry_columns          | view     | postgres
 public   | raster_columns            | view     | postgres
 public   | raster_overviews          | view     | postgres
 public   | spatial_ref_sys           | table    | postgres
 public   | vacantparcels             | table    | postgres
 public   | vacantparcels_ogc_fid_seq | sequence | postgres

 topology | layer                     | table    | postgres
 topology | topology                  | table    | postgres
 topology | topology_id_seq           | sequence | postgres
````

Take a looks at vacantparcels.  
We will see that the geometry is MultiPolygon and the projection is 900914.


````
\d vacantparcels
````

````
                                          Table "public.vacantparcels"
    Column    |             Type              |                            Modifiers                            
--------------+-------------------------------+-----------------------------------------------------------------
 ogc_fid      | integer                       | not null default nextval('vacantparcels_ogc_fid_seq'::regclass)
 wkb_geometry | geometry(MultiPolygon,900914) | 
 kivapin      | character varying             | 
 apn          | character varying             | 
 address      | character varying             | 
 addr         | integer                       | 
 fraction     | character varying             | 
 prefix       | character varying             | 
 street       | character varying             | 
 street_type  | character varying             | 
 suite        | character varying             | 
 own_name     | character varying             | 
 own_addr     | character varying             | 
 own_city     | character varying             | 
 own_state    | character varying             | 
 own_zip      | character varying             | 
 zoning       | character varying             | 
 shape_length | double precision              | 
 shape_area   | double precision              | 
Indexes:
    "vacantparcels_pkey" PRIMARY KEY, btree (ogc_fid)
    "vacantparcels_wkb_geometry_geom_idx" gist (wkb_geometry)
````

Now lets talk a look at the fields

````
SELECT ogc_fid, kivapin, apn, address, addr, fraction, prefix, street, street_type, suite 
FROM vacantparcels ORDER BY ogc_fid LIMIT 20;
 ogc_fid | kivapin |         apn          |       address        | addr  | fraction | prefix |  street   | street_type | suite 
---------+---------+----------------------+----------------------+-------+----------+--------+-----------+-------------+-------
       1 | 251245  | CL0991000130020401   | 10639 N Locust Ct CE | 10639 |          | N      | Locust    | Ct          | CE
       2 | 56354   | JA49620011500000000  |                      |       |          |        |           |             | 
       3 | 254645  | CL1411500060100001   | 4306 NE 85th Ter     |  4306 |          | NE     | 85th      | Ter         | 
       4 | 10005   | JA28320170100000000  | 3303 E 9th St        |  3303 |          | E      | 9th       | St          | 
       5 | 100190  | CL0960200010040001   | 12181 N Woodland Ave | 12181 |          | N      | Woodland  | Ave         | 
       6 | 50568   | JA32430052300000000  |                      |       |          |        |           |             | 
       7 | 100185  | CL0960200010070101   |                      |       |          |        |           |             | 
       8 | 249922  | CL1320800010170001   | 725 NW 94th Ter      |   725 |          | NW     | 94th      | Ter         | 
       9 | 100155  | CL1330500020010001   | 201 NW 95th Ter      |   201 |          | NW     | 95th      | Ter         | 
      10 | 77006   | CL1810600180010001   | 4527 N Winn Rd       |  4527 |          | N      | Winn      | Rd          | 
      11 | 75014   | CA050102300000001009 |                      |       |          |        |           |             | 
      12 | 255889  | JA67900020902000000  |                      |       |          |        |           |             | 
      13 | 252049  | PL172010000000004900 |                      |       |          |        |           |             | 
      14 | 255687  | CL1431000060110001   | 9106 N Evanston Ave  |  9106 |          | N      | Evanston  | Ave         | 
      15 | 9572    | JA28310182200000000  | 804 Myrtle Ave       |   804 |          |        | Myrtle    | Ave         | 
      16 | 238889  | CL1431700150050001   | 8252 N Oxford Ave    |  8252 |          | N      | Oxford    | Ave         | 
      17 | 56356   | JA49620011700000000  | 9151 Hillcrest Rd    |  9151 |          |        | Hillcrest | Rd          | 
      18 | 100206  | CL0960100010140001   | 12100 N Main St      | 12100 |          | N      | Main      | St          | 
      19 | 166479  | PL199029300008017000 | 5737 N Beaman Ave    |  5737 |          | N      | Beaman    | Ave         | 
      20 | 166482  | PL199029300009002000 | 5602 N Polk Dr       |  5602 |          | N      | Polk      | Dr          | 
(20 rows)

SELECT ogc_fid, own_name, own_addr, own_city, own_state, own_zip, zoning
FROM vacantparcels ORDER BY ogc_fid LIMIT 20;
 ogc_fid |                own_name                 |        own_addr         |    own_city    | own_state |  own_zip   |   zoning    
---------+-----------------------------------------+-------------------------+----------------+-----------+------------+-------------
       1 | Machicao Lisa                           | 8204 W 145th St         | Overland Park  | KS        | 66223      | R-5
       2 | Cerner Property Development Inc         | 2800 Rockcreek Pkwy     | Kansas City    | MO        | 64117      | UR
       3 | Trophy Homes Inc                        | PO Box 545              | Liberty        | MO        | 64069-0545 | R-6
       4 | Inzerillo Andrew L                      | 9047 E 51st Ter         | Kansas City    | MO        | 64133      | B3-2, R-2.5
       5 | Property Reserve Inc                    | PO Box 511196           | Salt Lake City | UT        | 84151-1196 | R-80
       6 | Prime Real Estate Development LLC       | PO Box 5322             | Kansas City    | MO        | 64131      | B3-2
       7 | Knisley Gene V & Joyce A                | 12601 N Woodland Ave    | Kansas City    | MO        | 64165      | R-80
       8 | BT Residential LLC                      | 5201 Johnson Dr Ste 450 | Mission        | KS        | 66205-2930 | R-7.5
       9 | BT Residential LLC                      | 5201 Johnson Dr Ste 450 | Mission        | KS        | 66205-2930 | R-80
      10 | Winnwood Baptist Church                 | 4513 N Jackson Ave      | Kansas City    | MO        | 64117-1899 | R-2.5
      11 | Adesa Missouri LLC                      | Westover Rd             | Belton         | MO        |            | M1-5
      12 | The Kansas City Southern Railway Co     | 427 W 12th St           | Kansas City    | MO        | 64105      | M1-5
      13 | CBS Outdoor                             | 2459 Summit             | Kansas City    | MO        | 64108      | KCIA
      14 | Copperleaf of KC Home Owner's Assoc Inc | 1010 Walnut St Ste 500  | Kansas City    | MO        | 64106-2147 | R-7.5
      15 | Meek Thomas A                           | 3616 E 10th St          | Kansas City    | MO        | 64127      | R-2.5
      16 | Bankliberty                             | 9200 NE Barry Rd        | Kansas City    | MO        | 64157-1209 | SC
      17 | Cerner Property Development Inc         | 2800 Rockcreek Pkwy     | Kansas City    | MO        | 64117      | UR
      18 | Scol Inc                                | 300 W 11th St           | Kansas City    | MO        | 64105-1618 | R-80
      19 | Northwood Hills Homes Association Inc   | 5717 N Beaman Ave       | Kansas City    | MO        | 64151      | R-7.5
      20 | JDM LLC                                 | PO Box 9203             | Riverside      | MO        | 64168      | R-7.5
(20 rows)

````

We see our identifiers

* kivapin -> city_id
* apn -> county_id


We now have some data we did not have otherwise.  
In the case of the owner information we have county.

We will add these fields 

City
* own_name -> city_owner_name
* own_addr -> city_owner_address
* own_city -> city_owner_city
* own_state -> city_owner_state
* own_zip -> city_owner_zip
* zoning -> city_zoning



We also have existing data that could be verified


* address -> single_line_address (Will need to use conversion)
* addr -> street_number
* fraction  --- NEW
* prefix -> pre_direction
* street -> street_name
* street_type -> street_type
* suite --- IS THIS THE SAME AS internal in the address record?

We are missing `post_direction`

Analysis of faction

````
select count(*), fraction from vacantparcels group by fraction;
 count | fraction 
-------+----------
 27575 | 
     4 | B
    20 | 1/2
     2 | C
   115 | A
     1 | E
````


1) Add database field to the following.  Example is `vacant_parcel`
  * `city_address_attributes` in `install.sql`
  * `api-docs/swagger.json`
  * `src/Code4KC/Address/Address.php` in the `$base_sql` variable
  
2) Add to `area_types` in `src/Code4KC/Address/Areas.php`. example `'VacantParcels' => 4,`

3) 
   * change table name `vacantparcel`
   * change field name `vacant_parcel` in three places

4) Change shell script
   * table name to `vacantparcel`
   * PHP script name