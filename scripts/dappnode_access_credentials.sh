#!/bin/bash

# This script will iterate over the access methods in dappnode
# and display its credentials based on priority.
# PRIORITY: Wi-Wi > Avahi > VPN (Wireguard > OpenVpn)

#############
#0.VARIABLES#
#############
# Containers
WIFI_CONTAINER="DAppNodeCore-wifi.dnp.dappnode.eth"
WIREGUARD_CONTAINER="DAppNodeCore-api.wireguard.dnp.dappnode.eth"
OPENVPN_CONTAINER="DAppNodeCore-vpn.dnp.dappnode.eth"
HTTPS_CONTAINER="DAppNodeCore-https.dnp.dappnode.eth"
# Credentials
WIREGUARD_GET_CREDS="docker exec -i $WIREGUARD_CONTAINER getWireguardCredentials"
OPENVPN_GET_CREDS="docker exec -i $OPENVPN_CONTAINER getAdminCredentials"
WIFI_GET_CREDS=$(cat /usr/src/dappnode/DNCORE/docker-compose-wifi.yml 2> /dev/null | grep 'SSID\|WPA_PASSPHRASE')
# Endpoints
AVAHI_ENDPOINT="dappnode.local"
DAPPNODE_ADMINUI_URL="http://my.dappnode"
DAPPNODE_ADMINUI_LOCAL_URL="http://${AVAHI_ENDPOINT}"
DAPPNODE_WELCOME_URL="http://welcome.dappnode"

#############
#1.FUNCTIONS#
#############

# How to check dappnode was initialized successfully:
# 1. docker service running
# 2. Default timeout

function dappnode_startup_delay () {
  echo "Wait until DAppNode initializes..."
  sleep 10
}

# $1 Connection method $2 Credentials
function create_connection_message () {
  echo -e "\n\e[32mConnect to DAppNode through $1 using the following credentials:\e[0m\n$2\n\nVisit \e[4m$DAPPNODE_ADMINUI_URL\e\n\n[0mCheck out all the access methods available to connect to your DAppNode at \e[4m$DAPPNODE_WELCOME_URL\e[0m\n"
}

function wifi_connection () {
  # NOTE: network interface may be in use by host => $(cat /sys/class/net/${INTERFACE}/operstate)" !== "up")
  # NOTE: wifi has a delay up to 1 min
  # wifi container running
  [ "$(docker inspect -f '{{.State.Running}}' ${WIFI_CONTAINER} 2> /dev/null)" = "true" ] && \
  # Check interface variable is set
  [ ! -z $(docker exec -it $WIFI_CONTAINER iw dev | grep 'Interface' | awk 'NR==1{print $2}') ] && \
  create_connection_message "Wi-Fi" "$WIFI_GET_CREDS" && \
  exit 0 || echo "Wifi not available"
}

function avahi_connection () {
  # Ping to avahi endpoint: -c: number of pings. -w: timeout
  avahi-resolve -n $AVAHI_ENDPOINT > /dev/null 2>&1 || { echo "Avahi-daemon not available" ; return ; }
  # Https container exists
  [ "$(docker ps -a | grep ${HTTPS_CONTAINER})" ] && \
  # Https container running
  [ "$(docker inspect -f '{{.State.Running}}' ${HTTPS_CONTAINER})" = "true" ] && \
  # Https env variable LOCAL_PROXYING="true"
  [ "$(docker exec -i ${HTTPS_CONTAINER} sh -c 'echo "$LOCAL_PROXYING"')" = "true" ] && \
  # avahi-daemon running => systemctl is-active avahi-daemon RETURNS "active" or "inactive"
  [ "$(systemctl is-active avahi-daemon)" = "active" ] && \
  echo -e "\n\e[32mConnect to DAppNode through avahi-daemon.\e[0m\n\nVisit \e[4m$DAPPNODE_ADMINUI_LOCAL_URL\e\n\n[0mCheck out all the access methods available to connect to your DAppNode at \e[4m$DAPPNODE_WELCOME_URL\e[0m\n" && \
  exit 0 || echo "Avahi-daemon not available"
}

function wireguard_connection () {
  # wireguard container exists
  [ "$(docker ps -a | grep ${WIREGUARD_CONTAINER})" ] && \
  # wireguard container running
  [ "$(docker inspect -f '{{.State.Running}}' ${WIREGUARD_CONTAINER})" = "true" ] && \
  create_connection_message "Wireguard" "$($WIREGUARD_GET_CREDS)" && \
  exit 0 || echo "Wireguard not available"
}

function openvpn_connection () {
  # openvpn container exists
  [ "$(docker ps -a | grep ${OPENVPN_CONTAINER})" ] && \
  # openvpn container running
  [ "$(docker inspect -f '{{.State.Running}}' ${OPENVPN_CONTAINER})" = "true" ] && \
  create_connection_message "Open-VPN" "$($OPENVPN_GET_CREDS)" && \
  exit 0 || echo "Open-VPN not available"
}

########
#2.MAIN#
########

dappnode_startup_delay
wifi_connection
avahi_connection
wireguard_connection
openvpn_connection

echo -e "\e[33mWARNING: no connection services available\e[0m"
exit 0