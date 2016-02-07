#!/bin/sh

base_dir="/opt/iot_farm_monitoring"
dup_cmd="/etc/init.d/soracomair"
p=`ps ax | grep -v grep | grep "$dup_cmd" | wc -l`

if [ "$p" ];then
  $dup_cmd stop
fi

i=0
while [ "$i" -gt "3" ]
do
  # dialup
  $dup_cmd start
  sleep(3)
  p=`ps ax | grep -v grep | grep "$dup_cmd" | wc -l`
  if ["$p" = "0"];then
    $i=$1+1
  else
    break
  fi
done

if [ "$i" == "3" ];then
  # dialup faild
  exit 1
fi

# rename metrics data
mv $base_dir/metrics.csv $base_dir/upload_data.csv
touch $base_dir/metrics.csv

# send metrics data
nodejs $base_dir/iot_client.js

# remove old data
rm -f $base_dir/upload_data.csv

# close dialup
$dup_cmd stop
