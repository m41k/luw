#!/bin/bash

#Em desenvolvimento

eval `/opt/luw/proccgi $*`

echo -e "Content-type: text/html\n\n"

proc=`echo $0 | rev | cut -d / -f1 | rev`


#if [ $FORM_senha = "123" ]; then
#else
#echo $REMOTE_USER
echo "<table border='0' width='100%' height='100%'>"
echo "<tr height='10%'>"
echo "<td>"
 cat <<FDA
  <form method='post' action='$proc'>
        <input type='submit' name='enter' value='Passwd'>
   </form>
FDA
echo "</td>"
echo "</tr>"
echo "</tr>"
echo "<td>"
echo "<iframe src=luw-mdc.sh frameborder='0' width='100%' height='100%'></iframe>"
echo "</td>"
echo "</tr>"


#fi
