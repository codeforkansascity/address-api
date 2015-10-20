Need to know where and when data was downloaded.

Need to select by attribute, city, state, county, zip, census, 

Need to select by point in time.  Councel district that existed on July 1, 1990

   



Is the KIVAPIN a unique identifier for an address?

   SELECT COUNT(*), address_id, city_address_id 
   FROM address_keys
   GROUP BY address_id, city_address_id
   HAVING COUNT(*) > 1;

Is there a one to one between KIVAPIN and county APN?

   SELECT COUNT(*), city_address_id, county_address_id
   FROM address_keys
   GROUP BY city_address_id, county_address_id
   HAVING COUNT(*) > 1;

Can a parcel have multiple addresses?

Can a address have multiple parcels?

A City can be in multiple counties.


A County can have multiple cities.
