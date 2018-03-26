#!/bin/sh

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

echo "Saving images... (it takes some time)"
docker save \
dappnode/dnp_bind \
dappnode/dnp_ethforward  \
dappnode/dnp_vpn \
dappnode/dnp_ipfs \
dappnode/dnp_provisioning \
dappnode/dnp_ethchain \
dappnode/dnp_installer | \
xz > /images/dappnode_all_docker_images.tar.xz

echo "Coping dappnode_all_docker_images.tar.xz to dappnode dir..."
cp /images/dappnode_all_docker_images.tar.xz dappnode/dappnode_all_docker_images.tar.xz

echo "Finished!"