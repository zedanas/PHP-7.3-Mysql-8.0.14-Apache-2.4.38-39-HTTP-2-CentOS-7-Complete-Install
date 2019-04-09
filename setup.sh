#!/bin/bash
###################################################################################
# PHP 7.3 php-fpm mysql and other libs instalation --->> setup.sh                 #
# Runs script: chmod +x 777 setup.sh && ./setup.sh                                #
# K. G. 29.01.2019                                                                #
###################################################################################
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY* ;
yum install -y yum-utils && yum groups install 'Development Tools' 'Compatibility Libraries' -q;
yum install -y http://rpms.remirepo.net/enterprise/remi-release-7.rpm -q;
yum install -y hmaccalc zlib-devel binutils-devel elfutils-libelf-devel ncurses-devel bc wget -q;
yum install tuned-* htop ImageMagick7 -q -y ;
tuned --profile throughput-performance --daemon;
sudo yum-config-manager --disable remi-php* ;
sudo yum-config-manager --enable remi-php73;
yum install -y php php-cli vim php-fpm php-mysqlnd git gitlib php-opcache php-pdo xz lz4 p7zip lzma php-gd php-zip php-devel php-gd php-mcrypt php-mbstring php-xml php-pear php-bcmath php-json php-ldap php-odbc php-zstd php-zstd-devel php-scldevel php-process autoconf automake openssl-devel expat-devel cmake expat-devel libtool composer libnghttp2-devel pcre-devel sudo wget perl pcre-devel libxml2-devel;
yum install -y https://dev.mysql.com/get/mysql80-community-release-el7-1.noarch.rpm -q;
yum install -y mysql-server -q;
yum clean all -v;
rm -rf /var/cache/* ;
yum update -q -y; 
mkdir /var/www && mkdir /var/www/html && cd /var/www/html;
git clone git@github.com:phpmyadmin/phpmyadmind.git;
cd phpmyadmin && composer update;
touch /var/www/html/index.php;
echo "<?php phpinfo(); ?>" >> /var/www/html/index.php  ;
yum update -q -y;
systemctl start mysqld; 
systemctl enable mysqld;
php -v && mysql -V;
# sudo grep 'temporary password' /var/log/mysqld.log \
# mysql_secure_installation \
rm -rf /var/cache/* ;
yum clean all -v;
ls -ali;
