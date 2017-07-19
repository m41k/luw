#!/bin/bash
#--------------------------------------------------------------------------------#
#                  LUW-IMAGES - GERENCIAMENTO DE IMAGES                          #
#                  CREATED BY: maik.alberto@hotmail.com                          #
#--------------------------------------------------------------------------------#
eval `/opt/luw/proccgi $*`

#CONFIGURACAO
URL="https://us.images.linuxcontainers.org"
RLOCAL="/tmp/repo"
CARD="/cardapio.luw"
ARQ1="meta.tar.xz"
ARQ2="rootfs.tar.xz"
BUIL="build_id"
META="/meta/1.0"
INDX="/index-user"

#VERICACAO EXISTENCIA CARDAPIO
[ -e $RLOCAL$CARD ] || > $RLOCAL$CARD

#LISTA PARA DOWNLOAD
LISTA=`wget -qO- https://us.images.linuxcontainers.org/meta/1.0/index-user`
#DIFERENCA ENTRE REPOSITORIO LOCAL E DISPONIVEIS PARA DOWNLOAD
#diff cardapio.luw index-user | grep ">" | tr -d ">" | tail -n +2
DISP=`diff $RLOCAL$CARD $RLOCAL$INDX | grep ">" | tr -d ">"`

#ATAULIZADO LISTA DISPONIVEL PARA DOWNLOAD
rm -rf $RLOCAL$INDX
wget $URL$META$INDX -P $RLOCAL

echo -e "Content-type: text/html\n\n"
echo "<pre>"
echo "Distros Repositorio Local"
echo "<hr>"
cat $RLOCAL$CARD
echo "<hr>"
echo "Distros Disponives para download"
echo "<form method='post' action='$proc'>"


NUM=1
        for line in $DISP
        do
           #echo $NUM "<input type='checkbox' name='list$NUM' value='$line'>" $line
           echo "<input type='checkbox' name='list$NUM' value='$line'>" $line
           NUM=`expr $NUM + 1`
        done

echo "<hr>"
echo "<input type='checkbox' name='confirma' value='on'>" Desejo baixar "<input type='submit' name='ok' value='ok'>"
echo "<hr>"
echo "</form>"

 if [ $FORM_confirma = "on" ]; then
    for l in $(seq $NUM);
      do

          FORM='$FORM_list'
          CFOR=$FORM$l
          FNUM=`eval echo $CFOR`

          if [[ $FNUM != "" ]]; then
           #DIR=`echo $FNUM | cut -d ";" -f6`
           #BID=`echo $DIR | rev | cut -d '/' -f2 | rev`
           DIR=`echo $FNUM | awk -F";" {'print $6'}`
           BID=`echo $DIR  | awk -F"/" {'print $7'}`
           DLR=`echo $DIR  | sed "s/$BID\///"`
           DOW1=$URL$DIR$ARQ1
           DOW2=$URL$DIR$ARQ2

           wget $DOW1 -P $RLOCAL$DLR
           wget $DOW2 -P $RLOCAL$DLR
           echo $FNUM >> $RLOCAL$CARD
           echo $BID > $RLOCAL$DLR$BUIL

#DEBUG
#echo $FNUM
#echo $URL
#echo $RLOCAL
#echo $ARQ1
#echo $ARQ2
#echo $BUIL
#echo $CARD
#echo $DIR
#echo $BID
#echo $DLR
#echo $DOW1
#echo $DOW2
#echo $DOW1 -P $RLOCAL$DLR
#echo $DOW2 -P $RLOCAL$DLR

F5='<meta http-equiv="refresh" content="0;">'
echo $F5

          fi

       done
  fi

echo "</pre>"
