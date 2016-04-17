#!/bin/bash
base_dir="/opt/pi_farm"
current_dir="${base_dir}/current"
release_dir="${base_dir}/release"

# check environment variables
if [ ! -e ${current_dir}/environment_variables ]; then
  echo "no env file"
  exit 1
fi
source ${current_dir}/environment_variables

new_source_dir=$(date +"%Y%m%d%H%M%S")

git clone ${GIT_REPO} ${release_dir}/${new_source_dir}

if [ 0 == $? ] ; then
  # git clone failed
  exit 1
fi

ln -nfs ${release_dir}/${new_source_dir} ${current_dir}

exit 0
