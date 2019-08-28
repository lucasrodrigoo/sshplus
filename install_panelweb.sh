#!/bin/bash
rm -rf $HOME/install_panelweb.sh
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;32m" [3]="\033[1;36m" [4]="\033[1;31m" [5]="\033[1;33m" )
barra="\033[0m\e[34m======================================================\033[1;37m"

fun_bar () {
comando="$1"
 _=$(
$comando > /dev/null 2>&1
) & > /dev/null
pid=$!
while [[ -d /proc/$pid ]]; do
echo -ne " \033[1;33m["
   for((i=0; i<10; i++)); do
   echo -ne "\033[1;31m##"
   sleep 0.2
   done
echo -ne "\033[1;33m]"
sleep 1s
echo
tput cuu1 && tput dl1
done
echo -e " \033[1;33m[\033[1;31m####################\033[1;33m] - \033[1;32m100%\033[0m"
sleep 1s
}

clear
echo -e "$barra"
echo -e " ${cor[5]}INSTALADOR DE RECURSOS ${cor[2]}[FULL SCRIPTS VPS]"
echo -e "$barra"
fun_bar "sudo apt-get update -y"
fun_bar "sudo apt-get upgrade -y"

panel_v10 () {
clear
IP=$(wget -qO- ipv4.icanhazip.com)
echo "America/Sao_Paulo" > /etc/timezone
ln -fs /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
dpkg-reconfigure --frontend noninteractive tzdata > /dev/null 2>&1
clear
echo -e "\E[44;1;37m           PAINEL SSHPLUS v10           \E[0m"
echo ""
echo -e "                \033[1;31mATENCION"
echo ""
echo -e "\033[1;32mINFORME SIEMPRE A MESMA SENHA"
echo -e "\033[1;32mSEMPRE CONFIRME A MESMA SENHA \033[1;37m Y"
echo ""
echo -e "\033[1;36mINICIANDO INSTALA플O"
echo ""
echo -e "\033[1;33mESPERE..."
apt-get update > /dev/null 2>&1
echo ""
echo -e "\033[1;36mINSTALANDO APACHE2\033[0m"
echo ""
echo -e "\033[1;33mESPERE..."
apt-get install apache2 -y > /dev/null 2>&1
sed -i "s;Listen 80;Listen 81;g" /etc/apache2/ports.conf
service apache2 restart > /dev/null 2>&1
apt-get install cron curl unzip -y > /dev/null 2>&1
echo ""
echo -e "\033[1;36mINSTALANDO DEPENDENCIAS\033[0m"
echo ""
echo -e "\033[1;33mESPERE..."
apt-get install php5 libapache2-mod-php5 php5-mcrypt -y > /dev/null 2>&1
service apache2 restart 
echo ""
echo -e "\033[1;36mINSTALANDO MySQL\033[0m"
echo ""
sleep 1
apt-get install mysql-server -y 
echo ""
clear
echo -e "                \033[1;31mATENCION"
echo ""
echo -e "\033[1;32mINFORME SEMPRE A MESMA SENHA QUANDO FOR SOLICITADO"
echo -e "\033[1;32mSEMPRE CONFIRME COM A MESMA SENHA  \033[1;37m Y"
echo ""
echo -ne "\033[1;33mEnter, Para Continuar!\033[1;37m"; read
mysql_install_db
mysql_secure_installation
clear
echo -e "\033[1;36mINSTALANDO PHPMYADMIN\033[0m"
echo ""
echo -e "\033[1;31mATENCION \033[1;33m!!!"
echo ""
echo -e "\033[1;32mSELECIONE LA OPCION \033[1;31mAPACHE2 \033[1;32mCON LA TECLA '\033[1;33mENTER\033[1;32m'"
echo ""
echo -e "\033[1;32mSELECIONE \033[1;31mYES\033[1;32m EN LA SIGUIENTE OPCION (\033[1;36mdbconfig-common\033[1;32m)"
echo -e "PARA CONFIGURAR LA BASE DE DATOS"
echo ""
echo -e "\033[1;32mSEMPRE CONFIRME COM A MESMA SENHA"
echo ""
echo -ne "\033[1;33mEnter, Para Continuar!\033[1;37m"; read
apt-get install phpmyadmin -y
php5enmod mcrypt
service apache2 restart
ln -s /usr/share/phpmyadmin /var/www/painel/phpmyadmin
apt-get install libssh2-1-dev libssh2-php -y > /dev/null 2>&1
apt-get install php5-curl > /dev/null 2>&1
service apache2 restart
clear
echo ""
echo -e "\033[1;31mATENCION \033[1;33m!!!"
echo ""
echo -ne "\033[1;32mCOLOQUE A MESMA SENHA\033[1;37m: "; read senha
echo -e "\033[1;32mOK\033[1;37m"
sleep 1
mysql -h localhost -u root -p$senha -e "CREATE DATABASE plus"
clear
echo -e "\033[1;36mFINALIZANDO INSTALA플O\033[0m"
echo ""
echo -e "\033[1;33mAGUARDE..."
echo ""
wget -O /var/www/index.html https://iptvhard.com/sshplus/index.html &> /dev/null
mkdir /var/www/painel
cd /var/www/painel
wget https://iptvhard.com/sshplus/painel10.zip > /dev/null 2>&1
sleep 1
unzip painel10.zip > /dev/null 2>&1
rm -rf painel10.zip index.html > /dev/null 2>&1
service apache2 restart
sleep 1
if [[ -e "/var/www/painel/pages/system/pass.php" ]]; then
sed -i "s;suasenha;$senha;g" /var/www/painel/pages/system/pass.php > /dev/null 2>&1
fi
sleep 1
cd
wget https://iptvhard.com/sshplus//plus.sql > /dev/null 2>&1
sleep 1
if [[ -e "$HOME/plus.sql" ]]; then
    mysql -h localhost -u root -p$senha --default_character_set utf8 plus < plus.sql
    rm /root/plus.sql
else
    clear
    echo -e "\033[1;31mERRO AO IMPORTAR BANCO DE DADOS\033[0m"
    sleep 2
    exit
fi
echo '* * * * * root /usr/bin/php /var/www/painel/pages/system/cron.php' >> /etc/crontab
echo '* * * * * root /usr/bin/php /var/www/painel/pages/system/cron.ssh.php ' >> /etc/crontab
echo '* * * * * root /usr/bin/php /var/www/painel/pages/system/cron.sms.php' >> /etc/crontab
echo '* * * * * root /usr/bin/php /var/www/painel/pages/system/cron.online.ssh.php' >> /etc/crontab
echo '10 * * * * root /usr/bin/php /var/www/painel/pages/system/cron.servidor.php' >> /etc/crontab
/etc/init.d/cron reload > /dev/null 2>&1
/etc/init.d/cron restart > /dev/null 2>&1
chmod 777 /var/www/painel/admin/pages/servidor/ovpn
chmod 777 /var/www/painel/admin/pages/download
chmod 777 /var/www/painel/admin/pages/faturas/comprovantes
service apache2 restart
sleep 1
clear
echo -e "\033[1;32mPAINEL INSTALADO COM EXITO!"
echo ""
echo -e "\033[1;36mLINK AREA DE ADMIN:\033[1;37m $IP:81/painel/admin\033[0m"
echo -e "\033[1;36mLINK AREA DE REVENDEDOR: \033[1;37m $IP:81/painel\033[0m"
echo -e "\033[1;36mUSUARIO\033[1;37m admin\033[0m"
echo -e "\033[1;36mCONTRASENA\033[1;37m admin\033[0m"
echo ""

echo -e "\033[1;36mINGRESSE NESTE LINK\033[0m"
echo -e "\033[1;37mwget http://ssh-plus.tk/revenda/confpainel/inst > /dev/null 2>&1; bash inst\033[0m"


echo -e "\033[1;33mTROQUE A CONTRA SENHA ENTRANDO EM\033[0m"
cat /dev/null > ~/.bash_history && history -c
}

panel_v11 () {
clear
IP=$(wget -qO- ipv4.icanhazip.com)
echo "America/Sao_Paulo" > /etc/timezone
ln -fs /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
dpkg-reconfigure --frontend noninteractive tzdata > /dev/null 2>&1
clear
echo -e "\E[44;1;37m           PANEL SSHPLUS v11          \E[0m"
echo ""
echo ""
echo -e "                \033[1;31mATEN플O"
echo ""
echo -e "\033[1;32mINTRODUZA A MESMA SENHA QUANDO SOLICITAR"
echo -e "\033[1;32mSEMPRE CONFIRME COM A MESMA SENHA \033[1;37m Y"
echo ""
echo -e "\033[1;36mINICIANDO INSTALA플O"
echo ""
echo -e "\033[1;33mESPERE..."
apt-get update > /dev/null 2>&1
echo ""
echo -e "\033[1;36mINSTALANDO O APACHE2\033[0m"
echo ""
echo -e "\033[1;33mESPERE..."
apt-get install apache2 -y > /dev/null 2>&1
sed -i "s;Listen 80;Listen 81;g" /etc/apache2/ports.conf
service apache2 restart > /dev/null 2>&1
apt-get install cron curl unzip -y > /dev/null 2>&1
echo ""
echo -e "\033[1;36mINSTALANDO DEPENDENCIAS\033[0m"
echo ""
echo -e "\033[1;33mESPERE..."
apt-get install php5 libapache2-mod-php5 php5-mcrypt -y > /dev/null 2>&1
service apache2 restart 
echo ""
echo -e "\033[1;36mINSTALANDO O MySQL\033[0m"
echo ""
sleep 1
apt-get install mysql-server -y 
echo ""
clear
echo -e "                \033[1;31mATENCION"
echo ""
echo -e "\033[1;32mINTRODUZA A MESMA SENHA QUANDO SOLICITADO"
echo -e "\033[1;32mSEMPRE CONFIRME A MESMA SENHA \033[1;37m Y"
echo ""
echo -ne "\033[1;33mEnter, Para Continuiar!\033[1;37m"; read
mysql_install_db
mysql_secure_installation
clear
echo -e "\033[1;36mINSTALANDO PHPMYADMIN\033[0m"
echo ""
echo -e "\033[1;31mATEN플O \033[1;33m!!!"
echo ""
echo -e "\033[1;32mSELECIONE A OP플O \033[1;31mAPACHE2 \033[1;32mCOM A TECLA '\033[1;33mENTER\033[1;32m'"
echo ""
echo -e "\033[1;32mSELECIONE \033[1;31mYES\033[1;32m NA SEGUINTE OP플O (\033[1;36mdbconfig-common\033[1;32m)"
echo -e "PARA CONFIGURAR O BANCO DE DADOS"
echo ""
echo -e "\033[1;32mSEMPRE COLOQUE A MESMA SENHA"
echo ""
echo -ne "\033[1;33mEnter, Para Continuar!\033[1;37m"; read
apt-get install phpmyadmin -y
php5enmod mcrypt
service apache2 restart
ln -s /usr/share/phpmyadmin /var/www/painel/phpmyadmin
apt-get install libssh2-1-dev libssh2-php -y > /dev/null 2>&1
apt-get install php5-curl > /dev/null 2>&1
service apache2 restart
clear
echo ""
echo -e "\033[1;31mATENA놦ON \033[1;33m!!!"
echo ""
echo -ne "\033[1;32mINFORME A MESMA SENHA\033[1;37m: "; read senha
echo -e "\033[1;32mOK\033[1;37m"
sleep 1
mysql -h localhost -u root -p$senha -e "CREATE DATABASE sshplus"
clear
echo -e "\033[1;36mFINALIZANDO INSTALA플O\033[0m"
echo ""
echo -e "\033[1;33mESPERE..."
echo ""
wget -O /var/www/index.html https://iptvhard.com/sshplus/index.html &> /dev/null
mkdir /var/www/painel
cd /var/www/painel
wget https://iptvhard.com/sshplus/PAINELWEB1.zip > /dev/null 2>&1
sleep 1
unzip PAINELWEB1.zip > /dev/null 2>&1
rm -rf PAINELWEB1.zip index.html > /dev/null 2>&1
service apache2 restart
sleep 1
if [[ -e "/var/www/painel/pages/system/pass.php" ]]; then
sed -i "s;suasenha;$senha;g" /var/www/painel/pages/system/pass.php > /dev/null 2>&1
fi
sleep 1
cd
wget https://iptvhard.com/sshplus/sshplus.sql > /dev/null 2>&1
sleep 1
if [[ -e "$HOME/sshplus.sql" ]]; then
    mysql -h localhost -u root -p$senha --default_character_set utf8 sshplus < sshplus.sql
    #rm /root/sshplus.sql
else
    clear
    echo -e "\033[1;31mERRO AO IMPORTAR BANCO DE DADOS\033[0m"
    sleep 2
    exit
fi
echo '* * * * * root /usr/bin/php /var/www/painel/pages/system/cron.php' >> /etc/crontab
echo '* * * * * root /usr/bin/php /var/www/painel/pages/system/cron.ssh.php ' >> /etc/crontab
echo '* * * * * root /usr/bin/php /var/www/painel/pages/system/cron.sms.php' >> /etc/crontab
echo '* * * * * root /usr/bin/php /var/www/painel/pages/system/cron.online.ssh.php' >> /etc/crontab
echo '10 * * * * root /usr/bin/php /var/www/painel/pages/system/cron.servidor.php' >> /etc/crontab
/etc/init.d/cron reload > /dev/null 2>&1
/etc/init.d/cron restart > /dev/null 2>&1
chmod 777 /var/www/painel/admin/pages/servidor/ovpn
chmod 777 /var/www/painel/admin/pages/download
chmod 777 /var/www/painel/admin/pages/faturas/comprovantes
service apache2 restart
sleep 1
clear
echo -e "\033[1;32mPAINEL INSTALADO COM EXITO!"
echo ""
echo -e "\033[1;36mLINK AREA ADMIN:\033[1;37m $IP:81/painel/admin\033[0m"
echo -e "\033[1;36mLINK AREA REVENDA: \033[1;37m $IP:81/painel\033[0m"
echo -e "\033[1;36mUSUARIO\033[1;37m admin\033[0m"
echo -e "\033[1;36mSENHA\033[1;37m admin\033[0m"
echo -e "\033[1;33mTROQUE A SENHA APOS ENTRAR NO PAINEL\033[0m"
cat /dev/null > ~/.bash_history && history -c
}

remove_panel () {
clear
echo -e "$barra"
echo -e "\033[1;32m SEMPRE CONFIRME COM A LETRA \033[1;37mY"
echo -e "\033[1;32m QUANDO SOLICITADO PROSSIGA COM \033[1;37mENTER"
echo -e "$barra"
sleep 7
sudo apt-get purge mysql-server mysql-client mysql-common mysql-server-core-* mysql-client-core-*
sudo rm -rf /etc/mysql /var/lib/mysql
sudo apt-get autoremove
sudo apt-get autoclean
sudo rm -rf /var/www/painel
mkdir /var/www/painel
touch /var/www/painel/index.html
apt-get install apache2  > /dev/null 2>&1
sed -i "s;Listen 80;Listen 81;g" /etc/apache2/ports.conf
service apache2 restart > /dev/null 2>&1
echo -e "$barra"
echo -e "\033[1;36mPAINEL SSHPLUS ELIMINADO COM EXITO \033[1;32m[!OK]"
echo -e "$barra"
}

gestor_fun () {
echo -e "$barra"
echo -e " ${cor[3]} PAINEL SSHPLUS ${cor[2]}[INSTALADOR]"
echo -e "$barra"
while true; do
echo -e "${cor[2]} [1] > ${cor[3]}SSHPLUS V10 VENTAS"
echo -e "${cor[2]} [2] > ${cor[3]}SSHPLUS V11 VENTAS"
echo -e "${cor[2]} [3] > ${cor[3]}ELIMINAR PANEL SSHPLUS"
echo -e "${cor[2]} [0] > ${cor[3]}VOLTAR \n${barra}"
while [[ ${opx} != @(0|[1-3]) ]]; do
echo -ne "${cor[0]}Digite a Opcao: \033[1;37m" && read opx
tput cuu1 && tput dl1
done
case $opx in
	0)
	return;;
	1)
	panel_v10
	break;;
	2)
	panel_v11
	break;;
	3)
	remove_panel
	break;;
esac
done
}
gestor_fun