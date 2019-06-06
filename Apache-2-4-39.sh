~!/bin/bash
###################################################################################
# Apache 2.4.39 build and install --->> Apache-2-4-39.sh                          #
# To run script use following comands:                                            #
# chmod +x Apache-2-4-39.sh                                                       #
# ./Apache-2-4-39.sh                                                              #
# K. G. 09.04.2019 last updated on 13.04.2019                                     #
###################################################################################
yum -y install dnf cockpit cockpit* ;
if [[ "$DNF_ENABLE" = [yY] ]]; then
	RPI='dnf -y install'
	RPIQ='dnf -y -q install'
	RPR='dnf -y remove'
	RPRQ='dnf -y -q remove'
	RPU='dnf -y update'
	RPUQ='dnf -y -q update'
else
	RPI='yum -y install'
	RPIQ='yum -y -q install'
	RPR='yum -y remove'
	RPRQ='yum -y -q remove'
	RPU='yum -y update'
	RPUQ='yum -y -q update'
fi
echo 'Preparing...';
cd ~;
mkdir sources;
cd sources;
RPIQ update ;
wget http://rpms.remirepo.net/enterprise/remi-release-7.rpm --quiet;
RPIQ localinstall remi-release-7.rpm;
RPIQ install epel-release yum-utils;
RPIQ groups install  'Development Tools' 'Compatibility Libraries' --quiet;
RPIQ install perl wget zlib-devel systemtap-devel pcre-devel libapreq2 libapreq2-devel openldap-devel libxml2-devel openssl-devel expat-devel valgrind cmake git automake autoconf libtool lbzip2 lbzip2-utils pbzip2 bzip2-devel bzip2 libicu-devel xz-devel xz-libs xz libicu icu xz-compat-libs which python36 libpsl-devel libidn2-devel CUnit-devel CUnit python36-devel lcov.noarch --quiet;
systemctl stop httpd;
mv /etc/httpd/conf /etc/httpd/_conf;
mv /etc/httpd/conf.d /etc/_conf.d;
mv /etc/httpd/conf.modules.d /etc/_conf.modules.d;
echo 'Downloading...';
wget -qO- https://dl.bintray.com/boostorg/release/1.70.0/source/boost_1_70_0.tar.gz | tar xz;
wget -qO- https://github.com/nghttp2/nghttp2/releases/download/v1.38.0/nghttp2-1.38.0.tar.gz | tar xz;
wget -qO- https://www.openssl.org/source/openssl-1.1.1b.tar.gz | tar xz;
wget -qO- http://mirrors.whoishostingthis.com/apache/apr/apr-1.7.0.tar.gz | tar xz;
wget -qO- http://mirrors.whoishostingthis.com/apache/apr/apr-util-1.6.1.tar.gz | tar xz;
wget -qO- http://mirrors.whoishostingthis.com/apache/httpd/httpd-2.4.39.tar.gz | tar xz;
echo '(Installing: 1/6) Configuring Boost 1.70.0';
cd boost_1_70_0;
./bootstrap.sh --prefix=/usr;
./b2 stage threading=multi link=shared;
./b2 install threading=multi link=shared;
ln -svf detail/sha1.hpp /usr/include/boost/uuid/sha1.hpp;
clear;
echo '(Installing: 1/6) Successfully Installed Boost 1.70.0';
cd ..;
cd openssl-1.1.1b;
echo '(Installing: 2/6) Configuring Openssl 1.1.1b';
./config --prefix=/usr;
echo '(Installing: 2/6) Openssl configuration is done...';
make --jobs=8 --quiet --silent;
echo '(Installing: 2/6) Openssl libaries is done...';
make test --quiet --silent
echo '(Installing: 2/6) Openssl test is done...';
sed -i '/INSTALL_LIBS/s/libcrypto.a libssl.a//' Makefile;
make MANSUFFIX=ssl install --quiet --silent;
echo '(Installing: 2/6) Successfully Installed Openssl.';
openssl version;
cd ..;
cd nghttp2-1.38.0;
echo '(Installing: 3/6) Configuring Nghttp2 1.37.0';
./configure --quiet --prefix=/usr --disable-static --enable-lib-only --docdir=/usr/share/doc/nghttp2-1.38.0;
echo '(Installing: 3/6) Nghttp2 configuration is done...';
make --jobs=8 --quiet --silent;
echo '(Installing: 3/6) Nghttp2 libaries is done...';
sudo make install --quiet --silent;
echo '(Installing: 3/6) Successfully Installed Nghttp2 1.37.0';
cd ..;
cd apr-1.7.0;
echo '(Installing: 4/6) Configuring Apr-1.7.0';
./configure --enable-threads --enable-posix-shm --quiet;
make --jobs=8 --quiet --silent;
echo '(Installing: 4/6) Apr libaries is done...';
sudo make install --quiet --silent;
echo '(Installing: 4/6) Successfully Installed Apr-1.7.0';
cd ..;
cd apr-util-1.6.1;
echo '(Installing: 5/6) Configuring Apr Util 1.6.1';
./configure --with-apr=/usr/local/apr --with-ldap --quiet;
make --jobs=8 --quiet --silent;
echo '(Installing: 5/6) Apr Util 1.6.1 libaries is done...';
sudo make install --quiet --silent;
echo '(Installing: 5/6) Successfully Installed Apr Util 1.6.1';
cd ..;
echo '(Installing: 6/6) Configuring Httpd 2.4.39';
cd httpd-2.4.39;
cp -r ../apr-1.7.0 srclib/apr;
cp -r ../apr-util-1.6.1 srclib/apr-util;
./configure --enable-layout=RedHat --enable-nonportable-atomics=yes --with-mpm=worker --with-ssl=/usr/local/ssl --with-pcre=/usr/bin/pcre-config --enable-unique-id --enable-ssl --enable-so --with-included-apr --enable-http2 --enable-mpms-shared='prefork worker event' --quiet;
make --jobs=8 --quiet --silent;
echo '(Installing: 6/6) Httpd libaries is done...';
sudo make install --quiet --silent;
echo '(Installing: 6/6) Successfully Installed Httpd 2.4.39';
cd ..;
systemctl daemon-reload;
systemctl start httpd && systemctl enable httpd;
httpd -V;
