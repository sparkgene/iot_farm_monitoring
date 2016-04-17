#!/bin/bash
base_dir="/opt/pi_farm"
source_dir="${base_dir}/current"
data_dir="${base_dir}/data"

# check environment variables
if [ ! -e ${base_dir}/environment_variables ]; then
  echo "no env file"
  exit 1
fi
source ${base_dir}/environment_variables

if [ -z "${S3_BUCKET+x}" ] ; then
  echo "environment variable S3_BUCKET is requierd"
  exit 1
fi
if [ -z "${IOT_CLIENT_ID+x}" ] ; then
  echo "environment variable IOT_CLIENT_ID is requierd"
  exit 1
fi
if [ -z "${AWS_REGION+x}" ] ; then
  echo "environment variable AWS_REGION is requierd"
  exit 1
fi

dup_cmd="/etc/init.d/soracomair"
p=`ps ax | grep -v grep | grep "wvdial" | wc -l`

if [ "$p" -gt "0" ];then
  $dup_cmd stop
fi

i=0
while [ "$i" -lt "3" ]
do
  # dialup
  $dup_cmd start
  sleep 3
  p=`ps ax | grep -v grep | grep "wvdial" | wc -l`
  if [ "$p" -gt  "0" ];then
    break
  else
    $i=$i+1
  fi
done

if [ $i -gt 3 ];then
  # dialup faild
  exit 1
fi

# rename metrics data
metrics_dir="${data_dir}/metrics"
mv ${metrics_dir}/metrics.csv ${metrics_dir}/upload_data.csv
touch ${metrics_dir}/metrics.csv

# send metrics data
nodejs ${source_dir}/iot_client.js
if [ ! 0 == $? ] ; then
  # upload failed
  echo "upload failed"
  $dup_cmd stop
  exit 1
fi

# remove old data
rm -f ${metrics_dir}/upload_data.csv

photo_dir="${data_dir}/photos/"

for img in `find $photo_dir -type f -name *.jpg`
do
  fname=`basename $img`
  y=`echo $fname | cut -d "-" -f1`
  m=`echo $fname | cut -d "-" -f2`
  d=`echo $fname | cut -d "-" -f3`
  aws s3 cp $img s3://${S3_BUCKET}/${y}/${m}/${d}/$fname
done

# close dialup
$dup_cmd stop
