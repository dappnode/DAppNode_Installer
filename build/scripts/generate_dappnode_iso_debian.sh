#!/bin/sh

echo "Downloading debian ISO image: debian-9.8.0-amd64-xfce-CD-1.iso..."
if [ ! -f /images/debian-9.8.0-amd64-xfce-CD-1.iso ]; then
    wget https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-9.8.0-amd64-xfce-CD-1.iso \
    -O /images/debian-9.8.0-amd64-xfce-CD-1.iso
fi
echo "Done!"

echo "Clean old files..."
rm -rf dappnode-iso
rm DappNode-debian-*

echo "Extracting the iso..."
xorriso -osirrox on -indev /images/debian-9.8.0-amd64-xfce-CD-1.iso \
 -extract / dappnode-iso

echo "Obtaining the isohdpfx.bin for hybrid ISO..."
dd if=/images/debian-9.8.0-amd64-xfce-CD-1.iso bs=432 count=1 \
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
cp ../../dappnode/scripts/preseed.cfg /tmp/makeinitrd
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
# both gtk and text?
#echo "preseed.cfg" > list
#cpio -o -v -H newc -A -F initrd < list > initrd
# to test with gtk one
#echo "header.png" | cpio -o -H newc -A -p /path/to/image -F initrd 
cd ..

echo "Configuring the boot menu for DappNode..."
#rm -f boot/grub/grub.cfg
#cp ../boot/grub.cfg boot/grub/grub.cfg
cp ../boot/menu.cfg isolinux/menu.cfg
cp ../boot/txt.cfg isolinux/txt.cfg
cp ../boot/splash.png isolinux/splash.png
# cd isolinux
# cpio -id init < bootlogo
# cat bootlogo | cpio -t > /tmp/list
# cp ../../boot/txt.cfg txt.cfg
# cp ../../boot/splash.pcx splash.pcx
# cp ../../boot/gfxboot.cfg gfxboot.cfg
# cpio -o < /tmp/list > bootlogo
# cd ..

echo "Fix md5 sum..."
md5sum `find ! -name "md5sum.txt" ! -path "./isolinux/*" -type f` > md5sum.txt

echo "Generating new iso..."
xorriso -as mkisofs -isohybrid-mbr isolinux/isohdpfx.bin \
-c isolinux/boot.cat -b isolinux/isolinux.bin -no-emul-boot -boot-load-size 4 \
-boot-info-table -eltorito-alt-boot -e boot/grub/efi.img -no-emul-boot \
-isohybrid-gpt-basdat -o /images/DAppNode-debian-9.8.0-amd64.iso .
