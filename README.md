# PHP/7.3.0RC5 Mysql/5.6.42 Apache/2.4.6 PhpMyAdmin/4.4.15.10 CentOS 7 Complete Install
Server:
CPU: Intel(R) Xeon(R) CPU D-1541 @ 2.10GHz

Cores: 16

Cache: 12288KB

RAM: 2x 16384MB 

Disks: 2 x 480GB SSd RAID0

Motherboard: X10SDV-TLN4F


Kernel version
4.9.133-xxxx-std-ipv6-64



After complete installiation please follow instructions below:

Replace "<Directory /usr/share/phpMyAdmin/>" on phpMyAdmin config:

vim /etc/httpd/conf.d/phpMyAdmin.conf

<Directory /usr/share/phpMyAdmin/>

   AddDefaultCharset UTF-8

<IfModule mod_authz_core.c>
	
# Apache 2.4
<RequireAny>
Require all granted
</RequireAny>
</IfModule>
<IfModule !mod_authz_core.c>
# Apache 2.2
Order Deny,Allow
Deny from All
Allow from 127.0.0.1
Allow from ::1
</IfModule>
</Directory>

Replace "<IfModule  mod_php7.c>" on Apache config file:
vim /etc/http/php.d/php.conf

<IfModule  mod_php7.c>
# Cause the PHP interpreter to handle files with a .php extension.
<FilesMatch \.(php|phar)$>
# SetHandler application/x-httpd-php
SetHandler "proxy:fcgi://127.0.0.1:9000"
</FilesMatch>
php_value session.save_handler "files" 
php_value session.save_path    "/var/lib/php/session" 
php_value soap.wsdl_cache_dir  "/var/lib/php/wsdlcache" 
php_value opcache.file_cache   "/var/lib/php/opcache" 
</IfModule>

Replace "[mysqld]" settings on my config file:
vim /etc/my.cfg

[mysqld]
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
innodb_file_per_table = true

innodb_flush_method = O_DIRECT
innodb_log_buffer_size = 64M
innodb_flush_log_at_trx_commit = 1
innodb_buffer_pool_size = 10240M
innodb_buffer_pool_instances=128
innodb_log_file_size = 1024M
innodb_log_files_in_group = 2

innodb_read_io_threads = 128
innodb_write_io_threads = 128
innodb_io_capacity = 20000
innodb_io_capacity_max = 40000


# Disabling symbolic-links is recommended to prevent assorted security risks
symbolic-links=0

# Recommended in standard MySQL setup
sql_mode=STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION

[mysqld_safe]
log-error=/var/log/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid

Add Zend OPcache settings on php.ini file:
vim /etc/php.ini

zend_extension=opcache.so
opcache.memory_consumption=64
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=7963
opcache.validate_timestamps=0
opcache.revalidate_freq=0
opcache.fast_shutdown=1
opcache.enable_cli=0
opcache.enable=1
