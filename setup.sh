###################################################################################
# PHP 7.3 php-fpm mysql and other libs instalation --->> setup.sh                 #
# Runs script: chmod -R 777 setup.sh && bash setup.sh                             #
# K. G. 29.01.2019                                                                #
###################################################################################
#!/bin/bash
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY* -qvy \
yum install epel-release yum-utils && yum groups install 'Development Tools' 'Compatibility Libraries' -q -y \
yum install hmaccalc zlib-devel binutils-devel elfutils-libelf-devel ncurses-devel bc wget -q -y \
yum install tuned-* htop ImageMagick7 -q -y \
tuned --profile throughput-performance --daemon \
sudo yum-config-manager --disable remi-php54 \
sudo yum-config-manager --disable remi-php56 \
sudo yum-config-manager --disable remi-php70 \
sudo yum-config-manager --disable remi-php71 \
sudo yum-config-manager --disable remi-php72 \
sudo yum-config-manager --enable remi-php73 \
yum install php php-cli vim php-fpm php-mysqlnd git gitlib php-opcache php-pdo xz lz4 p7zip lzma \
php-gd php-zip php-devel php-gd php-mcrypt php-mbstring php-xml php-pear php-bcmath php-json php-ldap \
php-odbc php-zstd php-zstd-devel php-scldevel php-process autoconf automake openssl-devel expat-devel \
cmake expat-devel libtool composer libnghttp2-devel pcre-devel sudo wget perl pcre-devel libxml2-devel -q -y \
yum install https://dev.mysql.com/get/mysql80-community-release-el7-1.noarch.rpm  -q -y \
yum install mysql-server  -q -y \
yum clean all -v && yum update  -q -y \ 
mkdir /var/www && mkdir /var/www/html && cd /var/www/html \
git clone git@github.com:phpmyadmin/phpmyadmind.git \
cd phpmyadmin && composer update \
touch /var/www/html/index.php \
echo "<?php phpinfo(); ?>" >> /var/www/html/index.php \
yum update all -q -y \
systemctl start mysqld.service \ 
systemctl enable mysqld.service \
php -v && mysql -V \
# sudo grep 'temporary password' /var/log/mysqld.log \
# mysql_secure_installation \
ls -ali
