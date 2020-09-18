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


## making full album vidoes 
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

## converting mp3s to video
function make_track_videos {
for mp3 in /home/cika/mp3s/*/*PITCHED.mp3
do 
  folder=$(dirname "$mp3")
  background="$folder"/folder.jpg
  video=$(basename "$mp3" PITCHED.mp3).mp4
  ffmpeg -loop_input -i "$folder"/folder.jpg -i "$mp3" -shortest \
  -acodec copy "$folder"/"$video" 
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
  youtube-upload --email=email@gmail.com --password=10101010aa \
    --title="$artist - $album (2012) (full album)" \
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
  #choosing account
  account=$(sed -n 1p txts/free_accounts.txt)
  sed -n 1p /home/cika/skripte/txts/free_accounts.txt >> /home/cika/skripte/txts/taken_accounts.txt
  sed 1d /home/cika/skripte/txts/free_accounts.txt > /home/cika/tmp.txt
  mv /home/cika/tmp.txt /home/cika/skripte/txts/free_accounts.txt
  username=$(echo $account | cut -d: -f1)
  password=$(echo $account | cut -d: -f2)
  
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
how to make easy money http://youtu.be/_Tk7oolltwY

$artist - $title - $album
EOF
  
  ## upload videos
  youtube-upload --email="$username" --password="$password" \
    --title="$artist - $title (2012)" \
    --description="$(<txts/description.txt)" \
    --category=Music \
    --keywords="$tags" \
	--api-upload \
    "$file"
  
  sleep 10
  done
done
}

extract_rars
pitch_mp3
combine_mp3
make_album_videos
make_track_videos
upload_album
upload_track











  
