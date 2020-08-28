echo "Bienvenido al script para instalar zabbix de Mike Archila"
read -p "Ingrese la ip para el servidor : " ipAddress
read -p "Ingrese la mascara de subred : " mascaraSubRed
read -p "Ingrese su puerta de enlace : " puertaDeEnlace
echo "Se creara una base de datos llamada zabbix y el usuario llamado zabbix, usted proporcione unicamente el password"
read -p "Ingrese el password para el usuario zabbix de mysql: " passwordZabbix
apt install net-tools -y
ifconfig enp0s3 $ipAddress netmask $mascaraSubRed
route add default gw $puertaDeEnlace
wget https://repo.zabbix.com/zabbix/5.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_5.0-1+focal_all.deb
dpkg -i zabbix-release_5.0-1+focal_all.deb
rm -rf zabbix-release_5.0-1+focal_all.deb
apt update
apt install zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-agent mysql-server -y
mysql -uroot -e "create database zabbix character set utf8 collate utf8_bin; create user zabbix@localhost identified by '$passwordZabbix'; grant all privileges on zabbix.* to zabbix@localhost;"
zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz | mysql -uzabbix --password=$passwordZabbix zabbix
sed -i "s/# DBPassword=/DBPassword=$passwordZabbix/g" /etc/zabbix/zabbix_server.conf
sed -i "s/# php_value date.timezone Europe\/Riga/php_value date.timezone America\/Guatemala/g" /etc/zabbix/apache.conf
systemctl restart zabbix-server zabbix-agent apache2
systemctl enable zabbix-server zabbix-agent apache2
echo 'INSTALACION TERMINADA'
