#!/bin/bash
path=$1
for i in $( awk '/tomcat/{print $1}' $path/host.log )
do
  ssh $i yum -y install  java-1.8.0-openjdk java-1.8.0-openjdk-headless
  scp $path/tomcat/apache-tomcat-9.0.6.tar.gz $i:/mnt
  scp $path/tomcat/tomcat $i:/usr/bin/
  ssh $i chmod +x /usr/bin/tomcat
  ssh $i tar -xf /mnt/apache-tomcat-9.0.6.tar.gz -C /mnt/
  ssh $i mv /mnt/apache-tomcat-9.0.6 /var/tomcat
done
