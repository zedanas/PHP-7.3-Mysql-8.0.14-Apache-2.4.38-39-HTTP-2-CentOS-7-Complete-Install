php_modules_preinstall_settings(){
    if [ "${php}" == "do_not_install" ]; then
        php_modules_install="do_not_install"
    else
        phpConfig=${php_location}/bin/php-config
        echo
        echo "${php} available modules:"
        # delete some modules & change some module version
        if [ "${php}" == "${php5_6_filename}" ]; then
            php_modules_arr=(${php_modules_arr[@]#${php_libsodium_filename}})
            php_modules_arr=(${php_modules_arr[@]#${swoole_filename}})
            php_modules_arr=(${php_modules_arr[@]#${yaf_filename}})
        else
            php_modules_arr=(${php_modules_arr[@]#${xcache_filename}})
            php_modules_arr=(${php_modules_arr[@]/#${xdebug_filename}/${xdebug_filename2}})
            php_modules_arr=(${php_modules_arr[@]/#${php_redis_filename}/${php_redis_filename2}})
            php_modules_arr=(${php_modules_arr[@]/#${php_memcached_filename}/${php_memcached_filename2}})
            php_modules_arr=(${php_modules_arr[@]/#${php_graphicsmagick_filename}/${php_graphicsmagick_filename2}})
        fi
        display_menu_multi php_modules last
    fi
}

#Pre-installation phpmyadmin
phpmyadmin_preinstall_settings(){
    if [ "${php}" == "do_not_install" ]; then
        phpmyadmin="do_not_install"
    else
        display_menu phpmyadmin 1
    fi
}

#Pre-installation kodexplorer
kodexplorer_preinstall_settings(){
    if [ "${php}" == "do_not_install" ]; then
        kodexplorer="do_not_install"
    else
        display_menu kodexplorer 1
    fi
}

install_php_modules(){
    local phpConfig=${1}
    if_in_array "${ionCube_filename}" "${php_modules_install}" && install_ionCube "${phpConfig}"
    if_in_array "${php_imagemagick_filename}" "${php_modules_install}" && install_php_imagesmagick "${phpConfig}"
    if_in_array "${php_mongo_filename}" "${php_modules_install}" && install_php_mongo "${phpConfig}"
    if [ "${php}" == "${php5_6_filename}" ]; then
        if_in_array "${xcache_filename}" "${php_modules_install}" && install_xcache "${phpConfig}"
        if_in_array "${xdebug_filename}" "${php_modules_install}" && install_xdebug "${phpConfig}"
        if_in_array "${php_graphicsmagick_filename}" "${php_modules_install}" && install_php_graphicsmagick "${phpConfig}"
        if_in_array "${php_redis_filename}" "${php_modules_install}" && install_php_redis "${phpConfig}"
        if_in_array "${php_memcached_filename}" "${php_modules_install}" && install_php_memcached "${phpConfig}"
    else
        if_in_array "${xdebug_filename2}" "${php_modules_install}" && install_xdebug "${phpConfig}"
        if_in_array "${php_libsodium_filename}" "${php_modules_install}" && install_php_libsodium "${phpConfig}"
        if_in_array "${php_graphicsmagick_filename2}" "${php_modules_install}" && install_php_graphicsmagick "${phpConfig}"
        if_in_array "${php_redis_filename2}" "${php_modules_install}" && install_php_redis "${phpConfig}"
        if_in_array "${php_memcached_filename2}" "${php_modules_install}" && install_php_memcached "${phpConfig}"
        if_in_array "${swoole_filename}" "${php_modules_install}" && install_swoole "${phpConfig}"
        if_in_array "${yaf_filename}" "${php_modules_install}" && install_yaf "${phpConfig}"
    fi
}

install_php_depends(){
    if check_sys packageManager apt; then
        apt_depends=(
            autoconf patch m4 bison libbz2-dev libgmp-dev libicu-dev libldb-dev libpam0g-dev
            libldap-2.4-2 libldap2-dev libsasl2-dev libsasl2-modules-ldap libc-client2007e-dev libkrb5-dev
            autoconf2.13 pkg-config libxslt1-dev zlib1g-dev libpcre3-dev libtool unixodbc-dev libtidy-dev
            libjpeg-dev libpng-dev libfreetype6-dev libpspell-dev libmhash-dev libenchant-dev libmcrypt-dev
            libcurl4-gnutls-dev libwebp-dev libxpm-dev libvpx-dev libreadline-dev snmp libsnmp-dev libzip-dev
        )
        log "Info" "Starting to install dependencies packages for PHP..."
        for depend in ${apt_depends[@]}
        do
            error_detect_depends "apt-get -y install ${depend}"
        done
        log "Info" "Install dependencies packages for PHP completed..."

        if is_64bit; then
            if [ ! -d /usr/lib64 ] && [ -d /usr/lib ]; then
                ln -sf /usr/lib /usr/lib64
            fi

            if [ -f /usr/include/gmp-x86_64.h ]; then
                ln -sf /usr/include/gmp-x86_64.h /usr/include/
            elif [ -f /usr/include/x86_64-linux-gnu/gmp.h ]; then
                ln -sf /usr/include/x86_64-linux-gnu/gmp.h /usr/include/
            fi

            ln -sf /usr/lib/x86_64-linux-gnu/libldap* /usr/lib64/
            ln -sf /usr/lib/x86_64-linux-gnu/liblber* /usr/lib64/

            if [ -d /usr/include/x86_64-linux-gnu/curl ] && [ ! -d /usr/include/curl ]; then
                ln -sf /usr/include/x86_64-linux-gnu/curl /usr/include/
            fi

            create_lib_link libc-client.a
            create_lib_link libc-client.so
        else
            if [ -f /usr/include/gmp-i386.h ]; then
                ln -sf /usr/include/gmp-i386.h /usr/include/
            elif [ -f /usr/include/i386-linux-gnu/gmp.h ]; then
                ln -sf /usr/include/i386-linux-gnu/gmp.h /usr/include/
            fi

            ln -sf /usr/lib/i386-linux-gnu/libldap* /usr/lib/
            ln -sf /usr/lib/i386-linux-gnu/liblber* /usr/lib/

            if [ -d /usr/include/i386-linux-gnu/curl ] && [ ! -d /usr/include/curl ]; then
                ln -sf /usr/include/i386-linux-gnu/curl /usr/include/
            fi
        fi
    elif check_sys packageManager yum; then
        yum_depends=(
            autoconf patch m4 bison bzip2-devel pam-devel gmp-devel libicu-devel
            curl-devel pcre-devel libtool-libs libtool-ltdl-devel libwebp-devel libXpm-devel
            libvpx-devel libjpeg-devel libpng-devel freetype-devel oniguruma-devel
            aspell-devel enchant-devel readline-devel unixODBC-devel libtidy-devel
            openldap-devel libxslt-devel net-snmp net-snmp-devel krb5-devel
        )
        log "Info" "Starting to install dependencies packages for PHP..."
        for depend in ${yum_depends[@]}
        do
            error_detect_depends "yum -y install ${depend}"
        done
        if yum list | grep "libc-client-devel" > /dev/null 2>&1; then
            error_detect_depends "yum -y install libc-client-devel"
        elif yum list | grep "uw-imap-devel" > /dev/null 2>&1; then
            error_detect_depends "yum -y install uw-imap-devel"
        else
            log "Error" "There is no rpm package libc-client-devel or uw-imap-devel, please check it and try again."
            exit 1
        fi
        log "Info" "Install dependencies packages for PHP completed..."

        install_mhash
        install_libmcrypt
        install_mcrypt
        install_libzip
    fi

    install_libiconv
    install_re2c
    # Fixed unixODBC issue
    if [ -f /usr/include/sqlext.h ] && [ ! -f /usr/local/include/sqlext.h ]; then
        ln -sf /usr/include/sqlext.h /usr/local/include/
    fi
}

install_libiconv(){
    if [ ! -e "/usr/local/bin/iconv" ]; then
        cd ${cur_dir}/software/
        log "Info" "${libiconv_filename} install start..."
        download_file  "${libiconv_filename}.tar.gz" "${libiconv_filename_url}"
        tar zxf ${libiconv_filename}.tar.gz
        patch -d ${libiconv_filename} -p0 < ${cur_dir}/conf/libiconv-glibc-2.16.patch
        cd ${libiconv_filename}

        error_detect "./configure"
        error_detect "parallel_make"
        error_detect "make install"
        log "Info" "${libiconv_filename} install completed..."
    fi
}

install_re2c(){
    if [ ! -e "/usr/local/bin/re2c" ]; then
        cd ${cur_dir}/software/
        log "Info" "${re2c_filename} install start..."
        download_file "${re2c_filename}.tar.gz" "${re2c_filename_url}"
        tar zxf ${re2c_filename}.tar.gz
        cd ${re2c_filename}

        error_detect "./configure"
        error_detect "make"
        error_detect "make install"
        log "Info" "${re2c_filename} install completed..."
    fi
}

install_mhash(){
    if [ ! -e "/usr/local/lib/libmhash.a" ]; then
        cd ${cur_dir}/software/
        log "Info" "${mhash_filename} install start..."
        download_file "${mhash_filename}.tar.gz" "${mhash_filename_url}"
        tar zxf ${mhash_filename}.tar.gz
        cd ${mhash_filename}

        error_detect "./configure"
        error_detect "parallel_make"
        error_detect "make install"
        log "Info" "${mhash_filename} install completed..."
    fi
}

install_mcrypt(){
    if [ ! -e "/usr/local/bin/mcrypt" ]; then
        cd ${cur_dir}/software/
        log "Info" "${mcrypt_filename} install start..."
        download_file "${mcrypt_filename}.tar.gz" "${mcrypt_filename_url}"
        tar zxf ${mcrypt_filename}.tar.gz
        cd ${mcrypt_filename}

        ldconfig
        error_detect "./configure"
        error_detect "parallel_make"
        error_detect "make install"
        log "Info" "${mcrypt_filename} install completed..."
    fi
}

install_libmcrypt(){
    if [ ! -e "/usr/local/lib/libmcrypt.la" ]; then
        cd ${cur_dir}/software/
        log "Info" "${libmcrypt_filename} install start..."
        download_file "${libmcrypt_filename}.tar.gz" "${libmcrypt_filename_url}"
        tar zxf ${libmcrypt_filename}.tar.gz
        cd ${libmcrypt_filename}

        error_detect "./configure"
        error_detect "parallel_make"
        error_detect "make install"
        log "Info" "${libmcrypt_filename} install completed..."
    fi
}

install_libzip(){
    if [ ! -e "/usr/lib/libzip.la" ]; then
        cd ${cur_dir}/software/
        log "Info" "${libzip_filename} install start..."
        download_file "${libzip_filename}.tar.gz" "${libzip_filename_url}"
        tar zxf ${libzip_filename}.tar.gz
        cd ${libzip_filename}

        error_detect "./configure --prefix=/usr"
        error_detect "parallel_make"
        error_detect "make install"
        log "Info" "${libzip_filename} install completed..."
    fi
}

install_phpmyadmin(){
    if [ -d "${web_root_dir}/phpmyadmin" ]; then
        rm -rf ${web_root_dir}/phpmyadmin
    fi

    cd ${cur_dir}/software

    log "Info" "${phpmyadmin_filename} install start..."
    download_file "${phpmyadmin_filename}.tar.gz" "${phpmyadmin_filename_url}"
    tar zxf ${phpmyadmin_filename}.tar.gz
    mv ${phpmyadmin_filename} ${web_root_dir}/phpmyadmin
    cp -f ${cur_dir}/conf/config.inc.php ${web_root_dir}/phpmyadmin/config.inc.php
    mkdir -p ${web_root_dir}/phpmyadmin/{upload,save}
    chown -R apache:apache ${web_root_dir}/phpmyadmin
    log "Info" "${phpmyadmin_filename} install completed..."
}

install_kodexplorer(){
    if [ -d "${web_root_dir}/kod" ]; then
        rm -rf ${web_root_dir}/kod
    fi

    cd ${cur_dir}/software

    log "Info" "${kodexplorer_filename} install start..."
    download_file "${kodexplorer_filename}.tar.gz" "${kodexplorer_filename_url}"
    tar zxf ${kodexplorer_filename}.tar.gz
    mv ${kodexplorer_filename} ${web_root_dir}/kod
    chown -R apache:apache ${web_root_dir}/kod
    log "Info" "${kodexplorer_filename} install completed..."
}

install_ionCube(){
    local phpConfig=${1}
    local php_version=$(get_php_version "${phpConfig}")
    local php_extension_dir=$(get_php_extension_dir "${phpConfig}")

    cd ${cur_dir}/software/

    log "Info" "PHP extension ionCube Loader install start..."
    if is_64bit; then
        download_file "${ionCube64_filename}.tar.gz" "${ionCube64_filename_url}"
        tar zxf ${ionCube64_filename}.tar.gz
        cp -pf ioncube/ioncube_loader_lin_${php_version}_ts.so ${php_extension_dir}/
    else
        download_file "${ionCube32_filename}.tar.gz" "${ionCube32_filename_url}"
        tar zxf ${ionCube32_filename}.tar.gz
        cp -pf ioncube/ioncube_loader_lin_${php_version}_ts.so ${php_extension_dir}/
    fi

    if [ ! -f ${php_location}/php.d/ioncube.ini ]; then
        log "Info" "PHP extension ionCube Loader configuration file not found, create it!"
        cat > ${php_location}/php.d/ioncube.ini<<-EOF
[ionCube Loader]
zend_extension = ${php_extension_dir}/ioncube_loader_lin_${php_version}_ts.so
EOF
    fi
    log "Info" "PHP extension ionCube Loader install completed..."
}

install_xcache(){
    local phpConfig=${1}
    local php_version=$(get_php_version "${phpConfig}")
    local php_extension_dir=$(get_php_extension_dir "${phpConfig}")

    log "Info" "PHP extension XCache install start..."
    cd ${cur_dir}/software/
    download_file "${xcache_filename}.tar.gz" "${xcache_filename_url}"
    tar zxf ${xcache_filename}.tar.gz
    cd ${xcache_filename}
    error_detect "${php_location}/bin/phpize"
    error_detect "./configure --enable-xcache --enable-xcache-constant --with-php-config=${phpConfig}"
    error_detect "make"
    error_detect "make install"
    
    rm -rf ${web_root_dir}/xcache
    cp -r htdocs/ ${web_root_dir}/xcache
    chown -R apache:apache ${web_root_dir}/xcache
    rm -rf /tmp/{pcov,phpcore}
    mkdir /tmp/{pcov,phpcore}
    chown -R apache:apache /tmp/{pcov,phpcore}
    chmod 700 /tmp/{pcov,phpcore}
    
    if [ ! -f ${php_location}/php.d/xcache.ini ]; then
        log "Info" "PHP extension XCache configuration file not found, create it!"
        cat > ${php_location}/php.d/xcache.ini<<-EOF
[xcache-common]
extension = ${php_extension_dir}/xcache.so

[xcache.admin]
xcache.admin.enable_auth = On
xcache.admin.user = "admin"
xcache.admin.pass = "e10adc3949ba59abbe56e057f20f883e"

[xcache]
xcache.shm_scheme = "mmap"
xcache.size = 64M
xcache.count = 1
xcache.slots = 8K
xcache.ttl = 3600
xcache.gc_interval = 60
xcache.var_size = 16M
xcache.var_count = 1
xcache.var_slots = 8K
xcache.var_ttl = 3600
xcache.var_maxttl = 0
xcache.var_gc_interval = 300
xcache.readonly_protection = Off
xcache.mmap_path = "/dev/zero"
xcache.coredump_directory = "/tmp/phpcore"
xcache.coredump_type = 0
xcache.disable_on_crash = Off
xcache.experimental = Off
xcache.cacher = On
xcache.stat = On
xcache.optimizer = Off

[xcache.coverager]
xcache.coverager = Off
xcache.coverager_autostart =  On
xcache.coveragedump_directory = "/tmp/pcov"
EOF
    fi
    log "Info" "PHP extension XCache install completed..."
}

install_php_libsodium(){
    local phpConfig=${1}
    local php_version=$(get_php_version "${phpConfig}")
    local php_extension_dir=$(get_php_extension_dir "${phpConfig}")

    cd ${cur_dir}/software/

    log "Info" "PHP extension libsodium install start..."
    download_file "${libsodium_filename}.tar.gz" "${libsodium_filename_url}"
    tar zxf ${libsodium_filename}.tar.gz
    cd ${libsodium_filename}
    error_detect "./configure --prefix=/usr"
    error_detect "make"
    error_detect "make install"

    cd ${cur_dir}/software/

    download_file "${php_libsodium_filename}.tar.gz" "${php_libsodium_filename_url}"
    tar zxf ${php_libsodium_filename}.tar.gz
    cd ${php_libsodium_filename}
    error_detect "${php_location}/bin/phpize"
    error_detect "./configure --with-php-config=${phpConfig}"
    error_detect "make"
    error_detect "make install"
    
    if [ ! -f ${php_location}/php.d/sodium.ini ]; then
        log "Info" "PHP extension libsodium configuration file not found, create it!"
        cat > ${php_location}/php.d/sodium.ini<<-EOF
[sodium]
extension = ${php_extension_dir}/sodium.so
EOF
    fi
    log "Info" "PHP extension libsodium install completed..."
}

install_php_imagesmagick(){
    local phpConfig=${1}
    local php_version=$(get_php_version "${phpConfig}")
    local php_extension_dir=$(get_php_extension_dir "${phpConfig}")

    cd ${cur_dir}/software/

    log "Info" "PHP extension imagemagick install start..."
    download_file "${ImageMagick_filename}.tar.gz" "${ImageMagick_filename_url}"
    tar zxf ${ImageMagick_filename}.tar.gz
    cd ${ImageMagick_filename}
    error_detect "./configure"
    error_detect "make"
    error_detect "make install"

    cd ${cur_dir}/software/

    download_file "${php_imagemagick_filename}.tgz" "${php_imagemagick_filename_url}"
    tar zxf ${php_imagemagick_filename}.tgz
    cd ${php_imagemagick_filename}
    error_detect "${php_location}/bin/phpize"
    error_detect "./configure --with-imagick=/usr/local --with-php-config=${phpConfig}"
    error_detect "make"
    error_detect "make install"
    
    if [ ! -f ${php_location}/php.d/imagick.ini ]; then
        log "Info" "PHP extension imagemagick configuration file not found, create it!"
        cat > ${php_location}/php.d/imagick.ini<<-EOF
[imagick]
extension = ${php_extension_dir}/imagick.so
EOF
    fi
    log "Info" "PHP extension imagemagick install completed..."
}

install_php_graphicsmagick(){
    local phpConfig=${1}
    local php_version=$(get_php_version "${phpConfig}")
    local php_extension_dir=$(get_php_extension_dir "${phpConfig}")

    cd ${cur_dir}/software/

    log "Info" "PHP extension graphicsmagick install start..."
    download_file "${GraphicsMagick_filename}.tar.gz" "${GraphicsMagick_filename_url}"
    tar zxf ${GraphicsMagick_filename}.tar.gz
    cd ${GraphicsMagick_filename}
    error_detect "./configure --enable-shared"
    error_detect "make"
    error_detect "make install"

    cd ${cur_dir}/software/

    if [ "$php" == "${php5_6_filename}" ]; then
        download_file "${php_graphicsmagick_filename}.tgz" "${php_graphicsmagick_filename_url}"
        tar zxf ${php_graphicsmagick_filename}.tgz
        cd ${php_graphicsmagick_filename}
    else
        download_file "${php_graphicsmagick_filename2}.tgz" "${php_graphicsmagick_filename2_url}"
        tar zxf ${php_graphicsmagick_filename2}.tgz
        cd ${php_graphicsmagick_filename2}
    fi

    error_detect "${php_location}/bin/phpize"
    error_detect "./configure --with-php-config=${phpConfig}"
    error_detect "make"
    error_detect "make install"
    
    if [ ! -f ${php_location}/php.d/gmagick.ini ]; then
        log "Info" "PHP extension graphicsmagick configuration file not found, create it!"
        cat > ${php_location}/php.d/gmagick.ini<<-EOF
[gmagick]
extension = ${php_extension_dir}/gmagick.so
EOF
    fi
    log "Info" "PHP extension graphicsmagick install completed..."
}

install_php_memcached(){
    local phpConfig=${1}
    local php_version=$(get_php_version "${phpConfig}")
    local php_extension_dir=$(get_php_extension_dir "${phpConfig}")

    cd ${cur_dir}/software

    log "Info" "libevent install start..."
    download_file "${libevent_filename}.tar.gz" "${libevent_filename_url}"
    tar zxf ${libevent_filename}.tar.gz
    cd ${libevent_filename}
    error_detect "./configure"
    error_detect "make"
    error_detect "make install"
    ldconfig
    log "Info" "libevent install completed..."

    cd ${cur_dir}/software

    log "Info" "memcached install start..."
    id -u memcached >/dev/null 2>&1
    [ $? -ne 0 ] && groupadd memcached && useradd -M -s /sbin/nologin -g memcached memcached
    download_file "${memcached_filename}.tar.gz" "${memcached_filename_url}"
    tar zxf ${memcached_filename}.tar.gz
    cd ${memcached_filename}
    error_detect "./configure --prefix=${depends_prefix}/memcached"
    sed -i "s/\-Werror//" Makefile
    error_detect "make"
    error_detect "make install"
    
    rm -f /usr/bin/memcached
    ln -s ${depends_prefix}/memcached/bin/memcached /usr/bin/memcached
    if check_sys packageManager apt;then
        cp -f ${cur_dir}/init.d/memcached-init-debian /etc/init.d/memcached
    elif check_sys packageManager yum;then
        cp -f ${cur_dir}/init.d/memcached-init-centos /etc/init.d/memcached
    fi
    chmod +x /etc/init.d/memcached
    boot_start memcached
    log "Info" "memcached install completed..."

    cd ${cur_dir}/software

    log "Info" "libmemcached install start..."
    if check_sys packageManager apt;then
        apt-get -y install libsasl2-dev
    elif check_sys packageManager yum;then
        yum -y install cyrus-sasl-plain cyrus-sasl cyrus-sasl-devel cyrus-sasl-lib
    fi
    download_file "${libmemcached_filename}.tar.gz" "${libmemcached_filename_url}"
    tar zxf ${libmemcached_filename}.tar.gz
    patch -d ${libmemcached_filename} -p0 < ${cur_dir}/conf/libmemcached-build.patch
    cd ${libmemcached_filename}
    error_detect "./configure --with-memcached=${depends_prefix}/memcached --enable-sasl"
    error_detect "make"
    error_detect "make install"
    log "Info" "libmemcached install completed..."
    
    cd ${cur_dir}/software
    
    log "Info" "PHP extension memcached extension install start..."
    if [ "$php" == "${php5_6_filename}" ]; then
        download_file "${php_memcached_filename}.tgz" "${php_memcached_filename_url}"
        tar zxf ${php_memcached_filename}.tgz
        cd ${php_memcached_filename}
    else
        download_file "${php_memcached_filename2}.tgz" "${php_memcached_filename2_url}"
        tar zxf ${php_memcached_filename2}.tgz
        cd ${php_memcached_filename2}
    fi
    error_detect "${php_location}/bin/phpize"
    error_detect "./configure --with-php-config=${phpConfig}"
    error_detect "make"
    error_detect "make install"

    if [ ! -f ${php_location}/php.d/memcached.ini ]; then
        log "Info" "PHP extension memcached configuration file not found, create it!"
        cat > ${php_location}/php.d/memcached.ini<<-EOF
[memcached]
extension = ${php_extension_dir}/memcached.so
memcached.use_sasl = 1
EOF
    fi
    log "Info" "PHP extension memcached install completed..."
}

install_php_redis(){
    local phpConfig=${1}
    local php_version=$(get_php_version "${phpConfig}")
    local php_extension_dir=$(get_php_extension_dir "${phpConfig}")
    local redis_install_dir=${depends_prefix}/redis
    local tram=$( free -m | awk '/Mem/ {print $2}' )
    local swap=$( free -m | awk '/Swap/ {print $2}' )
    local Mem=$(expr $tram + $swap)
    local RT=0

    cd ${cur_dir}/software/

    log "Info" "redis-server install start..."
    download_file "${redis_filename}.tar.gz" "${redis_filename_url}"
    tar zxf ${redis_filename}.tar.gz
    cd ${redis_filename}
    ! is_64bit && sed -i '1i\CFLAGS= -march=i686' src/Makefile && sed -i 's@^OPT=.*@OPT=-O2 -march=i686@' src/.make-settings
    error_detect "make"

    if [ -f "src/redis-server" ]; then
        mkdir -p ${redis_install_dir}/{bin,etc,var}
        cp src/{redis-benchmark,redis-check-aof,redis-check-rdb,redis-cli,redis-sentinel,redis-server} ${redis_install_dir}/bin/
        cp redis.conf ${redis_install_dir}/etc/
        ln -s ${redis_install_dir}/bin/* /usr/local/bin/
        sed -i 's@pidfile.*@pidfile /var/run/redis.pid@' ${redis_install_dir}/etc/redis.conf
        sed -i "s@logfile.*@logfile ${redis_install_dir}/var/redis.log@" ${redis_install_dir}/etc/redis.conf
        sed -i "s@^dir.*@dir ${redis_install_dir}/var@" ${redis_install_dir}/etc/redis.conf
        sed -i 's@daemonize no@daemonize yes@' ${redis_install_dir}/etc/redis.conf
        sed -i "s@^# bind 127.0.0.1@bind 127.0.0.1@" ${redis_install_dir}/etc/redis.conf
        [ -z "$(grep ^maxmemory ${redis_install_dir}/etc/redis.conf)" ] && sed -i "s@maxmemory <bytes>@maxmemory <bytes>\nmaxmemory $(expr ${Mem} / 8)000000@" ${redis_install_dir}/etc/redis.conf

        if check_sys packageManager apt; then
            cp -f ${cur_dir}/init.d/redis-server-init-debian /etc/init.d/redis-server
        elif check_sys packageManager yum; then
            if echo $(get_opsy) | grep -Eqi "fedora"; then
                cp -f ${cur_dir}/init.d/redis-server-init-fedora /etc/init.d/redis-server
            else
                cp -f ${cur_dir}/init.d/redis-server-init-centos /etc/init.d/redis-server
            fi
        fi

        id -u redis >/dev/null 2>&1
        [ $? -ne 0 ] && groupadd redis && useradd -M -s /sbin/nologin -g redis redis
        chown -R redis:redis ${redis_install_dir}
        chmod +x /etc/init.d/redis-server
        boot_start redis-server
        log "Info" "redis-server install completed!"
    else
        RT=1
        log "Error" "redis-server install failed."
    fi

    if [ ${RT} -eq 0 ]; then
        cd ${cur_dir}/software/
        log "Info" "PHP extension redis install start..."
        if [ "$php" == "${php5_6_filename}" ]; then
            download_file  "${php_redis_filename}.tgz" "${php_redis_filename_url}"
            tar zxf ${php_redis_filename}.tgz
            cd ${php_redis_filename}
        else
            download_file  "${php_redis_filename2}.tgz" "${php_redis_filename2_url}"
            tar zxf ${php_redis_filename2}.tgz
            cd ${php_redis_filename2}
        fi

        error_detect "${php_location}/bin/phpize"
        error_detect "./configure --enable-redis --with-php-config=${phpConfig}"
        error_detect "make"
        error_detect "make install"
        
        if [ ! -f ${php_location}/php.d/redis.ini ]; then
            log "Info" "PHP extension redis configuration file not found, create it!"
            cat > ${php_location}/php.d/redis.ini<<-EOF
[redis]
extension = ${php_extension_dir}/redis.so
EOF
        fi
        log "Info" "PHP extension redis install completed..."
    fi
}

install_php_mongo(){
    local phpConfig=${1}
    local php_version=$(get_php_version "${phpConfig}")
    local php_extension_dir=$(get_php_extension_dir "${phpConfig}")

    cd ${cur_dir}/software/

    log "Info" "PHP extension mongodb install start..."
    download_file "${php_mongo_filename}.tgz" "${php_mongo_filename_url}"
    tar zxf ${php_mongo_filename}.tgz
    cd ${php_mongo_filename}
    error_detect "${php_location}/bin/phpize"
    error_detect "./configure --with-php-config=${phpConfig}"
    error_detect "make"
    error_detect "make install"

    if [ ! -f ${php_location}/php.d/mongodb.ini ]; then
        log "Info" "PHP extension mongodb configuration file not found, create it!"
        cat > ${php_location}/php.d/mongodb.ini<<-EOF
[mongodb]
extension = ${php_extension_dir}/mongodb.so
EOF
    fi
    log "Info" "PHP extension mongodb install completed..."
}

install_swoole(){
    local phpConfig=${1}
    local php_version=$(get_php_version "${phpConfig}")
    local php_extension_dir=$(get_php_extension_dir "${phpConfig}")

    cd ${cur_dir}/software/

    log "Info" "PHP extension swoole install start..."
    download_file "${swoole_filename}.tar.gz" "${swoole_filename_url}"
    tar zxf ${swoole_filename}.tar.gz
    cd ${swoole_filename}
    error_detect "${php_location}/bin/phpize"
    error_detect "./configure --with-php-config=${phpConfig}"
    error_detect "make"
    error_detect "make install"

    if [ ! -f ${php_location}/php.d/swoole.ini ]; then
        log "Info" "PHP extension swoole configuration file not found, create it!"
        cat > ${php_location}/php.d/swoole.ini<<-EOF
[swoole]
extension = ${php_extension_dir}/swoole.so
EOF
    fi
    log "Info" "PHP extension swoole install completed..."
}

install_xdebug(){
    local phpConfig=${1}
    local php_version=$(get_php_version "${phpConfig}")
    local php_extension_dir=$(get_php_extension_dir "${phpConfig}")

    cd ${cur_dir}/software/

    log "Info" "PHP extension xdebug install start..."
    if [ "$php" == "${php5_6_filename}" ]; then
        download_file "${xdebug_filename}.tgz" "${xdebug_filename_url}"
        tar zxf ${xdebug_filename}.tgz
        cd ${xdebug_filename}
    else
        download_file "${xdebug_filename2}.tgz" "${xdebug_filename2_url}"
        tar zxf ${xdebug_filename2}.tgz
        cd ${xdebug_filename2}
    fi
    error_detect "${php_location}/bin/phpize"
    error_detect "./configure --enable-xdebug --with-php-config=${phpConfig}"
    error_detect "make"
    error_detect "make install"

    if [ ! -f ${php_location}/php.d/xdebug.ini ]; then
        log "Info" "PHP extension xdebug configuration file not found, create it!"
        cat > ${php_location}/php.d/xdebug.ini<<-EOF
[xdebug]
zend_extension = ${php_extension_dir}/xdebug.so
EOF
    fi
    log "Info" "PHP extension xdebug install completed..."
}

install_yaf(){
    local phpConfig=${1}
    local php_version=$(get_php_version "${phpConfig}")
    local php_extension_dir=$(get_php_extension_dir "${phpConfig}")

    cd ${cur_dir}/software/

    log "Info" "PHP extension yaf install start..."
    download_file "${yaf_filename}.tgz" "${yaf_filename_url}"
    tar zxf ${yaf_filename}.tgz
    cd ${yaf_filename}
    error_detect "${php_location}/bin/phpize"
    error_detect "./configure --with-php-config=${phpConfig}"
    error_detect "make"
    error_detect "make install"

    if [ ! -f ${php_location}/php.d/yaf.ini ]; then
        log "Info" "PHP extension yaf configuration file not found, create it!"
        cat > ${php_location}/php.d/yaf.ini<<-EOF
[yaf]
extension = ${php_extension_dir}/yaf.so
EOF
    fi
    log "Info" "PHP extension yaf install completed..."
}
