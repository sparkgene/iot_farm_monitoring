#!/bin/bash
# upload metrics and photos.
# this script check updates by AWS IoT shadow and replace source if the new source version is arrived
base_dir="/opt/pi_farm"
source_dir="${base_dir}/current"
data_dir="${base_dir}/data"

echo "start uploader"
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
  echo "stop existing modem"
  $dup_cmd stop
fi

i=0
while [ "$i" -lt "3" ]
do
  echo "start connecting..${i}"
  # dialup
  $dup_cmd start
  sleep 3
  p=`ps ax | grep -v grep | grep "wvdial" | wc -l`
  if [ "$p" -gt  "0" ];then
    break
  else
    $i=$(($i+1))
  fi
done

if [ "$i" == "3" ];then
  # dialup faild
  echo "dialup faild"
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
  echo "upload failed. exit upload."
  $dup_cmd stop
  exit 1
fi

# remove old data
rm -f ${metrics_dir}/upload_data.csv &> /dev/null

photo_dir="${data_dir}/photos/"

for img in `find $photo_dir -type f -name "*.jpg"`
do
  fname=`basename $img`
  y=`echo $fname | cut -d "-" -f1`
  m=`echo $fname | cut -d "-" -f2`
  d=`echo $fname | cut -d "-" -f3`
  echo "upload to s3://${S3_BUCKET}/${y}/${m}/${d}/$fname"
  aws s3 cp $img s3://${S3_BUCKET}/${y}/${m}/${d}/$fname &> /dev/null
  rm -f $img &> /dev/null
done

# check source updates
echo "check shadow"
nodejs ${source_dir}/iot_shadow.js
if [ ! 0 == $? ] ; then
  # update failed
  echo "update failed"
fi

echo "closing uploader"
# close dialup
$dup_cmd stop
echo "upload finished"