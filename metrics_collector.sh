#!/bin/sh

base_dir="/opt/iot_farm_monitoring"

python $base_dir/collector.py >> $base_dir/metrics.csv
