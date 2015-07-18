
# Sample Apache Configuration

````
# -----------------------------------------------
# ADDRESS_API.CODEFORKC.ORG
# -----------------------------------------------
<VirtualHost *:80>
    ServerName address_api.codeforkc.org
    DocumentRoot /var/www/address_api.org/webroot
    DirectoryIndex index.php

    Header set Access-Control-Allow-Origin "*"
    Header set Access-Control-Allow-Credentials true
    Header set Access-Control-Allow-Methods "POST, GET, OPTIONS"

    <Directory "/var/www/address_api.org/webroot/">
       RewriteEngine On
       RewriteCond %{REQUEST_FILENAME} !-d
       RewriteCond %{REQUEST_FILENAME} !-f
       RewriteRule ^(.*)$ index.php?url=$1 [QSA,L]
       Options -Indexes FollowSymLinks
       Order allow,deny
       Allow from all
    </Directory>

</VirtualHost>
````
