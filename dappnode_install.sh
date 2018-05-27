#!/bin/bash


# FOR PRODUCTION: Replace links with IPFS
CORE_URL="https://raw.githubusercontent.com/dappnode/DNCORE/master/docker-compose.yml"
DCKR_URL="https://raw.githubusercontent.com/dappnode/DN_ISO_Generator/master/build/dappnode/bin/docker/docker-ce_17.12.0~ce-0~ubuntu_amd64.deb"
DCMP_URL="https://raw.githubusercontent.com/dappnode/DN_ISO_Generator/master/build/dappnode/bin/docker/docker-compose-Linux-x86_64"
LIB1_URL="https://raw.githubusercontent.com/dappnode/DN_ISO_Generator/master/build/dappnode/libs/linux/debian/aufs-tools_1%253a3.2%2B20130722-1.1ubuntu1_amd64.deb"
LIB2_URL="https://raw.githubusercontent.com/dappnode/DN_ISO_Generator/master/build/dappnode/libs/linux/debian/cgroupfs-mount_1.2_all.deb"
LIB3_URL="https://raw.githubusercontent.com/dappnode/DN_ISO_Generator/master/build/dappnode/libs/linux/debian/libltdl7_2.4.6-0.1_amd64.deb"


# STEP 0: Declare paths and directories
# ----------------------------------------
DAPPNODE_DIR="/usr/src/dappnode/"
DCKR_DIR="${DAPPNODE_DIR}bin/docker/"
DCKR_PATH="${DCKR_DIR}docker-ce_17.12.0~ce-0~ubuntu_amd64.deb"
DCMP_DIR="/usr/local/bin/"
DCMP_PATH="${DCMP_DIR}docker-compose"
LIB_DIR="${DAPPNODE_DIR}libs/linux/debian/"
LIB1_PATH="${LIB_DIR}aufs-tools_1%253a3.2%2B20130722-1.1ubuntu1_amd64.deb"
LIB2_PATH="${LIB_DIR}cgroupfs-mount_1.2_all.deb"
LIB3_PATH="${LIB_DIR}libltdl7_2.4.6-0.1_amd64.deb"
CORE_PATH="${DAPPNODE_DIR}docker-compose.yml"
# Ensure paths exist
mkdir -p $DAPPNODE_DIR
mkdir -p $DCKR_DIR
mkdir -p $DCMP_DIR
mkdir -p $LIB_DIR


# STEP 1: Download files from a decentralized source
# ----------------------------------------
[ -f $DCKR_PATH ] && echo "File exists" || wget -O $DCKR_PATH $DCKR_URL
[ -f $DCMP_PATH ] && echo "File exists" || wget -O $DCMP_PATH $DCMP_URL
[ -f $LIB1_PATH ] && echo "File exists" || wget -O $LIB1_PATH $LIB1_URL
[ -f $LIB2_PATH ] && echo "File exists" || wget -O $LIB2_PATH $LIB2_URL
[ -f $LIB3_PATH ] && echo "File exists" || wget -O $LIB3_PATH $LIB3_URL
[ -f $CORE_PATH ] && echo "File exists" || wget -O $CORE_PATH $CORE_URL
# Give permissions
chmod +x $DCMP_PATH


# STEP 2: Install packages
# ----------------------------------------
dpkg -i $DCKR_PATH
dpkg -i $LIB1_PATH
dpkg -i $LIB2_PATH
dpkg -i $LIB3_PATH

# Define color coding
RED="\033[0;31m"
GREEN="\033[0;32m"
NC="\033[0m" # No Color

# Validate the installation of docker
if docker -v; then
    echo -e "${GREEN}\n\nVerified docker installation \n\n -------${NC}"
else
    echo -e "${RED}\n\nERROR:\n  docker is not installed \n\n Please re-install it \n\n -------${NC}"
    exit 1
fi

# Validate the installation of docker-compose
if docker-compose -v; then
    echo -e "${GREEN}\n\nVerified docker-compose installation \n\n -------${NC}"
else
    echo -e "${RED}\n\nERROR:\n  docker-compose is not installed \n\n Please re-install it \n\n -------${NC}"
    exit 1
fi


# STEP 3: Start DAppNode
# ----------------------------------------
cd $DAPPNODE_DIR
docker-compose up -d

# Testing result
if docker-compose ps | grep -q "dncore-dnp_ethchain"; then
    echo -e "${GREEN}\n\nVerified dappnode installation \n\n -------${NC}"
else
    echo -e "${RED}\n\nERROR:\n  docker-compose ps, does not return the expected packages \n\n -------${NC}"
    exit 1
fi

# Give credentials to the user to connect
docker exec -it dncore-dnp_vpn node getAdminCredentials.js
