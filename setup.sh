#!/usr/bin/env bash
sudo yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm -q
sudo yum -y install epel-release yum-utils -q
sudo yum-config-manager --disable remi-php54
sudo yum-config-manager --disable remi-php56
sudo yum-config-manager --enable remi-php73
sudo yum -y install php php-cli php-fpm php-mysqlnd php-opcache php-lz4 php-lzma php-gd php-zip php-devel php-gd php-mcrypt php-mbstring php-curl php-xml php-pear php-bcmath php-json -q
sudo yum install httpd autoconf expat-devel libtool libnghttp2-devel pcre-devel -y -q
sudo yum install tuned-* htop ImageMagick -y -q
sudo tuned --profile throughput-performance --daemon
sudo tuned-adm profile throughput-performance
sudo yum -y install https://dev.mysql.com/get/mysql80-community-release-el7-1.noarch.rpm -q
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY*
sudo yum install mysql-server -y -q
sudo systemctl start httpd.service 
sudo systemctl enable httpd.service 
sudo systemctl start mysqld.service 
sudo systemctl enable mysqld.service 
sudo yum clean all -v
sudo yum update
