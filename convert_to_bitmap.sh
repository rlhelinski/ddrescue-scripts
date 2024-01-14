#!/bin/sh

set -x
set -e

make_visual_image () {
    image_path="$1"
    image_basename=`basename "$image_path" .img`
    block_size=512
    floppy_size=`expr $block_size '*' 2 '*' 1440`
    image_width=$block_size
    image_height=`expr $floppy_size / $image_width`

    if [ ! -d "$image_basename" ]; then mkdir "$image_basename" ; fi

    #convert -verbose -size $bitmap_size -depth 8 GRAY:"$image_path" "$image_path.rgb.png"
    PAD_PATH=`mktemp -t --suffix=.img padded.XXX`
    cp "$image_path" "$PAD_PATH"
    chmod +w "$PAD_PATH"
    truncate -s $floppy_size "$PAD_PATH"
    convert -verbose -size ${image_width}x${image_height} -depth 8 gray:"$PAD_PATH" "${image_basename}/${image_basename}.gray.png"
    #convert -verbose -size 1024x1440 -depth 8 gray:"$image_path" "$image_path.gray.png"
# convert -verbose -size 1200x409 -depth 24 RGB:FLOPPYWin2k_W2PFPB2_EN_1704927877.img FLOPPYWin2k_W2PFPB2_EN_1704927877.rgb.png
# convert -verbose -size 1474560x1 -depth 24 RGB:FLOPPYWin2k_W2PFPB2_EN_1704927877.img -crop 1024x1 +repage +write info: -append +repage FLOPPYWin2k_W2PFPB2_EN_1704927877.rgb.png

}

for image_path in *.img ; do
    make_visual_image "$image_path"
done
