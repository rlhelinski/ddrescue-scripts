#!/bin/sh

set -x
set -e

extract_image () {
    image_path="$1"
    image_basename=`basename "$image_path" .img`
    mount_options="loop,ro,nosuid,nodev,relatime,uid=$(id -u),gid=$(id -g),fmask=0022,dmask=0022,codepage=437,iocharset=iso8859-1,shortname=mixed,showexec,utf8,flush,errors=remount-ro,uhelper=udisks2"

    mount_dir=`mktemp -t -d floppy.XXX`
    sudo mount -t vfat -o "$mount_options" "$image_path" "$mount_dir" || return 0
    if [ ! -d "$image_basename" ]; then mkdir "$image_basename" ; fi
    cp -r "$mount_dir" "$image_basename/fat"
    sudo umount "$mount_dir"
    rmdir "$mount_dir"
}

for image_path in *.img ; do
    extract_image "$image_path"
done
