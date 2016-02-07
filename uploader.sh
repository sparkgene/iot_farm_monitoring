#!/bin/sh

base_dir="/opt/iot_farm_monitoring"
dup_cmd="/opt/sora/connect_air.sh"

if [`ps ax | grep -v grep | grep "$dup_cmd"`]
then
  # exit when dialup is allready started
  exit
fi

i=0
while [$i < 3]
do
  # dialup
  $dup_cmd start

  if [`ps ax | grep -v grep | grep "$dup_cmd"`]
  then
    break
  fi
  $i=$1+1
done

if [$i == 3]
  # dialup faild
  exit 1
fi

# rename metrics data
mv $base_dir/metrics.csv $base_dir/upload_data.csv
touch $base_dir/metrics.csv

# send metrics data
node $base_dir/iot_client.js

# remove old data
rm -f $base_dir/upload_data.csv

# close dialup
dup_cmd stop
