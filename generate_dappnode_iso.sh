#!/bin/bash

echo "Downloading ubuntu ISO image: ubuntu-16.04.3-server-amd64.iso..."
if [ ! -f images/ubuntu-16.04.3-server-amd64.iso ]; then
    wget http://releases.ubuntu.com/16.04.3/ubuntu-16.04.3-server-amd64.iso \
    -O images/ubuntu-16.04.3-server-amd64.iso
fi
echo "Done!"

echo "Clean old files..."
sudo rm -rf dappnode-iso
sudo rm DappNode-ubuntu-*

echo "Extracting the iso..."
sudo xorriso -osirrox on -indev images/ubuntu-16.04.3-server-amd64.iso \
 -extract / dappnode-iso

echo "Obtaining the isohdpfx.bin for hybrid ISO..."
sudo dd if=images/ubuntu-16.04.3-server-amd64.iso bs=512 count=1 \
of=dappnode-iso/isolinux/isohdpfx.bin

cd dappnode-iso

echo "Creating necessary directories and copying files"
sudo mkdir dappnode
sudo cp -r ../dappnode/* dappnode/

echo "d-i preseed/late_command string \
in-target mkdir -p /usr/src/dappnode ; \
cp -ar /cdrom/dappnode/* /target/usr/src/dappnode/ ; \
cp -a /cdrom/dappnode/scripts/dappnode_cron_task /target/etc/cron.d/ ;\
cp -a /cdrom/dappnode/docker/docker-compose-Linux-x86_64 /target/usr/local/bin/docker-compose ; \
in-target chmod +x /usr/src/dappnode/scripts/docker_installer.sh ; \
in-target chmod +x /usr/src/dappnode/scripts/load_docker_images.sh ; \
in-target chmod +x /usr/local/bin/docker-compose ; \
in-target /usr/src/dappnode/scripts/docker_installer.sh" | sudo tee -a preseed/ubuntu-server.seed

echo "Generating new iso..."
xorriso -as mkisofs -isohybrid-mbr isolinux/isohdpfx.bin \
-c isolinux/boot.cat -b isolinux/isolinux.bin -no-emul-boot -boot-load-size 4 \
-boot-info-table -eltorito-alt-boot -e boot/grub/efi.img -no-emul-boot \
-isohybrid-gpt-basdat -o ../images/DappNode-ubuntu-16.04.3-server-amd64.iso .
