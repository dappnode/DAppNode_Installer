#!/bin/bash

###### When incorporating the images from IPFS:
# echo $URL_LIST | xargs -n 1 -P 8 wget -q --show-progress -q
# ref: https://stackoverflow.com/questions/7577615/parallel-wget-in-bash

DAPPNODE_DIR="/usr/src/dappnode/DNCORE/"

mkdir -p $DAPPNODE_DIR

  # FOR PRODUCTION: Replace links with IPFS
  CORE_URL="https://raw.githubusercontent.com/dappnode/DNCORE/master/docker-compose.yml"

# If the versions file exists we should use its values
if [ ! -f versions.sh ]; then
    BIND_VERSION="0.1.0"
    IPFS_VERSION="0.1.0"
    ETHCHAIN_VERSION="0.1.1"
    ETHFORWARD_VERSION="0.1.0"
    VPN_VERSION="0.1.0"
    WAMP_VERSION="0.1.0"
else
    source versions.sh
fi

BIND_URL="https://github.com/dappnode/DNP_BIND/releases/download/v${BIND_VERSION}/bind.dnp.dappnode.eth_${BIND_VERSION}.tar.xz"
IPFS_URL="https://github.com/dappnode/DNP_IPFS/releases/download/v${IPFS_VERSION}/ipfs.dnp.dappnode.eth_${IPFS_VERSION}.tar.xz"
ETHCHAIN_URL="https://github.com/dappnode/DNP_ETHCHAIN/releases/download/v${ETHCHAIN_VERSION}/ethchain.dnp.dappnode.eth_${ETHCHAIN_VERSION}.tar.xz"
ETHFORWARD_URL="https://github.com/dappnode/DNP_ETHFORWARD/releases/download/v${ETHFORWARD_VERSION}/ethforward.dnp.dappnode.eth_${ETHFORWARD_VERSION}.tar.xz"
VPN_URL="https://github.com/dappnode/DNP_VPN/releases/download/v${VPN_VERSION}/vpn.dnp.dappnode.eth_${VPN_VERSION}.tar.xz"
WAMP_URL="https://github.com/dappnode/DNP_WAMP/releases/download/v${WAMP_VERSION}/wamp.dnp.dappnode.eth_${WAMP_VERSION}.tar.xz"

BIND_YML="https://github.com/dappnode/DNP_BIND/releases/download/v${BIND_VERSION}/docker-compose-bind.yml"
IPFS_YML="https://github.com/dappnode/DNP_IPFS/releases/download/v${IPFS_VERSION}/docker-compose-ipfs.yml"
ETHCHAIN_YML="https://github.com/dappnode/DNP_ETHCHAIN/releases/download/v${ETHCHAIN_VERSION}/docker-compose-ethchain.yml"
ETHFORWARD_YML="https://github.com/dappnode/DNP_ETHFORWARD/releases/download/v${ETHFORWARD_VERSION}/docker-compose-ethforward.yml"
VPN_YML="https://github.com/dappnode/DNP_VPN/releases/download/v${VPN_VERSION}/docker-compose-vpn.yml"
WAMP_YML="https://github.com/dappnode/DNP_WAMP/releases/download/v${WAMP_VERSION}/docker-compose-wamp.yml"

BIND_YML_FILE="${DAPPNODE_DIR}docker-compose-bind.yml"
IPFS_YML_FILE="${DAPPNODE_DIR}docker-compose-ipfs.yml"
ETHCHAIN_YML_FILE="${DAPPNODE_DIR}docker-compose-ethchain.yml"
ETHFORWARD_YML_FILE="${DAPPNODE_DIR}docker-compose-ethforward.yml"
VPN_YML_FILE="${DAPPNODE_DIR}docker-compose-vpn.yml"
WAMP_YML_FILE="${DAPPNODE_DIR}docker-compose-wamp.yml"

BIND_FILE="${DAPPNODE_DIR}bind.dnp.dappnode.eth_${BIND_VERSION}.tar.xz"
IPFS_FILE="${DAPPNODE_DIR}ipfs.dnp.dappnode.eth_${IPFS_VERSION}.tar.xz"
ETHCHAIN_FILE="${DAPPNODE_DIR}ethchain.dnp.dappnode.eth_${ETHCHAIN_VERSION}.tar.xz"
ETHFORWARD_FILE="${DAPPNODE_DIR}ethforward.dnp.dappnode.eth_${ETHFORWARD_VERSION}.tar.xz"
VPN_FILE="${DAPPNODE_DIR}vpn.dnp.dappnode.eth_${VPN_VERSION}.tar.xz"
WAMP_FILE="${DAPPNODE_DIR}wamp.dnp.dappnode.eth_${WAMP_VERSION}.tar.xz"

dappnode_core_download()
{
    # STEP 1: Download files if not exist
    # ----------------------------------------
    [ -f $BIND_FILE ] || wget -q --show-progress -O $BIND_FILE $BIND_URL >/dev/tty 2>&1
    [ -f $IPFS_FILE ] || wget -q --show-progress -O $IPFS_FILE $IPFS_URL >/dev/tty 2>&1
    [ -f $ETHCHAIN_FILE ] || wget -q --show-progress -O $ETHCHAIN_FILE $ETHCHAIN_URL  >/dev/tty 2>&1
    [ -f $ETHFORWARD_FILE ] || wget -q --show-progress -O $ETHFORWARD_FILE $ETHFORWARD_URL >/dev/tty 2>&1
    [ -f $VPN_FILE ] || wget -q --show-progress -O $VPN_FILE $VPN_URL >/dev/tty 2>&1
    [ -f $WAMP_FILE ] || wget -q --show-progress -O $WAMP_FILE $WAMP_URL >/dev/tty 2>&1

    [ -f $BIND_YML_FILE ] || wget -q --show-progress -O $BIND_YML_FILE $BIND_YML >/dev/tty 2>&1
    [ -f $IPFS_YML_FILE ] || wget -q --show-progress -O $IPFS_YML_FILE $IPFS_YML >/dev/tty 2>&1
    [ -f $ETHCHAIN_YML_FILE ] || wget -q --show-progress -O $ETHCHAIN_YML_FILE $ETHCHAIN_YML >/dev/tty 2>&1
    [ -f $ETHFORWARD_YML_FILE ] || wget -q --show-progress -O $ETHFORWARD_YML_FILE $ETHFORWARD_YML >/dev/tty 2>&1
    [ -f $VPN_YML_FILE ] || wget -q --show-progress -O $VPN_YML_FILE $VPN_YML >/dev/tty 2>&1
    [ -f $WAMP_YML_FILE ] || wget -q --show-progress -O $WAMP_YML_FILE $WAMP_YML >/dev/tty 2>&1
}

dappnode_core_load()
{

    [ ! -z $(docker images -q bind.dnp.dappnode.eth:${BIND_VERSION}) ] || docker load -i $BIND_FILE >/dev/tty 2>&1
    [ ! -z $(docker images -q ipfs.dnp.dappnode.eth:${IPFS_VERSION}) ] || docker load -i $IPFS_FILE >/dev/tty 2>&1
    [ ! -z $(docker images -q ethchain.dnp.dappnode.eth:${ETHCHAIN_VERSION}) ] || docker load -i $ETHCHAIN_FILE >/dev/tty 2>&1
    [ ! -z $(docker images -q ethforward.dnp.dappnode.eth:${ETHFORWARD_VERSION}) ] || docker load -i $ETHFORWARD_FILE >/dev/tty 2>&1
    [ ! -z $(docker images -q vpn.dnp.dappnode.eth:${VPN_VERSION}) ] || docker load -i $VPN_FILE >/dev/tty 2>&1
    [ ! -z $(docker images -q wamp.dnp.dappnode.eth:${WAMP_VERSION}) ] || docker load -i $WAMP_FILE >/dev/tty 2>&1

    # Delete build line frome yml
    sed -i '/build: \.\/build/d' $DAPPNODE_DIR/*.yml >/dev/tty 2>&1
}



##############################################
##############################################
####             SCRIPT START             ####
##############################################
##############################################

echo -e "\e[32m##############################################\e[0m" >/dev/tty 2>&1
echo -e "\e[32m##############################################\e[0m" >/dev/tty 2>&1
echo -e "\e[32m####          DAPPNODE INSTALLER          ####\e[0m" >/dev/tty 2>&1
echo -e "\e[32m##############################################\e[0m" >/dev/tty 2>&1
echo -e "\e[32m##############################################\e[0m" >/dev/tty 2>&1

echo -e "\e[32mDownloading DAppNode Core...\e[0m" >/dev/tty 2>&1
dappnode_core_download

echo -e "\e[32mLoading DAppNode Core...\e[0m" >/dev/tty 2>&1    
dappnode_core_load

echo -e "\e[32mDAppNode installed\e[0m" >/dev/tty 2>&1

echo -e "\e[32mDAppNode starting...\e[0m" >/dev/tty 2>&1
docker-compose -f $BIND_YML_FILE -f $IPFS_YML_FILE -f $ETHCHAIN_YML_FILE -f $ETHFORWARD_YML_FILE -f $VPN_YML_FILE -f $WAMP_YML_FILE up -d >/dev/tty 2>&1

echo -e "\e[32mDAppNode started\e[0m" >/dev/tty 2>&1

# Give credentials to the user to connect
docker exec -it DAppNodeCore-vpn.dnp.dappnode.eth getAdminCredentials >/dev/tty 2>&1