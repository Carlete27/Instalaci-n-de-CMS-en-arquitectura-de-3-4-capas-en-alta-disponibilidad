#!/bin/bash

# Actualizar el sistema
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y nginx

# Configurar nginx como balanceador de carga
cat > /etc/nginx/sites-available/load_balancer <<EOL
upstream owncloud_balanceador {

    server 192.168.50.20;
    server 192.168.50.30;
}

server {
    listen 80;

    location / {
        proxy_pass http://owncloud_balanceador;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

EOL

cd /etc/nginx/sites-enabled/
sudo rm -r default
cd
ln -s /etc/nginx/sites-available/load_balancer /etc/nginx/sites-enabled

# Reiniciar nginx
sudo systemctl restart nginx