#!/bin/bash

rodared='<meta http-equiv="refresh" content="0;url=http://'$SERVER_NAME:$SERVER_PORT'/~'$REMOTE_USER'/cgi-bin/luw.sh">'
echo "Content-type: text/html"
echo ""
echo $rodared
