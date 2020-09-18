#!/bin/bash

## downloading rar files 
function download_rars {
x=1
while read line
do  
  url_normal=$(sed -n ${x}p /home/cika/txts/rars.txt)
  url_premium=$(curl -b /home/cika/txts/cookies.txt "$url_normal" | \
  awk -F"'" '/premium_download_link/{ print $2 }')
  echo "url premium is:"
  echo "$url_premium"
  curl -o /home/cika/rars/${x}.rar "$url_premium"
  let x=x+1
done </home/cika/txts/rars.txt
}

## downloading and resizing covers
function download_jpgs {
x=1
while read line
do
  jpg=/home/cika/jpgs/${x}.jpg
  wget -O $jpg $line
  mogrify -resize x360 $jpg
  composite -gravity center $jpg /home/cika/background.jpg $jpg
  let x=x+1 
done < /home/cika/txts/covers.txt
}

## extracting rars and moving matched cover into folder
function extract_rars {
x=1
for file in /home/cika/rars/*.rar
do
  rar=$(ls -rt /home/cika/rars/ | sed -n ${x}p)
  rar x /home/cika/rars/${rar} /home/cika/tmp/
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
  video=$(basename "$mp3" .mp3)
  ffmpeg -loop_input -i "$background" -i "$mp3" -shortest \
  -acodec copy "$folder"/output.mpg
  cat /home/cika/intro.mpg "$folder"/output.mpg > "$folder"/"$video".mpg
  rm "$folder"/output.mpg 
  ffmpeg -i "$folder"/"$video".mpg -acodec copy "$folder"/"$video".mp4
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
