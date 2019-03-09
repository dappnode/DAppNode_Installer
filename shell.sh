#!/bin/bash

GIT_BRANCH="master"
DAPPNODE_DIR="/usr/src/dappnode"
DOCKER_PKG="docker-ce_18.09.3~3-0~debian-stretch_amd64.deb"
DOCKER_CLI_PKG="docker-ce-cli_18.09.3~3-0~debian-stretch_amd64.deb"
CONTAINERD_PKG="containerd.io_1.2.4-1_amd64.deb"
DOCKER_REPO="https://download.docker.com/linux/debian/dists/stretch/pool/stable/amd64"
DOCKER_PATH="${DAPPNODE_DIR}/bin/docker/${DOCKER_PKG}"
DOCKER_CLI_PATH="${DAPPNODE_DIR}/bin/docker/${DOCKER_CLI_PKG}"
CONTAINERD_PATH="${DAPPNODE_DIR}/bin/docker/${CONTAINERD_PKG}"
DCMP_PATH="/usr/local/bin/docker-compose"
DOCKER_URL="${DOCKER_REPO}/${DOCKER_PKG}"
DOCKER_CLI_URL="${DOCKER_REPO}/${DOCKER_CLI_PKG}"
CONTAINERD_URL="${DOCKER_REPO}/${CONTAINERD_PKG}"
DCMP_URL="https://github.com/docker/compose/releases/download/1.23.2/docker-compose-Linux-x86_64"

#!ISOBUILD Do not modify, variables above imported for ISO build
