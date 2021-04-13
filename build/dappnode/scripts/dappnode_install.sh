#!/bin/bash

DAPPNODE_DIR="/usr/src/dappnode"
DAPPNODE_CORE_DIR="${DAPPNODE_DIR}/DNCORE"
LOGFILE="${DAPPNODE_DIR}/dappnode_install.log"
MOTD_FILE="/etc/motd"
PKGS=(BIND IPFS VPN DAPPMANAGER WIFI)
CONTENT_HASH_PKGS=(geth openethereum nethermind)
CONTENT_HASH_FILE="${DAPPNODE_CORE_DIR}/packages-content-hash.csv"
CRED_CMD="docker exec -i DAppNodeCore-vpn.dnp.dappnode.eth getAdminCredentials"
ARCH=$(dpkg --print-architecture)

if [ "$UPDATE" = true ]; then
    echo "Cleaning for update..."
    rm -rf $LOGFILE
    rm -rf ${DAPPNODE_CORE_DIR}/docker-compose-*.yml
    rm -rf ${DAPPNODE_CORE_DIR}/dappnode_package-*.json
    rm -rf ${DAPPNODE_CORE_DIR}/*.tar.xz
    rm -rf ${DAPPNODE_CORE_DIR}/*.txz
    rm -rf ${DAPPNODE_CORE_DIR}/.dappnode_profile
    rm -rf ${CONTENT_HASH_FILE}
fi

mkdir -p $DAPPNODE_DIR
mkdir -p $DAPPNODE_CORE_DIR
mkdir -p "${DAPPNODE_CORE_DIR}/scripts"
mkdir -p "${DAPPNODE_DIR}/config"

PROFILE_BRANCH=${PROFILE_BRANCH:-"master"}
PROFILE_URL="https://raw.githubusercontent.com/dappnode/DAppNode_Installer/${PROFILE_BRANCH}/build/scripts/.dappnode_profile"
DAPPNODE_PROFILE="${DAPPNODE_CORE_DIR}/.dappnode_profile"
WGET="wget -q --show-progress --progress=bar:force"
SWGET="wget -q -O-"
IPFS_ENDPOINT=${IPFS_ENDPOINT:-"http://ipfs.io"}

function valid_ip() {
    local ip=$1
    local stat=1

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 && \
        ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}

if [[ ! -z $STATIC_IP ]]; then
    if valid_ip $STATIC_IP; then
        echo $STATIC_IP >${DAPPNODE_DIR}/config/static_ip
    else
        echo "The static IP provided: ${STATIC_IP} is not valid."
        exit 1
    fi
fi

[ -f $DAPPNODE_PROFILE ] || ${WGET} -O ${DAPPNODE_PROFILE} ${PROFILE_URL}

source "${DAPPNODE_PROFILE}"

# The indirect variable expansion used in ${!ver##*:} allows us to use versions like 'dev:development'
# If such variable with 'dev:'' suffix is used, then the component is built from specified branch or commit.
# you can also specify an IPFS version like /ipfs/QmWg8P2b9JKQ8thAVz49J8SbJbCoi2MwkHnUqMtpzDTtxR:0.2.7, it's important
# to include the exact version also in the IPFS hash format since it's needed to be able to download it 
for comp in "${PKGS[@]}"; do
    ver="${comp}_VERSION"
    DOWNLOAD_URL="https://github.com/dappnode/DNP_${comp}/releases/download/v${!ver}"
    if [[ ${!ver} == /ipfs/* ]]; then
        DOWNLOAD_URL=${IPFS_ENDPOINT}/api/v0/cat?arg=${!ver%:*}
    fi
    eval "${comp}_URL=\"${DOWNLOAD_URL}/${comp,,}.dnp.dappnode.eth_${!ver##*:}_linux-${ARCH}.txz\""
    eval "${comp}_YML=\"${DOWNLOAD_URL}/docker-compose.yml\""
    eval "${comp}_MANIFEST=\"${DOWNLOAD_URL}/dappnode_package.json\""
    eval "${comp}_YML_FILE=\"${DAPPNODE_CORE_DIR}/docker-compose-${comp,,}.yml\""
    eval "${comp}_FILE=\"${DAPPNODE_CORE_DIR}/${comp,,}.dnp.dappnode.eth_${!ver##*:}_linux-${ARCH}.txz\""
    eval "${comp}_MANIFEST_FILE=\"${DAPPNODE_CORE_DIR}/dappnode_package-${comp,,}.json\""
done

dappnode_core_build() {
    for comp in "${PKGS[@]}"; do
        ver="${comp}_VERSION"
        file="${comp}_FILE"
        if [[ ${!ver} == dev:* ]]; then
            echo "Cloning & building DNP_${comp}..."
            if ! dpkg -s git >/dev/null 2>&1; then
                apt-get install -y git
            fi
            TMPDIR=$(mktemp -d)
            pushd $TMPDIR
            git clone -b "${!ver##*:}" https://github.com/dappnode/DNP_${comp}
            # Change version in YAML to the custom one
            DOCKER_VER=$(echo "${!ver##*:}" | sed 's/\//_/g')
            sed -i "s~^\(\s*image\s*:\s*\).*~\1${comp,,}.dnp.dappnode.eth:${DOCKER_VER}~" DNP_${comp}/docker-compose.yml
            docker-compose -f ./DNP_${comp}/docker-compose.yml build
            cp ./DNP_${comp}/docker-compose.yml ${DAPPNODE_CORE_DIR}/docker-compose-${comp,,}.yml
            cp ./DNP_${comp}/dappnode_package.json ${DAPPNODE_CORE_DIR}/dappnode_package-${comp,,}.json
            rm -r ./DNP_${comp}
            popd
        fi
    done
}

dappnode_core_download() {
    for comp in "${PKGS[@]}"; do
        ver="${comp}_VERSION"
        if [[ ${!ver} != dev:* ]]; then
            # Download DAppNode Core Images if it's needed
            echo "Downloading ${comp} tar..."
            eval "[ -f \$${comp}_FILE ] || $WGET -O \$${comp}_FILE \$${comp}_URL || exit 1"
            # Download DAppNode Core docker-compose yml files if it's needed
            echo "Downloading ${comp} yml..."
            eval "[ -f \$${comp}_YML_FILE ] || $WGET -O \$${comp}_YML_FILE \$${comp}_YML || exit 1";
	    # Download DAppNode Core manifest files if it's needed
            echo "Downloading ${comp} manifest..."
            eval "[ -f \$${comp}_MANIFEST_FILE ] || $WGET -O \$${comp}_MANIFEST_FILE \$${comp}_MANIFEST || exit 1";
        fi
    done
}

dappnode_core_load() {
    for comp in "${PKGS[@]}"; do
        ver="${comp}_VERSION"
        if [[ ${!ver} != dev:* ]]; then
            eval "[ ! -z \$(docker images -q ${comp,,}.dnp.dappnode.eth:${!ver##*:}) ] || docker load -i \$${comp}_FILE 2>&1 | tee -a \$LOGFILE"
        fi
    done

    for COMPOSE_PATH in ${DAPPNODE_CORE_DIR}/*.yml; do
        # Remove the build property from the core docker-compose-*.yml
       sed -i '/build:/,/image:/{//!d};/build:/d' $COMPOSE_PATH
    done
}

customMotd() {
    if [ -f ${MOTD_FILE} ]; then
        cat <<EOF >${MOTD_FILE}
 ___   _             _  _         _
|   \ /_\  _ __ _ __| \| |___  __| |___
| |) / _ \| '_ \ '_ \ .  / _ \/ _  / -_)
|___/_/ \_\ .__/ .__/_|\_\___/\__,_\___|
          |_|  |_|
EOF
    fi
}

addSwap() {
    # Is swap enabled?
    IS_SWAP=$(swapon --show | wc -l)

    # if not then create it
    if [ $IS_SWAP -eq 0 ]; then
        echo -e '\e[32mSwap not found. Adding swapfile.\e[0m'
        #RAM=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
        #SWAP=$(($RAM * 2))
        SWAP=8388608
        fallocate -l ${SWAP}k /swapfile
        chmod 600 /swapfile
        mkswap /swapfile
        swapon /swapfile
        echo '/swapfile none swap defaults 0 0' >>/etc/fstab
    else
        echo -e '\e[32mSwap found. No changes made.\e[0m'
    fi
}

dappnode_start() {
    echo -e "\e[32mDAppNode starting...\e[0m" 2>&1 | tee -a $LOGFILE
    source "${DAPPNODE_PROFILE}" >/dev/null 2>&1

    # Execute `compose-up` independently
    # To execute `compose-up` against more than 1 compose, composes files must share compose file version (e.g 3.5)
    for comp in "${DNCORE_YMLS_ARRAY[@]}"; do
        docker-compose -f $comp up -d 2>&1 | tee -a $LOGFILE
        echo "${comp} started" 2>&1 | tee -a $LOGFILE
    done
    echo -e "\e[32mDAppNode started\e[0m" 2>&1 | tee -a $LOGFILE

    # Show credentials to the user on login
    USER=$(cat /etc/passwd | grep 1000 | cut -f 1 -d:)
    [ ! -z $USER ] && PROFILE=/home/$USER/.profile || PROFILE=/root/.profile

    if ! grep -q "${DAPPNODE_PROFILE}" "$PROFILE"; then
        echo "########          DAPPNODE PROFILE          ########" >>$PROFILE
        echo -e "source ${DAPPNODE_PROFILE}\n" >>$PROFILE
    fi

    sed -i '/return/d' $DAPPNODE_PROFILE | tee -a $LOGFILE

    if ! grep -q 'http://my.dappnode/' "$DAPPNODE_PROFILE"; then
        echo "echo -e \"\nTo get a VPN profile file and connect to your DAppNode, run the following command:\"" >>$DAPPNODE_PROFILE
        echo "echo -e \"\n\e[32mdappnode_connect\e[0m\"" >>$DAPPNODE_PROFILE
        echo "echo -e \"\nOnce connected through the VPN (OpenVPN) you can access to the admin UI by following this link:\"" >>$DAPPNODE_PROFILE
        echo "echo -e \"\nhttp://my.dappnode/\n\"" >>$DAPPNODE_PROFILE
        echo -e "return\n" >>$DAPPNODE_PROFILE
    fi
    # Show credentials at shell installation
    # [ ! -f "/usr/src/dappnode/iso_install.log" ] && docker run --rm -v dncore_vpndnpdappnodeeth_data:/usr/src/app/secrets $(docker inspect DAppNodeCore-vpn.dnp.dappnode.eth --format '{{.Config.Image}}') getAdminCredentials

    # Delete dappnode_install.sh execution from rc.local if exists, and is not the unattended firstboot
    if [ -f "/etc/rc.local" ] && [ ! -f "/usr/src/dappnode/.firstboot" ]; then
        sed -i '/\/usr\/src\/dappnode\/scripts\/dappnode_install.sh/d' /etc/rc.local 2>&1 | tee -a $LOGFILE
    fi
}

installExtra() {
    if [ -d "/usr/src/dappnode/extra" ]; then
        dpkg -i /usr/src/dappnode/extra/*.deb 2>&1 | tee -a $LOGFILE
    fi
}

grabContentHashes() {
    if [ ! -f "${CONTENT_HASH_FILE}" ]; then
        for comp in "${CONTENT_HASH_PKGS[@]}"; do
            CONTENT_HASH=$(eval ${SWGET} https://github.com/dappnode/DAppNodePackage-${comp}/releases/latest/download/content-hash)
            if [ -z $CONTENT_HASH ]; then
                echo "ERROR! Failed to find content hash of ${comp}." 2>&1 | tee -a $LOGFILE
                exit 1
            fi
            echo "${comp}.dnp.dappnode.eth,${CONTENT_HASH}" >>${CONTENT_HASH_FILE}
        done
    fi
}

installSgx() {
    if [ -d "/usr/src/dappnode/sgx" ]; then
        # from sgx_linux_x64_driver_2.5.0_2605efa.bin
        /usr/src/dappnode/sgx/sgx_linux_x64_driver.bin 2>&1 | tee -a $LOG_DIR
        /usr/src/dappnode/sgx/enable_sgx 2>&1 | tee -a $LOG_DIR
    fi
}

installExtra() {
    if [ -d "/usr/src/dappnode/extra" ]; then
        dpkg -i /usr/src/dappnode/extra/*.deb 2>&1 | tee -a $LOG_DIR
    fi
}

##############################################
##############################################
####             SCRIPT START             ####
##############################################
##############################################

echo -e "\e[32m\n##############################################\e[0m" 2>&1 | tee -a $LOGFILE
echo -e "\e[32m##############################################\e[0m" 2>&1 | tee -a $LOGFILE
echo -e "\e[32m####          DAPPNODE INSTALLER          ####\e[0m" 2>&1 | tee -a $LOGFILE
echo -e "\e[32m##############################################\e[0m" 2>&1 | tee -a $LOGFILE
echo -e "\e[32m##############################################\e[0m" 2>&1 | tee -a $LOGFILE

echo -e "\e[32mCreating swap memory...\e[0m" 2>&1 | tee -a $LOGFILE
addSwap

echo -e "\e[32mCustomizing login...\e[0m" 2>&1 | tee -a $LOGFILE
customMotd

echo -e "\e[32mInstalling extra packages...\e[0m" 2>&1 | tee -a $LOGFILE
installExtra

echo -e "\e[32mGrabbing latest content hashes...\e[0m" 2>&1 | tee -a $LOGFILE
grabContentHashes

if [ $ARCH == "amd64" ]; then 
    echo -e "\e[32mInstalling SGX modules...\e[0m" 2>&1 | tee -a $LOG_DIR
    installSgx

    echo -e "\e[32mInstalling extra packages...\e[0m" 2>&1 | tee -a $LOG_DIR
    installExtra
fi

echo -e "\e[32mCreating dncore_network if needed...\e[0m" 2>&1 | tee -a $LOG_DIR
docker network create --driver bridge --subnet 172.33.0.0/16 dncore_network || echo "dncore_network already exists"

echo -e "\e[32mBuilding DAppNode Core if needed...\e[0m" 2>&1 | tee -a $LOG_DIR
dappnode_core_build

echo -e "\e[32mDownloading DAppNode Core...\e[0m" 2>&1 | tee -a $LOGFILE
dappnode_core_download

echo -e "\e[32mLoading DAppNode Core...\e[0m" 2>&1 | tee -a $LOGFILE
dappnode_core_load

if [ ! -f "/usr/src/dappnode/.firstboot" ]; then
    echo -e "\e[32mDAppNode installed\e[0m" 2>&1 | tee -a $LOGFILE
    dappnode_start
fi

# Run test in interactive terminal
if [ -f "/usr/src/dappnode/.firstboot" ]; then
    openvt -s -w -- sudo -u root /usr/src/dappnode/scripts/dappnode_test_install.sh
    exit 0
fi

# Show credentials if installed from script
[ ! -f "/usr/src/dappnode/iso_install.log" ] && eval ${CRED_CMD}

exit 0