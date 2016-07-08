#!/bin/bash

echo "Content-type: text/html"
echo ""

puser=$(echo $REQUEST_URI | cut -d "~" -f2 | cut -d "/" -f1)
#echo '<br>'
#echo $SCRIPT_NAME | cut -d "~" -f2 | cut -d "/" -f1
if [ $puser != $REMOTE_USER ];
  then

rodared='<meta http-equiv="refresh" content="0;url=http://'$SERVER_NAME'/~'$REMOTE_USER'/cgi-bin/ceu.sh">'
echo "Content-type: text/html"
echo ""
echo $rodared

  else
#   /usr/lib/cgi-bin/ccc.sh
   /usr/lib/cgi-bin/duv.sh
#   /usr/lib/cgi-bin/reload.sh


fi


exit 0

