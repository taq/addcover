#!/bin/bash
cover="cover.jpg"
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

# find the cover image
if [ ! -f "$cover" ]; then
   echo default cover not found, searching for some image ...
   first=$(find -type f -iname '*.jpg' -o -iname '*.gif' -o -iname '*.png' | sort | head)
   if [ -z "$first" ]; then
      echo no image found, exiting ...
      exit 1
   fi
   cover="$first"
fi
echo using $cover image file ...

for file in $(find -iname '*.mp3'); do
   # check for the tag version
   echo checking "$file"
   echo -n checking tag ...
   tag=$(eyeD3 "$file"  | grep "^ID3" | cut -f2 -d' ' | grep -o "[0-9\.]" | tr -d '\n')
   echo " $tag"
   tag=$(echo $tag | tr -d '.')
   if [ $tag -lt 24 ]; then
      echo converting the tag for 2.4 version ...
      eyeD3 --to-v2.4 "$file" &> /dev/null
   fi

   # search and add image
   img=$(eyeD3 "$file" | grep FRONT_COVER)
   if [ -z "$img" ]; then
      echo no image, adding $cover image ...
      eyeD3 --add-image $cover:FRONT_COVER "$file" &> /dev/null
   else
      echo already have cover image
   fi      
   echo -ne "\n"
done

IFS=$SAVEIFS
