#!/bin/zsh
#-->Cabecalho padrao para rodar script no browser
#echo Content-Type: text/html; charset="utf-8"
#echo
 
#-->Topo pagina web html + $ruser pegar usuario logado
#echo "<pre>"
#echo "<h2>Container Control Center</h2>"
#echo "<br>"
echo "<form method='post' action='/cgi-bin/duv.sh'>"
echo "<input type='submit' name='top'  value='Home'>" "<input type='submit' name='top'  value='Check Config'>" "<input type='submit' name='top' value='New Container'>"
echo "</form>"
#echo "</pre>"
 
#-->Listando containers e gerando arquivo
#lxc-ls -f > lista.txt
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ubuntu@luw lxc-ls -f > /tmp/lista$REMOTE_USER.txt
 
#-->Variaveis iniciais
#------->pegar inicio da linha
    pil="awk {'print \$1'}"
    bp1="awk -F: {'print \$1'}"
    bp2="awk -F: {'print \$2'}"
    bp3="awk -F: {'print \$3'}"

#------->pegar nomes dos conternes na lista gerado pelo lxc-ls
    n=`wc -l /tmp/lista$REMOTE_USER.txt | eval $pil`
#------->numero de linhas cabecalho
#------>versao2=1 
#---->versao<2=2
    lc=1
 
#------->Funca botao = Gerar botaoes de comandos para conatiners---#
#Resumo:                               |
#   Pega nome do container para gerar value para usar no form  |
#   Array com as ordens do descritas no comando                |
#       For verifica quantidades de botao, da nome, valor e gera   |
#------------------------------------------------------------------#
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
 
#-------> Inicio da tabela dos caontaines
#-------> html misurado com shell - vitamina old school
 echo "<form method='post' action='/cgi-bin/duv.sh'>"
 echo "<table border=1>"
 echo "<tr>"
 echo "<td><pre>"
    #Shell
    head -n$lc /tmp/lista$REMOTE_USER.txt
 echo "</pre></td>"
 echo "<td><center>$REMOTE_USER</center></td>"
 echo "</tr>"
 
    #Shell
    until [ $lc = $n ];
    do
    lc=`expr $lc + 1`
    lcont=`head -n $lc /tmp/lista$REMOTE_USER.txt | tail -1`
        state=`echo $lcont | awk {'print $2'}`
 
 echo "<tr>"
 
    #Shell
    case $state in
        STOPPED)
 echo "<td bgcolor=red><pre>"
        ;;
        RUNNING)
 echo "<td bgcolor=green><pre>"
    ;;
    FROZEN)
echo "<td bgcolor=blue><pre>"
    ;;
    *)
echo "<td><pre>"
    ;;
    esac
 
    #Shell
    echo $lcont
 
 echo "</pre></td>"
 echo "<td>"
    #Shell
    botao;
echo "</td>"
echo "</tr>"
 
    #Shell
    done
 
echo "</form>"
echo "</table>"

rm -f /tmp/lista$REMOTE_USER.txt
