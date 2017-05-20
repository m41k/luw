#!/bin/bash

#--------------------------------------------------------------------------------#
#       LUW-FW - MODULO PARA CONFIGURACAO DE PORTAS PARA USUARIOS                #
#               CREATED BY: maik.alberto@hotmail.com                             #
#--------------------------------------------------------------------------------#

PATHFW=/opt/luw/fw
ARQPORT=/opt/luw/fw/portas.fw

case $1 in

#->[c] = Criar lista de portas verificando portas em uso
   -c)
        if [ ! -d "$PATHFW" ]; then  -zmkdir $PATHFW; fi
        #Definicao de rande de porta (mudar para var)
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
;;
#->[u] = Definir porta para usuario
   -u)
        USER=$2
        LAS=`grep ':$' $ARQPORT | head -1`
        #echo $LAS
        sed -i s/$LAS/$LAS$USER/g $ARQPORT 2> /dev/null
;;
