#!/bin/bash

##########################
# dappnode_install_pre.sh#
##########################

# Docker should be uninstalled
apt-get purge docker-ce docker-ce-cli containerd.io

# Create necessary folder
mkdir -p /etc/network/
echo "iface en.x inet dhcp" >> /etc/network/interfaces