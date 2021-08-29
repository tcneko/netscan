#!/bin/bash

# auther: tcneko <tcneko@outlook.com>
# start from: 2021.03
# last test environment: ubuntu 18.04
# description:

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

trap "safe_exit" 2 9 15

# variables
d_cur="$(dirname ${BASH_SOURCE[0]})"
f_worker="${d_cur}/netscan_worker.sh"
f_painter="${d_cur}/netscan_painter.sh"
f_cfg='netscan.json'
l_child_pid=()

declare -gA a_scan_output

# function
safe_exit() {
  kill -1 ${l_worker_pid[@]}
  wait ${l_worker_pid[@]} 2>/dev/null
  kill -1 ${painter_pid}
  wait ${painter_pid} 2>/dev/null
  exit 0
}

load_cfg() {
  if [[ -r ${f_cfg} ]]; then
    ipc_port=$(jq -r ".ipc_port" ${f_cfg})
    mapfile -t l_net < <(jq -r ".l_net[]" ${f_cfg})
    rescan=$(jq -r ".rescan" ${f_cfg})
    export l_net
  else
    exit 1
  fi
}

start_painter() {
  bash ${f_painter} ${ipc_port} &
  painter_pid=$!
}

start_worker() {
  for net in ${l_net[@]}; do
    bash ${f_worker} ${net} ${rescan} ${ipc_port} &>/dev/null &
    l_worker_pid=($! ${l_worker_pid[@]})
  done
}

main() {
  load_cfg
  start_painter
  sleep 1
  start_worker
  wait
}

# main
main

exit 0
