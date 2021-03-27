#!/bin/bash

# auther: tcneko <tcneko@outlook.com>
# start from: 2021.03
# last test environment: ubuntu 18.04
# description:

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

trap "safe_exit" 1 2 9 15

# variables
d_cur="$(dirname ${BASH_SOURCE[0]})"
f_worker="${d_cur}/netscan_worker.sh"
f_cfg='netscan.json'
# d_work=$(mktemp -d -p /dev/shm)
# f_pipe=$(mkfifo ${d_work}/netscan_fifo_pipe)
f_pipe="${d_cur}/netscan_fifo_pipe"
l_child_pid=()

declare -gA a_scan_output

# function
safe_exit() {
  kill ${l_child_pid[@]}
  clear
  exit
}

load_cfg() {
  if [[ -r ${f_cfg} ]]; then
    mapfile -t l_net < <(jq -r ".l_net[]" ${f_cfg})
    rescan=$(jq -r ".rescan" ${f_cfg})
  else
    exit 1
  fi
}

echo_info() {
  echo -ne "\e[1;32m$@\e[0m"
}

echo_warning() {
  echo -ne "\e[1;33m$@\e[0m"
}

echo_error() {
  echo -ne "\e[1;31m$@\e[0m"
}

save_scan_history() {
  while read line; do
    l_output=($line)
    net=${l_output[0]}
    index=${l_output[1]}
    success=${l_output[2]}
    total=${l_output[3]}
    a_scan_output[${net}]="[${index}]${success}/${total} ${a_scan_output[$net]}"
  done
}

draw_history() {
  for net in ${l_net[@]}; do
    echo -n ${net}
    l_history=(${a_scan_output[${net}]})
    ix=0
    while true; do
      iy=$((ix + 1))
      success_cur=$(echo ${l_history[${ix}]} | cut -d ] -f 2 | cut -d / -f 1)
      success_last=$(echo ${l_history[${iy}]} | cut -d ] -f 2 | cut -d / -f 1)
      if ((ix < 5)) && [[ -n ${success_cur} ]]; then
        if [[ ${success_cur} -eq 0 ]]; then
          echo -n "|"
          echo_error "${l_history[${ix}]}"
        elif [[ -n ${success_last} && ${success_cur} -ne ${success_last} ]]; then
          echo -n "|"
          echo_warning "${l_history[${ix}]}"
        else
          echo -n "|"
          echo_info "${l_history[${ix}]}"
        fi
      else
        break
      fi
      ix=${iy}
    done
    echo
  done
}

start_worker() {
  for net in ${l_net[@]}; do
    bash ${f_worker} ${net} ${rescan} ${f_pipe} &
    l_child_pid=($! ${l_child_pid[@]})
  done
}

start_watcher() {
  while true; do
    save_scan_history <${f_pipe}
    clear
    draw_history | column -t -s'|'
  done
}

main() {
  clear
  load_cfg
  start_worker
  start_watcher
}

# main
main

exit 0
