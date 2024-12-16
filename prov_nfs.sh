#!/bin/bash

# Actualizar el sistema
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y nfs-kernel-server php7.4 php7.4-cli php7.4-common php7.4-curl php7.4-zip php7.4-gd php7.4-mysql php7.4-xml php7.4-mbstring php7.4-json php7.4-intl libapache2-mod-php7.4 php7.4-fpm

# Crear directorio para OwnCloud y configurar permisos
mkdir -p /nfs/
chown nobody:nogroup /nfs/
chmod 777 /nfs/

# Descargar OwnCloud
sudo wget https://download.owncloud.com/server/stable//owncloud-latest.zip
sudo apt install -y unzip
sudo unzip owncloud-latest.zip -d /nfs/

sudo chown -R www-data:www-data /nfs/owncloud
sudo chmod -R 755 /nfs/owncloud

# Configurar exportaciones NFS
echo "/nfs/owncloud/ 192.168.50.20/24(rw,sync,no_subtree_check)" >> /etc/exports
echo "/nfs/owncloud/ 192.168.50.30/24(rw,sync,no_subtree_check)" >> /etc/exports

sudo exportfs -a
sudo systemctl restart nfs-kernel-server

# Archivo Auto-config
cat <<EOF /nfs/owncloud/config/autoconfig.php
<?php
\$AUTOCONFIG = array(
  "dbtype" => "mariadb",
  "dbname" => "owncloud",
  "dbuser" => "owncloud_user",
  "dbpassword" => "12345",
  "dbhost" => "192.168.60.10",
  "directory" => "/nfs/owncloud/data",
  "adminlogin" => "admin",
  "adminpass" => "12345"
)
EOF


php -r "
$configFile = "/nfs/ownCloud/config/config.php";
if (file_exists($configFile)) {
    $config = include($configFile);
    $config["trusted_domains"] = array(
        "localhost",
        "localhost:8080",
        "192.168.50.1",
        "192.168.50.20",
        "192.168.50.30",
    );
    file_put_contents($configFile, "<?php return " . var_export($config, true) . ";");
} else {
    echo "No se pudo encontrar el archivo config.php";
}"

# Reiniciar NFS
exportfs -a
systemctl restart nfs-kernel-server
