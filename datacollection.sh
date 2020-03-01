#!/bin/bash
score5=0
for i in cpu_one_minute mem_swap_one_minute io_one_minute system-resources.data error.data; do
  ls -l /developers |grep $i
  if [[ "$?" == 0 ]]; then
     score5=$((score5+4))
  fi
done
echo SECURITY SCORE IS $score5
