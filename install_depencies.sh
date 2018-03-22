#!bin/bash 

# Source the detection script and write it to DETECTOS variable and print it in 
# the console.
#. ./dappnode/scripts/sherlock

   DETECTOS=`dappnode/scripts/sherlock`

detect () {

# runs the different isntall scripts for each supported OS
if [ "$DETECTOS" = "centos" ] ; then
	sh dappnode/scripts/depend_install/linux/redhat_docker_installer.sh
	sh dappnode/scripts/depend_install/linux/linux_docker_compose_installer.sh
elif [ "$DETECTOS" = "darwin" ] ; then
	sh dappnode/scripts/depend_install/unix/osx_docker_installer.sh
	sh dappnode/scripts/depend_install/unix/unix_docker_compose_installer.sh
elif [ "$DETECTOS" = "fedora" ] ; then
        sh dappnode/scripts/depend_install/linux/fedora_docker_installer.sh
        sh dappnode/scripts/depend_install/linux/linux_docker_compose_installer.sh	
elif [ "$DETECTOS" = "Ubuntu" ] ; then
        cp -r dappnode /usr/src/dappnode
	sh dappnode/scripts/depend_install/linux/debian_docker_installer.sh
	sh dappnode/scripts/depend_install/linux/linux_docker_compose_installer.sh
elif [ "$DETECTOS" = "debian" ] ; then
        sh dappnode/scripts/depend_install/linux/debian_docker_installer.sh
	sh dappnode/scripts/depend_install/linux/linux_docker_compose_installer.sh
fi
}

echo "Detected OS: '$DETECTOS' "

detect
