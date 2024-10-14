#!/bin/bash

# Konfigurasi
DB_HOST="localhost"
DB_USER="username"
DB_PASS="password"
DB_NAME="nama_database"
BACKUP_DIR="/path/to/backup/directory"
LOG_FILE="/var/log/mysql_backup.log"

# Konfigurasi FTP
FTP_HOST="ftp.example.com"
FTP_USER="username"
FTP_PASS="password"
FTP_DIR="/path/to/ftp/directory"

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

# Fungsi untuk mengupload file backup ke FTP
upload_backup() {
  ftp -n "${FTP_HOST}" <<EOF
    user ${FTP_USER} ${FTP_PASS}
    cd ${FTP_DIR}
    put ${backup_file}
    bye
EOF

  if [ $? -eq 0 ]; then
    write_log "Upload file backup ${backup_file} ke FTP berhasil."
  else
    write_log "Upload file backup ${backup_file} ke FTP gagal."
  fi
}

# Panggil fungsi untuk melakukan backup
backup_database

# Panggil fungsi untuk mengupload file backup ke FTP
upload_backup