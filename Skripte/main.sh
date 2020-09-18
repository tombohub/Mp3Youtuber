#!/bin/bash

## downloading rar files 
function download_rars {
x=1
while read line
do  
  urlrar=$(sed -n ${x}p /home/cika/txts/rars.txt)
  plowdown -a id:pass -o /home/cika/rars/ $urlrar
  let x=x+1
done </home/cika/txts/rars.txt
}

## downloading covers
function download_jpgs {
x=1
while read line
do
  wget -O /home/cika/jpgs/${x}.jpg $line
  let x=x+1 
done < /home/cika/txts/covers.txt
}

## extracting rars and moving matched cover into folder
function extract_rars {
x=1
for file in /home/cika/rars/*.rar
do
  rar=$(ls -rt /home/cika/rars/ | sed -n ${x}p)
  rar x /home/cika/rars/"${rar}" /home/cika/tmp/
  mv /home/cika/jpgs/${x}.jpg /home/cika/jpgs/folder.jpg
  mv /home/cika/jpgs/folder.jpg /home/cika/tmp/*/ 
  mv /home/cika/tmp/* /home/cika/mp3s/
  let x=x+1
done
}

## converting mp3s to video
function make_videos {
for mp3 in /home/cika/mp3s/*/*.mp3
do 
  folder=$(dirname "$mp3")
  background="$folder"/folder.jpg
  video=$(basename "$mp3" .mp3).mp4
  ffmpeg -loop_input -i "$folder"/folder.jpg -i "$mp3" -shortest \
  -acodec copy -b 400 "$folder"/"$video" 
done
}

##copy youtube.sh to every folder
function copy {
for folder in /home/cika/mp3s/*/
do
  cp youtube.sh "$folder"
done
}

download_rars
download_jpgs
extract_rars
make_videos
copy

