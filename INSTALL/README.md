# Requirements

# Create a Virtual Box with Address API

The following software will be installed:

* Ubuntu 14.04.3 LTS - trusty
* PHP 5.5.9
* Apache/2.4.7
* Postgresql 9.3.11 - server encoding UTF8, installed extensions

  * fuzzystrmatch     1.0     - determine similarities and distance between strings
  * ogr_fdw           1.0     - foreign-data wrapper for GIS data access - https://github.com/pramsey/pgsql-ogr-fdw
  * plpgsql           9.2.14  - PL/pgSQL procedural language
  * postgis           2.1.2   - PostGIS geometry, geography, and raster spatial types and functions
  * postgis_topology  2.1.2   - PostGIS topology spatial types and functions
  * postgres_fdw      1.0     - foreign-data wrapper for remote PostgreSQL servers

* PostGIS 2.2.2 r14797
  * GDAL 2.1.0, released 2016/04/250

## Requirements
* Make certain `ssh` can be executed and is in your`PATH`
  * Windows users: the easiest way to make sure this happens is to install [Git for Windows](https://git-for-windows.github.io)
  * Windows users: be sure to use the _Run as Administrator_ option on your command prompt or the following steps may fail
* [Virtual Box](https://www.virtualbox.org/)
* [Vagrant](https://www.vagrantup.com/)


## Clone repository
```
$ git clone git@github.com:codeforkansascity/address-api.git
$ cd address-api
```
## Install required Vagrant plugins
```
$ vagrant plugin install vagrant-hostmanager
$ vagrant plugin install vagrant-vbguest
```

## Setup data to be restored
You need to create a directory called `dumps` and copy the dump files to them

```
$ mkdir dumps
```

Copy the dumps from `https://drive.google.com/drive/u/0/folders/0B1F5BJsDsPCXb2NYSmxCT09TX1k`
to the dumps directory and unzip them.

```
$ cd dumps
$ gunzip address_api-20160919-1829.dump.gz
$ gunzip code4kc-20160919-1829.dump.gz
$ cd ..
```

## Add our `address-api` box to vagrant

Copy the `address-api.box` from `https://drive.google.com/drive/u/0/folders/0B1F5BJsDsPCXb2NYSmxCT09TX1k`
to the dumps directory.

Now install the `address-api` box

````
$ cd dumps
$ vagrant box add address-api address-api.box
$ cd ..
````

## Create image
```
$ vagrant up
```

## Login
```
$ vagrant ssh
```

# Setup postgres

## Login as postgres
```
$ sudo su - postgres
```


## Restore databases
```
$ cd /var/www/address-api/dumps
$ pg_restore -C -d address_api address_api-20160919-1829.dump
$ pg_restore -C -d code4kc code4kc-20160919-1829.dump
$ exit
```

You will get several errors but you can ignore them.

## Run Composer

````
$ cd /var/www/address-api
$ composer update
````

## Test that everything works

You should now be able to browse to the following:

```
http://dev-api.codeforkc.devel/address-attributes/V0/210%20W%2019TH%20TER%20FL%201%2C?city=Kansas%20City&state=mo
```

And see:

```
{"code":200,"status":"success","message":"","data":{"id":200567,"single_line_address":"210 W 19TH TER FL 1, KANSAS CITY...
```

You should also be able to navigate to the api documentation:

```
http://dev-api.codeforkc.devel/api-docs
```

You should have access to [OGR Foreign Data Wrapper](https://github.com/pramsey/pgsql-ogr-fdw).

### Notes
We need to figure out how if we need sfcgal and address_standardizer and if so how to install them.

```sql
CREATE EXTENSION postgis_sfcgal;
CREATE EXTENSION address_standardizer;
```

# Installing `gh-pages` and Jekyll
Do this above the `address-api` directory, so both are at the same level.

1. Create clone of `address-api` and switch to the `gh-pages` branch

```
$ git clone git@github.com:zmon/address-api.git address-api-gh-pages
$ cd address-api-gh-pages
$ git remote add upstream git@github.com:codeforkansascity/address-api.git
$ git checkout gh-pages
```

2. Make it so your local git does not include CNAME by editing .git/info/exclude and adding the line

```
CNAME
```

2. Contect `address-api-gh-pages` to your virual box by editing the `Vagrantfile` in the `address-api` directory, and add the following line at about line 42.

```ruby
config.vm.synced_folder "../address-api-gh-pages", "/var/www/gh-pages"
```

3. Start or restart your Vagrant box from the `address-api` directory.

```
$ vagrant reload
```

4. Log into the Vagrant box.

```
$ vagrant ssh
```

5. Install Ruby 2.2.3

```
$ sudo su -
# rvm install ruby-2.2.3
# rvm use ruby-2.2.3 --default
# gem install jekyll
# sudo apt-get install ruby-dev
```

6. Start Jekyll

```
cd /var/www/gh-pages
jekyll serve --host 0.0.0.0
```

7. Now go view the site at `http://192.168.33.11:4000/`
