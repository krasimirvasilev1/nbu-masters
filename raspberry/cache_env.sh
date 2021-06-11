#!/bin/bash

crontab -l > check_cache
echo "00 00 * * 1 declare -a CHECK_CACHE=()" >> check_cache
crontab check_cache
rm check_cache
