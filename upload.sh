#!/bin/bash


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
  rm $file
  let x=x+1
done
}


## adding pitch to mp3
function pitch_mp3 {
for mp3 in /home/cika/mp3s/*/*.mp3 
do 
  cd "$(dirname "$mp3")"
  output=$(basename "$mp3" .mp3)PITCHED.mp3
  case "$mp3" in
  *PITCHED.mp3)
    echo skipping "$mp3"
	;;
  *)
    sox -S "$mp3" -C 192 "$output" pitch 50
	;;
  esac
done
}

## spajanje i povisivanje mp3-a
function combine_mp3 {
for album in /home/cika/mp3s/*
do
  cd "$album"
  sox -S --combine concatenate *.mp3 -C 192 combined.mp3 pitch $
done
}


## making full album videos 
function make_album_videos {
for mp3 in /home/cika/mp3s/*/combined.mp3
do 
  folder=$(dirname "$mp3")
  background="$folder"/folder.jpg
  video=$RANDOM.mp4
  ffmpeg -loop_input -i "$folder"/folder.jpg -i "$mp3" -shortest \
  -acodec copy "$folder"/"$video" 
done
}

## converting mp3s to video, stavljajuci cover na background
function make_track_videos {
for mp3 in /home/cika/mp3s/*/*.mp3
do 
  
  folder=$(dirname "$mp3")
  echo "$mp3"
  background="$folder"/folder.jpg
  mogrify -resize x360 "$background"
  composite -gravity center "$background" /home/cika/background.jpg "$background"
  
  video=$(basename "$mp3" .mp3).mp4
  
  #intro=/home/cika/intro.mp3
  #combined="$folder"/combined.mp3
  #sox -S "$intro" "$mp3"  "$combined"
  
  ffmpeg  -loop_input -i "$background" -i "$mp3"  -shortest \
  -acodec copy -b 1000k "$folder"/"$video" 
done
}


## uploading videos
# define title tags and description of video
function upload_album {
for file in /home/cika/mp3s/*/*.mp4
do
  path=$(dirname "$file")
  artist=${path##*/}; artist=${artist%-*};
  album=${path##*/};  album=${album##*-};
  tags=$(echo $artist $album full album music 2012)

  # eliminate tags less than 3 characters
  x=0
  for tag in $tags
  do
  tags2[$x]=$tag
    if [[ ${#tag} < "3" ]]
    then
      tags2[$x]=""
    fi 
    let x=x+1
done

  tags=$(echo "${tags2[*]}" | sed 's/ /,/g')
  ## upload videos
  youtube-upload --email=mariojung530@gmail.com --password=10101010aa \
    --title="$artist - $album (2013) (full album)" \
    --description="If you like the music and want better quality please \
	  support the artist at http://amzn.to/SHaU81" \
    --category=Music \
    --keywords="$tags" \
    "$file"
  sleep 30
done
}
	

## uploading videos
# define title tags and description of video
function upload_track {
for folder in /home/cika/mp3s/*
do
  
  username=$(mysql -ucika -ppassword youtube -Bse "select username from accounts where free='yes' limit 1")
  password=$(mysql  -ucika -ppassword youtube -Bse "select password from accounts where free='yes' limit 1")
  echo "password je $password eccount je $username"
    
  for file in "$folder"/*.mp4
  do
   #creating artist and title names
   path=$(dirname "$file")
   artist=${path##*/}; artist=${artist%-*};
   album=${path##*/};  album=${album##*-};
   title=$(basename "$file" .mp4 | cut -c 6-)
   tags=$(echo $artist $album $title full album music 2012)
   

   # eliminate tags less than 3 characters
   x=0
   for tag in $tags
   do
   tags2[$x]=$tag
    if [[ ${#tag} < "3" ]]
    then
      tags2[$x]=""
    fi 
    let x=x+1
   done
   tags=$(echo "${tags2[*]}" | sed 's/ /,/g')
  
# creating description file
cat <<EOF >txts/description.txt
If you like the music support the artist! You can win iTunes Card and buy their music. 
http://support-the-artist.com

$artist - $title - $album
EOF
  
  ## upload videos
  youtube-upload --email=${username} --password=${password} \
    --title="$artist - $title (2013)" \
    --description="$(</home/cika/skripte/txts/description.txt)" \
    --category=Music \
    --keywords="$tags" \
	--api-upload \
    "$file"
  
  sleep 10
  done
  
  # create rars for upload on rg and php files with rg link in it
  # cd /home/cika/
  # rar a "$artist $album".rar [PASSWORD][READ].txt full_album.rar
  # dl_link=$(plowup rapidgator -a email@gmail.com:password "$artist $album".rar | cut -d' ' -f1)
  
  # echo "<?php header('location: $dl_link') ?>" > /var/www/itunes/dl/${artist// /_}.php
  # rm "$artist $album".rar
  
  
  
  mysql  -ucika -ppassword youtube -e "update accounts set free='no' where username='$username'"
done
}

extract_rars
##pitch_mp3
##combine_mp3
##make_album_videos
make_track_videos
##upload_album
upload_track
