
# FOR PRODUCTION: Replace links with IPFS
CORE_URL="https://raw.githubusercontent.com/dappnode/DNCORE/master/docker-compose.yml"
DOCKER_URL="https://raw.githubusercontent.com/dappnode/DN_ISO_Generator/master/build/dappnode/bin/docker/docker-ce_17.12.0~ce-0~ubuntu_amd64.deb"
DOCKER_COMPOSE_URL="https://raw.githubusercontent.com/dappnode/DN_ISO_Generator/master/build/dappnode/bin/docker/docker-compose-Linux-x86_64"
LIB1_URL="https://raw.githubusercontent.com/dappnode/DN_ISO_Generator/master/build/dappnode/libs/linux/debian/aufs-tools_1%253a3.2%2B20130722-1.1ubuntu1_amd64.deb"
LIB2_URL="https://raw.githubusercontent.com/dappnode/DN_ISO_Generator/master/build/dappnode/libs/linux/debian/cgroupfs-mount_1.2_all.deb"
LIB3_URL="https://raw.githubusercontent.com/dappnode/DN_ISO_Generator/master/build/dappnode/libs/linux/debian/libltdl7_2.4.6-0.1_amd64.deb"


# STEP 0: Declare paths and directories
# ----------------------------------------
DAPPNODE_DIR="/usr/src/dappnode/"
DOCKER_DIR="${DAPPNODE_DIR}bin/docker/"
DOCKER_PATH="${DOCKER_DIR}docker-ce_17.12.0~ce-0~ubuntu_amd64.deb"
DOCKER_COMPOSE_DIR="/usr/local/bin/"
DOCKER_COMPOSE_PATH="${DOCKER_COMPOSE_DIR}docker-compose"
LIB_DIR="${DAPPNODE_DIR}libs/linux/debian/"
LIB1_PATH="${LIB_DIR}aufs-tools_1%253a3.2%2B20130722-1.1ubuntu1_amd64.deb"
LIB2_PATH="${LIB_DIR}cgroupfs-mount_1.2_all.deb"
LIB3_PATH="${LIB_DIR}libltdl7_2.4.6-0.1_amd64.deb"

# Ensure paths exist
mkdir -p $DAPPNODE_DIR
mkdir -p $DOCKER_DIR
mkdir -p $DOCKER_COMPOSE_DIR
mkdir -p $LIB_DIR


# STEP 1: Download files from a decentralized source
# ----------------------------------------
wget -O $DOCKER_PATH $DOCKER_URL
wget -O $DOCKER_COMPOSE_PATH $DOCKER_COMPOSE_URL
wget -O $LIB1_PATH $LIB1_URL
wget -O $LIB2_PATH $LIB2_URL
wget -O $LIB3_PATH $LIB3_URL
# Give permissions
chmod +x $DOCKER_COMPOSE_PATH


# STEP 2: Install packages
# ----------------------------------------
dpkg -i $DOCKER_PATH
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
# Get the docker-compose.yml and up it
cd $DAPPNODE_DIR
wget $CORE_URL
docker-compose up -d

# Testing result
if docker-compose ps | grep -q "dncore-dnp_ethchain"; then
    echo -e "${GREEN}\n\nVerified dappnode installation \n\n -------${NC}"
else
    echo -e "${RED}\n\nERROR:\n  docker-compose ps, does not return the expected packages \n\n -------${NC}"
    exit 1
fi
