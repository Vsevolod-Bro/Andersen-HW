#!/bin/bash

# prevent messages
apt-get remove apt-listchanges --assume-yes --force-yes
export DEBIAN_FRONTEND=noninteractive
export APT_LISTCHANGES_FRONTEND=none

# Update and Upgrade without interacting
apt-get -qy update
apt-get --force-yes \
 -o Dpkg::Options::="--force-confold" --force-yes \
 -o Dpkg::Options::="--force-confdef" -fuy \
 upgrade &&
apt-get --force-yes \
 -o Dpkg::Options::="--force-confold" --force-yes \
 -o Dpkg::Options::="--force-confdef" -fuy \
 dist-upgrade

# Clean
apt-get -qy autoclean
