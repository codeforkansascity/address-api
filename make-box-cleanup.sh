#!/bin/sh
#
# Used to clean up box before packaging
#
# From https://scotch.io/tutorials/how-to-create-a-vagrant-base-box-from-an-existing-one
#
sudo apt-get clean
sudo dd if=/dev/zero of=/EMPTY bs=1M
sudo rm -f /EMPTY
