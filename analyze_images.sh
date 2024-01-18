#!/bin/sh

set -x
set -e

visualize_image () {
    image_path="$1"
    block_size=512
    floppy_size=`expr $block_size '*' 2 '*' 1440`
    image_width=$block_size
    image_height=`expr $floppy_size / $image_width`

    PAD_PATH=`mktemp -t --suffix=.img padded.XXX`
    cp "$image_path" "$PAD_PATH"
    chmod +w "$PAD_PATH"
    truncate -s $floppy_size "$PAD_PATH"
    convert -verbose -size ${image_width}x${image_height} -depth 8 gray:"$PAD_PATH" "${image_basename}/${image_basename}.gray.png"
}

extract_image_files () {
    image_path="$1"
    mount_options="loop,ro,nosuid,nodev,relatime,uid=$(id -u),gid=$(id -g),fmask=0022,dmask=0022,codepage=437,iocharset=iso8859-1,shortname=mixed,showexec,utf8,flush,errors=remount-ro,uhelper=udisks2"

    mount_dir=`mktemp -t -d floppy.XXX`
    sudo mount -t vfat -o "$mount_options" "$image_path" "$mount_dir" || return 0
    cp -r "$mount_dir" "$image_basename/fat"
    sudo umount "$mount_dir"
    rmdir "$mount_dir"
}


run_foremost () {
    image_path="$1"

    foremost -v -b 512 -o "$image_basename/foremost" -i "$image_path"
}

if [ $# -eq 0 ] ; then
    image_paths=*.img
else
    image_paths=$@
fi


for image_path in $image_paths ; do
    if [ ! -f "$image_path" ] ; then
        echo "$image_path not found"
        continue
    fi
    image_basename=`basename "$image_path" .img`
    if [ ! -d "$image_basename" ]; then mkdir "$image_basename" ; fi

    visualize_image "$image_path"
    extract_image_files "$image_path"
    run_foremost "$image_path"
done
