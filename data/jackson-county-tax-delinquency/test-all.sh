    sh setup-for-test.sh 
    sudo -u postgres psql code4kc < install.sql 
    cp tax.csv /tmp
    ./load
