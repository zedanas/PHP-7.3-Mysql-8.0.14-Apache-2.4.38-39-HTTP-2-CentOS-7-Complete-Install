#!bin/bash
###################################################################################
# Apache 2.4.39 build and install --->> Apache-2-4-39.sh                          #
# Runs script: chmod -x Apache-2-4-39.sh && ./Apache-2-4-39.sh                    #
# K. G. 09.04.2019                                                                #
###################################################################################
yum groups install -y "Development Tools" "Compatibility Libraries" -q;
sudo yum install -y perl zlib-devel pcre-devel libxml2-devel openssl-devel expat-devel cmake git automake autoconf libtool;
cd ~;
mkdir sources;
cd sources;
wget https://www.openssl.org/source/openssl-1.1.1b.tar.gz;
tar -zxvf openssl-1.1.1b.tar.gz;
cd openssl-1.1.1b;
./config --prefix=/usr shared zlib-dynamic;
make --jobs=8;
sudo make install;
cd ..;
wget https://github.com/nghttp2/nghttp2/releases/download/v1.37.0/nghttp2-1.37.0.tar.gz;
tar -zxvf nghttp2-1.37.0.tar.gz;
cd nghttp2-1.37.0;
./configure;
make --jobs=8;
sudo make install;
cd ..;
wget http://mirrors.whoishostingthis.com/apache/apr/apr-1.7.0.tar.gz;
tar -zxvf apr-1.7.0.tar.gz;
cd apr-1.7.0;
./configure  --enable-threads --enable-posix-shm;
make --jobs=8;
sudo make install;
cd ..;
wget http://mirrors.whoishostingthis.com/apache/apr/apr-util-1.6.1.tar.gz;
tar -zxvf apr-util-1.6.1.tar.gz;
cd apr-util-1.6.1;
./configure --with-apr=/usr/local/apr --with-ldap;
make --jobs=8;
sudo make install;
cd ..;
wget http://mirrors.whoishostingthis.com/apache/httpd/httpd-2.4.39.tar.gz;
tar -zxvf httpd-2.4.39.tar.gz; 
cd httpd-2.4.39;
cp -r ../apr-1.7.0 srclib/apr;
cp -r ../apr-util-1.6.1 srclib/apr-util;
./configure --enable-layout=RedHat  --enable-nonportable-atomics=yes --with-mpm=worker --with-ssl=/usr/local/ssl --with-pcre=/usr/bin/pcre-config --enable-unique-id --enable-ssl --enable-so --with-included-apr --enable-http2 --enable-mpms-shared='prefork worker event';
make --jobs=8;
sudo make install;
cd ..;
openssl version && httpd - V;
