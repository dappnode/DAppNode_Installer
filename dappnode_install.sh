#!/bin/bash

###### When incorporating the images from IPFS:
# echo $URL_LIST | xargs -n 1 -P 8 wget -q
# ref: https://stackoverflow.com/questions/7577615/parallel-wget-in-bash

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
DCKR_PATH="${DAPPNODE_DIR}bin/docker/docker-ce_17.12.0~ce-0~ubuntu_amd64.deb"
DCMP_PATH="/usr/local/bin/docker-compose"
LIB_DIR="${DAPPNODE_DIR}libs/linux/debian/"
LIB1_PATH="${LIB_DIR}aufs-tools_1%253a3.2%2B20130722-1.1ubuntu1_amd64.deb"
LIB2_PATH="${LIB_DIR}cgroupfs-mount_1.2_all.deb"
LIB3_PATH="${LIB_DIR}libltdl7_2.4.6-0.1_amd64.deb"
CORE_PATH="${DAPPNODE_DIR}DNCORE/docker-compose.yml"
# Ensure paths exist
mkdir -p $DAPPNODE_DIR
mkdir -p $(dirname "$DCKR_PATH")
mkdir -p $(dirname "$DCMP_PATH")
mkdir -p $LIB_DIR
mkdir -p $(dirname "$CORE_PATH")


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
dpkg -i $LIB1_PATH
dpkg -i $LIB2_PATH
dpkg -i $LIB3_PATH
dpkg -i $DCKR_PATH

# Validate the installation of docker
if docker -v; then
    echo -e "\e[32m \n\n Verified docker installation \n\n \e[0m"
else
    echo -e "\e[31m \n\n ERROR: docker is not installed \n\n Please re-install it \n\n \e[0m"
    exit 1
fi

# ##### THIS WILL FAIL WITHOUT INTERNET CONNECTION
if docker run hello-world | grep -q "Hello from Docker!"; then
    echo -e "\e[32m \n\n Verified docker with hello-world image \n\n \e[0m"
else
    echo -e "\e[31m \n\n ERROR: docker, could not run hello-world image \n\n \e[0m"
    exit 1
fi

# Validate the installation of docker-compose
if docker-compose -v; then
    echo -e "\e[32m \n\n Verified docker-compose installation \n\n \e[0m"
else
    echo -e "\e[31m \n\n ERROR: docker-compose is not installed \n\n Please re-install it \n\n \e[0m"
    exit 1
fi


# STEP 3: Start DAppNode
# ----------------------------------------
docker-compose -f ${CORE_PATH} up -d

# Testing result
if docker-compose -f ${CORE_PATH} ps | grep -q "dncore-dnp_ethchain"; then
    echo -e "\e[32m \n\n Verified dappnode installation \n\n \e[0m"
else
    echo -e "\e[31m \n\n ERROR: docker-compose ps, does not return the expected packages \n\n \e[0m"
    exit 1
fi

# Give credentials to the user to connect
docker exec -it dncore-dnp_vpn node getAdminCredentials.js
