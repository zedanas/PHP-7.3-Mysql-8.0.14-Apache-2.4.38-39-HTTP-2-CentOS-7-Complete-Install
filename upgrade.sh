#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
cur_dir=$(pwd)
include(){
    local include=$1
    if [[ -s ${cur_dir}/include/${include}.sh ]];then
        . ${cur_dir}/include/${include}.sh
    else
        echo "Error:${cur_dir}/include/${include}.sh not found, shell can not be executed."
        exit 1
    fi
}

upgrade_menu(){

    echo
    echo "+-------------------------------------------------------------------+"
    echo "| Auto Update LAMP(Linux + Apache + MySQL/MariaDB/Percona + PHP )   |"
    echo "+-------------------------------------------------------------------+"
    echo

    while true
    do
    echo -e "\t\033[1;32m1\033[0m. Upgrade Apache"
    echo -e "\t\033[1;32m2\033[0m. Upgrade MySQL/MariaDB/Percona"
    echo -e "\t\033[1;32m3\033[0m. Upgrade PHP"
    echo -e "\t\033[1;32m4\033[0m. Upgrade phpMyAdmin"
    echo -e "\t\033[1;32m5\033[0m. Exit"
    echo
    read -p "Please input a number: " number
    if [[ ! ${number} =~ ^[1-5]$ ]]; then
        log "Error" "Input error. please only input 1,2,3,4,5"
    else
        case "${number}" in
        1)
            upgrade_apache 2>&1 | tee ${cur_dir}/upgrade_apache.log
            break
            ;;
        2)
            upgrade_db 2>&1 | tee ${cur_dir}/upgrade_db.log
            break
            ;;
        3)
            upgrade_php 2>&1 | tee ${cur_dir}/upgrade_php.log
            break
            ;;
        4)
            upgrade_phpmyadmin 2>&1 | tee ${cur_dir}/upgrade_phpmyadmin.log
            break
            ;;
        5)
            exit
            ;;
        esac
    fi
    done

}

display_usage(){
printf "

Usage: $0 [ apache | db | php | phpmyadmin ]
apache                    --->Upgrade Apache
db                        --->Upgrade MySQL/MariaDB/Percona
php                       --->Upgrade PHP
phpmyadmin                --->Upgrade phpMyAdmin

"
}

include config
include public
include upgrade_apache
include upgrade_db
include upgrade_php
include upgrade_phpmyadmin
load_config
rootness

if [ ${#} -eq 0 ]; then
    upgrade_menu
elif [ ${#} -eq 1 ]; then
    case $1 in
    apache)
        upgrade_apache 2>&1 | tee ${cur_dir}/upgrade_apache.log
        ;;
    db)
        upgrade_db 2>&1 | tee ${cur_dir}/upgrade_db.log
        ;;
    php)
        upgrade_php 2>&1 | tee ${cur_dir}/upgrade_php.log
        ;;
    phpmyadmin)
        upgrade_phpmyadmin 2>&1 | tee ${cur_dir}/upgrade_phpmyadmin.log
        ;;
    *)
        display_usage
        ;;
    esac
else
    display_usage
fi
