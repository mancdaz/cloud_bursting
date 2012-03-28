#!/bin/bash
HIGH=20
LOW=10

get_mon_num () {
    # do some stuff here to squeeze your magic
    # number out of your monitoring system
}

while true; do
    get_mon_num
    if [[ $MON_NUM -gt $HIGH ]]; then
        delete_servers 1
        sleep 60
    elif [[ $MON_NUM -lt $LOW ]]; then
        build_servers 1
        sleep 60
    fi
done
