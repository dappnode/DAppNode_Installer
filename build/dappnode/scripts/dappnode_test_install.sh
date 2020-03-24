#!/bin/bash

error_exit() {
    echo -e "\e[31m Error on installation!!! \n \e[0m"
    read -r -p "Check installation source. Press enter to continue"
    exit 1
}

echo "DAppNode Installation Test"
echo "##########################"

components=(BIND IPFS ETHFORWARD VPN WAMP DAPPMANAGER ADMIN WIFI)

if docker -v >/dev/null 2>&1; then
    echo -e "\e[32m Docker installed ok\n \e[0m"
else
    error_exit
fi

if docker-compose -v >/dev/null 2>&1; then
    echo -e "\e[32m docker-compose installed ok\n \e[0m"
else
    error_exit
fi

for comp in "${components[@]}"; do
    if docker images | grep "${comp,,}" >/dev/null 2>&1; then
        echo -e "\e[32m ${comp} docker image loaded ok\n \e[0m"
    else
        echo -e "\e[31m ${comp} docker image not loaded ok! \n \e[0m"
        error_exit
    fi
done

rm /usr/src/dappnode/.firstboot
read -r -p "Test completed successfully. Press enter to continue"
