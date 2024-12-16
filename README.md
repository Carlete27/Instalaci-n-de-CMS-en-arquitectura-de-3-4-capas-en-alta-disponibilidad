# Instalaci-n-de-CMS-en-arquitectura-de-3-4-capas-en-alta-disponibilidad

## ÍNDICE
### INTRODUCCIÓN
### DESARROLLO
### SCREENCASH

#### **1. Introducción**
En esta práctica se despliega una infraestructura con **Vagrant** y **Nginx** para el balanceo de carga, servidores web con recursos en un **NFS** compartido y una base de datos en un servidor MariaDB. Todo el despliegue se automatiza mediante **scripts de aprovisionamiento**.

---

#### **2. Configuración del Balanceador**

##### **2.1 Actualización de los repositorios**
```bash
sudo apt update
```
![image](https://github.com/user-attachments/assets/2ed9ea96-de8a-472f-8030-bb5b5e62fe83)

##### **2.2 Instalación de Nginx**
```bash
sudo apt install -y nginx
```
![image](https://github.com/user-attachments/assets/bf552d7e-9fe7-40cc-a361-da9fca7a62a2)

##### **2.3 Configuración del Balanceador de Carga**
1. Acceder al archivo de configuración principal de Nginx:
   ```bash
   sudo nano /etc/nginx/sites-available/load_balancer
   ```
2. Configurar la sección `upstream` para los servidores web:

![image](https://github.com/user-attachments/assets/f439b675-8413-4bec-a6b5-df8ef9aacede)

##### **2.4 Reinicio del Servicio Nginx**
```bash
sudo systemctl restart nginx
```
![image](https://github.com/user-attachments/assets/24929ddb-aaef-43de-8e32-4f3a0c3c3ccf)

#### **3. Configuración del Servidor NFS**

##### **3.1 Instalación del Servidor NFS**
```bash
sudo apt install -y nfs-kernel-server
```
![image](https://github.com/user-attachments/assets/af91fb8a-0a1f-44c3-89af-b44db5119765)


##### **3.2 Creación del Directorio Compartido**
```bash
sudo mkdir -p /nfs/owncloud
sudo chown -R nobody:nogroup /nfs/owncloud
sudo chmod 755 /nfs/owncloud
```
![image](https://github.com/user-attachments/assets/c3a625e8-0229-41fe-8bfa-1901c2cd935a)
![image](https://github.com/user-attachments/assets/f08abfe8-6a74-42b1-8a0a-4a65a78aef85)

##### **3.3 Configuración del Archivo `/etc/exports`**
1. Editar el archivo:
   ```bash
   sudo nano /etc/exports
   ```
   ![image](https://github.com/user-attachments/assets/c0ac18c7-0b55-4590-924a-cca2af7266af)

2. Añadir la exportación para los servidores web:
   
 ![image](https://github.com/user-attachments/assets/c583c9b1-499a-433c-8e7d-a5282c9d1039)

![Configuración de exports](./capturas/configuracion_exports.png)

---

##### **3.4 Reinicio del Servicio NFS**
```bash
sudo systemctl restart nfs-kernel-server
```
![image](https://github.com/user-attachments/assets/e45760d4-3f58-49bb-95af-d902dc9e40b2)

#### **4. Configuración de los Servidores Web**

##### **4.1 Instalación del Cliente NFS**
```bash
sudo apt install -y nfs-common
```
![Instalación cliente NFS](./capturas/instalacion_cliente_nfs.png)

---

##### **4.2 Montaje Automático del Directorio NFS**
1. Editar el archivo `/etc/fstab`:
   ```bash
   sudo nano /etc/fstab
   ```
2. Añadir la siguiente línea:
   ```
   192.168.50.10:/nfs/owncloud /var/www/html/owncloud nfs defaults 0 0
   ```
3. Montar el directorio:
   ```bash
   sudo mount -a
   ```
![Montaje NFS](./capturas/montaje_nfs.png)

---

##### **4.3 Instalación de Nginx y PHP**
```bash
sudo apt install -y nginx php-fpm
```
![Instalación Nginx y PHP](./capturas/instalacion_nginx_php.png)

---

##### **4.4 Configuración del Servidor Nginx**
1. Editar el archivo `/etc/nginx/sites-available/default`:
   ```bash
   sudo nano /etc/nginx/sites-available/default
   ```

2. Configurar la sección de PHP:

   ```nginx
   server {
       listen 80;

       root /var/www/html/owncloud;
       index index.php index.html;

       location / {
           try_files $uri $uri/ =404;
       }

       location ~ \.php$ {
           include snippets/fastcgi-php.conf;
           fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
       }

       location ~ /\.ht {
           deny all;
       }
   }
   ```
![Configuración Nginx PHP](./capturas/configuracion_nginx_php.png)

3. Reiniciar Nginx:
   ```bash
   sudo systemctl restart nginx
   ```
![Reinicio Nginx](./capturas/reinicio_nginx_php.png)

---

#### **5. Configuración del Servidor de Base de Datos**

##### **5.1 Instalación de MariaDB**
```bash
sudo apt install -y mariadb-server
```
![Instalación MariaDB](./capturas/instalacion_mariadb.png)

---

##### **5.2 Configuración de la Base de Datos**
1. Acceder a MariaDB:
   ```bash
   sudo mysql -u root
   ```
2. Crear la base de datos y el usuario:
   ```sql
   CREATE DATABASE owncloud;
   CREATE USER 'ownclouduser'@'%' IDENTIFIED BY 'password';
   GRANT ALL PRIVILEGES ON owncloud.* TO 'ownclouduser'@'%';
   FLUSH PRIVILEGES;
   ```
3. Salir del cliente MariaDB:
   ```sql
   EXIT;
   ```
![Configuración MariaDB](./capturas/configuracion_mariadb.png)

---

##### **5.3 Configuración del Archivo `my.cnf`**
Editar la configuración para aceptar conexiones remotas:

1. Abrir el archivo:
   ```bash
   sudo nano /etc/mysql/mariadb.conf.d/50-server.cnf
   ```
2. Modificar la línea:
   ```
   bind-address = 0.0.0.0
   ```
3. Reiniciar MariaDB:
   ```bash
   sudo systemctl restart mariadb
   ```
![Reinicio MariaDB](./capturas/reinicio_mariadb.png)

---

#### **6. Pruebas y Validaciones**

1. Acceder al **balanceador de carga** desde un navegador utilizando la dirección IP pública.
2. Verificar que el tráfico se distribuye entre **Servidor Web 1** y **Servidor Web 2**.
3. Comprobar que la aplicación OwnCloud es accesible y que los recursos se cargan desde el servidor **NFS**.
4. Validar que la base de datos responde correctamente.

---

## **7. Conclusiones**
<ESPACIO PARA TEXTO
