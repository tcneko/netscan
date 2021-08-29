#!/bin/bash

# auther: tcneko <tcneko@outlook.com>
# start from: 2021.03
# last test environment: ubuntu 18.04
# description:

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

# variables
ipc_port=$1
declare -gA a_scan_output

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

draw_history() {
  for net in ${!a_scan_output[@]}; do
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

listener() {
  while read line; do
    echo ${line}
    l_output=(${line})
    net=${l_output[0]}
    index=${l_output[1]}
    success=${l_output[2]}
    total=${l_output[3]}
    a_scan_output[${net}]="[${index}]${success}/${total} ${a_scan_output[$net]}"
    clear
    draw_history | column -t -s'|'
  done < <(socat tcp-l:${ipc_port},fork,reuseaddr -)
}

main() {
  listener
}

# main
main

exit 0
