#!/bin/bash


DAPPNODE_DIR="/usr/src/dappnode/"
DAPPNODE_CORE_DIR="${DAPPNODE_DIR}DNCORE/"

mkdir -p $DAPPNODE_DIR
mkdir -p $DAPPNODE_CORE_DIR
mkdir -p "${DAPPNODE_CORE_DIR}scripts"

PROFILE_BRANCH="v0.2.0-alpha"
PROFILE_URL="https://raw.githubusercontent.com/dappnode/DAppNode_Installer/${PROFILE_BRANCH}/build/scripts/.dappnode_profile"
PROFILE_FILE="${DAPPNODE_CORE_DIR}scripts/.dappnode_profile"

[ -f $PROFILE_FILE ] || wget -q --show-progress -O $PROFILE_FILE $PROFILE_URL 2>&1 | tee -a $LOG_DIR

source "${PROFILE_FILE}"

# Remove DAppNodePackages
find /var/lib/docker/volumes/dncore_dappmanagerdnpdappnodeeth_data/_data -name "*yml"  | xargs -I {} docker-compose -f {} down  --rmi 'all' -v

# Disconnect all packages from the network
docker container ls -a -q -f name=DAppNode* | xargs -I {} docker network disconnect dncore_network {}

# Remove containers, volumes and images
docker-compose -f $BIND_YML_FILE -f $IPFS_YML_FILE -f $ETHCHAIN_YML_FILE -f $ETHFORWARD_YML_FILE -f $VPN_YML_FILE -f $WAMP_YML_FILE -f $DAPPMANAGER_YML_FILE -f $ADMIN_YML_FILE -f $WIFI_YML_FILE down  --rmi 'all' -v

# Remove dir
rm -rf /usr/src/dappnode

# Remove profile file
USER=$(cat /etc/passwd | grep 1000  | cut -f 1 -d:)
[ ! -z $USER ] && PROFILE=/home/$USER/.profile || PROFILE=/root/.profile  
sed -i '/########          DAPPNODE PROFILE          ########/g' $PROFILE
sed -i '/.*dappnode_profile/g' $PROFILE

echo "DAppNode uninstalled!"