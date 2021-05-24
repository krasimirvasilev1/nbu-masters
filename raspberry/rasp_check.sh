#!/bin/bash
set -x 

function log () {
    echo "date +"%m-%d-%Y %T": $1" > /tmp/tuz.log
}

function check_cloud_health () {
    wget -q --spider http://google.com
}

function cloud_check () {
    local pic=$1
    local cloud_url=$2
    log (echo -n '{"image": "'; base64 $pic; echo '"}') | curl -H "Content-Type: application/json" -d @- $cloud_url
}

function recognise_plate () {
    local pic=$1
    return docker run -it --rm -v $(pwd):/data:ro stiliancvetkov/tuesalpr -j -c eu + $pic | jq -r '.results[].candidates[].plate'
}

function check_cache () {
    local plate=$1
   redis-cli get $plate
}

function offline_check () {
    local pic=$1
    local plates=recognise_plate $pic
    for plate in plates
    do
        return check_cache $plate
    done
}

PIC=$1
CLOUD_URL=http://192.168.68.109:9000/2015-03-31/functions/function/invocations

if check_cloud_health
then
    cloud_check $PIC $CLOUD_URL
else
    offline_check $PIC
fi