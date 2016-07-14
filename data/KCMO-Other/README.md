

# Process

## Install

1) Install tables, normal and spatial
2) Fix permissions if nessary
3) Update from Git

## Load

1) Update Area/Shape data
    1) Download shape file and extract 
    2) Create temporary area/shape table
    3) Update spatial table with City, State, ID, Name, and shape
      * What do we do with ordnum, status, amendment, lastupdate?
      * Add, Change, Delete
2) Update address attributes
  * For each address, lookup longitude, latitude
  * See what areas the address is in
     * Add, Change, Delete as needed



99) cleanup


UPDATE GIS

When we add remember    IDs active_spatial_ids
When we change remember IDs active_spatial_ids

Mark all 'DELETED' that are not in active_spatial_ids


UPDATE Address

For all addresses in gis_ids_deleted remove TIF info
For all addresses in gis_ids_added Add TIF info
For all addresses in gis_ids_changed Update TIF info




