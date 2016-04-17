#!/bin/sh
base_dir="/opt/pi_farm"
source_dir="${base_dir}/current"
data_dir="${base_dir}/data/metrics"

if [ ! -f $data_dir/metrics.csv ]
then
  touch $data_dir/metrics.csv
fi

python $source_dir/collector.py >> $data_dir/metrics.csv
