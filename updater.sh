#!/bin/bash
base_dir="/opt/pi_farm"
current_dir="${base_dir}/current"
release_dir="${base_dir}/release"

# check environment variables & load
if [ ! -e ${base_dir}/environment_variables ]; then
  echo "no env file"
  exit 1
fi
source ${base_dir}/environment_variables

# get new source
new_source_dir=$(date +"%Y%m%d%H%M%S")
git clone ${GIT_REPO} ${release_dir}/${new_source_dir}

if [ ! 0 == $? ] ; then
  # git clone failed
  echo "git clone failed"
  exit 1
fi

# link to new source
ln -s /opt/pi_farm/node_modules ${release_dir}/${new_source_dir}/node_modules
ln -nfs ${release_dir}/${new_source_dir} ${current_dir}
crontab ${release_dir}/${new_source_dir}/crontab

# clean up old files
cnt=`ls $release_dir | wc -l`
max_cnt=5
if [ $cnt -gt $max_cnt ]; then
  find /opt/pi_farm/release/ -maxdepth 1 -mindepth 1 | sort | head -$(($cnt-$max_cnt)) | xargs rm -rf
fi

# update cron
crontab ${release_dir}/${new_source_dir}/crontab

exit 0
