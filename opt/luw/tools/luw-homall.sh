#!/bin/bash
#--------------------------------------------------------------------------------#
#	 	      LUW-HOMALL - Luw.sh updates for all users                  #
#               	CREATED BY: maik.alberto@hotmail.com                     #
#--------------------------------------------------------------------------------#
#!/bin/bash
#cp /home/ubuntu/public_html/cgi-bin/luw.sh /opt/luw/luw.sh
user=(${user[@]}`ls /home`)
#echo ${user[1]}
tuser=${#user[@]}
for (( u=0; u<$tuser; u++ ))
 do
  esse=${user[$u]}
  cp /opt/luw/luw.sh /home/$esse/public_html/cgi-bin/
  chown $esse:$esse /home/$esse/public_html/cgi-bin/luw.sh
 done
