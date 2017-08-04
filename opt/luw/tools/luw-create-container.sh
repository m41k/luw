#!/bin/zsh
#--------------------------------------------------------------------------------#
#           LUW-CREATE-CONTAINER - MODULE CRIACAO CONTAINER                      #
#               CREATED BY: maik.alberto@hotmail.com                             #
#--------------------------------------------------------------------------------#

case $1 in

 new)
        DISTROS=(`cat /opt/luw/repo/cardapio.luw | awk -F";" {'print $1"_"$2"_"$3'}`)
        VFLAVOR=$(head -1 /opt/luw/config/flavor)
#FORM PARA CRIACAO DE CONTAINER
        echo "<form method='post' action='$luw'>"
        echo "<h2>Novo Container</h2>"
        echo "Name:"
        echo " <input type='text' name='NCONT' maxlength='50' size='30'>"
        echo "Distro:"
#SELECT DISTRO
        echo "<select name='DCONT'>"
         for (( D=1; D<=${#DISTROS[@]}; D++ ))
          do
           echo "<option value=$DISTROS[$D]>$DISTROS[$D]"
         done
        echo  "</select>"
#SELECT FLAVOR - MEM
       if [[ $VFLAVOR = "enable" ]]; then
        LFLAVOR=(`tail -n +2 /opt/luw/config/flavor`)
        echo "Flavor:"
        echo "<select name='FLAVOR'>"
         for (( F=1; F<=${#LFLAVOR[@]}; F++ ))
          do
           echo "<option value=$LFLAVOR[$F]>$LFLAVOR[$F]"
         done
        echo "</select>"
        fi
        echo  "<input type='submit' value='Criar'>"
        echo  "</form>"
 ;;
 
 create)
         if  echo $FORM_NCONT | grep '[^[:alnum:]]' > /dev/null; then
                source ./luw-create-container.sh new
                echo "<font color=red size=2><b>Invalid name. Use alphanumeric characters only.</b></font>"
                exit 0
         else
                CONTNAME=$FORM_NCONT
                DISTRO=`echo $FORM_DCONT | awk -F_ {'print $1'}`
                RELEASE=`echo $FORM_DCONT | awk -F_ {'print $2'}`
                ARQUIT=`echo $FORM_DCONT | awk -F_ {'print $3'}`
                echo "<pre>"
#UTILIZANDO CACHE - REPO LOCAL
                eval mkdir -p $HOME/.cache/lxc/download/$DISTRO/$RELEASE/$ARQUIT/default/
                eval cp /opt/luw/repo/images/$DISTRO/$RELEASE/$ARQUIT/default/* $HOME/.cache/lxc/download/$DISTRO/$RELEASE/$ARQUIT/default/
                eval tar -Jxf $HOME/.cache/lxc/download/$DISTRO/$RELEASE/$ARQUIT/default/meta.tar.xz -C $HOME/.cache/lxc/download/$DISTRO/$RELEASE/$ARQUIT/default/
#DEBUG  echo "$ssh lxc-create -t download -n $CONTNAME -- -d $DISTRO -r $RELEASE -a $ARQUIT 2> /dev/null"
                eval $ssh lxc-create -t download -n $CONTNAME -- -d $DISTRO -r $RELEASE -a $ARQUIT 2> /dev/null
                echo "</pre>"
#CONFIGURANDO MEMORIA CONTAINER
                echo 'lxc.cgroup.memory.limit_in_bytes = '$FORM_FLAVOR >> ~/.local/share/lxc/$FORM_NCONT/config
#LOG CRIACAO DE CONTAINER
                LOGCREATE=/opt/luw/log/creation
                echo $REMOTE_USER $CONTNAME $DISTRO $RELEASE $ARQUIT >> $LOGCREATE
#LIMPEZA CACHE DE MEMORIA
        sudo /opt/luw/tools/luw-fw.sh -clm > /dev/null
 fi

 ;;

esac
