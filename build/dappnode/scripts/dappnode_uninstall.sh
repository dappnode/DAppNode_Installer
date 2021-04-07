#!/usr/bin/env bash
DAPPNODE_DIR="/usr/src/dappnode"
DAPPNODE_CORE_DIR="${DAPPNODE_DIR}/DNCORE"
PROFILE_FILE="${DAPPNODE_CORE_DIR}/.dappnode_profile"

[ -f $PROFILE_FILE ] || (
    echo "Error: DAppNode profile does not exist."
    exit 1
)

uninstall() {
    source "${PROFILE_FILE}"

    # Remove DAppNodePackages
    find /var/lib/docker/volumes/dncore_dappmanagerdnpdappnodeeth_data/_data -name "*yml" -exec bash -c "docker-compose -f {} down  --rmi 'all' -v" \;

    # Disconnect all packages from the network
    docker container ls -a -q -f name=DAppNode* | xargs -I {} docker network disconnect dncore_network {}

    # Remove containers, volumes and images
    for comp in "${DNCORE_YMLS_ARRAY[@]}"; do
        docker-compose -f $comp down --rmi 'all' -v
    done

    # Remove dncore_network
    docker network remove dncore_network || echo "dncore_network already removed"

    # Remove dir
    rm -rf /usr/src/dappnode

    # Remove profile file
    USER=$(cat /etc/passwd | grep 1000 | cut -f 1 -d:)
    [ -n "$USER" ] && PROFILE=/home/$USER/.profile || PROFILE=/root/.profile
    sed -i '/########          DAPPNODE PROFILE          ########/g' $PROFILE
    sed -i '/.*dappnode_profile/g' $PROFILE

    echo "DAppNode uninstalled!"
}

read -r -p "WARNING: This script will uninstall and delete all DAppNode
containers and volumes. Are You Sure? [Y/n] " input <&2

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
