#----------------------------------------------------------------------------
# Script  : build_install.sh
# Version : 1.0
# Author : mgueury 
# Description: creation of the build compute
#----------------------------------------------------------------------------

. /mnt/software/install/bin/env.sh $(basename $BASH_SOURCE)
run_as_root

echo '########## basic webserver ##############'
yum install httpd -y
yum install mod_ssl -y
systemctl enable  httpd.service
firewall-offline-cmd --add-service=http
firewall-offline-cmd --add-service=https
systemctl enable firewalld
systemctl restart firewalld

echo '########## XWindows ##############'

# Stop Firewall
. time.sh
systemctl stop firewalld
systemctl disable firewalld

# create oracle user
$INSTALL_DIR/bin/oracle_user_root.sh

if [ $INSTALL_DNS == 'true' ]; then
# certbot
cat <<EOT > /etc/httpd/conf.d/build.conf
<VirtualHost *:80>
  ServerName ${PREFIX}build.orablog.org
</VirtualHost>
EOT
  systemctl restart  httpd.service
  certbot --apache --non-interactive --agree-tos --domains ${PREFIX}build.orablog.org --email mgueury@skynet.be
fi

# To debug with VNC
yum groupinstall "Server with GUI" -y
yum install tigervnc-server -y

title "Set VNC password" 
cat <<EOT > /tmp/vnc 
$VNC_PASSWORD
$VNC_PASSWORD
n
EOT
vncpasswd < /tmp/vnc
sleep 1
title "Starting VNC"
# Start it this way to set the env variable correctly
# su -c "vncserver" - root
cp /lib/systemd/system/vncserver@.service  /etc/systemd/system/vncserver@\:1.service 
# Set the user to Root and home to /root
sed -i 's/<USER>/root/' /etc/systemd/system/vncserver@\:1.service 
sed -i 's/\/home\/root/\/root/' /etc/systemd/system/vncserver@\:1.service 
sed -i 's/\/bin\/sh/\/usr\/bin\/bash/' /etc/systemd/system/vncserver@\:1.service 
systemctl daemon-reload
systemctl enable vncserver@:1
systemctl status vncserver@:1
systemctl start vncserver@:1

# su -c "vncpasswd < /tmp/vnc" - oracle
# su -c "vncserver" - oracle
# rm /tmp/vnc

title "Install Desktop Icon"
mkdir /root/Desktop
cp $INSTALL_DIR/soa_quickstart/jdev.desktop /root/Desktop/.
# Trust the icon
dbus-launch gio set /root/Desktop/jdev.desktop "metadata::trusted" yes

title "Install SOA Quickstart - Hello World project and connection"
cd $ORACLE_BASE
tar xfz $INSTALL_DIR/soa_quickstart/jdeveloper.tgz

