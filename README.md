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
![Captura de pantalla 2024-12-16 201436](https://github.com/user-attachments/assets/54e8605d-b410-4fa7-a830-88d946ae12cb)

---

##### **4.2 Montaje Automático del Directorio NFS**
1. Editar el archivo `/etc/fstab`:
   ```bash
   sudo nano /etc/fstab
   ```
   ![Captura de pantalla 2024-12-16 201503](https://github.com/user-attachments/assets/0c29dbb1-4300-4540-aa0b-1964a9a984e7)

2. Añadir la siguiente línea:
   ```
   192.168.50.10:/nfs/owncloud /var/www/owncloud nfs defaults 0 0
   ```
   ![Captura de pantalla 2024-12-16 201532](https://github.com/user-attachments/assets/bbf4fb68-a14f-4510-b534-36781a9ccacf)

3. Montar el directorio:
   ```bash
   sudo mount -a
   ```
   
![Montaje NFS](./capturas/montaje_nfs.png)

---
![Captura de pantalla 2024-12-16 201602](https://github.com/user-attachments/assets/e3c5c216-6db4-4912-9e40-1d669b369882)

##### **4.3 Instalación de Nginx y PHP**
```bash
sudo apt install -y nginx php-fpm
```

![Captura de pantalla 2024-12-16 201652](https://github.com/user-attachments/assets/e488c6b7-478c-4197-ac3b-98cee16ae99e)

---

##### **4.4 Configuración del Servidor Nginx**
1. Editar el archivo `/etc/nginx/sites-available/owncloud`:
   ```bash
   sudo nano /etc/nginx/sites-available/owncloud
   ```

2. Configurar la sección de PHP:

  ![Captura de pantalla 2024-12-16 201732](https://github.com/user-attachments/assets/18e847a0-0d34-47d0-b1b4-5e0790e90ead)

![Configuración Nginx PHP](./capturas/configuracion_nginx_php.png)

3. Reiniciar Nginx:
   ```bash
   sudo systemctl restart nginx
   ```

![Captura de pantalla 2024-12-16 201833](https://github.com/user-attachments/assets/296b108e-5d3e-4858-bfb8-3acfb55b8f67)

---

#### **5. Configuración del Servidor de Base de Datos**

##### **5.1 Instalación de MariaDB**
```bash
sudo apt install -y mariadb-server
```
![Captura de pantalla 2024-12-16 201909](https://github.com/user-attachments/assets/65420015-a923-47b8-bbe6-5829c9d42dab)

---

##### **5.2 Configuración de la Base de Datos**
1. Acceder a MariaDB:
   ```bash
   sudo mariadb
   ```
   ![Captura de pantalla 2024-12-16 201951](https://github.com/user-attachments/assets/3925ad97-4bbb-408b-a6e9-7c062ae21853)

2. Crear la base de datos y el usuario:

CREATE DATABASE owncloud;
CREATE USER 'owncloud_user'@'192.168.50.20' IDENTIFIED BY '12345';
CREATE USER 'owncloud_user'@'192.168.50.30' IDENTIFIED BY '12345';
CREATE USER 'owncloud_user'@'192.168.60.1' IDENTIFIED BY '12345';
GRANT ALL PRIVILEGES ON owncloud.* TO 'owncloud_user'@'192.168.50.20';
GRANT ALL PRIVILEGES ON owncloud.* TO 'owncloud_user'@'192.168.50.30';
GRANT ALL PRIVILEGES ON owncloud.* TO 'owncloud_user'@'192.168.60.1';
FLUSH PRIVILEGES;

##### **5.3 Configuración del Archivo `my.cnf`**
Editar la configuración para aceptar conexiones remotas:

1. Abrir el archivo:
   ```bash
   sudo nano /etc/mysql/mariadb.conf.d/50-server.cnf
   ```
2. Modificar la línea:
  ![Captura de pantalla 2024-12-16 202229](https://github.com/user-attachments/assets/8ef3a18b-0e38-4019-a69f-f7e6efa2dc7a)

3. Reiniciar MariaDB:
   ```bash
   sudo systemctl restart mariadb
   ```
   ![Captura de pantalla 2024-12-16 202318](https://github.com/user-attachments/assets/010df73a-2034-4078-b8ec-2be6ab1fd925)

---

## **6. Screencash**

