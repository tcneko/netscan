#!/bin/bash

# auther: tcneko <tcneko@outlook.com>
# start from: 2021.03
# last test environment: ubuntu 18.04
# description:

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

# variables
net=$1
rescan=$2
nmap_time_profile=$3
f_pipe=$4

# function
netscan() {
  ix=1
  while true; do
    start_time=$(date +%s)
    output=$(nmap -T${nmap_time_profile} -n -sn ${net} 2>/dev/null | grep "Nmap done" | cut -d" " -f3,6 | tr -d '(' | sed -E "s#([0-9]*) ([0-9]*)#${net} ${ix} \2 \1#g")
    echo ${output} >${f_pipe}
    end_time=$(date +%s)
    sleep_time=$((${rescan} - ${end_time} + ${start_time}))
    if ((${sleep_time} > 0)); then
      sleep ${sleep_time}
    fi
    ix=$((${ix} + 1))
  done
}

main() {
  netscan
}

# main
main

exit 0
