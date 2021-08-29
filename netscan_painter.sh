#!/bin/bash

# auther: tcneko <tcneko@outlook.com>
# start from: 2021.03
# last test environment: ubuntu 18.04
# description:

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

# variables
ipc_port=$1
declare -gA a_scan_output
declare -gA a_scan_output_color
declare -gA a_scan_output_cache_cur
declare -gA a_scan_output_cache_last

# function
echo_info() {
  echo -ne "\e[1;32m$@\e[0m"
}

echo_warning() {
  echo -ne "\e[1;33m$@\e[0m"
}

echo_error() {
  echo -ne "\e[1;31m$@\e[0m"
}

verify_diff_rate() {
  # old_value=$1
  # new_value=$2
  # max_diff_rate=$3

  if (($(echo "$1 > $2" | bc) == 1)); then
    echo "scale=2; ($1 - $2) / $1 * 100 <= $3" | bc
  else
    echo "scale=2; ($2 - $1) / $1 * 100 <= $3" | bc
  fi
}

decide_color() {
  # net=$1

  l_scan_output_cache_cur=(${a_scan_output_cache_cur[$1]})
  index_cur=${l_scan_output_cache_cur[0]}
  alive_cur=${l_scan_output_cache_cur[1]}
  avg_rrt_cur=${l_scan_output_cache_cur[2]}

  if ((${index} == 0)); then
    a_scan_output_color[$1]="0"
  elif ((${index} == 1)); then
    if ((${alive_cur} == 0)); then
      a_scan_output_color[$1]="2 ${a_scan_output_color[$1]}"
    else
      a_scan_output_color[$1]="0 ${a_scan_output_color[$1]}"
    fi
  else
    l_scan_output_cache_last=(${a_scan_output_cache_last[$1]})
    index_last=${l_scan_output_cache_last[0]}
    alive_last=${l_scan_output_cache_last[1]}
    avg_rrt_last=${l_scan_output_cache_last[2]}
    if ((${alive_cur} == 0)); then
      a_scan_output_color[$1]="2 ${a_scan_output_color[$1]}"
    elif [[ $(verify_diff_rate ${alive_last} ${alive_cur} 0) -eq 1 && $(verify_diff_rate ${avg_rrt_last} ${avg_rrt_cur} 10) -eq 1 ]]; then
      a_scan_output_color[$1]="0 ${a_scan_output_color[$1]}"
    else
      a_scan_output_color[$1]="1 ${a_scan_output_color[$1]}"
    fi
  fi
}

draw_history() {
  clear
  for net in ${!a_scan_output[@]}; do
    echo -n ${net}
    l_history=(${a_scan_output[${net}]})
    ix=0
    while true; do
      iy=$((ix + 1))
      if [[ ${ix} -lt 5 && -n "${l_history[${ix}]}" ]]; then
        l_draw_color=(${a_scan_output_color[${net}]})
        draw_color=${l_draw_color[${ix}]}
        if ((${draw_color} == 2)); then
          echo -n "|"
          echo_error "${l_history[${ix}]}"
        elif ((${draw_color} == 1)); then
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

listener() {
  while read line; do
    # l_output=([0]="net" [1]="index" [2]="total" [3]="alive" [4]="min_rrt" [5]="avg_rrt" [6]="max_rrt")
    l_output=(${line})
    net=${l_output[0]}
    index=${l_output[1]}
    alive=${l_output[3]}
    total=${l_output[2]}
    avg_rrt=${l_output[5]}
    a_scan_output_cache_cur[${net}]="${index} ${alive} ${avg_rrt}"
    a_scan_output[${net}]="[${index}]${alive}/${total},${avg_rrt}ms ${a_scan_output[$net]}"
    decide_color ${net}
    draw_history | column -t -s'|'
    a_scan_output_cache_last[${net}]=${a_scan_output_cache_cur[${net}]}
  done < <(socat tcp-l:${ipc_port},fork,reuseaddr -)
}

main() {
  listener
}

# main
main

exit 0
