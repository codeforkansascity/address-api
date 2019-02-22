# Code for KC Address API - Script to build Vagrant Box

This will create an address-api.box that is uploaded to the Google Drive for the install at 
[https://github.com/codeforkansascity/address-api/tree/master/INSTALL](https://github.com/codeforkansascity/address-api/tree/master/INSTALL)

1. Clone this repo and change directory to the clone.
   1. If you are using this for a non address api project remove the two lines in Vagrantfile 
   ````
   config.vm.synced_folder "../address-api-gh-pages", "/var/www/gh-pages",...
   ````
1. Create the image

````
vagrant up
````

2. Login to the box

````
vagrant ssh
````

3. Test the image
All of the following should produce output.  
I did have a problem with the entry at the bottom of `/etc/bash.bashrc` that should be fixed.

````
pg_config --version
psql --version
ogrinfo --formats | grep -i OpenFileGDB
ogr_fdw_info -f | grep -i OpenFileGDB
ogr2ogr --version
sudo -u postgres psql code4kc -c 'SELECT PostGIS_full_version();'
sudo -u postgres psql code4kc -c 'SELECT PostGIS_Lib_Version();'
````

4. Logout

````
exit
````

5. Repackage the VM into a new Box

````
vagrant package --output address-api.box
````


6. Add new box into Vagrant, you may need to remove and existing one.

````
vagrant box add address-api address-api.box
````

7. In another directory follow the install instructions at [address-api](https://github.com/codeforkansascity/address-api/tree/master/INSTALL) skipping the add vagrant box step.

8. If the test works, then copy the `address-api.box` to the google drive https://drive.google.com/drive/u/0/folders/0B1F5BJsDsPCXb2NYSmxCT09TX1k


Most of this is from [How to Create a Vagrant Base Box from an Existing One](https://scotch.io/tutorials/how-to-create-a-vagrant-base-box-from-an-existing-one)
