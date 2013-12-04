#! /bin/bash
#
# General configuration
#
mkdir -p /root/ubuntu-unattended
basedir="/root/ubuntu-unattended"
downloads="/root"
builddir="/tmp/build"
mntdir="/tmp/mnt"
 
#
# Ubuntu release selection
#
release_name="precise"
release_version="12.04.3"
release_variant="server"
release_architecture="i386"
 
release_base_url="http://releases.ubuntu.com"
release_base_name="ubuntu-$release_version-$release_variant-$release_architecture"
release_image_file="$release_base_name.iso"
release_url="$release_base_url/$release_name/$release_image_file"
target_image_file="Ubuntu-$release_version-Zpanel-Autoinstall.iso"

rm -rf $builddir

rm -rf $mntdir

if [ -f $downloads/$release_image_file ] ; then
echo "not download required"
else
echo "download iso"
wget curl $release_url -o $downloads
fi

echo "cretate mount dir"

mkdir -p $mntdir

echo "mount iso"

mount -r -o loop $downloads/$release_image_file $mntdir

echo "create build dir"

mkdir -p $builddir

echo "copy mount dir in build dir"

cp -R $mntdir/* $builddir/

echo "umont"

umount $mntdir

echo "delete umount folder"

rm -rf $mntdir

echo "download ks.cfg"

curl https://raw.github.com/zpanel/installers/master/install/beta/kickstart/ubuntu_12.04_fr/i386/ks.cfg -o $builddir

echo "create ks.pressed"

cat > $builddir/ks.preseed <<EOF
d-i partman/confirm_write_new_label boolean true
d-i partman/choose_partition \
select Finish partitioning and write changes to disk
d-i partman/confirm boolean true
EOF

echo "costum language iso"

echo "fr" > $builddir/isolinux/lang

echo "edit txt.cfg"

sed -i "s| append file=/cdrom/preseed/ubuntu-server.seed vga=788 initrd=/install/initrd.gz quiet --| append file=/cdrom/preseed/ubuntu-server.seed initrd=/install/initrd.gz ks=cdrom:/ks.cfg preseed/file=/cdrom/ks.preseed --|" $builddir/isolinux/txt.cfg

echo "edit isolinux"

sed -i "s|timeout 0|timeout 5|" $builddir/isolinux/isolinux.cfg

echo "create iso"

mkisofs -D -r -V "UBUNTU_ZPANEL_AUTOINSTALL" -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o "$basedir/$target_image_file" "$builddir"

echo "delete build dir"
rm -rf $builddir
exit
