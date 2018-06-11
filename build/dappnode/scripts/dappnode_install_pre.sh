#!/bin/bash

DAPPNODE_DIR="/usr/src/dappnode/"
DCKR_PATH="${DAPPNODE_DIR}bin/docker/docker-ce_17.12.0~ce-0~ubuntu_amd64.deb"
LIB_DIR="${DAPPNODE_DIR}libs/linux/debian/"
LIB1_PATH="${LIB_DIR}aufs-tools_1:3.2+20130722-1.1ubuntu1_amd64.deb"
LIB2_PATH="${LIB_DIR}cgroupfs-mount_1.2_all.deb"
LIB3_PATH="${LIB_DIR}libltdl7_2.4.6-0.1_amd64.deb"
DCMP_PATH="/usr/local/bin/docker-compose"

###### When incorporating the images from IPFS:
# echo $URL_LIST | xargs -n 1 -P 8 wget -q
# ref: https://stackoverflow.com/questions/7577615/parallel-wget-in-bash

DCKR_URL="https://raw.githubusercontent.com/dappnode/DAppNode_Installer/master/build/dappnode/bin/docker/docker-ce_17.12.0~ce-0~ubuntu_amd64.deb"
LIB1_URL="https://raw.githubusercontent.com/dappnode/DAppNode_Installer/master/build/dappnode/libs/linux/debian/aufs-tools_1%253a3.2%2B20130722-1.1ubuntu1_amd64.deb"
LIB2_URL="https://raw.githubusercontent.com/dappnode/DAppNode_Installer/master/build/dappnode/libs/linux/debian/cgroupfs-mount_1.2_all.deb"
LIB3_URL="https://raw.githubusercontent.com/dappnode/DAppNode_Installer/master/build/dappnode/libs/linux/debian/libltdl7_2.4.6-0.1_amd64.deb"
DCMP_URL="https://raw.githubusercontent.com/dappnode/DAppNode_Installer/master/build/dappnode/bin/docker/docker-compose-Linux-x86_64"

detect_installation_type(){
    if [ -f "${DAPPNODE_DIR}iso_install.log" ]; then
        LOG_FILE=${DAPPNODE_DIR}iso_install.log
        ISO_INSTALLATION=true
    else
        LOG_FILE=${DAPPNODE_DIR}install.log
        ISO_INSTALLATION=false
    fi
}

install_docker()
{
  ##############################################
  ##############################################
  ####          DOCKER INSTALATION          ####
  ##############################################
  ##############################################

  # STEP 1: Download files from a decentralized source
  # ----------------------------------------
  [ -f $DCKR_PATH ] || wget -q --show-progress -O $DCKR_PATH $DCKR_URL 2>&1 | tee -a $LOG_FILE
  [ -f $LIB1_PATH ] || wget -q --show-progress -O $LIB1_PATH $LIB1_URL 2>&1 | tee -a $LOG_FILE
  [ -f $LIB2_PATH ] || wget -q --show-progress -O $LIB2_PATH $LIB2_URL 2>&1 | tee -a $LOG_FILE
  [ -f $LIB3_PATH ] || wget -q --show-progress -O $LIB3_PATH $LIB3_URL 2>&1 | tee -a $LOG_FILE


  # STEP 2: Install packages
  # ----------------------------------------
  dpkg -i $LIB1_PATH 2>&1 | tee -a $LOG_FILE
  dpkg -i $LIB2_PATH 2>&1 | tee -a $LOG_FILE
  dpkg -i $LIB3_PATH 2>&1 | tee -a $LOG_FILE
  dpkg -i $DCKR_PATH 2>&1 | tee -a $LOG_FILE

  USER=$(cat /etc/passwd | grep 1000  | cut -f 1 -d:)
  usermod -aG docker $USER
 
  # Disable check if ISO installation since it is not possible to check in this way
  if [ "$ISO_INSTALLATION" = "false" ]; then
    # Validate the installation of docker
    if docker -v; then
        echo -e "\e[32m \n\n Verified docker installation \n\n \e[0m" 2>&1 | tee -a $LOG_FILE
    else
        echo -e "\e[31m \n\n ERROR: docker is not installed \n\n Please re-install it \n\n \e[0m" 2>&1 | tee -a $LOG_FILE
        exit 1 
    fi
  fi
}

install_docker_compose()
{
  ##############################################
  ##############################################
  ####      DOCKER COMPOSE INSTALATION      ####
  ##############################################
  ##############################################

  # STEP 0: Declare paths and directories
  # ----------------------------------------
  
  # Ensure paths exist
  mkdir -p $(dirname "$DCMP_PATH") 2>&1 | tee -a $LOG_FILE

  # STEP 1: Download files from a decentralized source
  # ----------------------------------------
  [ -f $DCMP_PATH ] || wget -q --show-progress -O $DCMP_PATH $DCMP_URL 2>&1 | tee -a $LOG_FILE
  # Give permissions
  chmod +x $DCMP_PATH 2>&1 | tee -a $LOG_FILE

  # Disable check if ISO installation since it is not possible to check in this way
  if [ "$ISO_INSTALLATION" = "false" ]; then
    # Validate the installation of docker-compose
    if docker-compose -v; then
        echo -e "\e[32m \n\n Verified docker-compose installation \n\n \e[0m" 2>&1 | tee -a $LOG_FILE
    else
        echo -e "\e[31m \n\n ERROR: docker-compose is not installed \n\n Please re-install it \n\n \e[0m" 2>&1 | tee -a $LOG_FILE
        exit 1
    fi
  fi
}

##############################################
##############################################
####             SCRIPT START             ####
##############################################
##############################################

detect_installation_type

# Ensure paths exist
mkdir -p $DAPPNODE_DIR
mkdir -p $(dirname "$DCKR_PATH")
mkdir -p $LIB_DIR

touch $LOG_FILE

# Only install docker if needed
if docker -v >/dev/null 2>&1 ; then
    echo -e "\e[32m \n\n docker is already installed \n\n \e[0m" 2>&1 | tee -a $LOG_FILE
else
    install_docker 2>&1 | tee -a $LOG_FILE
fi

# Only install docker-compose if needed
if docker-compose -v >/dev/null 2>&1 ; then
    echo -e "\e[32m \n\n docker-compose is already installed \n\n \e[0m" 2>&1 | tee -a $LOG_FILE
else
    install_docker_compose 2>&1 | tee -a $LOG_FILE
fi

