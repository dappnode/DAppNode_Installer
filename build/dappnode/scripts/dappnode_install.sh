#!/bin/bash

DAPPNODE_DIR="/usr/src/dappnode/"
DAPPNODE_CORE_DIR="${DAPPNODE_DIR}DNCORE/"
LOG_DIR="${DAPPNODE_DIR}dappnode_install.log"
MOTD_FILE="/etc/motd"

if [ "$UPDATE" = true ] ; then
    echo "Cleaning for update..."
    rm -rf $LOG_DIR
    rm -rf ${DAPPNODE_CORE_DIR}*.yml
    rm -rf ${DAPPNODE_CORE_DIR}*.json
    rm -rf ${DAPPNODE_CORE_DIR}*.tar.xz
    rm -rf ${DAPPNODE_CORE_DIR}.dappnode_profile
fi

mkdir -p $DAPPNODE_DIR
mkdir -p $DAPPNODE_CORE_DIR
mkdir -p "${DAPPNODE_CORE_DIR}scripts"
mkdir -p "${DAPPNODE_DIR}config"

PROFILE_BRANCH="master"
PROFILE_URL="https://raw.githubusercontent.com/dappnode/DAppNode_Installer/${PROFILE_BRANCH}/build/scripts/.dappnode_profile"
PROFILE_FILE="${DAPPNODE_CORE_DIR}.dappnode_profile"

source /etc/os-release

function valid_ip()
{
    local  ip=$1
    local  stat=1

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}

if [ "$NAME" = "Ubuntu" ];then
    WGET="wget -q --show-progress "
else
    WGET="wget "
fi

if [[ ! -z $STATIC_IP ]]; then
    if valid_ip $STATIC_IP; then
        echo $STATIC_IP > ${DAPPNODE_DIR}config/static_ip
    else
        echo "The static IP provided: ${STATIC_IP} is not valid."
        exit 1
    fi
fi

[ -f $PROFILE_FILE ] || ${WGET} -O ${PROFILE_FILE} ${PROFILE_URL}

source "${PROFILE_FILE}"

components=(BIND IPFS ETHCHAIN ETHFORWARD VPN WAMP DAPPMANAGER ADMIN WIFI)

# The indirect variable expansion used in ${!ver##*:} allows us to use versions like 'dev:development'
# If such variable with 'dev:'' suffix is used, then the component is built from specified branch or commit.
for comp in "${components[@]}"; do
    ver="${comp}_VERSION"
    eval "${comp}_URL=\"https://github.com/dappnode/DNP_${comp}/releases/download/v${!ver}/${comp,,}.dnp.dappnode.eth_${!ver}.tar.xz\""
    eval "${comp}_YML=\"https://github.com/dappnode/DNP_${comp}/releases/download/v${!ver}/docker-compose-${comp,,}.yml\""
    eval "${comp}_ENV=\"https://github.com/dappnode/DNP_${comp}/releases/download/v${!ver}/${comp,,}.dnp.dappnode.eth.env\""
    eval "${comp}_MANIFEST=\"https://github.com/dappnode/DNP_${comp}/releases/download/v${!ver}/dappnode_package.json\""
    eval "${comp}_YML_FILE=\"${DAPPNODE_CORE_DIR}docker-compose-${comp,,}.yml\""
    eval "${comp}_FILE=\"${DAPPNODE_CORE_DIR}${comp,,}.dnp.dappnode.eth_${!ver##*:}.tar.xz\""
    eval "${comp}_ENV_FILE=\"${DAPPNODE_CORE_DIR}${comp,,}.dnp.dappnode.eth.env\""
    eval "${comp}_MANIFEST_FILE=\"${DAPPNODE_CORE_DIR}dappnode_package-${comp,,}.json\""
done

dappnode_core_build()
{
    for comp in "${components[@]}"; do
        ver="${comp}_VERSION"
        file="${comp}_FILE"
        if [[ ${!ver} == dev:* ]]; then
            echo "Cloning & building DNP_${comp}..."
            pushd $DAPPNODE_CORE_DIR
            git clone -b "${!ver##*:}" https://github.com/dappnode/DNP_${comp}
            # Change version in YAML to the custom one
            sed -i "s~^\(\s*image\s*:\s*\).*~\1${comp,,}.dnp.dappnode.eth:${!ver##*:}~" DNP_${comp}/docker-compose.yml
            docker-compose -f ./DNP_${comp}/docker-compose.yml build
            cp ./DNP_${comp}/docker-compose.yml $DAPPNODE_CORE_DIR/docker-compose-${comp,,}.yml
            rm -r ./DNP_${comp}
            popd
        fi
    done
}

dappnode_core_download()
{
    for comp in "${components[@]}"; do
        ver="${comp}_VERSION"
        if [[ ${!ver} != dev:* ]]; then
            # Download DAppNode Core Images if it's needed
            eval "[ -f \$${comp}_FILE ] || $WGET -O \$${comp}_FILE \$${comp}_URL"
            # Download DAppNode Core docker-compose yml files if it's needed
            eval "[ -f \$${comp}_YML_FILE ] || $WGET -O \$${comp}_YML_FILE \$${comp}_YML"
            # Download DAppNode Core env files if it's needed
            eval "[ -f \$${comp}_ENV_FILE ] || ( $WGET -O/dev/null -q \$${comp}_ENV && $WGET -O \$${comp}_ENV_FILE \$${comp}_ENV )"
            # Download DAppNode Core env files if it's needed
            eval "[ -f \$${comp}_MANIFEST_FILE ] || $WGET -O \$${comp}_MANIFEST_FILE \$${comp}_MANIFEST"
        fi
    done
}

dappnode_core_load()
{
    for comp in "${components[@]}"; do
        ver="${comp}_VERSION"
        if [[ ${!ver} != dev:* ]]; then
            eval "[ ! -z \$(docker images -q ${comp,,}.dnp.dappnode.eth:${!ver##*:}) ] || docker load -i \$${comp}_FILE 2>&1 | tee -a \$LOG_DIR"
        fi
    done

    # Delete build lines from yml
    sed -i '/build:\|context:\|dockerfile/d' $DAPPNODE_CORE_DIR/*.yml | tee -a $LOG_DIR
}

customMotd()
{
    if [ -f ${MOTD_FILE} ]; then
    cat <<EOF > ${MOTD_FILE}
 ___   _             _  _         _
|   \ /_\  _ __ _ __| \| |___  __| |___
| |) / _ \| '_ \ '_ \ .  / _ \/ _  / -_)
|___/_/ \_\ .__/ .__/_|\_\___/\__,_\___|
          |_|  |_|
EOF
    fi
}

addSwap()
{
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
        echo '/swapfile none swap defaults 0 0' >> /etc/fstab
    else
        echo -e '\e[32mSwap found. No changes made.\e[0m'
    fi
}

dappnode_start()
{
    echo -e "\e[32mDAppNode starting...\e[0m" 2>&1 | tee -a $LOG_DIR
    docker-compose -f $BIND_YML_FILE -f $IPFS_YML_FILE -f $ETHCHAIN_YML_FILE -f $ETHFORWARD_YML_FILE -f $VPN_YML_FILE -f $WAMP_YML_FILE -f $DAPPMANAGER_YML_FILE -f $ADMIN_YML_FILE -f $WIFI_YML_FILE up -d 2>&1 | tee -a $LOG_DIR
    echo -e "\e[32mDAppNode started\e[0m" 2>&1 | tee -a $LOG_DIR

    # Show credentials to the user on login
    USER=$(cat /etc/passwd | grep 1000  | cut -f 1 -d:)
    [ ! -z $USER ] && PROFILE=/home/$USER/.profile || PROFILE=/root/.profile

    if [ ! "$(grep -qF ".dappnode_profile" $PROFILE)" ]; then
        echo "########          DAPPNODE PROFILE          ########" >> $PROFILE
        echo -e "source ${DAPPNODE_CORE_DIR}.dappnode_profile\n" >> $PROFILE
    fi

    sed -i '/return/d' $PROFILE_FILE| tee -a $LOG_DIR

    if [ ! "$(grep -qF "getAdminCredentials" $PROFILE_FILE)" ]; then
        echo "docker exec DAppNodeCore-vpn.dnp.dappnode.eth getAdminCredentials" >> $PROFILE_FILE
        echo "echo -e \"\n\e[32mOnce connected through the VPN (OpenVPN) you can access to the administration console by following this link:\e[0m\"" >> $PROFILE_FILE
        echo "echo -e \"\nhttp://my.dappnode/\n\"" >> $PROFILE_FILE
        echo -e "return\n" >> $PROFILE_FILE
    else
        # Run first generation
        docker exec DAppNodeCore-vpn.dnp.dappnode.eth getAdminCredentials
    fi

    # Delete dappnode_install.sh execution from rc.local if exists, and is not the unattended firstboot
    if [ -f "/etc/rc.local" ] && [ ! -f "/usr/src/dappnode/.firstboot" ]; then
        sed -i '/\/usr\/src\/dappnode\/scripts\/dappnode_install.sh/d' /etc/rc.local 2>&1 | tee -a $LOG_DIR
    fi
}

##############################################
##############################################
####             SCRIPT START             ####
##############################################
##############################################

echo -e "\e[32m\n##############################################\e[0m" 2>&1 | tee -a $LOG_DIR
echo -e "\e[32m##############################################\e[0m" 2>&1 | tee -a $LOG_DIR
echo -e "\e[32m####          DAPPNODE INSTALLER          ####\e[0m" 2>&1 | tee -a $LOG_DIR
echo -e "\e[32m##############################################\e[0m" 2>&1 | tee -a $LOG_DIR
echo -e "\e[32m##############################################\e[0m" 2>&1 | tee -a $LOG_DIR

echo -e "\e[32mCreating swap memory...\e[0m" 2>&1 | tee -a $LOG_DIR
addSwap

echo -e "\e[32mCustomizing login...\e[0m" 2>&1 | tee -a $LOG_DIR
customMotd

echo -e "\e[32mBuilding DAppNode Core if needed...\e[0m" 2>&1 | tee -a $LOG_DIR
dappnode_core_build

echo -e "\e[32mDownloading DAppNode Core...\e[0m" 2>&1 | tee -a $LOG_DIR
dappnode_core_download

echo -e "\e[32mLoading DAppNode Core...\e[0m" 2>&1 | tee -a $LOG_DIR
dappnode_core_load

if [ ! -f "/usr/src/dappnode/.firstboot" ]; then
    echo -e "\e[32mDAppNode installed\e[0m" 2>&1 | tee -a $LOG_DIR
    dappnode_start
fi

# Run test in interactive terminal
if [ -f "/usr/src/dappnode/.firstboot" ]; then
   openvt -s -w /usr/src/dappnode/scripts/dappnode_test_install.sh
fi

[ ! -f "/usr/src/dappnode/iso_install.log" ] && source "${PROFILE_FILE}"

exit 0
