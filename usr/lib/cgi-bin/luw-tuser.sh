#!/bin/bash
#echo -e "Content-type: text/html\n\n"
#--------------------------------------------------------------------------------#
#   LUW-TUSER - Create and configure unprivileged temp user to LXC/LUW 		 #
# 		CREATED BY: maik.alberto@hotmail.com				 #
#--------------------------------------------------------------------------------#
echo "<table border=0 width=100%>"
echo "<tr>"
echo  "<td width=33%></td>"
echo  "<td>"
echo "<pre>"
cat <<EOF
	     ___________________________________
	    /                                / /|
	   ////////////////////////////////// /||
	  /                                / / ||
	 ////////////////////////////////// /  ||
	/________________________________/_/   ||
	|   _       _     _  _       _   | |   ||
	|  | |     | |   | || |     | |  | |   ||
	|  | |     | |   | || |  _  | |  | |   ||
	|  | |     | |   | || | | | | |  | |  //
	|  | |____ | |___| || |_| |_| |  | | //
	|  |______||_______||_________|  | |//
	|________________________________|_|/

	Have Fun!
EOF
echo "</pre>"
echo "</td><td></td></tr>"
echo "<tr>"
echo "<td width=33%></td>"
echo "<td valign=top align=right><font size=2><i>created by: maik.alberto@hotmail.com</i></font></td>"
echo "<td></td>"
echo "</tr>"
#--------------------------------------------------------------------------------#
#    			Criando usuario local 					 #
#--------------------------------------------------------------------------------#
echo "<tr>"
echo  "<td></td>"
echo "<td>"

nuser=u$RANDOM
tpass=P@5s$RANDOM


echo "<center><pre>"

echo "<h2>User: "$nuser" Pass: "$tpass"</h2>"
echo "</pre>"

echo "<h1><a href='./luw-enter/luw-enter.sh'>ENTER LUW</a></h1>"
echo "<font size=2 color=red>You have 25 minutes</font>"
echo "<br>"
echo "</center>"
echo "</td><td width=33%></td></tr>"
echo "</table>"
useradd -m $nuser -p `openssl passwd -1 $tpass`
#--------------------------------------------------------------------------------#
#      			Log - add usuario criado 					 #
#--------------------------------------------------------------------------------#
logacesso=/opt/luw/log/acesso
echo $nuser >> $logacesso
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
mkdir /home/$nuser/public_html/cgi-bin/luw-box
chown $nuser:$nuser /home/$nuser/public_html/cgi-bin/luw-box
cp /opt/luw/luw.sh /home/$nuser/public_html/cgi-bin/
chmod +x /home/$nuser/public_html/cgi-bin/luw.sh
chown $nuser:$nuser /home/$nuser/public_html/cgi-bin/luw.sh

#--------------------------------------------------------------------------------#
#                       Configurando Secutiry Shell 		                 #
#--------------------------------------------------------------------------------#
su $nuser -c "ssh-keygen -t rsa -f /home/$nuser/.ssh/id_rsa -N '' > /dev/null; cat /home/$nuser/.ssh/id_rsa.pub >> /home/$nuser/.ssh/authorized_keys"


#--------------------------------------------------------------------------------#
#            Criando script para deletar usuario e agendando tarefa 	 		                 #
#--------------------------------------------------------------------------------#
#sed -e "/$nuser veth lxcbr0 10/d" /etc/lxc/lxc-usernet > /etc/lxc/lxc-usernet

homesh=/opt/luw/homesh/$nuser.sh

echo '#!/bin/bash' > $homesh
echo 'nid=`id -u '$nuser'`' >> $homesh
echo 'procs=`ps -u $nid | cut -c 1-6 | paste -s | tr -d "PID" | expand -i | tr -s " "`' >> $homesh
echo 'userdel -rf  '$nuser' 2> /dev/null' >> $homesh
echo 'kill -9 $procs 2> /dev/null' >> $homesh
#echo 'sed -e "/'$nuser 'veth lxcbr0 10/d" /etc/lxc/lxc-usernet > /etc/lxc/lxc-usernet' >> $homesh
echo 'rm -rf /opt/luw/homesh/'$nuser.sh >> $homesh
chmod +x $homesh
at -f $homesh now +25 minutes
