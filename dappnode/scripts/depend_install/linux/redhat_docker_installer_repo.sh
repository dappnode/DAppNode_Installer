#!/bin/bash

#
#
# install required packages
sudo yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2

# set up docker stable repository 
sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

#TODO: verify that the docker gpg key fingerprint matches the below fingerprint
# 060A 61C5 1B55 8A7F 742B 77AA C52F EB6B 621E 9F35
# exit with descriptrive error "Could not verify software integrity. The docker GPG key fingerprint did not match the docker repository GPG key fingerprint. Expected fingerprint: 060A 61C5 1B55 8A7F 742B 77AA C52F EB6B 621E 9F35      docker repository fingerprint: <fingerprint provided by docker repository>"

# install docker from the official docker repository
sudo yum install -y docker-ce-17.12.0.ce

echo "////////////////////////////////////////////////////////////////////"
echo "Docker 17.12 installed, starting service! \ Docker will not start when your CentOS starts, and will still be installed after generating the DappNode ISO."
echo "////////////////////////////////////////////////////////////////////"

# starting service. Docker will be configured 
sudo systemctl start docker

echo "********************************************************************"
echo "Docker is started and ready for generating the ISO."
echo "********************************************************************"

#TODO: set the echos of the status for the docker installation in verbose mode
