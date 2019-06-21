#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

cur_dir=$(pwd)

include(){
    local include=$1
    if [[ -s ${cur_dir}/include/${include}.sh ]]; then
        . ${cur_dir}/include/${include}.sh
    else
        echo "Error:${cur_dir}/include/${include}.sh not found, shell can not be executed."
        exit 1
    fi
}

uninstall_lamp(){
    log "Info" "uninstalling Apache"
    if [ -f /etc/init.d/httpd ] && [ $(ps -ef | grep -v grep | grep -c "httpd") -gt 0 ]; then
        /etc/init.d/httpd stop > /dev/null 2>&1
    fi
    rm -f /etc/init.d/httpd
    rm -rf ${apache_location} /usr/sbin/httpd /var/log/httpd /etc/logrotate.d/httpd /var/spool/mail/apache
    log "Info" "Success"
    echo
    log "Info" "uninstalling MySQL/MariaDB/Percona"
    if [ -f /etc/init.d/mysqld ] && [ $(ps -ef | grep -v grep | grep -c "mysqld") -gt 0 ]; then
        /etc/init.d/mysqld stop > /dev/null 2>&1
    fi
    rm -f /etc/init.d/mysqld
    rm -rf ${mysql_location} ${mariadb_location} ${percona_location} /usr/bin/mysqldump /usr/bin/mysql /etc/my.cnf /etc/ld.so.conf.d/mysql.conf
    log "Info" "Success"
    echo
    log "Info" "uninstalling PHP"
    rm -rf ${php_location} /usr/bin/php /usr/bin/php-config /usr/bin/phpize /etc/php.ini
    log "Info" "Success"
    echo
    log "Info" "uninstalling others software"
    [ -f /etc/init.d/memcached ] && /etc/init.d/memcached stop > /dev/null 2>&1
    rm -f /etc/init.d/memcached
    rm -fr ${depends_prefix}/memcached /usr/bin/memcached
    [ -f /etc/init.d/redis-server ] && /etc/init.d/redis-server stop > /dev/null 2>&1
    rm -f /etc/init.d/redis-server
    rm -rf ${depends_prefix}/redis
    rm -rf /usr/local/lib/libcharset* /usr/local/lib/libiconv* /usr/local/lib/charset.alias /usr/local/lib/preloadable_libiconv.so
    rm -rf ${depends_prefix}/imap
    rm -rf ${depends_prefix}/pcre
    rm -rf ${openssl_location} /etc/ld.so.conf.d/openssl.conf
    rm -rf /usr/lib/libnghttp2.*
    rm -rf /usr/local/lib/libmcrypt.*
    rm -rf /usr/local/lib/libmhash.*
    rm -rf /usr/local/bin/iconv
    rm -rf /usr/local/bin/re2c
    rm -rf /usr/local/bin/mcrypt
    rm -rf /usr/local/bin/mdecrypt
    rm -rf /etc/ld.so.conf.d/locallib.conf
    rm -rf ${web_root_dir}/phpmyadmin
    rm -rf ${web_root_dir}/kod
    rm -rf ${web_root_dir}/xcache /tmp/{pcov,phpcore}
    log "Info" "Success"
    echo
    log "Info" "Successfully uninstall LAMP"
}

include config
include public
load_config
rootness

while true
do
    read -p "Are you sure uninstall LAMP? (Default: n) (y/n)" uninstall
    [ -z ${uninstall} ] && uninstall="n"
    uninstall=$(upcase_to_lowcase ${uninstall})
    case ${uninstall} in
        y) uninstall_lamp ; break;;
        n) log "Info" "Uninstall cancelled, nothing to do" ; break;;
        *) log "Warning" "Input error. Please only input y/n";;
    esac
done
