#!/bin/bash

DAPPNODE_DIR="/usr/src/dappnode/"
DAPPNODE_CORE_DIR="${DAPPNODE_DIR}DNCORE/"
LOG_DIR="${DAPPNODE_DIR}dappnode_install.log"

mkdir -p $DAPPNODE_DIR
mkdir -p $DAPPNODE_CORE_DIR

VERSION_URL="https://raw.githubusercontent.com/dappnode/DN_ISO_Generator/master/build/scripts/versions.sh"
VERSION_FILE="${DAPPNODE_CORE_DIR}scripts/versions.sh" 
[ -f $VERSION_FILE ] || wget -q --show-progress -O $VERSION_FILE $VERSION_URL 2>&1 | tee -a $LOG_DIR

source "${VERSION_FILE}"

###### When incorporating the images from IPFS:
# echo $URL_LIST | xargs -n 1 -P 8 wget -q --show-progress -q
# ref: https://stackoverflow.com/questions/7577615/parallel-wget-in-bash

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

BIND_YML_FILE="${DAPPNODE_CORE_DIR}docker-compose-bind.yml"
IPFS_YML_FILE="${DAPPNODE_CORE_DIR}docker-compose-ipfs.yml"
ETHCHAIN_YML_FILE="${DAPPNODE_CORE_DIR}docker-compose-ethchain.yml"
ETHFORWARD_YML_FILE="${DAPPNODE_CORE_DIR}docker-compose-ethforward.yml"
VPN_YML_FILE="${DAPPNODE_CORE_DIR}docker-compose-vpn.yml"
WAMP_YML_FILE="${DAPPNODE_CORE_DIR}docker-compose-wamp.yml"
DAPPMANAGER_YML_FILE="${DAPPNODE_CORE_DIR}docker-compose-dappmanager.yml"
ADMIN_YML_FILE="${DAPPNODE_CORE_DIR}docker-compose-admin.yml"

BIND_FILE="${DAPPNODE_CORE_DIR}bind.dnp.dappnode.eth_${BIND_VERSION}.tar.xz"
IPFS_FILE="${DAPPNODE_CORE_DIR}ipfs.dnp.dappnode.eth_${IPFS_VERSION}.tar.xz"
ETHCHAIN_FILE="${DAPPNODE_CORE_DIR}ethchain.dnp.dappnode.eth_${ETHCHAIN_VERSION}.tar.xz"
ETHFORWARD_FILE="${DAPPNODE_CORE_DIR}ethforward.dnp.dappnode.eth_${ETHFORWARD_VERSION}.tar.xz"
VPN_FILE="${DAPPNODE_CORE_DIR}vpn.dnp.dappnode.eth_${VPN_VERSION}.tar.xz"
WAMP_FILE="${DAPPNODE_CORE_DIR}wamp.dnp.dappnode.eth_${WAMP_VERSION}.tar.xz"
DAPPMANAGER_FILE="${DAPPNODE_CORE_DIR}dappmanager.dnp.dappnode.eth_${DAPPMANAGER_VERSION}.tar.xz"
ADMIN_FILE="${DAPPNODE_CORE_DIR}admin.dnp.dappnode.eth_${ADMIN_VERSION}.tar.xz"


dappnode_core_download()
{
    # Download DAppNode Core Images if it is need it
    [ -f $BIND_FILE ] || wget -q --show-progress -O $BIND_FILE $BIND_URL 2>&1 | tee -a $LOG_DIR
    [ -f $IPFS_FILE ] || wget -q --show-progress -O $IPFS_FILE $IPFS_URL 2>&1 | tee -a $LOG_DIR
    [ -f $ETHCHAIN_FILE ] || wget -q --show-progress -O $ETHCHAIN_FILE $ETHCHAIN_URL 2>&1 | tee -a $LOG_DIR
    [ -f $ETHFORWARD_FILE ] || wget -q --show-progress -O $ETHFORWARD_FILE $ETHFORWARD_URL 2>&1 | tee -a $LOG_DIR
    [ -f $VPN_FILE ] || wget -q --show-progress -O $VPN_FILE $VPN_URL 2>&1 | tee -a $LOG_DIR
    [ -f $WAMP_FILE ] || wget -q --show-progress -O $WAMP_FILE $WAMP_URL 2>&1 | tee -a $LOG_DIR
    [ -f $DAPPMANAGER_FILE ] || wget -O $DAPPMANAGER_FILE $DAPPMANAGER_URL 2>&1 | tee -a $LOG_DIR
    [ -f $ADMIN_FILE ] || wget -O $ADMIN_FILE $ADMIN_URL 2>&1 | tee -a $LOG_DIR

    # Download DAppNode Core docker-compose yml files if it is need it
    [ -f $BIND_YML_FILE ] || wget -q --show-progress -O $BIND_YML_FILE $BIND_YML 2>&1 | tee -a $LOG_DIR
    [ -f $IPFS_YML_FILE ] || wget -q --show-progress -O $IPFS_YML_FILE $IPFS_YML 2>&1 | tee -a $LOG_DIR
    [ -f $ETHCHAIN_YML_FILE ] || wget -q --show-progress -O $ETHCHAIN_YML_FILE $ETHCHAIN_YML 2>&1 | tee -a $LOG_DIR
    [ -f $ETHFORWARD_YML_FILE ] || wget -q --show-progress -O $ETHFORWARD_YML_FILE $ETHFORWARD_YML 2>&1 | tee -a $LOG_DIR
    [ -f $VPN_YML_FILE ] || wget -q --show-progress -O $VPN_YML_FILE $VPN_YML 2>&1 | tee -a $LOG_DIR
    [ -f $WAMP_YML_FILE ] || wget -q --show-progress -O $WAMP_YML_FILE $WAMP_YML 2>&1 | tee -a $LOG_DIR
    [ -f $DAPPMANAGER_YML_FILE ] || wget -O $DAPPMANAGER_YML_FILE $DAPPMANAGER_YML 2>&1 | tee -a $LOG_DIR
    [ -f $ADMIN_YML_FILE ] || wget -O $ADMIN_YML_FILE $ADMIN_YML 2>&1 | tee -a $LOG_DIR

}

dappnode_core_load()
{

    [ ! -z $(docker images -q bind.dnp.dappnode.eth:${BIND_VERSION}) ] || docker load -i $BIND_FILE 2>&1 | tee -a $LOG_DIR
    [ ! -z $(docker images -q ipfs.dnp.dappnode.eth:${IPFS_VERSION}) ] || docker load -i $IPFS_FILE 2>&1 | tee -a $LOG_DIR
    [ ! -z $(docker images -q ethchain.dnp.dappnode.eth:${ETHCHAIN_VERSION}) ] || docker load -i $ETHCHAIN_FILE 2>&1 | tee -a $LOG_DIR
    [ ! -z $(docker images -q ethforward.dnp.dappnode.eth:${ETHFORWARD_VERSION}) ] || docker load -i $ETHFORWARD_FILE 2>&1 | tee -a $LOG_DIR
    [ ! -z $(docker images -q vpn.dnp.dappnode.eth:${VPN_VERSION}) ] || docker load -i $VPN_FILE 2>&1 | tee -a $LOG_DIR
    [ ! -z $(docker images -q wamp.dnp.dappnode.eth:${WAMP_VERSION}) ] || docker load -i $WAMP_FILE 2>&1 | tee -a $LOG_DIR
    [ ! -z $(docker images -q dappmanager.dnp.dappnode.eth:${DAPPMANAGER_VERSION}) ] || docker load -i $DAPPMANAGER_FILE 2>&1 | tee -a $LOG_DIR
    [ ! -z $(docker images -q admin.dnp.dappnode.eth:${ADMIN_VERSION}) ] || docker load -i $ADMIN_FILE 2>&1 | tee -a $LOG_DIR

    # Delete build line frome yml
    sed -i '/build: \.\/build/d' $DAPPNODE_CORE_DIR/*.yml 2>&1 | tee -a $LOG_DIR
   
    # Delete dappnode_install.sh execution from rc.local
    sed -i '/\/usr\/src\/dappnode\/scripts\/dappnode_install.sh/d' /etc/rc.local 2>&1 | tee -a $LOG_DIR

    # Show credentials to the user on login
    USER=$(cat /etc/passwd | grep 1000  | cut -f 1 -d:)
    echo "docker exec -it DAppNodeCore-vpn.dnp.dappnode.eth getAdminCredentials" >> /home/$USER/.profile
    echo "echo -e \"\n\e[32mOnce connected through the VPN (L2TP/IPSec) you can access to the administration console by following this link:\e[0m\"" >> /home/$USER/.profile
    echo "echo -e \"\nhttp://my.admin.dnp.dappnode.eth/\n\"" >> /home/$USER/.profile

}

##############################################
##############################################
####             SCRIPT START             ####
##############################################
##############################################

echo -e "\e[32m##############################################\e[0m" 2>&1 | tee -a $LOG_DIR
echo -e "\e[32m##############################################\e[0m" 2>&1 | tee -a $LOG_DIR
echo -e "\e[32m####          DAPPNODE INSTALLER          ####\e[0m" 2>&1 | tee -a $LOG_DIR
echo -e "\e[32m##############################################\e[0m" 2>&1 | tee -a $LOG_DIR
echo -e "\e[32m##############################################\e[0m" 2>&1 | tee -a $LOG_DIR

echo -e "\e[32mDownloading DAppNode Core...\e[0m" 2>&1 | tee -a $LOG_DIR
dappnode_core_download

echo -e "\e[32mLoading DAppNode Core...\e[0m" 2>&1 | tee -a $LOG_DIR    
dappnode_core_load

echo -e "\e[32mDAppNode installed\e[0m" 2>&1 | tee -a $LOG_DIR

echo -e "\e[32mDAppNode starting...\e[0m" 2>&1 | tee -a $LOG_DIR
docker-compose -f $BIND_YML_FILE -f $IPFS_YML_FILE -f $ETHCHAIN_YML_FILE -f $ETHFORWARD_YML_FILE -f $VPN_YML_FILE -f $WAMP_YML_FILE -f $DAPPMANAGER_YML_FILE -f $ADMIN_YML_FILE up -d 2>&1 | tee -a $LOG_DIR
echo -e "\e[32mDAppNode started\e[0m" 2>&1 | tee -a $LOG_DIR
