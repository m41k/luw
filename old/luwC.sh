#!/bin/zsh
#--------------------------------------------------------------------------------#
#		PROJETO LUW - LXC Unprivileged Web				 #
# 		CREATED BY: maik.alberto@hotmail.com				 #
#--------------------------------------------------------------------------------#

eval `/opt/luw/proccgi $*`
if [ -z $1 ]; then
  echo -e "Content-type: text/html\n\n"
fi

#--------------------------------------------------------------------------------#
#				VARIVEIS					 #
#--------------------------------------------------------------------------------#
#-->Hostname
hostname=`hostname`
#-->Secutiry Shell comand
ssh="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $REMOTE_USER@$hostname"
#-->Corte para pegar nome do arquivo
#form=`echo $0 | rev | cut -d / -f1 | rev`
luw=`echo $0 | rev | cut -d / -f1 | rev`
#-->Corte para pegar usuario na URL
puser=$(echo $REQUEST_URI | cut -d "~" -f2 | cut -d "/" -f1)

#--------------------------------------------------------------------------------#
#	   CONFERENCIA USUARIO LOGADO COM PAGINA ACESSADA - SECURITY		 #
#--------------------------------------------------------------------------------#
if [ $puser != $REMOTE_USER ];
  then
#	rodared='<meta http-equiv="refresh" content="0;url=http://'$SERVER_NAME'/~'$REMOTE_USER'/cgi-bin/'$form'">'
	rodared='<meta http-equiv="refresh" content="0;url=http://'$SERVER_NAME'/~'$REMOTE_USER'/cgi-bin/'$luw'">'
	echo $rodared
        exit 0
fi

#--------------------------------------------------------------------------------#
#			COMANDOS CRIACAO ARQUIVO				 #
#--------------------------------------------------------------------------------#
lcomandos=~/.comandos.lxc
eval $ssh echo "1:info:$ssh lxc-info -n" > $lcomandos
eval $ssh echo "2:start:$ssh lxc-start -n" >> $lcomandos
eval $ssh echo "3:stop:$ssh lxc-stop -n" >> $lcomandos
eval $ssh echo "4:freeze:$ssh lxc-freeze -n" >> $lcomandos
eval $ssh echo "5:unfreeze:$ssh lxc-unfreeze -n" >> $lcomandos
eval $ssh echo "6:destroy:$ssh lxc-destroy -n" >> $lcomandos

#--------------------------------------------------------------------------------#
#			BOTOES CABECALHO - EXECUCAO				 #
#--------------------------------------------------------------------------------#

#===============================[BOTAO HOME]=====================================#
if [ $FORM_top = "Home" ]; then 

fi

#============================[BOTAO CHECKCONFIG]=================================#
if [ $FORM_top = "Check Config" ]; then 
	echo "<pre>"
        $0 retorno
#	/usr/lib/cgi-bin/bcc
	lxc-checkconfig
	echo "</pre>"
	exit 0
fi

#===========================[BOTAO CREATE CONTAINER]=============================#
if [ $FORM_top = "New Container" ]; then 
#------->Baixa pagina de imagens LXC e cria lista das Distros usada no FORM 
	ipage=~/.imgpage.html
	ilist=~/.imglist.lxc
	wget -q http://images.linuxcontainers.org/ -O $ipage
	lynx -dump -width 120 $ipage > $ilist
#	rm -f index*.*
	cini=`cat -n $ilist | grep "Distribution Release Architecture" | awk {'print $1'}`
	cfin=`cat -n $ilist | grep "_________________________________" | awk {'print $1'}`
	de=`expr $cfin - $cini - 1`
	ate=`expr $cfin - 1`
	distro=( `cat $ilist | head -n $ate | tail -n $de | awk {'print $1"_"$2"_"$3'}` )
	rm -rf $ipage
	rm -rf $ilist

#------->Form para criacao de container

#	echo "<form method='post' action='$form'>"
	echo "<form method='post' action='$luw'>"
	echo "<h2>Novo Container</h2>"
#	echo "Nome:"
	echo "Name:"
	echo " <input type='text' name='ncont' maxlength='50' size='30'>"
	echo "Distro:"
	echo "<select name='dcont'>"

	 for (( d=1; d<=${#distro[@]}; d++ ))
          do
           echo "<option value=$distro[$d]>$distro[$d]"
         done
	echo  "</select>"
	echo  "<input type='submit' value='Criar'>"
	echo  "</form>"
fi

#--------------------------------------------------------------------------------#
#		BOTOES CONTAINERS  - FILEIRA DE BOTOES - EXECUCAO		 #
#--------------------------------------------------------------------------------#
#=======================EXECUTANDO COMANDO DO BOTAO CLICADO======================#
#if [ $FORM_nome != "" ]; then
if [ $FORM_botao != "" ]; then
#	teste=`echo $FORM_nome | awk -F: {'print $1'}` 
	ivn=`echo $FORM_botao | awk -F: {'print $1'}` 
	echo "<pre>"
#	comand=`cat -n /usr/lib/cgi-bin/comands.txt | grep $teste | awk -F: {'print $3'}`
#	comand=`cat -n $lcomandos | grep $teste | awk -F: {'print $3'}`
	comand=`cat -n $lcomandos | grep $ivn | awk -F: {'print $3'}`
#	container=`echo $FORM_nome | awk -F: {'print $2'}`
	container=`echo $FORM_botao | awk -F: {'print $2'}`
	var2=`echo $comand $container`
	eval $var2
fi

#--------------------------------------------------------------------------------#
#			BOTAO CRIAR CONTAINER - EXECUCAO			 #
#--------------------------------------------------------------------------------#
#==================================LXC-CREATE====================================#
if [ $FORM_ncont != "" ]; then
	contname=$FORM_ncont
	distro=`echo $FORM_dcont | awk -F_ {'print $1'}`
	release=`echo $FORM_dcont | awk -F_ {'print $2'}`
	arquit=`echo $FORM_dcont | awk -F_ {'print $3'}`
#	echo lxc-create -t download -n $nome -- -d $distro -r $release -a $arquit
	echo "<pre>"
	eval $ssh lxc-create -t download -n $contname -- -d $distro -r $release -a $arquit
	echo "</pre>"
#	ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ubuntu@luw lxc-create -t busybox -n busyweb
fi

#--------------------------------------------------------------------------------#
#			HTML - BOTOES CABECALHO	- CRIACAO			 #
#--------------------------------------------------------------------------------#
#echo "<form method='post' action='$form'>"
echo "<form method='post' action='$luw'>"
echo "<input type='submit' name='top'  value='Home'>" "<input type='submit' name='top'  value='Check Config'>" "<input type='submit' name='top' value='New Container'>"
echo "</form>"

#--------------------------------------------------------------------------------#
#		    CRIANDO LISTA DE CONTAINERS EXISTENTES			 #
#--------------------------------------------------------------------------------#

#ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ubuntu@luw lxc-ls -f > /tmp/lista$REMOTE_USER.txt
lista=~/.contdo$REMOTE_USER.lxc
#eval $ssh lxc-ls -f > /tmp/lista$REMOTE_USER.txt
eval $ssh lxc-ls -f > $lista

#--------------------------------------------------------------------------------#
#			    VARIAVES AUXILIARES SHELL				 #
#--------------------------------------------------------------------------------#
#-->pegar inicio da linha
    pil="awk {'print \$1'}"
#-->pegar partes botoes
    bp1="awk -F: {'print \$1'}"
    bp2="awk -F: {'print \$2'}"
    bp3="awk -F: {'print \$3'}"
#-->pegar nomes dos conternes na lista gerado pelo lxc-ls
#    n=`wc -l /tmp/lista$REMOTE_USER.txt | eval $pil`
    n=`wc -l $lista | eval $pil`
#-->numero de linhas cabecalho LXCv2=1 LXC<2=2
    lc=1 

#--------------------------------------------------------------------------------#
#	FUNCAO BOTAO - FILEIRA DE BOTOES NA LISTA DE CONTAINERS			 #
#--------------------------------------------------------------------------------#
#------->Funca botao = Gerar botaoes de comandos para conatiners-----------------#
#Faz o que saporra?								 #
#   Pega nome do container para gerar value para usar no form  			 #
#   Array com as ordens do descritas no comando                			 #
#       For verifica quantidades de botao, da nome, valor e gera   		 #
#--------------------------------------------------------------------------------#
function botao()
{
	vbotao=`echo $lcont | eval $pil`
#	nbotao=($(< /usr/lib/cgi-bin/comands.txt | eval $bp2 ))
#	indice=($(< /usr/lib/cgi-bin/comands.txt | eval $bp1 )) 
	nbotao=($(< $lcomandos | eval $bp2 ))
	indice=($(< $lcomandos | eval $bp1 )) 

        for (( b=1; b<=${#nbotao[@]}; b++ ))
          do
	  value=$indice[$b]":"$vbotao":"$nbotao[$b]
#          printf "<button type='submit' name='nome' value=$value>$nbotao[$b]</button>"
          printf "<button type='submit' name='botao' value=$value>$nbotao[$b]</button>"
         done
}

#--------------------------------------------------------------------------------#
#	    	     TABELA DOS CONTAINRES - DESENHANDO				 #
#--------------------------------------------------------------------------------#
#-------> Inicio da tabela dos caontaines
#-------> html misurado com shell - vitamina old school
#echo "<form method='post' action='$form'>"
echo "<form method='post' action='$luw'>"
 echo  "<table border=1>"
	echo   "<tr>"
	echo    "<td><pre>"
#		    head -n$lc /tmp/lista$REMOTE_USER.txt
		    head -n$lc $lista
	echo 	"</pre></td>"
	echo    "<td><center>$REMOTE_USER</center></td>"
	echo    "</tr>"
		     until [ $lc = $n ];
  do
			lc=`expr $lc + 1`
#			lcont=`head -n $lc /tmp/lista$REMOTE_USER.txt | tail -1`
			lcont=`head -n $lc $lista | tail -1`
			state=`echo $lcont | awk {'print $2'}`
 	echo   "<tr>"
	    case $state in
	         STOPPED)
	echo	  "<td bgcolor=red><pre>"
        	 ;;
        	 RUNNING)
	echo 	  "<td bgcolor=green><pre>"
    		 ;;
    		 FROZEN)
	echo 	  "<td bgcolor=blue><pre>"
		 ;;
		 *)
	echo 	 "<td><pre>"
		 ;;
	    esac

	echo $lcont
	echo 	 "</pre></td>"
	echo 	 "<td>"
		   botao;
	echo 	"</td>"
	echo   "</tr>"

   done
  echo "</table>"
echo "</form>"

#rm -f /tmp/lista$REMOTE_USER.txt
rm -f $lista
rm -f $lcomandos
