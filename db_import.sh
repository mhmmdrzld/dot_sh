#!/bin/bash

# Konfigurasi
DB_HOST="localhost"
DB_USER="username"
DB_PASS="password"
DB_NAME="nama_database"
BACKUP_DIR="/path/to/backup/directory"
LOG_FILE="/var/log/mysql_import.log"

# Fungsi untuk menulis log
write_log() {
  message="$1"
  timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  echo "${timestamp} ${message}" >> "${LOG_FILE}"
}

# Fungsi untuk mendapatkan file backup terbaru
get_latest_backup() {
  latest_backup=$(ls -t "${BACKUP_DIR}"/*.sql | head -1)
  echo "${latest_backup}"
}

# Fungsi untuk mengecek keberadaan database
check_database_exists() {
  db_exists=$(mysql -h "${DB_HOST}" -u "${DB_USER}" -p"${DB_PASS}" -e "SHOW DATABASES LIKE '${DB_NAME}'" | grep "${DB_NAME}")

  if [ -z "${db_exists}" ]; then
    echo "0"
  else
    echo "1"
  fi
}

# Fungsi untuk menghapus database
drop_database() {
  mysql -h "${DB_HOST}" -u "${DB_USER}" -p"${DB_PASS}" -e "DROP DATABASE ${DB_NAME}"
  write_log "Database ${DB_NAME} berhasil dihapus."
}

# Fungsi untuk membuat database baru
create_database() {
  mysql -h "${DB_HOST}" -u "${DB_USER}" -p"${DB_PASS}" -e "CREATE DATABASE ${DB_NAME}"
  write_log "Database ${DB_NAME} berhasil dibuat."
}

# Fungsi untuk melakukan import database
import_database() {
  latest_backup=$(get_latest_backup)

  if [ -z "${latest_backup}" ]; then
    write_log "Tidak ditemukan file backup di direktori ${BACKUP_DIR}."
    exit 1
  fi

  db_exists=$(check_database_exists)

  if [ "${db_exists}" -eq 1 ]; then
    # Jika database sudah ada, hapus database terlebih dahulu
    drop_database
  fi

  # Buat database baru
  create_database

  mysql -h "${DB_HOST}" -u "${DB_USER}" -p"${DB_PASS}" "${DB_NAME}" < "${latest_backup}"

  if [ $? -eq 0 ]; then
    write_log "Import ${DB_NAME} berhasil dari file ${latest_backup}."
  else
    write_log "Import ${DB_NAME} gagal dari file ${latest_backup}."
  fi
}

# Panggil fungsi untuk melakukan import
import_database