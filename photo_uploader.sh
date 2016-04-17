#!/bin/sh

s3_bucket="sparkgene-pi-farm"
photo_dir="/opt/farm_data/photo/"

for img in `find $photo_dir -type f -name *.jpg`
do
  fname=`basename $img`
  y=`echo $fname | cut -d "-" -f1`
  m=`echo $fname | cut -d "-" -f2`
  d=`echo $fname | cut -d "-" -f3`
  aws s3 cp $img s3://${s3_bucket}/${y}/${m}/${d}/$fname
done
