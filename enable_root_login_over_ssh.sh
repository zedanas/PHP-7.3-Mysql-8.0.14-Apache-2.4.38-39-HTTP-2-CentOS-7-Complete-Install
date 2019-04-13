#!/bin/bash
###################################################################################
# Enable root login over SSH --->> enable_root_login_over_ssh.sh                  #
# To run script use following comands:                                            #
# chmod +x enable_root_login_over_ssh.sh && ./enable_root_login_over_ssh.sh       #
# Script works with Google Cloud VM Instance (centos 7)                           #
# K. G. 13.04.2019                                                                #
###################################################################################
pkg="zenity"
if rpm -q --quiet $pkg
then
    echo "$pkg installed"

sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config;
sed -i 's/PermitRootLogin no/PermitRootLogin yes/g' /etc/ssh/sshd_config;
systemctl restart sshd;
echo 'Now you can connect to your server using root password.';
Your Server ip addres:
curl ifconfig.co;
passwd

else
	echo "$pkg NOT installed"
    yum install -y $pkg -q;
fi
