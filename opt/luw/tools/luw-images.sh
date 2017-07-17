#!/bin/bash
#--------------------------------------------------------------------------------#
#                  LUW-IMAGES - GERENCIAMENTO DE IMAGES                          #
#                  CREATED BY: maik.alberto@hotmail.com                          #
#--------------------------------------------------------------------------------#
eval `/opt/luw/proccgi $*`

echo -e "Content-type: text/html\n\n"
echo "<h2>Distros a serem disponibilizadas</h2>"
echo "<pre>"
echo "<form method='post' action='$proc'>"

LISTA=`wget -qO- https://us.images.linuxcontainers.org/meta/1.0/index-user`
NUM=1
        for line in $LISTA
        do
           #echo $NUM "<input type='checkbox' name='list$NUM' value='$line'>" $line
           echo "<input type='checkbox' name='list$NUM' value='$line'>" $line
           NUM=`expr $NUM + 1`
        done

echo "<hr>"
echo "<input type='checkbox' name='confirma' value='on'>" Desejo baixar "<input type='submit' name='ok' value='ok'>"
echo "<hr>"
echo "</form>"

 if [[ $FORM_confirma = "on" ]]; then
    for l in $(seq $NUM);
      do

          FORM='$FORM_list'
          CFOR=$FORM$l
          FNUM=`eval echo $CFOR`

          if [[ $FNUM != "" ]]; then
           echo $FNUM
          fi
       done
  fi

echo "</pre>"
