#!/bin/bash

GIT_BRANCH="master"
DAPPNODE_DIR="/usr/src/dappnode"
DOCKER_PKG="docker-ce_18.06.1~ce~3-0~ubuntu_amd64.deb"
LIBLTDL_PKG="libltdl7_2.4.6-2_amd64.deb"
DOCKER_PATH="${DAPPNODE_DIR}/bin/docker/${DOCKER_PKG}"
LIB_DIR="${DAPPNODE_DIR}/libs/linux/debian/"
LIBLTDL_PATH="${LIB_DIR}/${LIBLTDL_PKG}"
DCMP_PATH="/usr/local/bin/docker-compose"

DOCKER_URL="https://raw.githubusercontent.com/dappnode/DAppNode_Installer/${GIT_BRANCH}/build/dappnode/bin/docker/${DOCKER_PKG}"
LIBLTDL_URL="https://raw.githubusercontent.com/dappnode/DAppNode_Installer/${GIT_BRANCH}/build/dappnode/libs/linux/debian/${LIBLTDL_PKG}"
DCMP_URL="https://raw.githubusercontent.com/dappnode/DAppNode_Installer/${GIT_BRANCH}/build/dappnode/bin/docker/docker-compose-Linux-x86_64"

detect_installation_type(){
    if [ -f "${DAPPNODE_DIR}/iso_install.log" ]; then
        LOG_FILE=${DAPPNODE_DIR}/iso_install.log
        ISO_INSTALLATION=true
    else
        LOG_FILE=${DAPPNODE_DIR}/install.log
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

  # STEP 1: Download files 
  # TODO: From a decentralized source
  # ----------------------------------------
  wget -q --show-progress -O $DOCKER_PATH $DOCKER_URL
  wget -q --show-progress -O $LIBLTDL_PATH $LIBLTDL_URL

  # STEP 2: Install packages
  # ----------------------------------------
  dpkg -i $LIBLTDL_PATH 2>&1 | tee -a $LOG_FILE
  dpkg -i $DOCKER_PATH 2>&1 | tee -a $LOG_FILE

  USER=$(cat /etc/passwd | grep 1000  | cut -f 1 -d:)
  [ -z $USER ] || usermod -aG docker $USER
 
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
  [ -f $DCMP_PATH ] || wget -q --show-progress -O $DCMP_PATH $DCMP_URL
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
mkdir -p $(dirname "$DOCKER_PATH")
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

