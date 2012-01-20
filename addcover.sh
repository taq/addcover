#!/bin/bash
# 
# addcover.sh - Add an image to a MP3 file
# 
# Homepage: http://github.com/taq/addcover
# Author: Eustaquio 'TaQ' Rangel
# 
# Run this script on a directory to search and, if found,
# add an image to MP3 files, as the cover image, for files
# that *don't have a cover image*.
# If needed, it converts the ID3 tag to the latest version
# (2.4 right now).
# 
# Dependencies: eyeD3 is the heart of the script
#
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
VERSION=1.0
cover="cover.jpg"

header() {
   echo ----------------------------------------------------------
   echo addimage.sh - adding images to MP3 files, version $VERSION
   echo ----------------------------------------------------------
   echo -ne "\n"
}

check_eyed3() {
   echo -n checking for eyeD3 ...
   local eyed3ok=$(which eyeD3)
   if [ -z "$eyed3ok" ]; then
      echo "you need eyeD3 (http://eyed3.nicfit.net/) to run this script"
      exit 1
   fi
   echo " found."
   echo -ne "\n"
}

cover_img() {
   echo "checking default cover image ..."
   # find the cover image
   if [ ! -f "$cover" ]; then
      echo "default cover not found, searching for some image ..."
      local first=$(find -type f -iname '*.jpg' -o -iname '*.gif' -o -iname '*.png' | sort | head -n1)
      if [ -z "$first" ]; then
         echo "no image found, exiting ..."
         exit 1
      fi
      cover="$first"
   fi
   echo "using $cover image file ..."
   echo -ne "\n"
}

header
while [ "$1" ]; do
   case $1 in 
      -v) exit 0;;
      -c) check_eyed3; exit 0;;
      -i) cover_img; exit 0;;
   esac
   shift
done

check_eyed3
cover_img

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
      echo file already have cover image
   fi      
   echo -ne "\n"
done

IFS=$SAVEIFS
