#!/bin/bash 
#--------------------------------------------------------------------------------#
#	LUW-USER - Create and configure unprivileged user to LXC/LUW 		 #
# 		CREATED BY: maik.alberto@hotmail.com				 #
#--------------------------------------------------------------------------------#
nuser=u$RANDOM
tpass=P@5s$RANDOM

echo $nuser $tpass

useradd -m $nuser -p `openssl passwd -1 $tpass`

#--------------------------------------------------------------------------------#
#		      Configurando usuario para utilizar o LXC	                 #
#--------------------------------------------------------------------------------#

mkdir -p /home/$nuser/.config/lxc
chown $nuser:$nuser /home/$nuser/.config/lxc
ini=`grep $nuser /etc/subuid | cut -d : -f2`
fim=`grep $nuser /etc/subuid | cut -d : -f3`
echo lxc.include = /etc/lxc/default.conf > /home/$nuser/.config/lxc/default.conf
echo lxc.id_map = u 0 $ini $fim >> /home/$nuser/.config/lxc/default.conf
echo lxc.id_map = g 0 $ini $fim >> /home/$nuser/.config/lxc/default.conf
chown $nuser:$nuser /home/$nuser/.config/lxc/default.conf


echo $nuser veth lxcbr0 10 >> /etc/lxc/lxc-usernet

#passwd $nuser

#--------------------------------------------------------------------------------#
#       		Configurando ambiente LUW para usuario	                 #
#--------------------------------------------------------------------------------#

mkdir /home/$nuser/public_html
chown $nuser:$nuser /home/$nuser/public_html
mkdir /home/$nuser/public_html/cgi-bin
chown $nuser:$nuser /home/$nuser/public_html/cgi-bin
cp /opt/luw/luw.sh /home/$nuser/public_html/cgi-bin/
chmod +x /home/$nuser/public_html/cgi-bin/luw.sh
chown $nuser:$nuser /home/$nuser/public_html/cgi-bin/luw.sh

#--------------------------------------------------------------------------------#
#                       Configurando Secutiry Shell 		                 #
#--------------------------------------------------------------------------------#
su $nuser -c "ssh-keygen -t rsa -f /home/$nuser/.ssh/id_rsa -N ''; cat /home/$nuser/.ssh/id_rsa.pub >> /home/$nuser/.ssh/authorized_keys"


#--------------------------------------------------------------------------------#
#                       Tempo de vida do usuario 		                 #
#--------------------------------------------------------------------------------#
#segundos - teste 5 minutos
sleep 200
#--------------------------------------------------------------------------------#
#                           Eliminando usuario	 		                 #
#--------------------------------------------------------------------------------#
nid=`id -u $nuser`

#deletando
userdel -rf  $nuser 2> /dev/null

#matando processos
#ps -u $nuser | cut -c 1-6 | paste -s | tr -d 'PID' | expand -i | tr -s ' '
#procs=`ps -u $nid | cut -d " " -f 6 | paste -s | tr -d 'PID' | expand -i | tr -s ' '`
procs=`ps -u $nid | cut -c 1-6 | paste -s | tr -d 'PID' | expand -i | tr -s ' '`
kill -9 $procs 2> /dev/null

#sed -e "/$nuser veth lxcbr0 10/d" /etc/lxc/lxc-usernet > /etc/lxc/lxc-usernet

echo Contribua!
