#!/bin/sh
dockerd &
sleep 5;

/usr/src/app/generate_docker_images.sh
/usr/src/app/generate_dappnode_iso.sh