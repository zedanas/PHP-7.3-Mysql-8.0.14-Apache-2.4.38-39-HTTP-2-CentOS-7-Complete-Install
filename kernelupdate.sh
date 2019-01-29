#!bin/bash
###################################################################################
# run script:                                                                     #
# chmod -R 777 kernelupdate.sh                                                    #
# ./kernelupdate.sh                                                               #
# All available kernel realises you can find it here:                             #
# https://mirrors.edge.kernel.org/pub/linux/kernel/                               #
# K. G. 29.01.2019                                                                #
###################################################################################
cd /tmp
sudo yum group install "Development Tools" -y -q
wget https://mirrors.edge.kernel.org/pub/linux/kernel/v4.x/linux-4.9.153.tar.sign
gpg --verify linux-4.9.153.tar.sign
wget https://mirrors.edge.kernel.org/pub/linux/kernel/v4.x/linux-4.9.153.tar.xz
xz -d -v linux-4.9.153.tar.xz
gpg --verify linux-4.9.153.tar.sign
gpg --recv-keys 6092693E
tar xvf linux-4.9.153.tar
cd linux-4.9.153 && cp -v /boot/config-$(uname -r) .config
make menuconfig --silent
make --jobs=3 --silent
sudo make modules_install --jobs=3 --silent
sudo make install --jobs=3 --silent
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
sudo grubby --set-default /boot/vmlinuz-4.9.153
grubby --info=ALL | more
grubby --default-index && grubby --default-kernel
