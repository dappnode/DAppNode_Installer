#!/bin/bash

DAPPNODE_DIR="/usr/src/dappnode"
DOCKER_PKG="docker-ce_18.09.5~3-0~debian-buster_amd64.deb"
DOCKER_CLI_PKG="docker-ce-cli_18.09.5~3-0~debian-buster_amd64.deb"
CONTAINERD_PKG="containerd.io_1.2.5-1_amd64.deb"
DOCKER_REPO="https://download.docker.com/linux/debian/dists/buster/pool/stable/amd64"
DOCKER_PATH="${DAPPNODE_DIR}/bin/docker/${DOCKER_PKG}"
DOCKER_CLI_PATH="${DAPPNODE_DIR}/bin/docker/${DOCKER_CLI_PKG}"
CONTAINERD_PATH="${DAPPNODE_DIR}/bin/docker/${CONTAINERD_PKG}"
DCMP_PATH="/usr/local/bin/docker-compose"
DOCKER_URL="${DOCKER_REPO}/${DOCKER_PKG}"
DOCKER_CLI_URL="${DOCKER_REPO}/${DOCKER_CLI_PKG}"
CONTAINERD_URL="${DOCKER_REPO}/${CONTAINERD_PKG}"
DCMP_URL="https://github.com/docker/compose/releases/download/1.24.0/docker-compose-Linux-x86_64"
WGET="wget -q --show-progress --progress=bar:force"

#!ISOBUILD Do not modify, variables above imported for ISO build

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
    ####          DOCKER INSTALLATION         ####
    ##############################################
    ##############################################
    
    # STEP 0: Detect if it's a Debian 9 (stretch) installation
    # ----------------------------------------
    if [ -f "/etc/os-release" ] && grep -q "stretch" "/etc/os-release"; then
        DOCKER_PKG="docker-ce_18.09.5~3-0~debian-stretch_amd64.deb"
        DOCKER_CLI_PKG="docker-ce-cli_18.09.5~3-0~debian-stretch_amd64.deb"
        CONTAINERD_PKG="containerd.io_1.2.5-1_amd64.deb"
        DOCKER_REPO="https://download.docker.com/linux/debian/dists/stretch/pool/stable/amd64"
        DOCKER_PATH="${DAPPNODE_DIR}/bin/docker/${DOCKER_PKG}"
        DOCKER_CLI_PATH="${DAPPNODE_DIR}/bin/docker/${DOCKER_CLI_PKG}"
        CONTAINERD_PATH="${DAPPNODE_DIR}/bin/docker/${CONTAINERD_PKG}"
        DOCKER_URL="${DOCKER_REPO}/${DOCKER_PKG}"
        DOCKER_CLI_URL="${DOCKER_REPO}/${DOCKER_CLI_PKG}"
        CONTAINERD_URL="${DOCKER_REPO}/${CONTAINERD_PKG}"
        
        
    fi
    
    # STEP 1: Download files
    # ----------------------------------------
    [ -f $DOCKER_PATH ] || $WGET -O $DOCKER_PATH $DOCKER_URL
    [ -f $DOCKER_CLI_PATH ] || $WGET -O $DOCKER_CLI_PATH $DOCKER_CLI_URL
    [ -f $CONTAINERD_PATH ] || $WGET -O $CONTAINERD_PATH $CONTAINERD_URL
    
    # STEP 2: Install packages
    # ----------------------------------------
    dpkg -i $CONTAINERD_PATH 2>&1 | tee -a $LOG_FILE
    dpkg -i $DOCKER_CLI_PATH 2>&1 | tee -a $LOG_FILE
    dpkg -i $DOCKER_PATH 2>&1 | tee -a $LOG_FILE
    
    # Ensure xz is installed
    [ -f "/usr/bin/xz" ] || (apt-get update -y && apt-get install -y xz-utils)
    
    USER=$(grep 1000 "/etc/passwd" | cut -f 1 -d:)
    [ -z "$USER" ] || usermod -aG docker "$USER"
    
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
    ####      DOCKER COMPOSE INSTALLATION     ####
    ##############################################
    ##############################################
    
    # STEP 0: Declare paths and directories
    # ----------------------------------------
    
    # Ensure paths exist
    mkdir -p $(dirname "$DCMP_PATH") 2>&1 | tee -a $LOG_FILE
    
    # STEP 1: Download files from a decentralized source
    # ----------------------------------------
    [ -f $DCMP_PATH ] || $WGET -O $DCMP_PATH $DCMP_URL
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

install_wireguard()
{
    ##############################################
    ##############################################
    ####      WIREGUARD INSTALLATION     ####
    ##############################################
    ##############################################

    echo "deb http://deb.debian.org/debian/ unstable main" > /etc/apt/sources.list.d/unstable.list
    printf 'Package: *\nPin: release a=unstable\nPin-Priority: 90\n' > /etc/apt/preferences.d/limit-unstable
    apt update | tee -a $LOG_FILE
    apt -y install wireguard | tee -a $LOG_FILE
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

# Only install wireguard if needed
if modprobe wireguard >/dev/null 2>&1 ; then
    echo -e "\e[32m \n\n wireguard is already installed \n\n \e[0m" 2>&1 | tee -a $LOG_FILE
else
    install_wireguard 2>&1 | tee -a $LOG_FILE
fi
