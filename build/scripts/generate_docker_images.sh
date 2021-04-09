#!/bin/bash

source ./.dappnode_profile

echo "Cleaning previous files"
rm -rf ./DNP_*

echo "Cloning & building DNP_VPN..."
git clone -b "v${VPN_VERSION}" https://github.com/dappnode/DNP_VPN
docker-compose -f ./DNP_VPN/docker-compose-vpn.yml build
docker save vpn.dnp.dappnode.eth:${VPN_VERSION} | xz -e9vT0 >/images/vpn.dnp.dappnode.eth_${VPN_VERSION}_linux-amd64.txz

echo "Cloning & building DNP_HTTPS..."
git clone -b "v${HTTPS_VERSION}" https://github.com/dappnode/DNP_HTTPS
docker-compose -f ./DNP_HTTPS/docker-compose-https.yml build
docker save https.dnp.dappnode.eth:${HTTPS_VERSION} | xz -e9vT0 >/images/https.dnp.dappnode.eth_${HTTPS_VERSION}_linux-amd64.txz

echo "Cloning & building DNP_IPFS..."
git clone -b "v${IPFS_VERSION}" https://github.com/dappnode/DNP_IPFS
docker-compose -f ./DNP_IPFS/docker-compose-ipfs.yml build
docker save ipfs.dnp.dappnode.eth:${IPFS_VERSION} | xz -e9vT0 >/images/ipfs.dnp.dappnode.eth_${IPFS_VERSION}_linux-amd64.txz

echo "Cloning & building DNP_BIND..."
git clone -b "v${BIND_VERSION}" https://github.com/dappnode/DNP_BIND
docker-compose -f ./DNP_BIND/docker-compose-bind.yml build
docker save bind.dnp.dappnode.eth:${BIND_VERSION} | xz -e9vT0 >/images/bind.dnp.dappnode.eth_${BIND_VERSION}_linux-amd64.txz

echo "Cloning & building DNP_DAPPMANAGER..."
git clone -b "v${DAPPMANAGER_VERSION}" https://github.com/dappnode/DNP_DAPPMANAGER
docker-compose -f ./DNP_DAPPMANAGER/docker-compose-dappmanager.yml build
docker save dappmanager.dnp.dappnode.eth:${DAPPMANAGER_VERSION} | xz -e9vT0 >/images/dappmanager.dnp.dappnode.eth_${DAPPMANAGER_VERSION}_linux-amd64.txz

echo "Coping dappnode_all_docker_images_linux-amd64.txz to dappnode dir..."
cp /images/* dappnode/

echo "Finished!"
