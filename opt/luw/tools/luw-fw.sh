#!/bin/bash

#--------------------------------------------------------------------------------#
#       LUW-FW - MODULO PARA CONFIGURACAO DE PORTAS PARA USUARIOS                #
#               CREATED BY: maik.alberto@hotmail.com                             #
#--------------------------------------------------------------------------------#

PATHFW=/opt/luw/fw
ARQPORT=/opt/luw/fw/portas.fw
CHAIN=LUW

case $1 in

#->[c] = Criar lista de portas verificando portas em uso
   -c)
      #->Criando arquivos tabela de portas
        if [ ! -d "$PATHFW" ]; then  mkdir $PATHFW; fi
        #Definicao de range de porta (mudar para var)
        PI=$2
        PF=$3

        rm -f $ARQPORT

        for ((i=$PI;i<=$PF;i++)); do
         printf "$i:" >> $ARQPORT
         fuser -sn tcp $i
         if [ $? = 0 ]; then
          printf "uso\n" >> $ARQPORT
         else
          printf "\n" >> $ARQPORT
         fi
        done
      #->Criando regras iptables
        REMPRE=`sudo iptables -t nat -S | grep "j $CHAIN" | head -n 1 | sed 's/-A/-D/g'`

	/sbin/iptables -t nat -F LUW 2> /dev/null
        /sbin/iptables -t nat $REMPRE 2> /dev/null
	/sbin/iptables -t nat -N LUW 2> /dev/null
	/sbin/iptables -t nat -A PREROUTING -p tcp --dport $PI:$PF -j $CHAIN

;;
#->Definir porta para usuario
   -u)
        LAS=`grep ':$' $ARQPORT | head -1`
        #echo $LAS
        sed -i s/$LAS/$LAS$2/g $ARQPORT 2> /dev/null
;;
#->search port user
   -s)
        cat $ARQPORT | grep '\b'$2'\b' | cut -d ":" -f1
;;
#->tabela de portas
   -t)
        cat $ARQPORT
;;

#->inserir regra de portas
   -i)
      /sbin/iptables -t nat -A $CHAIN -p tcp --dport $2 -j DNAT --to $3:$4
;;
#->reescrever tabela
   -r)
      #sed utilizado para remover ^M do arquivo temporario
      sed -e 's/\r//g' $2 > $ARQPORT 2> /dev/null
;;

#->Desassociar portas do usuario
   -d)
	sed -i s/$2//g $ARQPORT 2> /dev/null
;;
#->listar iptables
   -l)
        /sbin/iptables -n -t nat -L LUW
;;
esac
