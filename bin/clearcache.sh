#!/bin/bash
# https://www.tecmint.com/clear-ram-memory-cache-buffer-and-swap-space-on-linux/
# Note, we are using "echo 3", but it is not recommended in production instead use "echo 1"

echo "echo ${1:-1} > /proc/sys/vm/drop_caches"  && swapoff -a && swapon -a && printf '\n%s\n' 'Ram-cache and Swap Cleared'
# su -c "echo ${1:-1} >'/proc/sys/vm/drop_caches' && swapoff -a && swapon -a && printf '\n%s\n' 'Ram-cache and Swap Cleared'" root
# su -c "echo 1 >'/proc/sys/vm/drop_caches' && swapoff -a && swapon -a && printf '\n%s\n' 'Ram-cache and Swap Cleared'" root

# crontab -e
# 0  2  *  *  *  /path/to/clearcache.sh 

#  echo "0  2  *  *  *  /opt/csimeu/cli/bin/clearcache.sh" | crontab -