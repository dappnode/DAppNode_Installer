#!/bin/sh
dockerd &
sleep 5;

rm -f /images/*.tar.xz
rm -f /images/*.yml


if [ "$BUILD" = true ]; then
    /usr/src/app/generate_docker_images.sh
else
    /usr/src/app/download_core.sh
fi

#file generated to detectd ISO installation
touch dappnode/iso_install.log

if [ "$UBUNTU" = "18.04" ]; then
    /usr/src/app/generate_dappnode_iso.18.04.sh
else
    /usr/src/app/generate_dappnode_iso.16.04.sh
fi
