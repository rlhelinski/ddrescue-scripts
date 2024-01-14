#!/bin/bash

set -x
set -e

FLOPPY_DEV_ID="usb-MITSUMI_MITSUMI_USB_FDD_061M"
if [ ! -e /dev/disk/by-id/$FLOPPY_DEV_ID ]
then
	FLOPPY_DEV_ID="usb-TEACV0.0_TEACV0.0"
fi

FLOPPY_DEV=`readlink /dev/disk/by-id/${FLOPPY_DEV_ID}` || echo "No device found"
FLOPPY_DEV=/dev/disk/by-id/`readlink /dev/disk/by-id/${FLOPPY_DEV_ID}`

if [ ! -e $FLOPPY_DEV ]
then
    exit
fi

# ufiformat is specifically for formatting USB floppy disks
# These use a SCSI connection instead of traditional /dev/fd*

echo "Query the device for available formats:"
#modprobe sg
ufiformat -i ${FLOPPY_DEV}

read -p "Continue with destructive low-level format? (Ctrl+C to abort)" response

time ufiformat -v ${FLOPPY_DEV}
time mkdosfs -n "TEST" -I ${FLOPPY_DEV}

mkdir /media/floppy || echo "No problem"
mount -o rw,user,noauto,exec,gid=floppy,umask=007 ${FLOPPY_DEV} /media/floppy
touch /media/floppy/test
TEST_STRING="This is a test $(date)"
echo "${TEST_STRING}" > /media/floppy/test
umount ${FLOPPY_DEV}
rmdir /media/floppy
sync

IMG_PATH=`mktemp -t --suffix=.img floppy_test.XXX`
MAP_PATH=`mktemp -t --suffix=.map floppy_test.XXX`
ddrescue -b 512 -c 18 -d -r 3 ${FLOPPY_DEV} "${IMG_PATH}" "${MAP_PATH}" || echo "ddrescue Failed"

grep -U "${TEST_STRING}" "${IMG_PATH}" && echo "Found test string in image" || echo "Did not find test string in image"
