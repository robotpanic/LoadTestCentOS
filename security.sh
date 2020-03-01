#!/bin/bash
#Security section
score2=0

getfacl -p /developers |grep group:developers:rwx &> /dev/null
if [[ "$?" == 0 ]]; then
  score2=$((score2+2))
fi
getfacl -p /developers |grep group:managers:r-- &> /dev/null
if [[ "$?" == 0 ]]; then
  score2=$((score2+4))
fi

grep "%administrators ALL=(ALL) ALL" /etc/sudoers &> /dev/null
if [[ "$?" == 0 ]]; then
  score2=$((score2+4))
fi

for i in cyrax sector; do
  cat /etc/group |grep developers |grep $i &> /dev/null
  if [[ "$?" == 0 ]]; then
    score2=$((score2+2))
  fi
done
cat /etc/group |grep managers |grep shaokahn &> /dev/null
if [[ "$?" == 0 ]]; then
    score2=$((score2+2))
fi

for i in noobsaibot scorpion; do
  cat /etc/group |grep administrators |grep $i &> /dev/null
  if [[ "$?" == 0 ]]; then
    score2=$((score2+2))
  fi
done
echo "SECURITY section score is $score2 points"
