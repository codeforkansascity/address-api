---
layout: default
title: About
---

Since all open data does not have the same attributes (neighborhood, city council, TIF districts) this system give researchers and software developers an easy place to go and add them to the data they are collecting.

The system is being designed for the CodeForKC projects, to make it simple for them to get information about an address in one place.  We want to keep our projects from building database with the same data.   Also to take the burden of learning how to process GIS layers from the project teams, and converting spatial data layers into columns in a database for them.

The audience for the data is:

1. Programs that can consume data from a API.
2. Statistical programmers using packages like R that can consume data from an API.
3. Spreadsheet users to download a CSV file of the data.

Data we are planning to store are:

* Identifiers that other systems use to identify the address/parcel, City Identifiers, County Identifiers
* Attributes of an address/parcel such as Census Tract, City Council District, TIF, ...
* Some data about an address/parcel if it is not readily available , amount paid in taxes, ...

The system is intended to answer the following:

* Get a normalized standard address, for example "210 W 19th Ter, Kansas City, MO"
standard address might be
"210 West 19th Terrace, Kansas City, MO, 64108"
* Return selected identifiers, attributes, and data related to one or more address.
* Get a list of addresses with attributes/data within a Attribute, for example all addresses in a given City Council District
* Get a list of addresses with attributes/data within a radius of a coordinate or other boundary.
* Provide data for address type ahead fields in web forms.

In addition with the data we collect for the above we can return other information such as:

* All addresses in a census tract
* Census tracts that are in a neighborhood

Sources of data attributes:
* City
* County
* State
* Census
* Others

We plan to have some simple web pages developed on top of this so people can make queries about the data.


Please see the [Wiki](https://github.com/codeforkansascity/address-api/wiki) for more information

Having issue with CORS
