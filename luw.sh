#!/bin/zsh
#--------------------------------------------------------------------------------#
#		PROJETO LUW - LXC Unprivileged Web				 #
# 		CREATED BY: maik.alberto@hotmail.com				 #
#--------------------------------------------------------------------------------#

eval `/opt/luw/proccgi $*`

echo -e "Content-type: text/html\n\n"

#--------------------------------------------------------------------------------#
#			     VARIAVEIS INICIAIS					 #
#--------------------------------------------------------------------------------#
#-->Hostname
hostname=`hostname`
#-->Secutiry Shell comand
ssh="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $REMOTE_USER@$hostname"
#-->Corte para pegar nome do arquivo
luw=`echo $0 | rev | cut -d / -f1 | rev`
#-->Corte para pegar usuario na URL
puser=$(echo $REQUEST_URI | cut -d "~" -f2 | cut -d "/" -f1)

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
#  			        BUILD CONSOLE			                 #
#--------------------------------------------------------------------------------#
function Fss()
{
cpid=~/.pid_$container.lxc
port=`echo $[ 10000 + $[ RANDOM % 10000 ]]`
echo $port
netcat -z 127.0.0.1 $port
if [ $? = 0 ]; then
 Fss
else
# shellinaboxd --no-beep -p $port -t -b$cpid -s "/:AUTH:HOME:lxc-attach -n $container"
  shellinaboxd --no-beep -p $port -t -b$cpid -s "/:AUTH:HOME:/bin/bash /home/ubuntu/public_html/cgi-bin/apoio"
fi


#echo "shellinaboxd --no-beep -p $port -t -bteste.pid -s '/:AUTH:HOME:lxc-attach -n $container'"
}

function Fsp()
{
cpid=~/.pid_$container.lxc
pidc=`cat $cpid`; kill -9 $pidc
}

function Fst()
{

#./luw.sh -teste
echo "#!/bin/bash" > ~/public_html/cgi-bin/$container.sh
echo shellinaboxd --no-beep --cgi -t -s '"'/:$(id -u):$(id -g):HOME:/bin/bash /home/$REMOTE_USER/public_html/cgi-bin/$container.box'"' >> ~/public_html/cgi-bin/$container.sh
echo lxc-console -q -n $container > ~/public_html/cgi-bin/$container.box
chmod 705 ~/public_html/cgi-bin/$container.sh
chmod +x ~/public_html/cgi-bin/$container.sh
goshell='<meta http-equiv="refresh" content="0;url=http://'$SERVER_NAME'/~'$REMOTE_USER'/cgi-bin/'$container.sh'">'
echo $goshell

#echo teste

#echo $0
#shellinaboxd --no-beep --cgi -t -s "/:$(id -u):$(id -g):HOME:/bin/bash /home/ubuntu/public_html/cgi-bin/apoio"
}

#--------------------------------------------------------------------------------#
#	CATALOGO DE COMANDOS - INDICE:NOMEBOTAO:COMANDO - CRIACAO ARQUIVO	 #
#--------------------------------------------------------------------------------#
catcom=~/.catcom.lxc
eval $ssh echo "1:info:$ssh lxc-info -n" > $catcom 2> /dev/null
eval $ssh echo "2:start:$ssh lxc-start -n" >> $catcom 2> /dev/null
eval $ssh echo "3:stop:$ssh lxc-stop -n" >> $catcom 2> /dev/null
eval $ssh echo "4:freeze:$ssh lxc-freeze -n" >> $catcom 2> /dev/null
eval $ssh echo "5:unfreeze:$ssh lxc-unfreeze -n" >> $catcom 2> /dev/null
eval $ssh echo "6:destroy:$ssh lxc-destroy -n" >> $catcom 2> /dev/null
eval $ssh echo "7:console:Fst" >> $catcom 2> /dev/null

#--------------------------------------------------------------------------------#
#		BOTOES CONTAINERS  - FILEIRA DE BOTOES - EXECUCAO		 #
#--------------------------------------------------------------------------------#
#=======================EXECUTANDO COMANDO DO BOTAO CLICADO======================#
if [ $FORM_botao != "" ]; then
	ivn=`echo $FORM_botao | awk -F: {'print $1'}` 
	echo "<pre>"
	comand=`cat -n $catcom | grep $ivn | awk -F: {'print $3'}`
	container=`echo $FORM_botao | awk -F: {'print $2'}`
	var2=`echo $comand $container`
	eval $var2
fi 2> /dev/null

#--------------------------------------------------------------------------------#
#		    CRIANDO LISTA DE CONTAINERS EXISTENTES			 #
#--------------------------------------------------------------------------------#

lslxc=~/.contdo$REMOTE_USER.lxc
eval $ssh lxc-ls -f > $lslxc 2> /dev/null

#--------------------------------------------------------------------------------#
#			HTML - BOTOES CABECALHO	- CRIACAO			 #
#--------------------------------------------------------------------------------#
echo "<form method='post' action='$luw'>"
btop_home="<input type='submit' name='top'  value='Home'>"
btop_chek="<input type='submit' name='top'  value='Check Config'>"
btop_ncon="<input type='submit' name='top' value='New Container'>"
btop_clon="<input type='submit' name='top' value='Clone'>"
btop_atta="<input type='submit' name='top' value='Attach'>"
echo $btop_home $btop_chek $btop_ncon $btop_clon $btop_atta
#echo "<input type='submit' name='top'  value='Home'>" "<input type='submit' name='top'  value='Check Config'>" "<input type='submit' name='top' value='New Container'>" "<input type='submit' name='top' value='Clone'>"
echo "</form>"


#--------------------------------------------------------------------------------#
#			BOTOES CABECALHO - EXECUCAO				 #
#--------------------------------------------------------------------------------#

#===============================[BOTAO HOME]=====================================#
if [ $FORM_top = "Home" ]; then 

fi 2> /dev/null

#============================[BOTAO CHECKCONFIG]=================================#
if [ $FORM_top = "Check Config" ]; then 
#	echo "<form method='post' action='$luw'>"
#	echo "<input type='submit' name='top'  value='Home'>" 
#	echo "</form>"
	echo "<pre>"
	echo "<h2>LXC-CHECKCONFIG</h1>"
	lxc-checkconfig | sed 's/\[0;39m/ / ; s/\[1;32m/ /'
	echo "</pre>"
	exit 0
fi 2> /dev/null

#===========================[BOTAO CREATE CONTAINER]=============================#
if [ $FORM_top = "New Container" ]; then 
#------->Baixa pagina de imagens LXC e cria lista das Distros usada no FORM 
	ipage=~/.imgpage.html
	ilist=~/.imglist.lxc
	wget -q http://images.linuxcontainers.org/ -O $ipage
	lynx -dump -width 120 $ipage > $ilist
	cini=`cat -n $ilist | grep "Distribution Release Architecture" | awk {'print $1'}`
	cfin=`cat -n $ilist | grep "_________________________________" | awk {'print $1'}`
	de=`expr $cfin - $cini - 1`
	ate=`expr $cfin - 1`
	distro=( `cat $ilist | head -n $ate | tail -n $de | awk {'print $1"_"$2"_"$3'}` )
	rm -rf $ipage
	rm -rf $ilist

#------->Form para criacao de container

	echo "<form method='post' action='$luw'>"
	echo "<h2>Novo Container</h2>"
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
fi 2> /dev/null

#=================================[BOTAO CLONE]==================================#
if [ $FORM_top = "Clone" ]; then 
#------->Criar array do containers existentes para o select 
	wc_lslxc=`wc $lslxc | awk {'print $1'}`
	tt_cont=`expr $wc_lslxc - 1`
	orig=( `cat $lslxc | awk {'print $1'} | tail -$tt_cont` )

#------->Form para criacao de container

	echo "<form method='post' action='$luw'>"
	echo "<h2>Clone Container</h2>"
	echo "<select name='orig'>"
         for (( d=1; d<=${#orig[@]}; d++ ))
          do
 	   echo "<option value=$orig[$d]>$orig[$d]"
         done
	echo  "</select>"
	   echo ">>>"
	   echo "<input type='text' name='clone' maxlength='50' size='30'>"
  	   echo  "<input type='submit' value='Clonar'>"
	echo  "</form>"

#	echo "</pre>"
fi 2> /dev/null

#=================================[BOTAO ATTACH]==================================#
if [ $FORM_top = "Attach" ]; then
#------->Criar array do containers existentes para o select
        wc_lslxc=`wc $lslxc | awk {'print $1'}`
        tt_cont=`expr $wc_lslxc - 1`
        orig=( `cat $lslxc | awk {'print $1'} | tail -$tt_cont` )

#------->Form para criacao de container

        echo "<form method='post' action='$luw'>"
#        echo "<h2>Attach Command</h2>"
        echo "<h2>Define password:</h2>"
#        echo "root@"
         echo "Container:"
        echo "<select name='orig'>"
         for (( d=1; d<=${#orig[@]}; d++ ))
          do
           echo "<option value=$orig[$d]>$orig[$d]"
         done
        echo  "</select>"
#          echo ":/#"
#           echo "<input type='text' name='attach' maxlength='50' size='30'>"
#           echo  "<input type='submit' value='Execute'>"
	echo "User:"
        echo "<select name='user'>"
	echo "<option value='luw'>luw</option>"
	echo "<option value='root'>root</option>"
        echo  "</select>"
	echo "Password:"
        echo "<input type='password' name='pass' maxlength='50' size='30'>"
        echo  "<input type='submit' value='Execute'>"

#	   echo "<br>"
#           echo "<input type='text' name='aroot' maxlength='50' size='30'>"
#           echo  "<input type='submit' value='Execute'>"

        echo  "</form>"

#       echo "</pre>"
fi 2> /dev/null

#--------------------------------------------------------------------------------#
#			BOTAO CRIAR CONTAINER - EXECUCAO			 #
#--------------------------------------------------------------------------------#
#      add validation to remote code execution solution - Stéphane reported      #
#==================================LXC-CREATE====================================#
if [ $FORM_ncont != "" ]; then
 if  echo $FORM_ncont | grep '[^[:alnum:]]' > /dev/null; then
  echo "<font color=red size=2><b>Invalid name. Use alphanumeric characters only.</b></font>"
 else
	contname=$FORM_ncont
	distro=`echo $FORM_dcont | awk -F_ {'print $1'}`
	release=`echo $FORM_dcont | awk -F_ {'print $2'}`
	arquit=`echo $FORM_dcont | awk -F_ {'print $3'}`
	echo "<pre>"
	eval $ssh lxc-create -t download -n $contname -- -d $distro -r $release -a $arquit 2> /dev/null
	echo "</pre>"
 fi
fi 2> /dev/null

#--------------------------------------------------------------------------------#
#                       BOTAO CLONE CONTAINER - EXECUCAO                         #
#--------------------------------------------------------------------------------#
#==================================LXC-CLONE=====================================#
if [ $FORM_clone != "" ]; then
 if  echo $FORM_clone | grep '[^[:alnum:]]' > /dev/null; then
  echo "<font color=red size=2><b>Invalid name. Use alphanumeric characters only.</b></font>"
 else
        echo "<pre>"
#        eval $ssh lxc-create -t download -n $contname -- -d $distro -r $release -a $arquit 2> /dev/null
	 eval $ssh  lxc-clone -o $FORM_orig -n $FORM_clone 2> /dev/null 
        echo "</pre>"
 fi
fi 2> /dev/null

#--------------------------------------------------------------------------------#
#                       BOTAO ATTACH COMMAND - EXECUCAO                          #
#--------------------------------------------------------------------------------#
#==================================LXC-ATTACH====================================#
if [ $FORM_pass != "" ]; then
        echo "<pre>"
          eval $ssh lxc-start -n $FORM_orig 2> /dev/null 
          eval $ssh lxc-attach -n $FORM_orig -- useradd -m $FORM_user -s /bin/bash
          eval $ssh lxc-attach -n $FORM_orig -- usermod -p $(openssl passwd $FORM_pass) $FORM_user
        echo "Password changed. <a href=http://$SERVER_NAME/~$REMOTE_USER/cgi-bin/$FORM_orig.sh>Have Fun!</a>"
        echo "</pre>"

lslxc=~/.contdo$REMOTE_USER.lxc
eval $ssh lxc-ls -f > $lslxc 2> /dev/null

fi 2> /dev/null


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
    n=`wc -l $lslxc | eval $pil`
#-->numero de linhas cabecalho LXCv2=1 LXC<2=2
    lc=1 

#--------------------------------------------------------------------------------#
#	FUNCAO BOTAO - FILEIRA DE BOTOES NA LISTA DE CONTAINERS			 #
#--------------------------------------------------------------------------------#
#------->Funca botao = Gerar botaoes de comandos para conatiners-----------------#
#Sinopse:									 #
#   Pega nome do container para gerar value para usar no form; 			 #
#   Array com as ordens do descritas no comando                			 #
#       For verifica quantidades de botao, da nome, valor e gera botao		 #
#--------------------------------------------------------------------------------#
function botao()
{
	vbotao=`echo $lcont | eval $pil`
	nbotao=($(< $catcom | eval $bp2 ))
	indice=($(< $catcom | eval $bp1 )) 

        for (( b=1; b<=${#nbotao[@]}; b++ ))
          do
	  value=$indice[$b]":"$vbotao":"$nbotao[$b]
          printf "<button type='submit' name='botao' value=$value>$nbotao[$b]</button>"
         done
}

#--------------------------------------------------------------------------------#
#	    	     TABELA DOS CONTAINRES - DESENHANDO				 #
#--------------------------------------------------------------------------------#
#-------> Inicio da tabela dos caontaines
#-------> html misurado com shell - vitamina old school
if [ -s $lslxc ]; then
echo "<form method='post' action='$luw'>"
 echo  "<table border=1>"
	echo   "<tr>"
	echo    "<td><pre>"
		    head -n$lc $lslxc
	echo 	"</pre></td>"
	echo    "<td><center>$REMOTE_USER</center></td>"
	echo    "</tr>"
		     until [ $lc = $n ];
  do
			lc=`expr $lc + 1`
			lcont=`head -n $lc $lslxc | tail -1`
			state=`echo $lcont | awk {'print $2'}`
 	echo   "<tr>"
	    case $state in
	         STOPPED)
	echo	  "<td bgcolor=red><pre>"
        	 ;;
        	 RUNNING)
	echo	  "<td bgcolor=green><pre>"
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
else
 echo "Nenhum container criado"
fi

rm -f $lslxc
rm -f $catcom
