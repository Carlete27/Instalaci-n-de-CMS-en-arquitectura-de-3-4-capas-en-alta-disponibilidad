#!/bin/bash

# Actualizar el sistema
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y mariadb-server

# Configurar base de datos para OwnCloud
mariadb<<EOF
CREATE DATABASE owncloud;
CREATE USER 'owncloud_user'@'192.168.50.20' IDENTIFIED BY '12345';
CREATE USER 'owncloud_user'@'192.168.50.30' IDENTIFIED BY '12345';
CREATE USER 'owncloud_user'@'192.168.60.1' IDENTIFIED BY '12345';
GRANT ALL PRIVILEGES ON owncloud.* TO 'owncloud_user'@'192.168.50.20';
GRANT ALL PRIVILEGES ON owncloud.* TO 'owncloud_user'@'192.168.50.30';
GRANT ALL PRIVILEGES ON owncloud.* TO 'owncloud_user'@'192.168.60.1';
FLUSH PRIVILEGES;
EOF

# Configurar MariaDB para escuchar en todas las interfaces
sed -i "s/^bind-address.*/bind-address = 192.168.60.10/" /etc/mysql/mariadb.conf.d/50-server.cnf

# Reiniciar MariaDB
systemctl restart mariadb
