#!/bin/bash
set -x 

function log () {
    echo "`date +"%m-%d-%Y %T"`: $1"
}

function check_cloud_health () {
    wget -q --spider http://google.com
}

function cloud_check () {
    local pic=$1
    local cloud_url=$2
    local cloud_response=`(echo -n '{"image": "'; base64 $pic; echo '"}') | curl -sH "Content-Type: application/json" -d @- $cloud_url`
    local plate=`echo "$cloud_response" | jq -r . | jq '.plate'`
    local status=`echo "$cloud_response" | jq -r . | jq '.status'`
    local timestamp=`echo "$cloud_response" | jq -r . | jq  '.timestamp'`
    log "`echo $cloud_response | jq -r .`"
    if [[ "$status" -eq 200 ]]; then
        add_to_cache_file $plate
        echo "1" > ./gpio17/value
        wait 20
        echo "0" ./gpio17/value
    elif [[ "$status" -eq 400 ]]; then
        echo "1" > ./gpio18/value
        wait 20
        echo "0" > ./gpio18/value
    fi
}

function recognise_plate () {
    local pic=$1
    return docker run -it --rm -v $(pwd):/data:ro krasimirvasilev1/nbu-alpr -j -c eu + $pic | jq -r '.results[].candidates[].plate'
}

# function check_cache_env () {
#     local plate=$1
#     if [[ " ${CHECK_CACHE[@]} " =~ " ${plate} " ]]; then
#         log "Success from offline check!"
#         return "Success!"
#     fi
# }

# function add_to_cache_env () {
#     local plate=$1
#     # add check to see if the plate num is already in the cache before adding it
#     CHECK_CACHE+=$plate
#     CHECK_CACHE=($(echo "${CHECK_CACHE[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
# }

function check_cache_file () {
    local plate=$1
    if grep -Fxq "$plate" /tmp/rasp_cache.txt; then
        log "Success from offline check!"
    fi
}

function add_to_cache_file () {
    local plate=$1
    # add check to see if the plate num is already in the cache before adding it
    echo "$plate" >> /tmp/rasp_cache.txt
    sort -u /tmp/rasp_cache.txt -o /tmp/rasp_cache.txt
}

function offline_check () {
    local pic=$1
    local plates=recognise_plate $pic
    for plate in plates
    do
        return check_cache_file $plate
    done
}

PIC=$1
CLOUD_URL=http://192.168.1.8:9000/2015-03-31/functions/function/invocations

if check_cloud_health
then
    cloud_check $PIC $CLOUD_URL
else
    offline_check $PIC
fi
