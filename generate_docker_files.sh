#!/bin/bash

echo "Cleaning previous files"
rm -rf ./DNP_*

echo "Cloning & building DNP_VPN..."
git clone https://github.com/dappnode/DNP_VPN
docker-compose -f ./DNP_VPN/docker-compose.yml build 

echo "Cloning & building DNP_PROVISIONING..."
git clone https://github.com/dappnode/DNP_PROVISIONING
docker-compose -f ./DNP_PROVISIONING/docker-compose.yml build 

echo "Cloning & building DNP_IPFS..."
git clone https://github.com/dappnode/DNP_IPFS
docker-compose -f ./DNP_IPFS/docker-compose.yml build 

echo "Cloning & building DNP_ETHCHAIN..."
git clone https://github.com/dappnode/DNP_ETHCHAIN
docker-compose -f ./DNP_ETHCHAIN/docker-compose.yml build 

echo "Cloning & building DNP_INSTALLER..."
git clone https://github.com/dappnode/DNP_INSTALLER
docker-compose -f ./DNP_INSTALLER/docker-compose.yml build 

echo "Cloning & building DNP_ETHFORWARD..."
git clone https://github.com/dappnode/DNP_ETHFORWARD
docker-compose -f ./DNP_ETHFORWARD/docker-compose.yml build 

echo "Cloning & building DNP_BIND..."
git clone https://github.com/dappnode/DNP_BIND
docker-compose -f ./DNP_BIND/docker-compose.yml build 

echo "Creating necessary dirs"
mkdir images

docker save \
dnp_bind:dev \
dnp_ethforward:dev  \
dnp_vpn:dev \
dnp_ipfs:dev \
dnp_provisioning:dev \
dnp_ethchain:dev \
dnp_installer:dev | \
xz > images/dappnode_all_docker_images.tar.xz

echo "Coping dappnode_all_docker_images.tar.xz to DPS dir..."
cp images/dappnode_all_docker_images.tar.xz dappnode/dappnode_all_docker_images.tar.xz

echo "Finished!"