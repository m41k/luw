#!/bin/bash

#--------------------------------------------------------------------------------#
#		PROJETO LUW - LXC Unprivileged Web				 #
# 		CREATED BY: maik.alberto@hotmail.com				 #
#--------------------------------------------------------------------------------#

#Install - Ubuntu 16.04  

 #Atualizando
  apt-get update

#Instalacoes
 
 #Instalando LXC
  apt-get install lxc -y

 #Instalando Apache2
  apt-get install apache2 -y

 #Instalando Modulos Apache2
  apt-get install libapache2-mod-authnz-external apache2-suexec-custom -y

 #Instalando pacotes necessários
 #apt-get install gcc -y
 apt-get install zsh -y
 apt-get install lynx -y
 apt-get install shellinabox -y


 #Habilitando Modulos
  a2enmod userdir cgi authnz_external suexec

 #Configurando quantidades de interfaces lxc
  echo "ubuntu veth lxcbr0 10" >> /etc/lxc/lxc-usernet


 #Configurando ambiente web

 #Conf apache
   cd /etc/apache2/sites-available/
   mv 000-default.conf 000-default.bkp
   wget https://raw.githubusercontent.com/m41k/luw/master/etc/apache2/sites-enabled/000-default.conf
 

 #Preparando index
   cd /var/www/html/
   mv index.html index.bkp
   wget https://raw.githubusercontent.com/m41k/luw/master/var/www/html/capa.png
   wget https://raw.githubusercontent.com/m41k/luw/master/var/www/html/index.html
   wget https://github.com/m41k/luw/raw/master/var/www/html/man.tar
   tar -xf man.tar
   rm -f man.tar
   

 #Preparando cgi-bin

  cd /usr/lib/cgi-bin
  wget  https://raw.githubusercontent.com/m41k/luw/master/usr/lib/cgi-bin/luw-enter/luw-enter.sh
  wget https://raw.githubusercontent.com/m41k/luw/master/usr/lib/cgi-bin/luw-ini.sh
  wget https://raw.githubusercontent.com/m41k/luw/master/usr/lib/cgi-bin/luw-tuser.sh 
  chmod +x *

 #Preparando cgi-bin/luw-enter

  mkdir /usr/lib/cgi-bin/luw-enter
  cd /usr/lib/cgi-bin/luw-enter
  wget https://raw.githubusercontent.com/m41k/luw/master/usr/lib/cgi-bin/luw-enter/luw-enter.sh
  chmod +x *

 #Preparando /opt/luw
   mkdir /opt/luw
   cd /opt/luw
   wget https://github.com/m41k/luw/raw/master/opt/luw/proccgi
   wget https://raw.githubusercontent.com/m41k/luw/master/opt/luw/luw.sh
   chmod +x *
   
  #Preparando /opt/luw/homesh
   mkdir /opt/luw/homesh
   
  #Preparando /opt/luw/log
   mkdir /opt/luw/log/
   touch /opt/luw/log/creation 
   touch /opt/luw/log/acesso
   chown www-data:www-data /opt/luw/log/acesso
   
  #Preparando /opt/luw/tools
   mkdir /opt/luw/tools
   cd /opt/luw/tools
   wget https://raw.githubusercontent.com/m41k/luw/master/opt/luw/tools/luw-homall.sh
   wget https://raw.githubusercontent.com/m41k/luw/master/opt/luw/tools/luw-monitor.sh
   wget https://raw.githubusercontent.com/m41k/luw/master/opt/luw/tools/luw-user.sh
   chmod +x *
 
  #Editando /etc/sudoers
   echo "www-data ALL=NOPASSWD:/usr/lib/cgi-bin/luw-tuser.sh" >> /etc/sudoers
   

 #Reiniciando Apache
  /etc/init.d/apache2 restart
