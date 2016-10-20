/usr/lib/cgi-bin/

luw-ini.sh  	Cria log acesso, invoca luw-tuser(permissão /etc/sudoers)  	Script
luw-mdc.sh	  Monitora Memoria, disco, cpu, container, usuário.	Script
luw-tuser.sh	- Cria usuário no linux, configura o perfil para utilização do LXC unprivilege. 
              - Configura ambiente web (LUW): public_html, cgi-bin, copia a base do luw.sh
              - Configura ssh para usuário criado.
              - Escreve script no /opt/luw/homesh/ para deletar usuário, agendando para excluir o usuário matando processos do mesmo. 	Script

/usr/lib/cgi-bin/luw-enter	

luw-enter.sh	Redirecionamento para página do usuário.	Script
