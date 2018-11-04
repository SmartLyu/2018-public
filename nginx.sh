#!/bin/bash
path=$1
sed -i '/^cpu/ccpu='$(awk -F= '/cpunum/{print $2}' $path/main.conf | sed 's/ //g') $path/nginx/nginx_start

if [ $(sed -n '/nginx/p' $path/host.log | wc -l) -lt 2 ];then
  sed -i '/startRsync/cstartRsync = 0' $path/main.conf
fi
for i in  $(awk '/nginx/{print $1}' $path/host.log)
do
   ssh $i mkdir /nginx
   scp $path/nginx/* $i:/nginx
   ssh $i source /nginx/nginx_start &
done
wait

if [ $(awk -F= '/startRsync/{print $2}' $path/main.conf | sed 's/ //g') -ne 0 ];then
  main_ip=$(awk '$3==1' $path/host.log | awk '/nginx/{print $1}')
  ssh $main_ip yum install -y rsync
  for i in $( awk '$3>1' $path/host.log | awk '/nginx/{print $1}')
  do
     ssh $main_ip source /nginx/nginx_rsync $i &
     ssh $i yum install -y rsync
  done
fi
