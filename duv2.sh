#!/bin/zsh
#--------------------------------------------------------------------------------#
#		PROJETO LUW - LXC Unprivileged Web				 #
# 		CREATED BY: maik.alberto@hotmail.com				 #
#--------------------------------------------------------------------------------#

eval `./proccgi $*`
if [ -z $1 ]; then
 echo -e "Content-type: text/html\n\n"
fi

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
	/usr/lib/cgi-bin/bcc
	echo "</pre>"
	exit 0
fi

#===========================[BOTAO CREATE CONTAINER]=============================#
if [ $FORM_top = "New Container" ]; then 
#------->Baixa pagina de imagens LXC e cria lista das Distros usada no FORM 
	wget -q http://images.linuxcontainers.org/ -O /tmp/lxcimg.html
	lynx -dump -width 120 /tmp/lxcimg.html > /tmp/lcreate.txt
	rm -f index*.*
	cini=`cat -n /tmp/lcreate.txt | grep "Distribution Release Architecture" | awk {'print $1'}`
	cfin=`cat -n /tmp/lcreate.txt | grep "_________________________________" | awk {'print $1'}`
	de=`expr $cfin - $cini - 1`
	ate=`expr $cfin - 1`
	distro=( `cat /tmp/lcreate.txt | head -n $ate | tail -n $de | awk {'print $1"_"$2"_"$3'}` )
	rm -rf /tmp/lcreate.txt
	rm -rf /tmp/lxcimg.html

#------->Form para crIação de container

	echo "<form method='post' action='./duv.sh'>"
	echo "<h2>Novo Container</h2>"
	echo "Nome:"
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
if [ $FORM_nome != "" ]; then
	teste=`echo $FORM_nome | awk -F: {'print $1'}` 
	echo "<pre>"
	comand=`cat -n /usr/lib/cgi-bin/comands.txt | grep $teste | awk -F: {'print $3'}`
	container=`echo $FORM_nome | awk -F: {'print $2'}`
	var2=`echo $comand $container`
	eval $var2
fi

#--------------------------------------------------------------------------------#
#			BOTAO CRIAR CONTAINER - EXECUCAO			 #
#--------------------------------------------------------------------------------#
#==================================LXC-CREATE====================================#
if [ $FORM_ncont != "" ]; then
	nome=$FORM_ncont
	distro=`echo $FORM_dcont | awk -F_ {'print $1'}`
	release=`echo $FORM_dcont | awk -F_ {'print $2'}`
	arquit=`echo $FORM_dcont | awk -F_ {'print $3'}`
	echo lxc-create -t download -n $nome -- -d $distro -r $release -a $arquit
	ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ubuntu@luw lxc-create -t download -n $nome -- -d $distro -r $release -a $arquit
	#ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ubuntu@luw lxc-create -t busybox -n busyweb
fi

#--------------------------------------------------------------------------------#
#			HTML - BOTOES CABECALHO	- CRIACAO			 #
#--------------------------------------------------------------------------------#
echo "<form method='post' action='./duv.sh'>"
echo "<input type='submit' name='top'  value='Home'>" "<input type='submit' name='top'  value='Check Config'>" "<input type='submit' name='top' value='New Container'>"
echo "</form>"

#--------------------------------------------------------------------------------#
#		    CRIANDO LISTA DE CONTAINERS EXISTENTES			 #
#--------------------------------------------------------------------------------#

ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ubuntu@luw lxc-ls -f > /tmp/lista$REMOTE_USER.txt

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
    n=`wc -l /tmp/lista$REMOTE_USER.txt | eval $pil`
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
	nbotao=($(< /usr/lib/cgi-bin/comands.txt | eval $bp2 ))
	indice=($(< /usr/lib/cgi-bin/comands.txt | eval $bp1 )) 

        for (( b=1; b<=${#nbotao[@]}; b++ ))
          do
	  value=$indice[$b]":"$vbotao":"$nbotao[$b]
          printf "<button type='submit' name='nome' value=$value>$nbotao[$b]</button>"
         done
}

#--------------------------------------------------------------------------------#
#	    	     TABELA DOS CONTAINRES - DESENHANDO				 #
#--------------------------------------------------------------------------------#
#-------> Inicio da tabela dos caontaines
#-------> html misurado com shell - vitamina old school
echo "<form method='post' action='./duv.sh'>"
 echo  "<table border=1>"
	echo   "<tr>"
	echo    "<td><pre>"
		    head -n$lc /tmp/lista$REMOTE_USER.txt
	echo 	"</pre></td>"
	echo    "<td><center>$REMOTE_USER</center></td>"
	echo    "</tr>"
		     until [ $lc = $n ];
  do
			lc=`expr $lc + 1`
			lcont=`head -n $lc /tmp/lista$REMOTE_USER.txt | tail -1`
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

rm -f /tmp/lista$REMOTE_USER.txt
