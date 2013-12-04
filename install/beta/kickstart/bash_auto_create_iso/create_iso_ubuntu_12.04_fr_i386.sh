#! /bin/bash
 
#thank mutech http://www.utech.de/2013/05/shell-script-creating-a-cd-for-unattended-ubuntu-server-installations/ for the script
#
# General configuration
#
mkdir -p /root/ubuntu-unattended
basedir="/root/ubuntu-unattended"
downloads="/root"
tmpdir="${TMPDIR:-/tmp}"
builddir="$tmpdir/build.$$"
mntdir="$tmpdir/mnt.$$"
 
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
 
#
# Target settings
#
target_base_name="${release_base_name}-auto"
target_directory="$basedir"
target_image_file="$target_base_name.iso"
 
progress() {
    echo "$*" >&2
}
 
error() {
    code="$1"; shift
    echo "ERROR: $*" >&2
    exit $code
}
 
create_directory() {
    path="$1"
    if [ ! -d "$path" ]; then
    progress "Creating directory $path..."
    mkdir -p "$path" || error 2 "Failed to create directory $path"
    fi
}
 
extract_iso() {
    archive="$1"
    if [ ! -r "$archive" ]; then
    error 1 "Cannot read ISO image $archive."
    fi
    directory="$2"
    if [ ! -d "$directory" ]; then
    mkdir "$directory" || exit 2 "Cannot extract CD to $directory"
    fi
 
    progress "Mounting image $archive (you may be asked for your password to authorize)..."
    create_directory "$mntdir"
    sudo mount -r -o loop "$archive" "$mntdir" || error 2 "Failed to mount image $archive"
 
    progress "Copying image contents..."
    cp -rT "$mntdir" "$directory" || error 2 "Failed to copy content of image $archive to $directory"
    chmod -R u+w "$directory"
 
    progress "Unmounting image $archive from $mntdir..."
    sudo umount "$mntdir"
    rmdir "$mntdir"
}
 
preset_language() {
    progress "Presetting language to 'en'..."
    echo "fr" >"isolinux/lang" || error 2 "Failed to write $(pwd)/isolinux/lang"
}
 
create_kscfg() {
    if [ ! -f "ks.cfg" ]; then
    progress "download ks.cfg file..."
wget https://raw.github.com/zpanel/installers/master/install/beta/kickstart/ubuntu_12.04_fr/i386/ks.cfg
    fi
}
 
create_kspreseed() {
    if [ ! -f "ks.preseed" ]; then
    progress "Create ks.preseed file..."
    cat >"ks.preseed" <<EOF
d-i partman/confirm_write_new_label boolean true
d-i partman/choose_partition \
select Finish partitioning and write changes to disk
d-i partman/confirm boolean true
EOF
    fi
}
 
patch_txtcfg() {
    (cd "isolinux";
    patch -p0 <<EOF
*** txt.cfg.orig    2013-05-14 10:06:19.000000000 +0200
--- txt.cfg 2013-05-14 10:07:54.000000000 +0200
***************
*** 2,8 ****
  label install
    menu label ^Install Ubuntu Server
    kernel /install/vmlinuz
!   append  file=/cdrom/preseed/ubuntu-server.seed vga=788 initrd=/install/initrd.gz quiet --
  label cloud
    menu label ^Multiple server install with MAAS
    kernel /install/vmlinuz
--- 2,8 ----
  label install
    menu label ^Install Ubuntu Server
    kernel /install/vmlinuz
!   append  file=/cdrom/preseed/ubuntu-server.seed initrd=/install/initrd.gz ks=cdrom:/ks.cfg preseed/file=/cdrom/ks.preseed --
  label cloud
    menu label ^Multiple server install with MAAS
    kernel /install/vmlinuz
EOF
    )
}
 
patch_isolinuxcfg() {
    (cd "isolinux";
    patch -p0 <<EOF
*** isolinux.cfg.orig   2013-05-14 10:20:37.000000000 +0200
--- isolinux.cfg    2013-05-14 10:20:50.000000000 +0200
***************
*** 2,6 ****
  include menu.cfg
  default vesamenu.c32
  prompt 0
! timeout 0
  ui gfxboot bootlogo
--- 2,6 ----
  include menu.cfg
  default vesamenu.c32
  prompt 0
! timeout 5
  ui gfxboot bootlogo
EOF
    )
}
 
modify_release() {
    preset_language && \
    create_kscfg && \
    create_kspreseed && \
    patch_txtcfg && \
    patch_isolinuxcfg
}
 
create_image() {
    if [ ! -f "$target_directory/$target_image_file" ]; then
    if [ ! -f "$downloads/$release_image_file" ]; then
        progress "Downloading Ubuntu $release_name $release_variant..."
        curl "$release_url" -o "$downloads/$release_image_file"
    fi
    create_directory "$builddir"
    extract_iso "$downloads/$release_image_file" "$builddir"
    (cd "$builddir" && modify_release
    ) || error 2 "Failed to modify image"
 
    create_directory "$target_directory"
    progress "Creating ISO image $target_image_file..."
    mkisofs -D -r -V "UNATTENDED_UBUNTU" -cache-inodes -J -l \
        -b isolinux/isolinux.bin \
        -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 \
        -boot-info-table \
        -o "$target_directory/$target_image_file" \
        "$builddir" || error 2 "Failed to create image $target_image_file"
    if [ "x$builddir" != x -a "x$builddir" != "x/" ]; then
        rm -rf "$builddir"
    fi
    fi
}
 
create_image
