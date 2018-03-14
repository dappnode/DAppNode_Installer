#!/bin/bash
apt-get update 2>&1

#Install necessary libs
dpkg -i /usr/src/dappnode/libs/aufs-tools_1%3a3.2+20130722-1.1ubuntu1_amd64.deb
dpkg -i /usr/src/dappnode/libs/cgroupfs-mount_1.2_all.deb
dpkg -i /usr/src/dappnode/libs/libltdl7_2.4.6-0.1_amd64.deb

#Install docker
dpkg -i /usr/src/dappnode/docker/docker-ce_17.12.0~ce-0~ubuntu_amd64.deb

HOSTNAME=$(cat /etc/hostname)
USER=$(cat /etc/passwd | grep 1000  | cut -f 1 -d:)
usermod -aG docker $USER
printf "$USER:$(openssl passwd -1 -salt AlHYrEQp $USER@$HOSTNAME)\n" > /usr/src/dappnode/htpasswd
