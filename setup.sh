#!/bin/sh
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY*
sudo yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm -q
sudo yum -y install epel-release yum-utils -q
sudo yum install tuned-* htop ImageMagick -y -q
sudo tuned --profile throughput-performance --daemon
sudo tuned-adm profile throughput-performance
sudo yum-config-manager --disable remi-php54
sudo yum-config-manager --disable remi-php56
sudo yum-config-manager --disable remi-php70
sudo yum-config-manager --disable remi-php71
sudo yum-config-manager --disable remi-php72
sudo yum-config-manager --enable remi-php73
sudo yum -y install php php-cli vim php-fpm php-mysqlnd git php-opcache php-lz4 php-lzma php-gd php-zip php-devel php-gd php-mcrypt php-mbstring php-curl php-xml php-pear php-bcmath php-json -q
sudo yum install httpd autoconf expat-devel mod_fcgid libtool composer npm libnghttp2-devel pcre-devel mod_ssl -y -q
sudo yum -y install https://dev.mysql.com/get/mysql80-community-release-el7-1.noarch.rpm -q
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY*
sudo yum install mysql-server -y -q
sudo yum clean all -v && yum update -y -q && cd /var/www/html 
sudo git clone https://github.com/phpmyadmin/phpmyadmind.git -q
cd phpmyadmin && composer update 
touch /var/www/html/index.php && 
echo "<?php phpinfo(); ?>" >> /var/www/html/index.php
sudo yum update -y -q 
sudo systemctl start httpd.service mysqld.service
sudo systemctl enable httpd.service mysqld.service
ab -k -c 350 -n 20000 localhost/index.php
sudo php -v
sudo mysql -V
sudo httpd -V
sudo grep 'temporary password' /var/log/mysqld.log
mysql_secure_installation
