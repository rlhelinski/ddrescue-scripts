#!/bin/sh

set -x
set -e

run_foremost () {
    image_path="$1"
    image_basename=`basename "$image_path" .img`

    if [ ! -d "$image_basename" ]; then mkdir "$image_basename" ; fi
    foremost -v -b 512 -o "$image_basename/foremost" -i "$image_path"
}

for image_path in *.img ; do
    run_foremost "$image_path"
done
