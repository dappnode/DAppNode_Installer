#!/bin/sh

echo "Downloading debian ISO image: debian-testing-amd64-netinst.iso..."
if [ ! -f /images/debian-testing-amd64-netinst.iso ]; then
    wget https://cdimage.debian.org/cdimage/weekly-builds/amd64/iso-cd/debian-testing-amd64-netinst.iso \
    -O /images/debian-testing-amd64-netinst.iso
fi
echo "Done!"

echo "Clean old files..."
rm -rf dappnode-iso
rm DappNode-debian-*

echo "Extracting the iso..."
xorriso -osirrox on -indev /images/debian-testing-amd64-netinst.iso \
 -extract / dappnode-iso

echo "Obtaining the isohdpfx.bin for hybrid ISO..."
dd if=/images/debian-testing-amd64-netinst.iso bs=432 count=1 \
of=dappnode-iso/isolinux/isohdpfx.bin

cd dappnode-iso

echo "Creating necessary directories and copying files..."
mkdir dappnode
cp -r ../dappnode/* dappnode/

echo "Downloading third-party packages..."
sed '1,/^\#\!ISOBUILD/!d' ../dappnode/scripts/dappnode_install_pre.sh > /tmp/vars.sh
source /tmp/vars.sh
mkdir -p dappnode/bin/docker
cd dappnode/bin/docker
wget ${DOCKER_URL}
wget ${DOCKER_CLI_URL}
wget ${CONTAINERD_URL}
wget ${DCMP_URL}
cd -

echo "Customizing preseed..."
mkdir /tmp/makeinitrd
cd install.amd
cp initrd.gz /tmp/makeinitrd/
if [[  ${UNATTENDED} == "true" ]]; then
    cp ../../dappnode/scripts/preseed_unattended.cfg /tmp/makeinitrd/preseed.cfg
else
    cp ../../dappnode/scripts/preseed.cfg /tmp/makeinitrd/preseed.cfg
fi
cd /tmp/makeinitrd
gunzip initrd.gz
cpio -id -H newc< initrd
cat initrd | cpio -t > /tmp/list
echo "preseed.cfg" >> /tmp/list
rm initrd
cpio -o -H newc < /tmp/list > initrd
gzip initrd
cd -
mv /tmp/makeinitrd/initrd.gz ./initrd.gz
cd ..

echo "Configuring the boot menu for DappNode..."
cp ../boot/menu.cfg isolinux/menu.cfg
cp ../boot/txt.cfg isolinux/txt.cfg
cp ../boot/splash.png isolinux/splash.png

echo "Fix md5 sum..."
md5sum `find ! -name "md5sum.txt" ! -path "./isolinux/*" -type f` > md5sum.txt

echo "Generating new iso..."
xorriso -as mkisofs -isohybrid-mbr isolinux/isohdpfx.bin \
-c isolinux/boot.cat -b isolinux/isolinux.bin -no-emul-boot -boot-load-size 4 \
-boot-info-table -eltorito-alt-boot -e boot/grub/efi.img -no-emul-boot \
-isohybrid-gpt-basdat -o /images/DAppNode-debian-9.8.0-amd64.iso .
