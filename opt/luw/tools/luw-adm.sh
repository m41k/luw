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
btop_port="<input type='submit' name='top' value='Ports'>"
btop_imag="<input type='submit' name='top' value='Images'>"
btop_clon="<input type='submit' name='top' value='LIP'>"
btop_atta="<input type='submit' name='top' value='Console'>"
btop_logs="<input type='submit' name='top' value='Log'>"
btop_exit="<input type='submit' name='top' value='Logout'>"
echo "$btop_home $btop_chek $btop_ncon $btop_port $btop_imag $btop_clon $btop_atta $btop_logs $btop_exit"
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
#===============================[BOTAO IMAGES]=====================================#
if [ $FORM_top = "Images" ]; then
#echo "teste"
	echo "<table border='0' width='100%' height='92%'>"
	echo "<tr>"
	echo "<td>"
	echo "<iframe src=luw-images.sh frameborder='0' width='100%' height='100%'></iframe>"
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

#===============================[BOTAO PORTS]====================================#
if [ $FORM_top = "Ports" ]; then
#-Criar tabela->
 echo "<pre>"
        echo "<form method='post' action='$proc'>"
        echo "Criar tabela de Porta<br>"
        echo Porta inicial:
        echo "<input type='text' name='pi' maxlength='5' size='5'>"
        echo Porta final:
        echo "<input type='text' name='pf' maxlength='5' size='5'>"
        echo "<input type='submit' value='Criar'>"
        echo "</form>"
#-Associar usuario->
 echo "<hr>"
        users=( `ls /home` )
        echo "<form method='post' action='$proc'>"
        echo "Associar porta livre a usuario<br>"
        echo -n User:
        echo "<select name='uport'>"
         for (( u=0; u<${#users[@]}; u++ ))
          do
           echo "<option value=${users[$u]}>${users[$u]}"
         done
        echo  "</select> <input type='submit' value='Add'>"
        echo "</form>"
#-Exibir tabela->
 	echo "<hr>"
 	echo "Tabela"
	echo "<form method='post' action='$proc'>"
	echo "<textarea name='contable' rows='10' cols='50'>"
	        sudo /opt/luw/tools/luw-fw.sh -t
 	echo "</textarea>"
	echo "<input type='checkbox' name='check' value='on'>Desejo reescrever <input type='submit' value='Save'>"
        echo "</form>"
#-Exibir tabela->
 	echo "<hr>"
	sudo /opt/luw/tools/luw-fw.sh -l
 	echo "</pre>"
	 exit 0
fi 2> /dev/null

#=============================[BOTAO LOGOUT]=====================================#
if [ $FORM_top = "Logout" ]; then
	source /opt/luw/tools/luw-logout.sh
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
	echo "Fork para conhecimento:"
	echo "<a href='http://$SERVER_NAME/lip'>http://$SERVER_NAME/lip</a>"
        exit 0
fi 2> /dev/null
#===============================[BOTAO CONSOLE]==================================#
if [ $FORM_top = "Console" ]; then
        echo "<pre>"
	echo "Desativado"
        exit 0
fi 2> /dev/null
#===============================[BOTAO LOG]==================================#
if [ $FORM_top = "Log" ]; then
        echo "<pre>"
	tac /opt/luw/log/acesso
        echo "</pre>"
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

#--------------------------------------------------------------------------------#
#                            FORM PORTS - EXECUCAO                               #
#--------------------------------------------------------------------------------#
#==================================[CRIAR TABELA]================================#
if [ $FORM_pi != "" ] && [ $FORM_pf != "" ]; then
   echo "<pre>"
    sudo /opt/luw/tools/luw-fw.sh -c $FORM_pi $FORM_pf
   echo Created new table
   echo "</pre>"
   exit 0
fi

#=================================[ASSOCIAR PORTA]===============================#
if [ $FORM_uport != "" ]; then
   echo "<pre>"
    sudo /opt/luw/tools/luw-fw.sh -u $FORM_uport
   echo $FORM_uport associado a porta
   echo "</pre>"
   exit 0
fi

#==================================[ALTERAR TABELA]===============================#
#if [ $FORM_contable != "" ]; then
if [ $FORM_check = "on" ]; then
   echo "<pre>"
   TABTEMP=/tmp/portas.fw
   rm $TABTEMP 2> /dev/null
   array=($FORM_contable)
     for (( l=0; l<${#array[@]}; l++ ))
      do
       echo ${array[$l]} >> $TABTEMP
      done
    sudo /opt/luw/tools/luw-fw.sh -r $TABTEMP
    rm $TABTEMP 2> /dev/null
    echo Tabela reescrita.
   echo "</pre>"
   exit 0
fi
#echo $FORM_check

#----------------------------------------------------------------------------------#
#===============================[CAPA PAGE]========================================#
#----------------------------------------------------------------------------------#
#if [ $FORM_top -z ]; then
	echo "<b>Monitor</b><br>Monitoramente de recursos do sistema<br><br>"
	echo "<b>Check Config</b><br>Verificação da configuração do LXC<br><br>"
	echo "<b>Users</b><br>Administração de usuários<br><br>"
	echo "<b>Limits</b><br>Limitar recursos dos containers<br><br>"
	echo "<b>Console</b><br>Console do sistema<br><br>"
	echo "<b>Logout</b><br>Sair<br><br>"
#fi 2> /dev/null
