#!/bin/bash
set -ex

function parse_url() {
    local local_url=$1
    local local_url_nopro=${local_url:7}
    local local_url_rel=${local_url_nopro#*/}
    echo "${local_url_rel%%\?*}"
}

filename=$1
length_num=$(cat $filename | jq -r ".log.entries | length")
length=$((length_num - 1))

for i in $(seq 0 $length); do
    step_url=$(jq -r ".log.entries[$i].request.url" $filename)
    parsed_url=$(parse_url $step_url)
    dir_name=$(dirname $parsed_url)
    mkdir -p $dir_name
done

for i in $(seq 0 $length); do
    step_url=$(jq -r ".log.entries[$i].request.url" $filename)
    parsed_url=$(parse_url $step_url)
    dir_name=$(dirname $parsed_url)
    harx/harx.py -x $i -d $dir_name $filename || true
done