#!/bin/bash

# PRIORITY: Wi-Wi > Avahi > VPN (Wireguard > OpenVpn)

#############
#0.VARIABLES#
#############
# Containers
WIFI_CONTAINER="DAppNodeCore-wifi.dnp.dappnode.eth"
WIREGUARD_CONTAINER="DAppNodeCore-wireguard.dnp.dappnode.eth"
OPENVPN_CONTAINER="DAppNodeCore-vpn.dnp.dappnode.eth"
HTTPS_CONTAINER="DAppNodeCore-https.dnp.dappnode.eth"
# Credentials
WIREGUARD_CREDS="docker exec $WIREGUARD_CONTAINER cat /config/peer_dappnode_admin/peer_dappnode_admin.conf"
OPENVPN_CREDS="docker exec -i $OPENVPN_CONTAINER getAdminCredentials"
WIFI_CREDS=$(cat /usr/src/dappnode/DNCORE/docker-compose-wifi.yml 2> /dev/null | grep 'SSID\|WPA_PASSPHRASE')
# Endpoints
DAPPNODE_ENDPOINT="http://my.dappnode"
DAPPNODE_AVAHI_ENDPOINT="http://my.dappnode.local"

#############
#1.FUNCTIONS#
#############

# $1 Connection method $2 Credentials
function create_connection_message () {
  echo -e "\e[32mConnect to DAppNode through $1 using the following credentials:\e[0m\n$2\nVisit \e[4m$DAPPNODE_ENDPOINT\e"
}

function wifi_connection () {
  # NOTE: network interface may be in use by host => $(cat /sys/class/net/${INTERFACE}/operstate)" !== "up")
  # NOTE: wifi has a delay up to 1 min
  INTERFACE=$(ls /sys/class/ieee80211/*/device/net 2> /dev/null)
  [ "$(docker inspect -f '{{.State.Running}}' ${WIFI_CONTAINER} 2> /dev/null)" = "true" ] && [ ! -z $INTERFACE ] && create_connection_message "Wi-Fi" "$WIFI_CREDS" && exit 0 || echo "Wifi not available"
}

function avahi_connection () {
  # Ping to avahi endpoint && avahi-daemon running => systemctl is-active avahi-daemon RETURNS "active" or "inactive"
  ping -c 1 -w 10000 $DAPPNODE_AVAHI_ENDPOINT > /dev/null 2>&1 || { echo "Avahi-daemon not available" ; return ; }
  [ "$(docker ps -a | grep ${HTTPS_CONTAINER})" ] && [ "$(docker inspect -f '{{.State.Running}}' ${HTTPS_CONTAINER})" = "true" ] && [ "$(systemctl is-active avahi-daemon)" = "active" ] &&  echo -e "Connect to DAppNode through avahi-daemon.\n$2\nVisit \e[4m$DAPPNODE_AVAHI_ENDPOINT\e" && exit 0 || echo "Avahi-daemon not available"
}

function wireguard_connection () {
  # wireguard container running
  [ "$(docker ps -a | grep ${WIREGUARD_CONTAINER})" ] && [ "$(docker inspect -f '{{.State.Running}}' ${WIREGUARD_CONTAINER})" = "true" ] && create_connection_message "Wireguard" "$($WIREGUARD_CREDS)" && exit 0 || echo "Wireguard not available"
}

function openvpn_connection () {
  # openvpn container running
  [ "$(docker ps -a | grep ${OPENVPN_CONTAINER})" ] && [ "$(docker inspect -f '{{.State.Running}}' ${OPENVPN_CONTAINER})" = "true" ] && create_connection_message "Open-VPN" "$($OPENVPN_CREDS)" && exit 0 || echo "Open-VPN not available"
}

########
#2.MAIN#
########

wifi_connection
avahi_connection
wireguard_connection
openvpn_connection

echo -e "\e[33mWARNING: no connection services available\e[0m"
exit 0