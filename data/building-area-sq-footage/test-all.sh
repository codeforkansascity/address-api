#/bin/sh
echo "Step 1\n"
    sh setup-for-test.sh
    echo "Step 2 - Install\n"
    sudo -u postgres psql code4kc < install.sql
    echo "Step 3 - Load\n"
    ./load
