
    sh setup-for-test.sh
    sudo -u postgres psql code4kc < install.sql
    cp Legal-Aid-Data-Request-2-26-19.xlsx /tmp
    ./load
