#!/bin/bash
###################################################################################
# Enable root login over SSH --->> enable_root_login_over_ssh.sh                  #
# To run script use following comands:                                            #
# chmod a+x enable_root_login_over_ssh.sh && ./enable_root_login_over_ssh.sh      #
# Script works with Google Cloud VM Instance (centos 7)                           #
# K. G. 13.04.2019                                                                #
###################################################################################
if [ -f /etc/selinux/config ]; then
  sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config && setenforce 0
  sed -i 's/SELINUX=permissive/SELINUX=disabled/g' /etc/selinux/config && setenforce 0
fi
systemctl daemon-reload --quiet;
# Setup Colours
black='\E[30;40m'
red='\E[31;40m'
green='\E[32;40m'
yellow='\E[33;40m'
blue='\E[34;40m'
magenta='\E[35;40m'
cyan='\E[36;40m'
white='\E[37;40m'
Reset="tput sgr0" 

cecho ()                     # Coloured-echo.
                             # Argument $1 = message
                             # Argument $2 = color
{
message=$1
color=$2
echo -e "$color$message" ; $Reset
return
}
 if [[ ! -f /usr/bin/wget ]]; then
    yum -y -q  install wget
	cecho "INSTALLED: $(rpm -qa wget)" $green
 fi
pkg="openssh"
if rpm -q --quiet $pkg
then
    cecho "$pkg installed" $green

sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config;
sed -i 's/PermitRootLogin no/PermitRootLogin yes/g' /etc/ssh/sshd_config;
systemctl restart sshd && yum update -y -q && yum -q clean all && systemctl daemon-reload --quiet;
echo "1234" | passwd --stdin root;
cecho "New root password: 1234"; $red
cecho "Now you can connect to your server using root password."; $green
cecho "Your Server ip addres:" $green
curl ifconfig.co;


else
	cecho "$pkg NOT installed" $red
    yum install -y $pkg -q;
fi

# curl -sL https://raw.githubusercontent.com/zedanas/PHP-7.3-Mysql-8.0.14-Apache-2.4.38-39-HTTP-2-CentOS-7-Complete-Install/master/enable_root_login_over_ssh.sh | bash
