#!/bin/bash
apt-get update 2>&1

#Install necessary libs
dpkg -i /usr/src/dappnode/libs/linux/debian/aufs-tools_1%3a3.2+20130722-1.1ubuntu1_amd64.deb
dpkg -i /usr/src/dappnode/libs/linux/debian/cgroupfs-mount_1.2_all.deb
dpkg -i /usr/src/dappnode/libs/linux/debian/libltdl7_2.4.6-0.1_amd64.deb

#Install docker
dpkg -i /usr/src/dappnode/bin/docker/docker-ce_17.12.0~ce-0~ubuntu_amd64.deb


USER=$(cat /etc/passwd | grep 1000  | cut -f 1 -d:)
usermod -aG docker $USER
