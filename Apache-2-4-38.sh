#!bin/bash
###################################################################################
# Apache 2.4.38 build and install --->> Apache-2-4-38.sh                          #
# Runs script: chmod -x Apache-2-4-38.sh && ./Apache-2-4-38.sh                    #
# K. G. 29.01.2019                                                                #
###################################################################################
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY* ;
yum -y install epel-release yum-utils && yum groups -y install "Development Tools" "Compatibility Libraries" -q;
cd /tmp;
sudo yum -y install curl hmaccalc zlib-devel binutils-devel elfutils-libelf-devel ncurses-devel bc wget -q;
git clone git@github.com:google/brotli.git;
wget -qO- https://dl.bintray.com/boostorg/release/1.70.0/source/boost_1_70_0.tar.gz | tar xz;
wget -qO- http://mirrors.whoishostingthis.com/apache/apr/apr-util-1.6.1.tar.gz | tar xz;
wget -qO- http://mirrors.whoishostingthis.com/apache/httpd/httpd-2.4.38.tar.gz | tar xz;
wget -qO- https://github.com/nghttp2/nghttp2/releases/download/v1.38.0/nghttp2-1.38.0.tar.gz | tar xz;
tar -zxvf nghttp2-1.38.0.tar.gz;
rm -rf /tmp/nghttp2-1.38.0.tar.gz; 
cd nghttp2-1.38.0;
./configure --quiet --prefix=/usr; 
make -j4;
make test; 
sudo make install; 
cd /tmp/apr-1.7.0; 
./configure --enable-threads --enable-posix-shm --quiet;
make -j4;
make test;
sudo make -j4 install;
cd /tmp/apr-util-1.6.1; 
./configure --enable-threads --enable-posix-shm;
make -j4;
make test;
sudo make -j4 install;
cd /tmp/brotli;
git checkout v1.0; 
mkdir out && cd out; 
../configure-cmake;
make -j4;
make test;
sudo make -j4 install;
cd /tmp;
cd httpd-2.4.38;
cp -r ../apr-1.7.0 srclib/apr;
cp -r ../apr-util-1.6.1 srclib/apr-util;
./buildconf;
./configure --enable-layout=RedHat --with-ssl=/etc/pki/tls/certs --enable-unique-id --enable-ssl --with-included-apr --with-mpm=event --enable-rewrite --enable-mime_magic --enable-deflate --enable-http2  --enable-cgid --enable-cgi --enable-mime --enable-socache_dbm;
make -j4;
make test;
sudo make -j4 install;
cd /tmp;
openssl version && httpd - V;
#rm -rf /tmp/build
