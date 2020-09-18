#!/bin/bash

rm /home/cika/rars/*
rm /home/cika/jpgs/*
rm -r /home/cika/mp3s/*
php download.php
./upload.sh
