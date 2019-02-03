#!bin/bash
###################################################################################
# Apache 2.4.38 build and install --->> Apache-2-4-38.sh                          #
# Runs script: chmod -R 777 Apache-2-4-38.sh && bash Apache-2-4-38.sh             #
# K. G. 29.01.2019                                                                #
###################################################################################
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY*
yum -y install epel-release yum-utils && yum groups install "Development Tools" "Compatibility Libraries" -q
cd /tmp && mkdir /tmp/build && cd /tmp/build
sudo yum -y install hmaccalc zlib-devel binutils-devel elfutils-libelf-devel ncurses-devel bc wget -q
git clone git@github.com:google/brotli.git
curl http://mirrors.whoishostingthis.com/apache/apr/apr-1.6.5.tar.gz  | tar xz
curl http://mirrors.whoishostingthis.com/apache/apr/apr-util-1.6.1.tar.gz | tar xz
curl http://mirrors.whoishostingthis.com/apache/httpd/httpd-2.4.38.tar.gz | tar xz
wget https://github.com/nghttp2/nghttp2/releases/download/v1.36.0/nghttp2-1.36.0.tar.gz 
tar -zxvf nghttp2-1.36.0.tar.gz  
rm -rf /tmp/nghttp2-1.36.0.tar.gz && cd nghttp2-1.36.0
./configure 
make -j4
make test 
sudo make install 
cd /tmp/apr-1.6.5 
./configure 
make -j4
make test 
sudo make -j4 install
cd /tmp/apr-util-1.6.1 
./configure --with-apr=/usr/local/apr 
make -j4 
make test 
sudo make -j4 install 
cd /tmp/brotli
git checkout v1.0 
mkdir out && cd out 
../configure-cmake 
make -j4
make test 
sudo make -j4 install 
cd /tmp/build
cp -r apr-1.6.5 httpd-2.4.38/srclib/apr
cp -r apr-util-1.6.1 httpd-2.4.38/srclib/apr-util
cd httpd-2.4.38
./buildconf
./configure --enable-layout=RedHat --with-ssl=/etc/pki/tls/certs --enable-unique-id  \
 --enable-ssl --with-included-apr --with-mpm=event --enable-rewrite --enable-mime_magic \
 --enable-deflate --enable-http2  --enable-cgid --enable-cgi --enable-mime --enable-socache_dbm 
make  -j4 
make test  -j4
sudo make -j4 install
cd /tmp/build
rm -rf /usr/lib/systemd/system/httpd.service && rm -rf  /usr/lib/systemd/system/httpd.service
echo "[Unit]
Description=The Apache HTTP Server
After=network.target
[Service]
Type=forking
ExecStart=/usr/bin/apachectl -k start
ExecReload=/usr/bin/apachectl -k graceful
ExecStop=/usr/bin/apachectl -k graceful-stop
PIDFile=/exc/httpd/logs/httpd.pid
PrivateTmp=true
[Install]
WantedBy=multi-user.target" >> /usr/lib/systemd/system/httpd.service
#rm -rf /tmp/build
