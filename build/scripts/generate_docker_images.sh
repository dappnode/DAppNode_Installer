#!/bin/bash

source ./.dappnode_profile

echo "Cleaning previous files"
rm -rf ./DNP_*

echo "Cloning & building DNP_VPN..."
git clone -b "v${VPN_VERSION}" https://github.com/dappnode/DNP_VPN
docker-compose -f ./DNP_VPN/docker-compose-vpn.yml build
docker save vpn.dnp.dappnode.eth:${VPN_VERSION} | xz -e9vT0 > /images/vpn.dnp.dappnode.eth_${VPN_VERSION}.tar.xz

echo "Cloning & building DNP_IPFS..."
git clone -b "v${IPFS_VERSION}" https://github.com/dappnode/DNP_IPFS
docker-compose -f ./DNP_IPFS/docker-compose-ipfs.yml build 
docker save ipfs.dnp.dappnode.eth:${IPFS_VERSION} | xz -e9vT0 > /images/ipfs.dnp.dappnode.eth_${IPFS_VERSION}.tar.xz

echo "Cloning & building DNP_ETHCHAIN..."
git clone -b "v${ETHCHAIN_VERSION}" https://github.com/dappnode/DNP_ETHCHAIN
docker-compose -f ./DNP_ETHCHAIN/docker-compose-ethchain.yml build
docker save ethchain.dnp.dappnode.eth:${ETHCHAIN_VERSION} | xz -e9vT0 > /images/ethchain.dnp.dappnode.eth_${ETHCHAIN_VERSION}.tar.xz

echo "Cloning & building DNP_ETHFORWARD..."
git clone -b "v${ETHFORWARD_VERSION}" https://github.com/dappnode/DNP_ETHFORWARD
docker-compose -f ./DNP_ETHFORWARD/docker-compose-ethforward.yml build 
docker save ethforward.dnp.dappnode.eth:${ETHFORWARD_VERSION} | xz -e9vT0 > /images/ethforward.dnp.dappnode.eth_${ETHFORWARD_VERSION}.tar.xz

echo "Cloning & building DNP_BIND..."
git clone -b "v${BIND_VERSION}" https://github.com/dappnode/DNP_BIND
docker-compose -f ./DNP_BIND/docker-compose-bind.yml build 
docker save bind.dnp.dappnode.eth:${BIND_VERSION} | xz -e9vT0 > /images/bind.dnp.dappnode.eth_${BIND_VERSION}.tar.xz

echo "Cloning & building DNP_WAMP..."
git clone -b "v${WAMP_VERSION}" https://github.com/dappnode/DNP_WAMP
docker-compose -f ./DNP_WAMP/docker-compose-wamp.yml build 
docker save wamp.dnp.dappnode.eth:${WAMP_VERSION} | xz -e9vT0 > /images/wamp.dnp.dappnode.eth_${WAMP_VERSION}.tar.xz

echo "Cloning & building DNP_DAPPMANAGER..."
git clone -b "v${DAPPMANAGER_VERSION}" https://github.com/dappnode/DNP_DAPPMANAGER
docker-compose -f ./DNP_DAPPMANAGER/docker-compose-dappmanager.yml build 
docker save dappmanager.dnp.dappnode.eth:${DAPPMANAGER_VERSION} | xz -e9vT0 > /images/dappmanager.dnp.dappnode.eth_${DAPPMANAGER_VERSION}.tar.xz

echo "Cloning & building DNP_ADMIN..."
git clone -b "v${ADMIN_VERSION}" https://github.com/dappnode/DNP_ADMIN
docker-compose -f ./DNP_ADMIN/docker-compose-admin.yml build 
docker save admin.dnp.dappnode.eth:${ADMIN_VERSION} | xz -e9vT0 > /images/admin.dnp.dappnode.eth_${ADMIN_VERSION}.tar.xz

echo "Coping dappnode_all_docker_images.tar.xz to dappnode dir..."
cp /images/* dappnode/

echo "Finished!"
