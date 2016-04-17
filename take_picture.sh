#!/bin/sh

temp_dir="/opt/farm_data/photo/"
file_name=$(date +"%Y-%m-%d-%H%M%S").jpg

mkdir -p $temp_dir

raspistill -o $temp_dir$file_name
