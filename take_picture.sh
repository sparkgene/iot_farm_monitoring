#!/bin/sh

photo_dir="/opt/pi_farm/data/photo"
file_name=$(date +"%Y-%m-%d-%H%M%S").jpg

raspistill -o ${photo_dir}${file_name}
