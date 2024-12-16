#!/bin/bash

# Actualizar el sistema
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y nginx nfs-common wget php7.4 php7.4-cli php7.4-common php7.4-curl php7.4-zip php7.4-gd php7.4-mysql php7.4-xml php7.4-mbstring php7.4-json php7.4-intl libapache2-mod-php7.4 php7.4-fpm


# Configurar montaje NFS
mkdir -p /var/www/owncloud
echo "192.168.50.10:/nfs/owncloud/ /var/www/owncloud nfs defaults 0 0" >> /etc/fstab
sudo mount -a

# Configurar nginx para OwnCloud
cat > /etc/nginx/sites-available/owncloud <<EOL
server {
    listen 80;
    server_name localhost;

    root /var/www/owncloud;
    index index.php index.html index.htm;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass 192.168.50.10:9000;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }
}
EOL

# Activar configuración y reiniciar nginx
cd /etc/nginx/sites-enabled/
sudo rm -r default
cd
ln -s /etc/nginx/sites-available/owncloud /etc/nginx/sites-enabled/
systemctl restart nginx
