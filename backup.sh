#!/usr/bin/env bash
[[ $EUID -ne 0 ]] && echo "Error: This script must be run as root!" && exit 1

ENCRYPTFLG=true
BACKUPPASS="mypassword"
LOCALDIR="/root/backups/"
TEMPDIR="/root/backups/temp/"
LOGFILE="/root/backups/backup.log"
MYSQL_ROOT_PASSWORD=""
MYSQL_DATABASE_NAME[0]=""
BACKUP[0]=""
LOCALAGEDAILIES="7"
DELETE_REMOTE_FILE_FLG=false
FTP_FLG=false
FTP_HOST=""
FTP_USER=""
FTP_PASS=""
FTP_DIR=""
DAY=$(date +%d)
MONTH=$(date +%m)
YEAR=$(date +%C%y)
BACKUPDATE=$(date +%Y%m%d%H%M%S)
TARFILE="${LOCALDIR}""$(hostname)"_"${BACKUPDATE}".tgz
ENC_TARFILE="${TARFILE}.enc"
SQLFILE="${TEMPDIR}mysql_${BACKUPDATE}.sql"

log() {
    echo "$(date "+%Y-%m-%d %H:%M:%S")" "$1"
    echo -e "$(date "+%Y-%m-%d %H:%M:%S")" "$1" >> ${LOGFILE}
}
check_commands() {
    BINARIES=( cat cd du date dirname echo openssl mysql mysqldump pwd rm tar )
        for BINARY in "${BINARIES[@]}"; do
        if [ ! "$(command -v "$BINARY")" ]; then
            log "$BINARY is not installed. Install it and try again"
            exit 1
        fi
    done

    GDRIVE_COMMAND=false
    if [ "$(command -v "gdrive")" ]; then
        GDRIVE_COMMAND=true
    fi

    if ${FTP_FLG}; then
        if [ ! "$(command -v "ftp")" ]; then
            log "ftp is not installed. Install it and try again"
            exit 1
        fi
    fi
}

calculate_size() {
    local file_name=$1
    local file_size=$(du -h $file_name 2>/dev/null | awk '{print $1}')
    if [ "x${file_size}" = "x" ]; then
        echo "unknown"
    else
        echo "${file_size}"
    fi
}

mysql_backup() {
    if [ -z ${MYSQL_ROOT_PASSWORD} ]; then
        log "MySQL root password not set, MySQL backup skipped"
    else
        log "MySQL dump start"
        mysql -u root -p"${MYSQL_ROOT_PASSWORD}" 2>/dev/null <<EOF
exit
EOF
        if [ $? -ne 0 ]; then
            log "MySQL root password is incorrect. Please check it and try again"
            exit 1
        fi
    
        if [ "${MYSQL_DATABASE_NAME[*]}" == "" ]; then
            mysqldump -u root -p"${MYSQL_ROOT_PASSWORD}" --all-databases > "${SQLFILE}" 2>/dev/null
            if [ $? -ne 0 ]; then
                log "MySQL all databases backup failed"
                exit 1
            fi
            log "MySQL all databases dump file name: ${SQLFILE}"
            #Add MySQL backup dump file to BACKUP list
            BACKUP=(${BACKUP[*]} ${SQLFILE})
        else
            for db in ${MYSQL_DATABASE_NAME[*]}
            do
                unset DBFILE
                DBFILE="${TEMPDIR}${db}_${BACKUPDATE}.sql"
                mysqldump -u root -p"${MYSQL_ROOT_PASSWORD}" ${db} > "${DBFILE}" 2>/dev/null
                if [ $? -ne 0 ]; then
                    log "MySQL database name [${db}] backup failed, please check database name is correct and try again"
                    exit 1
                fi
                log "MySQL database name [${db}] dump file name: ${DBFILE}"
                #Add MySQL backup dump file to BACKUP list
                BACKUP=(${BACKUP[*]} ${DBFILE})
            done
        fi
        log "MySQL dump completed"
    fi
}

start_backup() {
    [ "${BACKUP[*]}" == "" ] && echo "Error: You must to modify the [$(basename $0)] config before run it!" && exit 1

    log "Tar backup file start"
    tar -zcPf ${TARFILE} ${BACKUP[*]}
    if [ $? -gt 1 ]; then
        log "Tar backup file failed"
        exit 1
    fi
    log "Tar backup file completed"

    # Encrypt tar file
    if ${ENCRYPTFLG}; then
        log "Encrypt backup file start"
        openssl enc -aes256 -in "${TARFILE}" -out "${ENC_TARFILE}" -pass pass:"${BACKUPPASS}" -md sha1
        log "Encrypt backup file completed"

        # Delete unencrypted tar
        log "Delete unencrypted tar file: ${TARFILE}"
        rm -f ${TARFILE}
    fi

    # Delete MySQL temporary dump file
    for sql in $(ls ${TEMPDIR}*.sql)
    do
        log "Delete MySQL temporary dump file: ${sql}"
        rm -f ${sql}
    done

    if ${ENCRYPTFLG}; then
        OUT_FILE="${ENC_TARFILE}"
    else
        OUT_FILE="${TARFILE}"
    fi
    log "File name: ${OUT_FILE}, File size: $(calculate_size ${OUT_FILE})"
}
gdrive_upload() {
    if ${GDRIVE_COMMAND}; then
        log "Tranferring backup file to Google Drive"
        gdrive upload --no-progress ${OUT_FILE} >> ${LOGFILE}
        if [ $? -ne 0 ]; then
            log "Error: Tranferring backup file to Google Drive failed"
            exit 1
        fi
        log "Tranferring backup file to Google Drive completed"
    fi
}

ftp_upload() {
    if ${FTP_FLG}; then
        [ -z ${FTP_HOST} ] && log "Error: FTP_HOST can not be empty!" && exit 1
        [ -z ${FTP_USER} ] && log "Error: FTP_USER can not be empty!" && exit 1
        [ -z ${FTP_PASS} ] && log "Error: FTP_PASS can not be empty!" && exit 1
        [ -z ${FTP_DIR} ] && log "Error: FTP_DIR can not be empty!" && exit 1

        local FTP_OUT_FILE=$(basename ${OUT_FILE})
        log "Tranferring backup file to FTP server"
        ftp -in ${FTP_HOST} 2>&1 >> ${LOGFILE} <<EOF
user $FTP_USER $FTP_PASS
binary
lcd $LOCALDIR
cd $FTP_DIR
put $FTP_OUT_FILE
quit
EOF
        log "Tranferring backup file to FTP server completed"
    fi
}
get_file_date() {
    DAYS=$(( $((10#${YEAR}*365)) + $((10#${MONTH}*30)) + $((10#${DAY})) ))

    unset FILEYEAR FILEMONTH FILEDAY FILEDAYS FILEAGE
    FILEYEAR=$(echo "$1" | cut -d_ -f2 | cut -c 1-4)
    FILEMONTH=$(echo "$1" | cut -d_ -f2 | cut -c 5-6)
    FILEDAY=$(echo "$1" | cut -d_ -f2 | cut -c 7-8)

    if [[ "${FILEYEAR}" && "${FILEMONTH}" && "${FILEDAY}" ]]; then
        #Approximate a 30-day month and 365-day year
        FILEDAYS=$(( $((10#${FILEYEAR}*365)) + $((10#${FILEMONTH}*30)) + $((10#${FILEDAY})) ))
        FILEAGE=$(( 10#${DAYS} - 10#${FILEDAYS} ))
        return 0
    fi

    return 1
}

# Delete Google Drive's old backup file
delete_gdrive_file() {
    local FILENAME=$1
    if ${DELETE_REMOTE_FILE_FLG} && ${GDRIVE_COMMAND}; then
        local FILEID=$(gdrive list -q "name = '${FILENAME}'" --no-header | awk '{print $1}')
        if [ -n ${FILEID} ]; then
            gdrive delete ${FILEID} >> ${LOGFILE}
            log "Google Drive's old backup file name: ${FILENAME} has been deleted"
        fi
    fi
}
delete_ftp_file() {
    local FILENAME=$1
    if ${DELETE_REMOTE_FILE_FLG} && ${FTP_FLG}; then
        ftp -in ${FTP_HOST} 2>&1 >> ${LOGFILE} <<EOF
user $FTP_USER $FTP_PASS
cd $FTP_DIR
del $FILENAME
quit
EOF
        log "FTP server's old backup file name: ${FILENAME} has been deleted"
    fi
}
clean_up_files() {
    cd ${LOCALDIR} || exit

    if ${ENCRYPTFLG}; then
        LS=($(ls *.enc))
    else
        LS=($(ls *.tgz))
    fi

    for f in ${LS[@]}
    do
        get_file_date ${f}
        if [ $? == 0 ]; then
            if [[ ${FILEAGE} -gt ${LOCALAGEDAILIES} ]]; then
                rm -f ${f}
                log "Old backup file name: ${f} has been deleted"
                delete_gdrive_file ${f}
                delete_ftp_file ${f}
            fi
        fi
    done
}
STARTTIME=$(date +%s)

# Check if the backup folders exist and are writeable
if [ ! -d "${LOCALDIR}" ]; then
    mkdir -p ${LOCALDIR}
fi
if [ ! -d "${TEMPDIR}" ]; then
    mkdir -p ${TEMPDIR}
fi

log "Backup progress start"
check_commands
mysql_backup
start_backup
log "Backup progress complete"

log "Upload progress start"
gdrive_upload
ftp_upload
log "Upload progress complete"

clean_up_files

ENDTIME=$(date +%s)
DURATION=$((ENDTIME - STARTTIME))
log "All done"
log "Backup and transfer completed in ${DURATION} seconds"
