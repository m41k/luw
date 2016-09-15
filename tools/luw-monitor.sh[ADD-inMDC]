#!/bin/bash
#--------------------------------------------------------------------------------#
#    		   LUW-MONITOR - verify containers in use		         #
#                   CREATED BY: maik.alberto@hotmail.com                         #
#--------------------------------------------------------------------------------#

if [ -z $1 ]; then
 	user=""
else
	user="| grep $1"
fi

	cont=`ps -aux | grep "lxc monitor" | wc -l`
	total=`expr $cont - 1`
	cmd="ps -aux | grep 'lxc monitor' | head -4 $user"
        eval $cmd
