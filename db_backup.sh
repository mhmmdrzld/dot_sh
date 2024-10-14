#!/bin/bash

# Konfigurasi
DB_HOST="localhost"
DB_USER="username"
DB_PASS="password"
DB_NAME="nama_database"
BACKUP_DIR="/path/to/backup/directory"
LOG_FILE="/var/log/mysql_backup.log"

# Format nama file backup
timestamp=$(date +%Y%m%d-%H%M%S)
backup_file="${BACKUP_DIR}/${DB_NAME}-${timestamp}.sql"

# Fungsi untuk menulis log
write_log() {
  message="$1"
  timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  echo "${timestamp} ${message}" >> "${LOG_FILE}"
}

# Fungsi untuk melakukan backup
backup_database() {
  mysqldump -h "${DB_HOST}" -u "${DB_USER}" -p"${DB_PASS}" "${DB_NAME}" > "${backup_file}"
  
  if [ $? -eq 0 ]; then
    write_log "Backup ${DB_NAME} berhasil. File: ${backup_file}"
  else
    write_log "Backup ${DB_NAME} gagal."
  fi
}

# Panggil fungsi untuk melakukan backup
backup_database