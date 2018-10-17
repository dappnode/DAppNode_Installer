#!/bin/sh
dockerd &
sleep 5;

rm -f /images/*.tar.xz
rm -f /images/*.yml


if [ "$BUILD" = true ]; then
    /opt/app/generate_docker_images.sh
else
    /opt/app/download_core.sh
fi

#file generated to detectd ISO installation
touch dappnode/iso_install.log

if [ "$UBUNTU" = "18.04" ]; then
    /opt/app/generate_dappnode_iso.18.04.sh
else
    /opt/app/generate_dappnode_iso.16.04.sh
fi
