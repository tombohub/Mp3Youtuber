#!/bin/bash

##choose account for upload
echo "enter account number: "
read acc_number
account=$(sed -n ${acc_number}p /home/cika/txts/accounts.txt)
username=$(echo $account | cut -d: -f1)
password=$(echo $account | cut -d: -f2)   


## define title tags and description of video
for file in *.mp4
do
  artist=${PWD##*/}; artist=${artist%-*};
  title=$(basename "$file" .mp4 | cut -c 6-)
  tags=$(echo $artist $title free music 2012)
  ## eliminate tags less than 3 characters
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
  youtube-upload --email=$username --password=$password \
    --title="$artist - $title (2012)" \
    --description="http://www.fumusic.net/free.php - don't waste your money \
      on buying music! Download your favorite songs LEGALLY and FREE \
      and be the first one to listen and share!!! || \
      $artist - $title (2012)" \
    --category=Music \
    --keywords="$tags" \
    "$file"
  sleep 8
done


