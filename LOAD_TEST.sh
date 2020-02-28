#!/bin/bash

function CPU_LOAD () {

yum install -y wget gcc libxml2-devel openssl openssl-devel openssl-libs curl libcurl-devel libjpeg-turbo-devel libpng-devel freetype-devel libmcrypt libmcrypt-devel libxslt libxslt-devel
wget -O /usr/src/php-5.6.30.tar.gz http://php.net/get/php-5.6.30.tar.gz/from/this/mirror
cd /usr/src; tar xfvz php-5.6.30.tar.gz
cd php-5.6.30/
yum -y install perl
yum -y install httpd-devel
./configure  --with-mysql --with-mysqli --with-pdo-mysql --enable-soap --with-gd --with-curl --with-jpeg-dir=/opt --with-png-dir=/opt --with-freetype-dir=/opt --with-zlib --enable-mbstring  --with-xsl --with-openssl  --enable-ftp --enable-exif --with-apxs2=/usr/bin/apxs
#make -j4
while true ; do make -j1 ; make clean ; done

}


function IO_LOAD () {

while true ; do dd if=/dev/zero of=/root/TEMPIOFILE bs=1024 count=10 ; rm /root/TEMPIOFILE ; sleep 1 ; done

}


function MEM_LOAD () {

mkdir /root/TEMP_MEM
mount -t tmpfs none /root/TEMP_MEM -o size=100m
while true ; do  dd if=/dev/zero of=/root/TEMP_MEM/ZeroesInMemory bs=1M count=99 ; rm /root/TEMP_MEM/ZeroesInMemory ; sleep 1 ; done

}


CPU_LOAD &

MEM_LOAD &

IO_LOAD &
