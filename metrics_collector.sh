#!/bin/sh

base_dir="/opt/iot_farm_monitoring"

if [ ! -f /etc/passwd ]
then
  touch $base_dir/metrics.csv
fi

python $base_dir/collector.py >> $base_dir/metrics.csv
