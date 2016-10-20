#!/bin/bash
echo -e "Content-type: text/html\n\n"
#sudo /usr/lib/cgi-bin/luw-tuser.sh
#--------------------------------------------------------------------------------#
#    LUW-INI - Apoio do www-data: log,permissoes e execucao do luw-tuser.sh      #
#                 CREATED BY: maik.alberto@hotmail.com                           #
#--------------------------------------------------------------------------------#
#--------------------------------------------------------------------------------#
#             		      	 PERMISSAO  	  		                 #
#		  chown www-data:www-data  /opt/luw/log/acesso			 #
#--------------------------------------------------------------------------------#
#--------------------------------------------------------------------------------#
# SECURITY - VERIFICA LOG - SE IP ESTA ATIVO - ATRAVES DE CALCULO DE TIMESTAP    #
#--------------------------------------------------------------------------------#
#var ip
ip=$REMOTE_ADDR
#ultimo acesso
#lacess=`grep $ip /opt/luw/log/acesso | tail -1 | cut -d "[" -f2 | cut -d "]" -f1`
lacess=`grep $ip /opt/luw/log/acesso | tail -1 | cut -d "-" -f2`
#converte ultimo acesso em timestap
tslast=`date +%s -d "$lacess"`
#timestap atual
tsnow=`date +%s`

#calclula timestap atual - ultimo acesso
tscalc=$(($tsnow-$tslast))
#echo $tscalc
if [ $tscalc -le 1500 ]; then
echo "<table border=0 width=100%>"
echo "<tr>"
echo  "<td width=33%></td>"
echo  "<td>"
echo "<pre>"
cat <<EOF
             ___________________________________
            /                                / /|
           ////////////////////////////////// /||
          /                                / //||
         ////////////////////////////////// ///||
        /________________________________/_////||
        |   _       _     _  _       _   | |///||
        |  | |     | |   | || |     | |  | |///||
        |  | |     | |   | || |  _  | |  | |///||
        |  | |     | |   | || | | | | |  | |////
        |  | |____ | |___| || |_| |_| |  | |///
        |  |______||_______||_________|  | |//
        |________________________________|_|/

EOF
echo "</pre>"
echo "</td><td></td></tr>"
echo "<tr>"
echo "<td width=33%></td>"
echo "<td valign=top align=right><font size=2><i>created by: maik.alberto@hotmail.com</i></font></td>"
echo "<td width=33%></td>"
echo "</tr>"
echo "</table>"

 echo "<br>"
 echo "<center>"
 echo "<b>IP: $ip logged, try again later...</b>"
 echo "<br>"
 echo "<a href=http://luw.servehttp.com>[Home]</a>"
 echo "<a href='./luw-enter/luw-enter.sh'>[Enter]</a>"
 echo "</center>"
else
#--------------------------------------------------------------------------------#
#             		  ESCREVE  LOG - IP - DATA  			         #
#--------------------------------------------------------------------------------#
data=$(date)
logacesso=/opt/luw/log/acesso
#echo -n $REMOTE_ADDR" - [$data] - " >> $logacesso
echo -n $ip" - $data - " >> $logacesso
#echo -ne $REMOTE_ADDR" - " >> $logacesso; date >> $logacesso;
#--------------------------------------------------------------------------------#
#                  Chama script de criacoa de usuario				 #
#  	           Script com permissao em /etc/sudoers				 #
#	   www-data ALL=NOPASSWD:/usr/lib/cgi-bin/luw-tuser.sh			 #
#--------------------------------------------------------------------------------#
sudo ./luw-tuser.sh
fi
