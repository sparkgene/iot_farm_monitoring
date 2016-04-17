#!/bin/sh

photo_dir="/opt/pi_farm/data/photos"
file_name=$(date +"%Y-%m-%d-%H%M%S").jpg

raspistill -w 1280 -h 720 -o ${photo_dir}/${file_name}
