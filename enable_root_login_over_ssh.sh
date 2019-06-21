#!/bin/bash
###################################################################################
# Enable root login over SSH --->> enable_root_login_over_ssh.sh                  #
# To run script use following comands:                                            #
# chmod a+x enable_root_login_over_ssh.sh && ./enable_root_login_over_ssh.sh      #
# Script works with Google Cloud VM Instance (centos 7)                           #
# K. G. 13.04.2019                                                                #
###################################################################################
source inc/source.inc
timedatectl set-timezone "Europe/London"
if [ -f /etc/selinux/config ]; then
  sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config && setenforce 0
  sed -i 's/SELINUX=permissive/SELINUX=disabled/g' /etc/selinux/config && setenforce 0
fi
if [ ! -f /usr/bin/wget ]; then
yum install -y -q wget
cecho "INSTALLED: $(rpm -q wget)" $green
fi
if [ ! -f /usr/bin/git ]; then
yum install -y -q git
cecho "INSTALLED: $(rpm -q git)" $green
fi
if [ ! -f /usr/bin/lynx ]; then
yum install -y -q lynx
cecho "INSTALLED: $(rpm -q lynx)" $green
fi
if [ ! -f /usr/bin/unzip ]; then
yum install -y -q unzip
cecho "INSTALLED: $(rpm -q unzip)" $green
fi
if [ -f /usr/local/bin/lzip ]; then
yum install -y -q lzip
cecho "INSTALLED: $(rpm -q lzip)" $green
fi
if [[ ! -f /usr/bin/pigz ]]; then
yum install -y -q pigz
cecho "INSTALLED: $(rpm -q pigz)" $green
fi
if [ ! -f /usr/bin/tee ]; then
yum install -y -q coreutils
cecho "INSTALLED: $(rpm -q coreutils)" $green
fi

if [ ! -f /usr/bin/applydeltarpm ]; then
yum install -y -q coreutils
cecho "INSTALLED: $(rpm -q deltarpm)" $green
fi
if [ ! -f /usr/bin/screen ]; then
yum install -y -q screen
cecho "INSTALLED: $(rpm -q screen)" $green
fi
 
pkg="openssh"
if rpm -q --quiet $pkg
then
    cecho "$pkg installed" $green

sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config;
sed -i 's/PermitRootLogin no/PermitRootLogin yes/g' /etc/ssh/sshd_config;
systemctl restart sshd && yum update -y -q && yum -q clean all && systemctl daemon-reload --quiet;
echo "1234" | passwd --stdin root;
cecho "New root password: 1234" $red
cecho "Now you can connect to your server using root password." $green
cecho "Your Server ip addres:" $green
curl ifconfig.co;


else
	cecho "$pkg NOT installed" $red
    yum install -y $pkg -q;
fi

# curl -sL https://raw.githubusercontent.com/zedanas/PHP-7.3-Mysql-8.0.14-Apache-2.4.38-39-HTTP-2-CentOS-7-Complete-Install/master/enable_root_login_over_ssh.sh | bash
