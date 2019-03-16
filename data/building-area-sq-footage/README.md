Tax Delinquency Data from Jackson County 2019 Update
=====================================================

`Legal-Aid-Data-Request-2-26-19.xlsx` contains tax information for 2010 to 2018

File from county

````
parcel_number
inactive_date
year		tax_year
base_delq_amt	balance_amt
taxpayer_name	organization
care_of
mailing_line_1
mailing_line_2
mailing_city
mailing_state
mailing_zip_code
physical_address
physical_city
physical_zip_code
````

# Changes

1) Copied jackson-county-tax-delinquency-2018 to jackson-county-tax-delinquency-2019
2) Modified 
    * install.sql
    * load
    * load-jackson-county-tax-delinquency.php
    * setup-for-test.sh
    * test-all.sh
3) Modified outside of jackson-county-tax-delinquency-2019

````
--- a/api-docs/swagger.json
+++ b/api-docs/swagger.json
@@ -700,6 +700,11 @@
           "description": "",
           "example": ""
         },
+        "county_delinquent_tax_2018": {
+          "type": "string",
+          "description": "",
+          "example": ""
+        },
        "county_situs_address": {
           "type": "string",
           "description": "",
diff --git a/src/Code4KC/Address/Address.php b/src/Code4KC/Address/Address.php
index f12dab7..2b682f8 100644
--- a/src/Code4KC/Address/Address.php
+++ b/src/Code4KC/Address/Address.php
@@ -94,6 +94,7 @@ class Address extends BaseTable
                 j.delinquent_tax_2015 AS county_delinquent_tax_2015,
                 j.delinquent_tax_2016 AS county_delinquent_tax_2016,
                 j.delinquent_tax_2017 AS county_delinquent_tax_2017,
+                j.delinquent_tax_2018 AS county_delinquent_tax_2018,
                 
                 cd.situs_address AS county_situs_address,
                 cd.situs_city AS county_situs_city,
diff --git a/src/Code4KC/Address/CountyAddressAttributes.php b/src/Code4KC/Address/CountyAddressAttributes.php
index 3c5b880..171c769 100644
--- a/src/Code4KC/Address/CountyAddressAttributes.php
+++ b/src/Code4KC/Address/CountyAddressAttributes.php
@@ -36,7 +36,10 @@ class CountyAddressAttributes extends BaseTable
         'delinquent_tax_2012' => 0,
         'delinquent_tax_2013' => 0,
         'delinquent_tax_2014' => 0,
-        'delinquent_tax_2015' => 0
+        'delinquent_tax_2015' => 0,
+        'delinquent_tax_2016' => 0,
+        'delinquent_tax_2017' => 0,
+        'delinquent_tax_2018' => 0
     );
 
 }

````

# Test run

```
cd /var/www/address-api/data/jackson-county-tax-delinquency-2019
sh test-all.sh
```


# First run

````
Address that were not found: Array
(
    [610 N GARLAND AVE] => 1
    [1501 GUINOTTE AVE] => 1
    [NO ADDRESS ASSIGNED BY CITY] => 199
    [254 W 3RD ST] => 1
    [910 E 5TH ST] => 1
    [808 E 5TH ST] => 1
    [401 CHERRY ST] => 1
    [800 WOODSWETHER RD] => 1
    [1115 N BELLEFONTAINE AVE] => 2
    [3500 NICHOLSON AVE] => 1
    [3526 NICHOLSON AVE] => 1
    [6606 INDEPENDENCE AVE] => 1
    [345 N WHITE AVE] => 1
    [520 BENNINGTON AVE] => 1
    [3234 THOMPSON AVE] => 1
    [3412 MORRELL AVE] => 1
    [500 JACKSON AVE] => 1
    [542 NORTON AVE] => 1
    [3418 INDEPENDENCE AVE] => 1
    [8605 THOMPSON AVE] => 1
    [515 BLUE RIDGE BLVD] => 1
    [8702 ROBERTS ST] => 1
    [2451 MCKINLEY AVE] => 1
    [2423 STARK AVE] => 1
    [1023 NEWTON AVE] => 1
    [704 WHEELING AVE] => 1
    [718 WHEELING AVE] => 1
    [1022 BENNINGTON AVE] => 1
    [1405 WINCHESTER AVE] => 1
    [5036 E 10TH ST] => 1
    [5510 E 12TH ST] => 1
    [724 CYPRESS AVE] => 1
    [3817 E 7TH ST] => 1
    [702 CHESTNUT AVE] => 1
    [2625 E 9TH ST] => 1
    [2630 E 10TH ST] => 1
    [3513 E 12TH ST] => 1
    [3014 E 20TH TER] => 1
    [2424 JACKSON AVE] => 1
    [4933 E 17TH ST] => 1
    [2028 CHELSEA AVE] => 1
    [2045 POPLAR AVE] => 1
    [2240 POPLAR AVE] => 1
    [2220 CHELSEA AVE] => 1
    [2312 BRIGHTON AVE] => 1
    [2449 JACKSON AVE] => 1
    [2519 LISTER AVE] => 1
    [5114 E 27TH ST] => 1
    [2612 LAWNDALE AVE] => 1
    [1915 NEWTON AVE] => 1
    [2845 WHITE AVE] => 1
    [2829 TOPPING AVE] => 1
    [3225 BEACON] => 1
    [2842 RAYTOWN RD] => 1
    [2920 KENSINGTON AVE] => 1
    [3006 BRIGHTON AVE] => 1
    [3017 YORK ST] => 1
    [3239 BRIGHTON AVE] => 1
    [3424 DRURY AVE] => 1
    [2712 BENTON BLVD] => 2
    [3239 VICTOR ST] => 1
    [3317 BENTON BLVD] => 1
    [1101 EUCLID AVE] => 1
    [713 TROOST AVE] => 1
    [600 E 8TH ST UNIT 7S] => 1
    [600 E 8TH ST UNIT 8F] => 1
    [600 E 8TH ST UNIT 8E] => 1
    [600 E 8TH ST UNIT 8R] => 1
    [600 E 8TH ST UNIT 8N] => 1
    [600 E 8TH ST UNIT 9D] => 1
    [600 E 8TH ST UNIT 12B] => 1
    [600 E 8TH ST UNIT TSF] => 1
    [612 CENTRAL ST UNIT 504] => 1
    [612 CENTRAL ST UNIT 501] => 1
    [21 W 10TH ST UNIT 10C] => 1
    [21 W 10TH ST UNIT 10D] => 1
    [101 W 11TH ST UNIT 2] => 2
    [NO ADDDRESS ASSIGNED BY CITY] => 2
    [819 E TRUMAN RD] => 1
    [1410 ST LOUIS AVE] => 1
    [906 W 17TH ST] => 1
    [1745 JEFFERSON ST] => 1
    [1743 MADISON AVE] => 1
    [1736 MADISON AVE] => 1
    [2021 WASHINGTON ST] => 1
    [2110 WASHINGTON ST] => 1
    [514 W 26TH ST UNIT 3S] => 1
    [2100 WYANDOTTE ST] => 1
    [301 SOUTHWEST BLVD] => 1
    [2510 GRAND AVE] => 1
    [2415 E 21ST ST] => 1
    [1700 E 18TH ST] => 1
    [1822 VINE ST] => 1
    [1600 E 19TH ST] => 1
    [1708 E 24TH ST] => 1
    [2432 TRACY AVE] => 1
    [1250 BEACON HILL LN] => 1
    [2454 W PASEO BLVD] => 1
    [2501 TRACY AVE] => 1
    [2600 TRACY AVE] => 1
    [2445 WOODLAND AVE] => 1
    [2523 MICHIGAN AVE] => 1
    [2501 WABASH AVE] => 1
    [2509 E 26 ST] => 1
    [2816 PASEO] => 1
    [2907 PASEO] => 1
    [3235 TROOST AVE] => 1
    [3210 WOODLAND AVE] => 1
    [3036 TROOST AVE] => 1
    [3029 OAK ST] => 1
    [2734 MCGEE TRFY] => 1
    [CA RESIDENTIAL] => 3
    [3030 BALTIMORE AVE] => 1
    [2940 BALTIMORE AVE UNIT 1304] => 1
    [2940 BALTIMORE AVE UNIT 1401] => 1
    [2940 BALTIMORE AVE UNIT 1408] => 1
    [2940 BALTIMORE AVE] => 4
    [2980 BALTIMORE AVE UNIT 2102] => 1
    [2980 BALTIMORE AVE UNIT 2103] => 1
    [2980 BALTIMORE AVE UNIT 2104] => 1
    [2980 BALTIMORE AVE UNIT 2106] => 1
    [2980 BALTIMORE AVE UNIT 2203] => 1
    [2980 BALTIMORE AVE UNIT 2201] => 1
    [2980 BALTIMORE AVE UNIT 2302] => 1
    [2980 BALTIMORE AVE UNIT 2304] => 1
    [2980 BALTIMORE AVE UNIT 2308] => 1
    [2980 BALTIMORE AVE UNIT 2301] => 1
    [3409 CENTRAL ST] => 1
    [3218 GILLHAM RD] => 1
    [3215 CHARLOTTE ST] => 1
    [3408 CHARLOTTE ST] => 1
    [2800 MADISON AVE] => 1
    [2929 MADISON AVE] => 1
    [2900 GENESSEE ST] => 1
    [2001 E 35TH ST] => 2
    [3710 WABASH AVE] => 1
    [3638 WOODLAND AVE] => 1
    [3630 WOODLAND AVE] => 1
    [3814 HIGHLAND AVE] => 1
    [4130 WAYNE AVE] => 1
    [4210 VIRGINIA AVE] => 1
    [3938 OLIVE ST] => 1
    [4125 OLIVE ST] => 1
    [3800 BALTIMORE AVE UNIT 4S] => 1
    [3917 KENWOOD AVE] => 2
    [3925 KENWOOD AVE APT 1] => 1
    [1023 W 38TH ST UNIT 1047] => 1
    [3517 TERRACE ST] => 1
    [3544 WYOMING] => 1
    [3546 WYOMING ST] => 1
    [3931 GENESSEE ST] => 1
    [3933 GENESSEE ST] => 1
    [3934 WYOMING ST] => 1
    [4006 WYOMING ST] => 1
    [4111 ROANOKE AVE] => 1
    [4500 MADISON AVE] => 1
    [1203 W 50TH ST] => 1
    [1300 W 50TH TER] => 1
    [4335 OAK ST UNIT 14] => 1
    [4314 OAK ST UNIT 27] => 1
    [4618 WARWICK BLVD UNIT 2C] => 1
    [4618 WARWICK BLVD UNIT 5E] => 1
    [4618 WARWICK BLVD UNIT 6E] => 1
    [4618 WARWICK BLVD UNIT 8F] => 1
    [121 W 48TH ST UNIT 505] => 1
    [121 W 48TH ST UNIT 701] => 1
    [121 W 48TH ST UNIT 803] => 1
    [121 W 48TH ST UNIT 902] => 1
    [121 W 48TH ST UNIT 906] => 1
    [121 W 48TH ST UNIT 908] => 1
    [121 W 48TH ST UNIT 1204] => 1
    [121 W 48TH ST UNIT 1203] => 1
    [4310 PROSPECT AVE] => 1
    [4307 TRACY AVE] => 1
    [1206 E 45TH ST] => 1
    [1221 E 45TH ST] => 1
    [2403 E 49TH ST] => 1
    [4900 WABASH AVE] => 1
    [4923 OLIVE ST] => 1
    [5007 OLIVE ST] => 2
    [5422 TRACY AVE] => 1
    [5816 WABASH AVE] => 1
    [301 E 51ST ST] => 1
    [5113 WYANDOTTE 1N] => 1
    [6309 E 35TH ST] => 1
    [3831 FREMONT AVE] => 1
    [3520 HARDESTY AVE] => 1
    [3850 CHELSEA DR] => 1
    [3818 CHELSEA DR] => 1
    [5502 E 36TH ST] => 1
    [3508 BRIGHTON AVE] => 1
    [3801 CYPRESS AVE] => 1
    [3806 CYPRESS AVE BLDG 7] => 1
    [3645 MONROE AVE] => 1
    [3601 BENTON BLVD] => 1
    [4032 MYRTLE AVE] => 1
    [5001 CHESTNUT AVE] => 1
    [5005 CHESTNUT AVE] => 1
    [5011 PROSPECT AVE] => 1
    [4332 CYPRESS AVE] => 1
    [7312 S PARK RD] => 1
    [7100 SNI-A-BAR RD] => 1
    [6515 E 53RD ST] => 1
    [6001 E 56TH ST] => 1
    [5323 HARDESTY AVE] => 1
    [4317 E 55TH ST] => 1
    [4315 E 55TH ST] => 1
    [4312 E 59TH ST] => 1
    [5819 LISTER AVE] => 1
    [5812 COLORADO AVE] => 1
    [5143 AGNES AVE] => 1
    [5543 PROSPECT AVE] => 1
    [5528 MYRTLE AVE] => 1
    [5656 BALES AVE] => 1
    [3639 E 58TH ST] => 1
    [9715 E US 40 HWY] => 1
    [3530 BLUE RIDGE CUT OFF] => 1
    [8805 LEEDS RD] => 1
    [4141 RAYTOWN RD] => 1
    [8804 E 47TH ST] => 1
    [8523 E 47TH ST] => 1
    [4604 HAWTHORNE AVE] => 1
    [4715 BLUE RIDGE CUT OFF] => 1
    [4514 HEDGES ST] => 1
    [5105 RINKER RD] => 1
    [7826 E 57TH ST] => 1
    [7922 E 58TH ST] => 1
    [4700 PHELPS RD] => 1
    [4731 HADEN CT] => 1
    [13107 E 54TH ST] => 1
    [7949 BLUE RIDGE BLVD] => 1
    [6120 E 64TH ST] => 1
    [5914 WALROND AVE] => 1
    [6339 CHESTNUT AVE] => 1
    [4026 E 67TH TER] => 1
    [3820 E 69TH ST] => 1
    [7013 PROSPECT AVE] => 1
    [7027 COLLEGE AVE] => 1
    [7326 INDIANA AVE] => 1
    [7116 E STRUMPWOOD CT] => 1
    [2711 E 77TH ST] => 1
    [8125 HICKMAN MILLS DR] => 1
    [6010 MICHIGAN AVE] => 1
    [6324 BALTIMORE AVE] => 1
    [413 E 63RD ST] => 1
    [415 E 63RD ST] => 1
    [6601 ROCKHILL RD] => 1
    [6600 TROOST AVE] => 1
    [641 W 61ST TER] => 1
    [211 W GREGORY BLVD] => 1
    [7108 WYANDOTTE ST] => 1
    [2429 E 75TH ST] => 1
    [1421 E 79TH ST] => 1
    [8022 FLORA AVE] => 1
    [7923 HICKMAN MILLS DR] => 2
    [8020 HICKMAN MILLS DR] => 1
    [1818 E 81ST TER] => 1
    [7777 HOLMES RD APT 246] => 1
    [210 W 78TH TER] => 1
    [220 E 80TH TER] => 1
    [8316 PARK AVE] => 1
    [2208 E 85TH ST] => 1
    [8625 TROOST AVE] => 1
    [936 E 83RD ST] => 1
    [8330 TROOST AVE] => 1
    [8505 HOLMES RD] => 1
    [925 E 85TH ST] => 1
    [8413 MAIN ST] => 1
    [9108 GRAND AVE] => 2
    [9212 GRAND AVE] => 3
    [9408 MCGEE ST] => 1
    [10104 FOREST AVE] => 1
    [8503 CRYSTAL AVE] => 1
    [7402 E 86TH ST] => 2
    [8485 PROSPECT AVE] => 1
    [3205 E 95TH TER] => 1
    [3208 RED BUD DR] => 1
    [9701 MARION PARK DR] => 1
    [10415 CHESTNUT AVE] => 1
    [8739 TENNESSEE AVE UNIT A] => 1
    [7404 E 87TH ST] => 1
    [8952 E BANNISTER RD] => 1
    [9311 RAYTOWN RD] => 1
    [11505 E BANNISTER RD] => 1
    [11501 E BANNISTER RD] => 1
    [10012 RICHMOND AVE] => 1
    [7704 E 107TH ST] => 1
    [14400 E 87TH ST] => 2
    [14300 E 87TH ST] => 1
    [9050 RHINEHART RD] => 1
    [8600 NOLAND RD] => 1
    [14001 BLUE PKWY] => 1
    [13001 E BANNISTER RD] => 1
    [13000 E 99TH ST] => 1
    [2651 LEES SUMMIT RD] => 1
    [10711 ELM AVE] => 1
    [10905 MC KINLEY ST] => 1
    [8706 E 114TH TER] => 1
    [11501 GRANDVIEW RD] => 1
    [1212 W 112TH TER] => 1
    [11501 WORNALL RD] => 2
    [12205 MCGEE ST] => 1
    [12402 HOLMES RD] => 1
    [12601 CHARLOTTE ST] => 1
    [1700 E 139TH ST] => 1
    [13115 HOLMES RD] => 2
    [14655 PROSPECT AVE] => 1
    [13920 PETERSON RD] => 1
    [11600 M 150 HWY] => 1
    [15020 HORRIDGE RD] => 1
)


Totals for SET area_name
-------------------------------------------------------------------------------------------------
table                              insert     update   inactive re-activate        N/A      ERROR 
county_address_attributes             624      24106          0          0        144        528
-------------------------------------------------------------------------------------------------

Number of lines processed 0

This process used 113 ms for its computations
It spent 3736 ms in system calls
Run time:  24s

````

# Production install

1. Badkup Site
    ```
    cd /var/www
    sudo tar czf address-api.tar.gz address-api
    ```
2. Backup DB

    Will make a backup of adddress_api and code4kc databases
    ```
    sudo su - postgres
    sh doit
    ls -lrt dumps
    exit
    ```
3. Update Site
    ```
    cd /var/www/address-api
    git pull origin master
    ```
3. Copy spread sheet to `/tmp`
    ```
    cd /var/www/address-api/data/jackson-county-tax-delinquency-2019
    cp Legal-Aid-Data-Request-2-26-19.xlsx /tmp
    ```
4. Run the `load` script
    ```
    cd /var/www/address-api/data/jackson-county-tax-delinquency-2019
    sudo -u postgres psql code4kc < install.sql
    sh ./load                
    ```
5. Verify data was loaded.

