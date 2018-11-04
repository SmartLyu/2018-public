#!/bin/bash
path=$1
for i in  $(awk '/mysql/{print $1}' $path/host.log)
do
  {
     ssh $i mkdir /mnt/mysql
     scp $path/mysql/* $i:/mnt/mysql/
     ssh $i bash /mnt/mysql/bulid_mysql.sh 0
  } &
done 
wait

if [ $(sed -n '/mysql/p' $path/host.log | wc -l) -lt 2 ];then
  sed -i '/startMasterslave/cstartMasterslave = 0' $path/main.conf
fi


if [ $(awk -F= '/startMasterslave/{print $2}' $path/main.conf | sed 's/ //g') -ne 0 ];then
  master_ip=$(awk '$3==1' $path/host.log | awk '/mysql/{print $1}')
  ssh $master_ip bash /mnt/mysql/bulid_mysql.sh 1
  for i in $( awk '$3>1' $path/host.log | awk '/mysql/{print $1}')
  do
    ssh $i bash /mnt/mysql/bulid_mysql.sh 2 $master_ip
  done
fi

