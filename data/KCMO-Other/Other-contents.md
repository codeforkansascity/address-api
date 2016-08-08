## Annexations
Layer name: Annexations
Geometry: Multi Polygon

Temp Table Name: public.annexations

````
                                           Table "public.annexations"
     Column      |             Type              |                           Modifiers                           
-----------------+-------------------------------+---------------------------------------------------------------
 ogc_fid         | integer                       | not null default nextval('annexations_ogc_fid_seq'::regclass)
 wkb_geometry    | geometry(MultiPolygon,900914) | 
 sq_miles        | double precision              | 
 ordnum          | character varying             | 
 ordacres        | double precision              | 
 acres           | double precision              | 
 annexation_year | integer                       | 
 effectdate      | character varying             | 
 authendate      | character varying             | 
 annexationtype  | integer                       | 
 sub_year        | character varying             | 
 lastupdate      | timestamp with time zone      | 
 shape_length    | double precision              | 
 shape_area      | double precision              | 
Indexes:
    "annexations_pkey" PRIMARY KEY, btree (ogc_fid)
    "annexations_wkb_geometry_geom_idx" gist (wkb_geometry)
````

````
field           | type                          |
--------------- + ----------------------------- |
id              | integer                       |
sq_miles        | double precision              |  
ordnum          | character varying             |  
ordacres        | double precision              |  
acres           | double precision              |  
annexation_year | integer                       |  
effectdate      | character varying             |  
authendate      | character varying             |  
annexationtype  | integer                       |  
sub_year        | character varying             |  
lastupdate      | timestamp with time zone      |  
--------------- + ----------------------------- |

````
select ogc_fid, sq_miles, ordnum, ordacres, acres, annexation_year, effectdate, authendate, annexationtype, sub_year, lastupdate from public.annexations limit 10;

 ogc_fid | sq_miles | ordnum | ordacres |  acres   | annexation_year | effectdate | authendate | annexationtype | sub_year | lastupdate 
---------+----------+--------+----------+----------+-----------------+------------+------------+----------------+----------+------------
       1 |     1.04 |        |        0 |   666.95 |            1853 |            |            |              1 |          | 
       2 |      2.8 |        |        0 |  1794.56 |            1859 |            |            |              1 |          | 
       3 |     1.42 |        |        0 |   906.57 |            1873 |            |            |              1 |          | 
       4 |     7.94 |        |        0 |  5080.91 |            1885 | 7/21/1885  |            |              1 |          | 
       5 |     6.35 |        |        0 |  4065.64 |            1897 |            |            |              1 | A        | 
       6 |     7.09 |        |        0 |  4535.17 |            1897 |            |            |              1 | B        | 
       7 |    27.31 |        |        0 | 17479.65 |            1909 |            |            |              1 | A        | 
       8 |     5.85 |        |        0 |  3741.73 |            1909 |            |            |              1 | B        | 
       9 |     3.08 | 8674   |        0 |  1971.51 |            1947 | 1/1/1947   |            |              1 |          | 
````