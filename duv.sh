#!/bin/zsh
# programa em C que eu pequei
eval `./proccgi $*`
echo -e "Content-type: text/html\n\n"

###############BOTAO HOME###############################################
if [ $FORM_top = "Home" ]; then 
#/usr/lib/cgi-bin/reload.sh
fi

###############BOTAO CHECK CONFIG###############################################
if [ $FORM_top = "Check Config" ]; then 
 echo "<pre>"
 /usr/lib/cgi-bin/teste.sh
 /usr/lib/cgi-bin/bcc
 echo "</pre>"
# exit 0
fi
#################################################################################

###############BOTAO CREATE CONTAINER###############################################
if [ $FORM_top = "New Container" ]; then 
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
########---HTML
echo "<form method='post' action='/cgi-bin/duv.sh'>"
echo " <h2>Novo Container</h2>"

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
#################################################################################

####################BOTOES CONATINERS############################################
#else

#echo $FORM_nome

teste=`echo $FORM_nome | awk -F: {'print $1'}` 
#echo $teste
#echo "<br>"
echo "<pre>"
comand=`cat -n /usr/lib/cgi-bin/comands.txt | grep $teste | awk -F: {'print $3'}`
container=`echo $FORM_nome | awk -F: {'print $2'}`
#reload=`cat -n /usr/lib/cgi-bin/comands.txt | grep $teste | awk -F: {'print $4'}`
#echo $comand
#echo $container
#echo $comand $container
#eval $comand
#var1="lxc-info -n"
#echo $reload
var2=`echo $comand $container`
#var3=`echo $reload`
eval $var2
#eval $var3
#fi

#############Botoes Novo Container#################################
if [ $FORM_ncont != "" ]; then
nome=$FORM_ncont
distro=`echo $FORM_dcont | awk -F_ {'print $1'}`
release=`echo $FORM_dcont | awk -F_ {'print $2'}`
arquit=`echo $FORM_dcont | awk -F_ {'print $3'}`
echo create -t download -n $nome -- -d $distro -r $release -a $arquit
fi

/usr/lib/cgi-bin/teste.sh

