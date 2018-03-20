#!/bin/bash

# adding dependencies for docker.
sudo dnf -y install dnf-plugins-core

# adding docker repository for fedora
sudo dnf config-manager \
	--add-repo \
	https://download.docker.com/linux/fedora/docker-ce.repo

# installing docker
sudo dnf -y install docker-ce

#TODO: verify that the docker gpg key fingerprint matches the below fingerprint
# 060A 61C5 1B55 8A7F 742B 77AA C52F EB6B 621E 9F35
# exit with descriptrive error "Could not verify software integrity. The docker 
# GPG key fingerprint did not match the docker repository GPG key fingerprint.  
# Expected fingerprint: 060A 61C5 1B55 8A7F 742B 77AA C52F EB6B 621E 9F35  
# docker repository fingerprint: <fingerprint provided by docker repository>"

# start docker service
sudo systemctl start docker

# change docker permissions
usermod -aG docker $USER

echo "Finished installing docker for Fedora!"
