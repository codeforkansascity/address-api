
# Backup DB

sudo su - postgres
sh doit
exit

# Make SQL updates - add new table areas and add fields.

sudo -u postgres psql code4kc < install.sql


Install Cron

test

/var/www/data/KCMO-Other/load  | mail -s "KCMO-land-bank-parcels" paulb@savagesoft.com 