#!/bin/bash


install_dappnode()
{
  ##############################################
  ##############################################
  ####         DAPPNODE INSTALATION         ####
  ##############################################
  ##############################################


  ###### When incorporating the images from IPFS:
  # echo $URL_LIST | xargs -n 1 -P 8 wget -q
  # ref: https://stackoverflow.com/questions/7577615/parallel-wget-in-bash

  # FOR PRODUCTION: Replace links with IPFS
  CORE_URL="https://raw.githubusercontent.com/dappnode/DNCORE/master/docker-compose.yml"

  # STEP 0: Declare paths and directories
  # ----------------------------------------
  DAPPNODE_DIR="/usr/src/dappnode/"
  CORE_PATH="${DAPPNODE_DIR}DNCORE/docker-compose.yml"
  # Ensure paths exist
  mkdir -p $(dirname "$CORE_PATH")


  # STEP 1: Download files from a decentralized source
  # ----------------------------------------
  [ -f $CORE_PATH ] && echo "File exists" || wget -O $CORE_PATH $CORE_URL
}


run_dappnode()
{
  ##############################################
  ##############################################
  ####             DAPPNODE RUN             ####
  ##############################################
  ##############################################

  # STEP 3: Start DAppNode
  # ----------------------------------------
  docker-compose -f $CORE_PATH up -d

  # Testing result
  if docker-compose -f $CORE_PATH ps | grep -q "dncore-dnp_ethchain"; then
      echo -e "\e[32m \n\n Verified dappnode installation \n\n \e[0m"
  else
      echo -e "\e[31m \n\n ERROR: docker-compose ps, does not return the expected packages \n\n \e[0m"
      exit 1
  fi

  # Give credentials to the user to connect
  docker exec -it dncore-dnp_vpn getAdminCredentials
}



##############################################
##############################################
####             SCRIPT START             ####
##############################################
##############################################



install_dappnode

run_dappnode
