#!/bin/bash

score=0
bonusScore=0
#Build section
sudo /usr/bin/yum -y install bc > /dev/null
if [[ $(cat /proc/cpuinfo |grep processor |wc -l) = 1 ]]; then
  score=$((score+2))
fi
mem=`awk '( $1 == "MemTotal:" ) { print $2/1048576 }' /proc/meminfo`
if [[ $(echo "$mem<1"| bc) ]]; then
  score=$((score+2))
fi
disk=`lsblk |grep sda |grep disk |awk '{print $4}'`
if [[ "$disk" == "20G" ]]; then
  score=$((score+3))
fi

for i in var tmp root; do
  sudo lvscan |grep "$i" &> /dev/null
  if [[ $? == 0 ]]; then
    score=$((score+1))
  fi
done

echo "Build section score is $score points"

#Network section
score1=0
localhostname=`hostname`
if [[ $localhostname == "server" ]]; then
  score1=$((score1+4))
fi
ssh -q examadmin@client exit &> /dev/null
if [[ "$?" == 0 ]]; then
  score1=$((score1+4))
fi

ssh examadmin@client /usr/sbin/ip -4 a |grep inet |grep 102 &> /dev/null
if [[ "$?" == 0 ]]; then
  score1=$((score1+4))
fi

/usr/sbin/ip -4 a |grep inet |grep bond |grep 101 &> /dev/null
if [[ "$?" == 0 ]]; then
  score1=$((score1+4))
fi

ssh -q root@client exit &> /dev/null
if [[ "$?" -ne 0 ]]; then
  score1=$((score1+4))
fi
#bonus points
/usr/sbin/ip -4 a |grep eth0 &> /dev/null
if [[ "$?" == 0 ]]; then
  bonusScore=$((bonusScore+5))
fi
ssh examadmin@client /usr/sbin/ip -4 a |grep eth0 &> /dev/null
if [[ "$?" == 0 ]]; then
  bonusScore=$((bonusScore+5))
fi

echo "Network section score is $score1 points"

#Security section
#score2=0

#getfacl -p /developers |grep group:developers:rwx &> /dev/null
#if [[ "$?" == 0 ]]; then
#  score2=$((score2+2))
#fi
#getfacl -p /developers |grep group:managers:r-- &> /dev/null
#if [[ "$?" == 0 ]]; then
#  score2=$((score2+4))
#fi

#grep "%administrators ALL=(ALL) ALL" /etc/sudoers &> /dev/null
#if [[ "$?" == 0 ]]; then
#  score2=$((score2+4))
#fi

#for i in cyrax sector; do
#  cat /etc/group |grep developers |grep $i &> /dev/null
#  if [[ "$?" == 0 ]]; then
#    score2=$((score2+2))
#  fi
#done
#cat /etc/group |grep managers |grep shaokahn &> /dev/null
#if [[ "$?" == 0 ]]; then
#    score2=$((score2+2))
#fi

#for i in noobsaibot scorpion; do
#  cat /etc/group |grep administrators |grep $i &> /dev/null
#  if [[ "$?" == 0 ]]; then
#    score2=$((score2+2))
#  fi
#done
#echo "Security section score is $score2 points"

#Storage Section
score3=0
devfs=`ssh client df -h | grep /developers | awk '{ print $2}'`
if [[ "$devfs" == "10G" ]]; then
  score3=$((score3+4))
fi

sudo mdadm -D /dev/md0 |grep "Raid Level"| awk '{ print $4}' &> /dev/null
if [[ "$?" == 0 ]]; then
  score3=$((score3+4))
fi

sudo mdadm -D /dev/md0 |grep "Raid Devices" |awk '{ print $4 }' &> /dev/null
if [[ "$?" == 0 ]]; then
  score3=$((score3+4))
fi


ssh examadmin@client "cat /proc/mounts |grep nfs |grep /home" &> /dev/null
if [[ "$?" == 0 ]]; then
  score3=$((score3+4))
fi

for i in shaokahn cyrax sector noobsaibot; do
  ssh examadmin@client "ls -l /home |grep $i"
  if [[ "$?" == 0 ]]; then
    score3=$((score3+1))
  fi
done
echo "Storage section score is $score3 points"

#Software
score4=0
ssh examadmin@client "/usr/sbin/httpd -v"
if [[ "$?" == 0 ]]; then
    score4=$((score4+1))
fi
owner=`ssh examadmin@client "getfacl -p /var/www |grep owner |cut -d : -f2 | tr -d ' '"`
if [[ "$owner" == "apacheAdmin" ]]; then
    score4=$((score4+2))
fi
grp=`ssh examadmin@client "getfacl -p /var/www |grep group |cut -d : -f2 | tr -d ' ' | grep -v ^$"`
if [[ "$grp" == "apacheAdmin" ]]; then
    score4=$((score4+1))
fi
countapacheconf=`ssh examadmin@client "grep apacheAdmin /etc/httpd/conf/httpd.conf  | wc -l"`
if [[ "$countapacheconf" == "2" ]]; then
score4=$((score4+4))
fi
#Bonus Points
ssh client 'grep -i compress /etc/logrotate.d/httpd'
if [[ "$?" == 0 ]]; then
    bonusScore=$((bonusScore+2))
fi
ssh client 'grep -i size /etc/logrotate.d/httpd'
if [[ "$?" == 0 ]]; then
    bonusScore=$((bonusScore+3))
fi
echo "Software section score is $score4 points"

#Data Collection Section
#score5=0
#for i in cpu_one_minute mem_swap_one_minute io_one_minute system-resources.data error.data; do
#  ls -l /developers |grep $1
#  if [[ "$?" == 0 ]]; then
#     score5=$((score5+4))
#  fi
#done
ssh examadmin@client 'rm datacollection.sh ; wget https://raw.githubusercontent.com/robotpanic/LoadTestCentOS/master/datacollection.sh && chmod +x datacollection.sh && ./datacollection.sh'
ssh examadmin@client 'rm security.sh ; wget https://raw.githubusercontent.com/robotpanic/LoadTestCentOS/master/security.sh && chmod +x security.sh && ./security.sh'
examScore=$(( $score + $score1 + $score2 +$score3 + $score4))
#echo "Data Collection section score is $score5 points"
echo "Exam score is: $examScore"
echo "Bonus points: $bonusScore"
total=$(( $examScore + bonusScore ))
echo "Total points: $examScore + $bonusScore"
