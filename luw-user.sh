#!/bin/bash
#--------------------------------------------------------------------------------#
#	LUW-USER - Create and configure unprivileged user to LXC/LUW 		 #
# 		CREATED BY: maik.alberto@hotmail.com				 #
#--------------------------------------------------------------------------------#
if [ -z $1 ]; then
  printf "New user: "
  read nuser
 else
  nuser=$1
fi

useradd -m $nuser

if [ $? -ne 0 ]; then
 echo "Error"
 exit 0
else

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

passwd $nuser

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

fi
