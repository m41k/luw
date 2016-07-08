#!/bin/bash

rodared='<meta http-equiv="refresh" content="0;url=http://'$SERVER_NAME'/~'$REMOTE_USER'/cgi-bin/luw.sh">'
echo "Content-type: text/html"
echo ""
echo $rodared
