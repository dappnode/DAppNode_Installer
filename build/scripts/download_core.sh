#!/bin/bash

source ./.dappnode_profile

DAPPNODE_DIR="/images/"

BIND_URL="https://github.com/dappnode/DNP_BIND/releases/download/v${BIND_VERSION}/bind.dnp.dappnode.eth_${BIND_VERSION}.tar.xz"
IPFS_URL="https://github.com/dappnode/DNP_IPFS/releases/download/v${IPFS_VERSION}/ipfs.dnp.dappnode.eth_${IPFS_VERSION}.tar.xz"
ETHCHAIN_URL="https://github.com/dappnode/DNP_ETHCHAIN/releases/download/v${ETHCHAIN_VERSION}/ethchain.dnp.dappnode.eth_${ETHCHAIN_VERSION}.tar.xz"
ETHFORWARD_URL="https://github.com/dappnode/DNP_ETHFORWARD/releases/download/v${ETHFORWARD_VERSION}/ethforward.dnp.dappnode.eth_${ETHFORWARD_VERSION}.tar.xz"
VPN_URL="https://github.com/dappnode/DNP_VPN/releases/download/v${VPN_VERSION}/vpn.dnp.dappnode.eth_${VPN_VERSION}.tar.xz"
WAMP_URL="https://github.com/dappnode/DNP_WAMP/releases/download/v${WAMP_VERSION}/wamp.dnp.dappnode.eth_${WAMP_VERSION}.tar.xz"
DAPPMANAGER_URL="https://github.com/dappnode/DNP_DAPPMANAGER/releases/download/v${DAPPMANAGER_VERSION}/dappmanager.dnp.dappnode.eth_${DAPPMANAGER_VERSION}.tar.xz"
ADMIN_URL="https://github.com/dappnode/DNP_ADMIN/releases/download/v${ADMIN_VERSION}/admin.dnp.dappnode.eth_${ADMIN_VERSION}.tar.xz"

BIND_YML="https://github.com/dappnode/DNP_BIND/releases/download/v${BIND_VERSION}/docker-compose-bind.yml"
IPFS_YML="https://github.com/dappnode/DNP_IPFS/releases/download/v${IPFS_VERSION}/docker-compose-ipfs.yml"
ETHCHAIN_YML="https://github.com/dappnode/DNP_ETHCHAIN/releases/download/v${ETHCHAIN_VERSION}/docker-compose-ethchain.yml"
ETHFORWARD_YML="https://github.com/dappnode/DNP_ETHFORWARD/releases/download/v${ETHFORWARD_VERSION}/docker-compose-ethforward.yml"
VPN_YML="https://github.com/dappnode/DNP_VPN/releases/download/v${VPN_VERSION}/docker-compose-vpn.yml"
WAMP_YML="https://github.com/dappnode/DNP_WAMP/releases/download/v${WAMP_VERSION}/docker-compose-wamp.yml"
DAPPMANAGER_YML="https://github.com/dappnode/DNP_DAPPMANAGER/releases/download/v${DAPPMANAGER_VERSION}/docker-compose-dappmanager.yml"
ADMIN_YML="https://github.com/dappnode/DNP_ADMIN/releases/download/v${ADMIN_VERSION}/docker-compose-admin.yml"

BIND_YML_FILE="${DAPPNODE_DIR}docker-compose-bind.yml"
IPFS_YML_FILE="${DAPPNODE_DIR}docker-compose-ipfs.yml"
ETHCHAIN_YML_FILE="${DAPPNODE_DIR}docker-compose-ethchain.yml"
ETHFORWARD_YML_FILE="${DAPPNODE_DIR}docker-compose-ethforward.yml"
VPN_YML_FILE="${DAPPNODE_DIR}docker-compose-vpn.yml"
WAMP_YML_FILE="${DAPPNODE_DIR}docker-compose-wamp.yml"
DAPPMANAGER_YML_FILE="${DAPPNODE_DIR}docker-compose-dappmanager.yml"
ADMIN_YML_FILE="${DAPPNODE_DIR}docker-compose-admin.yml"

BIND_FILE="${DAPPNODE_DIR}bind.dnp.dappnode.eth_${BIND_VERSION}.tar.xz"
IPFS_FILE="${DAPPNODE_DIR}ipfs.dnp.dappnode.eth_${IPFS_VERSION}.tar.xz"
ETHCHAIN_FILE="${DAPPNODE_DIR}ethchain.dnp.dappnode.eth_${ETHCHAIN_VERSION}.tar.xz"
ETHFORWARD_FILE="${DAPPNODE_DIR}ethforward.dnp.dappnode.eth_${ETHFORWARD_VERSION}.tar.xz"
VPN_FILE="${DAPPNODE_DIR}vpn.dnp.dappnode.eth_${VPN_VERSION}.tar.xz"
WAMP_FILE="${DAPPNODE_DIR}wamp.dnp.dappnode.eth_${WAMP_VERSION}.tar.xz"
DAPPMANAGER_FILE="${DAPPNODE_DIR}dappmanager.dnp.dappnode.eth_${DAPPMANAGER_VERSION}.tar.xz"
ADMIN_FILE="${DAPPNODE_DIR}admin.dnp.dappnode.eth_${ADMIN_VERSION}.tar.xz"

dappnode_core_download()
{
    # Download DAppNode Core Images
    [ -f $BIND_FILE ] || wget -O $BIND_FILE $BIND_URL
    [ -f $IPFS_FILE ] || wget -O $IPFS_FILE $IPFS_URL
    [ -f $ETHCHAIN_FILE ] || wget -O $ETHCHAIN_FILE $ETHCHAIN_URL
    [ -f $ETHFORWARD_FILE ] || wget -O $ETHFORWARD_FILE $ETHFORWARD_URL
    [ -f $VPN_FILE ] || wget -O $VPN_FILE $VPN_URL
    [ -f $WAMP_FILE ] || wget -O $WAMP_FILE $WAMP_URL
    [ -f $DAPPMANAGER_FILE ] || wget -O $DAPPMANAGER_FILE $DAPPMANAGER_URL
    [ -f $ADMIN_FILE ] || wget -O $ADMIN_FILE $ADMIN_URL

    # Download DAppNode Core docker-compose yml files 
    [ -f $BIND_YML_FILE ] || wget -O $BIND_YML_FILE $BIND_YML
    [ -f $IPFS_YML_FILE ] || wget -O $IPFS_YML_FILE $IPFS_YML
    [ -f $ETHCHAIN_YML_FILE ] || wget -O $ETHCHAIN_YML_FILE $ETHCHAIN_YML
    [ -f $ETHFORWARD_YML_FILE ] || wget -O $ETHFORWARD_YML_FILE $ETHFORWARD_YML
    [ -f $VPN_YML_FILE ] || wget -O $VPN_YML_FILE $VPN_YML
    [ -f $WAMP_YML_FILE ] || wget -O $WAMP_YML_FILE $WAMP_YML
    [ -f $DAPPMANAGER_YML_FILE ] || wget -O $DAPPMANAGER_YML_FILE $DAPPMANAGER_YML
    [ -f $ADMIN_YML_FILE ] || wget -O $ADMIN_YML_FILE $ADMIN_YML

}

echo -e "\e[32mDownloading DAppNode Core...\e[0m"
dappnode_core_download

mkdir -p dappnode/DNCORE

echo -e "\e[32mCopying files...\e[0m"
cp /images/*.tar.xz dappnode/DNCORE
cp /images/*.yml dappnode/DNCORE
cp ./.dappnode_profile dappnode/DNCORE