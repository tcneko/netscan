#!/bin/bash

# auther: tcneko <tcneko@outlook.com>
# start from: 2021.03
# last test environment: ubuntu 18.04
# description:

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

# variables
net=$1
rescan=$2
ipc_port=$3

# function
register() {
  socat - tcp:127.0.0.1:${ipc_port} < <(echo ${net} 0 0 0 0 0 0) 2>/dev/null
}

netscan() {
  ix=1
  while true; do
    start_time=$(date +%s)
    # output=([0]="total" [1]="alive" [2]="min_rrt" [3]="avg_rrt" [4]="max_rrt")
    output=($(fping -sq -c5 -t1000 -g ${net} 2>&1 | grep -E  "targets|alive|round trip time" | grep -Eo "[0-9\.]+"))
    socat - tcp:127.0.0.1:${ipc_port} < <(echo ${net} ${ix} ${output[@]}) 2>/dev/null
    if [[ $? -ne 0 ]]; then
      break
    fi
    end_time=$(date +%s)
    sleep_time=$((${rescan} - ${end_time} + ${start_time}))
    if ((${sleep_time} > 0)); then
      sleep ${sleep_time}
    fi
    ix=$((${ix} + 1))
  done
}

main() {
  register
  netscan
}

# main
main

exit 0
