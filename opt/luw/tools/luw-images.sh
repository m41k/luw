#!/bin/bash
#--------------------------------------------------------------------------------#
#                  LUW-IMAGES - GERENCIAMENTO DE IMAGES                          #
#                  CREATED BY: maik.alberto@hotmail.com                          #
#--------------------------------------------------------------------------------#
eval `/opt/luw/proccgi $*`

echo -e "Content-type: text/html\n\n"

if [[ $REMOTE_USER != "luw-adm" ]]; then
 echo "<b>ACESSO RESTRITO</b>"
 exit 0
fi

if [[ $REMOTE_USER != "luw-adm" ]]; then
 echo "<b>ACESSO RESTRITO</b>"
 exit 0
fi

#CONFIGURACAO
URL="https://us.images.linuxcontainers.org"
#RLOCAL="/tmp/repo"
RLOCAL="/opt/luw/repo/"
CARD="/cardapio.luw"
ARQ1="meta.tar.xz"
ARQ2="rootfs.tar.xz"
BUIL="build_id"
META="/meta/1.0"
INDX="/index-user"
F5='<meta http-equiv="refresh" content="0;">'

#ATAULIZADO LISTA DISPONIVEL PARA DOWNLOAD
rm -rf $RLOCAL$INDX
wget $URL$META$INDX -P $RLOCAL

#VERICACAO EXISTENCIA CARDAPIO && ORDENA OU CRIA
#[ -e $RLOCAL$CARD ] || > $RLOCAL$CARD
[ -e $RLOCAL$CARD ] && sort $RLOCAL$CARD -o $RLOCAL$CARD || > $RLOCAL$CARD
#[ -e lista ] && sort lista -o lista || > lista

#DIFERENCA ENTRE REPOSITORIO LOCAL E DISPONIVEIS PARA DOWNLOAD
#diff cardapio.luw index-user | grep ">" | tr -d ">" | tail -n +2
DISP=`diff $RLOCAL$CARD $RLOCAL$INDX | grep ">" | tr -d ">"`
#DISP=`diff $RLOCAL$CARD $RLOCAL$INDX | grep "[<>]" | tr -d "<>"`
#LISTA DOS BAIXADOS
BAIX=`cat $RLOCAL$CARD`
#BAIX=`sort $RLOCAL$CARD > $RLOCAL/scard`
#BAIX2=`cat $RLOCAL/scard`

#--------------------------------------------------------------------------------#
#                              CARPADIO LOCAL                                    #
#--------------------------------------------------------------------------------#

printf "<pre>"
printf "<b><u>Distros Repositorio Local</u></b>"
printf "<hr>"
printf "<form method='post' action='$proc'>"

	LNUM=1
	for LLOCAL in $BAIX
	do
#         echo "<input type='checkbox' name='LLOCAL$NUM' value='$LLOCAL'>" $LLOCAL
	  ALLOCAL[$LNUM]=$LLOCAL
#         echo $LNUM "<input type='submit' name='del$LNUM' value='Del'>" $LLOCAL
          echo "<input type='submit' name='del$LNUM' value='Del'>" $LLOCAL

	   LNUM=`expr $LNUM + 1`
	done

printf "<br>"

#--------------------------------------------------------------------------------#
#                              CARPADIO REMOTO                                    #
#--------------------------------------------------------------------------------#
printf "<b><u>Distros Disponiveis para Download</u></b>"
#echo "Distros Disponives para download"
printf "<hr>"

	NUM=1
	for line in $DISP
	do
#	   echo $NUM "<input type='checkbox' name='list$NUM' value='$line'>" $line
	   echo "<input type='checkbox' name='list$NUM' value='$line'>" $line
	   NUM=`expr $NUM + 1`
	done

#echo "<hr>"
#echo "<input type='checkbox' name='confirma' value='on'>" Desejo baixar "<input type='submit' name='ok' value='ok'>"
printf "<hr>"
echo "<input type='submit' name='download' value='download'>"
printf "</form>"

#--------------------------------------------------------------------------------#
#                       BOTAO DEL - APAGA DISTRO LOCAL                           #
#--------------------------------------------------------------------------------#

    for t in $(seq $LNUM);
      do
 	  FORM1='$FORM_del'
	  CFOR1=$FORM1$t
	  FNUM1=`eval echo $CFOR1`
         if [[ $FNUM1 != "" ]]; then
#APAGANDO NO CARDAPIO
         sed -i $(echo $t)d $RLOCAL$CARD
#APAGANDO NO REPOSITORIO
	  DIR=`echo ${ALLOCAL[t]} | awk -F";" {'print $6'}`
          BID=`echo $DIR  | awk -F"/" {'print $7'}`
          DIR=`echo $DIR  | sed "s/$BID\///"`
	  rm -rf $RLOCAL$DIR
#TESTE EXIBICAO
#          echo ${ALLOCAL[t]}
#REFRESH PAGE
           echo $F5
         fi
      done

#--------------------------------------------------------------------------------#
#                       BOTAO DOWNLOAD - BAIXAR DISTRO                           #
#--------------------------------------------------------------------------------#

# if [ $FORM_confirma = "on" ]; then
 if [ $FORM_download = "download" ]; then
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

	   wget $DOW1 -P $RLOCAL$DLR && echo $FNUM >> $RLOCAL$CARD
           wget $DOW2 -P $RLOCAL$DLR && echo $BID > $RLOCAL$DLR$BUIL

#REFRESH PAGE
           echo $F5

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
          fi

       done
  fi

echo "</pre>"
