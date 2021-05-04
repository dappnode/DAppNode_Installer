#!/bin/sh
set -e

dockerd &
sleep 5

if [ "$CLEAN" = true ]; then
    rm -f /images/*.tar.xz
    rm -f /images/*.yml
    rm -f /images/*.json
    rm -f /images/*.txz
fi

if [ "$BUILD" = true ]; then
    /usr/src/app/generate_docker_images.sh
else
    /usr/src/app/download_core.sh
fi

#file generated to detectd ISO installation
touch dappnode/iso_install.log

/usr/src/app/generate_dappnode_iso_debian.sh
