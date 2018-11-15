#!/bin/bash

source ./.dappnode_profile

DAPPNODE_CORE_DIR="/images/"

WGET="wget"

components=(BIND IPFS ETHCHAIN ETHFORWARD VPN WAMP DAPPMANAGER ADMIN)

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
            eval "[ -f \$${comp}_ENV_FILE ] || $WGET -O/dev/null -q \$${comp}_ENV && $WGET -O \$${comp}_ENV_FILE \$${comp}_ENV"
            # Download DAppNode Core env files if it's needed
            eval "[ -f \$${comp}_MANIFEST_FILE ] || $WGET -O \$${comp}_MANIFEST_FILE \$${comp}_MANIFEST"
        fi
    done
}

echo -e "\e[32mDownloading DAppNode Core...\e[0m"
dappnode_core_download

mkdir -p dappnode/DNCORE

echo -e "\e[32mCopying files...\e[0m"
cp /images/*.tar.xz dappnode/DNCORE
cp /images/*.yml dappnode/DNCORE
cp /images/*.json dappnode/DNCORE
cp /images/*.env dappnode/DNCORE
cp ./.dappnode_profile dappnode/DNCORE