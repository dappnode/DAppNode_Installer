#!/usr/bin/env bash
DAPPNODE_DIR="/usr/src/dappnode"
DAPPNODE_CORE_DIR="${DAPPNODE_DIR}/DNCORE"
PROFILE_FILE="${DAPPNODE_CORE_DIR}/.dappnode_profile"
input=$1 # Allow to call script with argument (must be Y/N)

[ -f $PROFILE_FILE ] || (
    echo "Error: DAppNode profile does not exist."
    exit 1
)

uninstall() {
    # shellcheck source=/usr/src/dappnode/DNCORE/.dappnode_profile
    source "${PROFILE_FILE}" &>/dev/null

    # Remove DAppNodePackages
    find /var/lib/docker/volumes/dncore_dappmanagerdnpdappnodeeth_data/_data -name "*yml" -exec bash -c "docker-compose -f {} down  --rmi 'all' -v" \;

    # Disconnect all packages from the network
    docker container ls -a -q -f name=DAppNode* | xargs -I {} docker network disconnect dncore_network {}

    # Remove containers, volumes and images
    docker-compose "$DNCORE_YMLS" down --rmi 'all' -v

    # Remove dncore_network
    docker network remove dncore_network || echo "dncore_network already removed"

    # Remove dir
    rm -rf /usr/src/dappnode

    # Remove profile file
    USER=$(grep 1000 /etc/passwd | cut -f 1 -d:)
    [ -n "$USER" ] && PROFILE=/home/$USER/.profile || PROFILE=/root/.profile
    sed -i '/########          DAPPNODE PROFILE          ########/g' $PROFILE
    sed -i '/.*dappnode_profile/g' $PROFILE

    echo "DAppNode uninstalled!"
}

if [ $# -eq 0 ]; then
    read -r -p "WARNING: This script will uninstall and delete all DAppNode
containers and volumes. Are You Sure? [Y/n] " input <&2
fi


case $input in
[yY][eE][sS] | [yY])
    uninstall
    ;;
[nN][oO] | [nN])
    echo "Ok."
    ;;
*)
    echo "Invalid input. Exiting..."
    exit 1
    ;;
esac
