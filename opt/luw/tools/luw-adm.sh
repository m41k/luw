#!/bin/bash

eval `/opt/luw/proccgi $*`

echo -e "Content-type: text/html; charset=utf-8\n\n"

#--------------------------------------------------------------------------------#
#			    	 HTML CSS STYLE					 #
#--------------------------------------------------------------------------------#
cat <<EOF
<html>
 <head>
  <title>LUW - IaaS Project </title>
   <style type="text/css">
	table{
		  border-collapse: collapse;
             }
	input,
	select,
	button{
		 color: black;
		 border: solid 1px silver;
		 border-radius: 5px;
		 margin: 2px;
	      }
   </style>
 </head>
 <body>
EOF

#--------------------------------------------------------------------------------#
#			     VARIAVEIS INICIAIS					 #
#--------------------------------------------------------------------------------#
#-->Hostname
#hostname=`hostname`
hostname="localhost"
#-->Secutiry Shell comand
ssh="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $REMOTE_USER@$hostname"
#-->Corte para pegar nome do arquivo
proc=`echo $0 | rev | cut -d / -f1 | rev`

#--------------------------------------------------------------------------------#
#	   CONFERENCIA USUARIO LOGADO COM PAGINA ACESSADA - SECURITY		 #
#--------------------------------------------------------------------------------#
if [ $puser != $REMOTE_USER ];
  then
	rodared='<meta http-equiv="refresh" content="0;url=http://'$SERVER_NAME'/~'$REMOTE_USER'/cgi-bin/'$luw'">'
	echo $rodared
        exit 0
fi 2> /dev/null

#--------------------------------------------------------------------------------#
#			HTML - BOTOES CABECALHO	- CRIACAO			 #
#--------------------------------------------------------------------------------#
echo "<form method='post' action='$proc'>"
btop_home="<input type='submit' name='top' value='Monitor'>"
btop_chek="<input type='submit' name='top' value='Check_Config'>"
btop_ncon="<input type='submit' name='top' value='Users'>"
btop_clon="<input type='submit' name='top' value='LIP'>"
btop_atta="<input type='submit' name='top' value='Console'>"
btop_exit="<input type='submit' name='top' value='Logout'>"
echo "$btop_home $btop_chek $btop_ncon $btop_clon $btop_atta $btop_exit"
echo "<hr>"
echo "</form>"

#===============================[BOTAO MONITOR]=====================================#
if [ $FORM_top = "Monitor" ]; then
#echo "teste"
	echo "<table border='0' width='100%' height='100%'>"
	echo "<tr>"
	echo "<td>"
	echo "<iframe src=luw-mdc.sh frameborder='0' width='100%' height='100%'></iframe>"
	echo "</td>"
	echo "</tr>"
	echo "</table>"
        exit 0
fi 2> /dev/null
#===============================[BOTAO USERS]====================================#
if [ $FORM_top = "Users" ]; then
#-Criar->
 echo "<pre>"
        echo "<form method='post' action='$proc'>"
	echo "Criar usuario<br>"
	echo User:
	echo "<input type='text' name='cuser' maxlength='50' size='30'>"
	echo Pass:
	echo "<input type='password' name='cpass' maxlength='50' size='30'>"
	echo "<input type='submit' value='Criar'>"
	echo "</form>"
#-Reset->
        echo "<form method='post' action='$proc'>"
	echo "Reset Password<br>"
	echo -n User:
        users=( `ls /home` )
        echo -e "<select name='ruser'>"
         for (( u=0; u<${#users[@]}; u++ ))
          do
           echo "<option value=${users[$u]}>${users[$u]}"
         done
        echo  "</select>"
	echo -n Pass:
	echo "<input type='password' name='rpass' maxlength='50' size='30'>"
	echo "<input type='submit' value='Reset'>"
	echo "</form>"
#-Delete->
        echo "<form method='post' action='$proc'>"
	echo "Delete User<br>"
	echo User:
        echo "<select name='duser'>"
         for (( u=0; u<${#users[@]}; u++ ))
          do
           echo "<option value=${users[$u]}>${users[$u]}"
         done
        echo  "</select>"
	echo "<input type='submit' value='Delete'>"
	echo "</form>"
 echo "</pre>"
        exit 0
fi 2> /dev/null
#=============================[BOTAO LOGOUT]=====================================#
if [ $FORM_top = "Logout" ]; then
	bye='<meta http-equiv="refresh" content="0;url=http://foo:foo@'$SERVER_NAME'">'
	echo $bye
#echo "teste"
#echo "<meta http-equiv='refresh' content='0';url='foo:foo@luw.servehttp.com'>"
fi 2> /dev/null

#============================[BOTAO CHECKCONFIG]=================================#
if [ $FORM_top = "Check_Config" ]; then 
	echo "<pre>"
	echo "<h2>LXC-CHECKCONFIG</h1>"
	lxc-checkconfig | sed 's/\[0;39m/ / ; s/\[1;32m/ /'
	echo "</pre>"
	exit 0
fi 2> /dev/null

#===============================[BOTAO LIP]=====================================#
if [ $FORM_top = "LIP" ]; then
        echo "<pre>"
        echo "Opções para os containers. Em desenvolvimento."
	echo "Fork para conhecimanto:"
	echo "<a href='http://$SERVER_NAME/lip'>http://$SERVER_NAME/lip</a>"
        exit 0
fi 2> /dev/null
#===============================[BOTAO LIP]=====================================#
if [ $FORM_top = "Console" ]; then
        echo "<pre>"
	echo "Desativado"
        exit 0
fi 2> /dev/null


#--------------------------------------------------------------------------------#
#                            FORM USERS - EXECUCAO                               #
#--------------------------------------------------------------------------------#

#==================================[CRIACAO]=====================================#
if [ $FORM_cuser != "" ] && [ $FORM_cpass != "" ]; then
   echo "<pre>"
    sudo /opt/luw/tools/luw-user.sh -a $FORM_cuser $FORM_cpass
   echo Created $FORM_cuser
   echo "</pre>"
   exit 0
fi
#=================================[ALTERACAO]=====================================#
if [ $FORM_ruser != "" ] && [ $FORM_rpass != "" ]; then
   echo "<pre>"
    sudo /opt/luw/tools/luw-user.sh -m $FORM_ruser $FORM_rpass
   echo Password changed for $FORM_ruser
   echo "</pre>"
   exit 0
fi

#==================================[EXCLUSAO]=====================================#
if [ $FORM_duser != "" ]; then
   echo "<pre>"
    sudo /opt/luw/tools/luw-user.sh -d $FORM_duser
   echo Deleted $FORM_duser
   echo "</pre>"
   exit 0
fi

#===============================[CAPA PAGE]========================================#
#if [ $FORM_top -z ]; then
	echo "<b>Monitor</b><br>Monitoramente de recursos do sistema<br><br>"
	echo "<b>Check Config</b><br>Verificação da configuração do LXC<br><br>"
	echo "<b>Users</b><br>Administração de usuários<br><br>"
	echo "<b>Limits</b><br>Limitar recursos dos containers<br><br>"
	echo "<b>Console</b><br>Console do sistema<br><br>"
	echo "<b>Logout</b><br>Sair<br><br>"
#fi 2> /dev/null
