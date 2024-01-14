#!/bin/bash

set -x
set -e

FLOPPY_DEV_ID="usb-MITSUMI_MITSUMI_USB_FDD_061M"
if [ ! -e /dev/disk/by-id/$FLOPPY_DEV_ID ]
then
	FLOPPY_DEV_ID="usb-TEACV0.0_TEACV0.0"
fi

FLOPPY_DEV=/dev/disk/by-id/`readlink /dev/disk/by-id/${FLOPPY_DEV_ID}`

if [ ! -e $FLOPPY_DEV ]
then
    exit
fi

#BACKUP_PATH=/nfs/tmp/salvage/floppy/

LABEL=
if [ $# -gt 0 ]
then
    LABEL=_$1
else
    read -p "Enter a label for this image (enter if no label): " LABEL
    if [ -z $LABEL ] ; then LABEL=unlabeled ; fi
fi


# -i flag?
FLOPPY_VOL_ID=$(dosfslabel $FLOPPY_DEV || echo INVALID)
#IMG_ID=${ID_FS_LABEL_SAFE}_${ID_FS_UUID}_$(date +%s)
IMG_ID=FLOPPY_${LABEL}_${FLOPPY_VOL_ID}_$(date +%s)

date
echo "Writing to $IMG_ID.*"

ddrescue -b 512 -c 18 -d -r 3 $FLOPPY_DEV "$IMG_ID.img" "$IMG_ID.map" || echo "ddrescue Failed"
#rsync -avP "$IMG_ID.img" "$IMG_ID.map" ${BACKUP_PATH}


# Extra credit
#foremost -o "$IMG_ID.foremost" "$IMG_ID.img"
