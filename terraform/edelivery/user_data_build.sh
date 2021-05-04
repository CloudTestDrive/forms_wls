#!/bin/bash -x
echo '################## mount NFS share #################'
sudo yum install nfs-utils
sudo mkdir -p /mnt/software
sudo mount ${mount_ip_adress}:/software /mnt/software
sudo chmod 777 /mnt/software

echo '################## copy files ######################'

cd /mnt/software
unzip /tmp/mnt_software.zip
mv mnt_software/* .
rmdir mnt_software
find -type d -exec chmod 755 {} \;
find -type f -exec chmod 644 {} \;
find . -name "*.sh" -exec chmod 755 {} \;
mkdir backup
chown -R opc:opc /mnt/software
mkdir share
chown -R oracle:oracle share
cd $HOME

echo '################## install_build.sh #################'
touch ~opc/build.`date +%F-%H-%M-%S`.start
/mnt/software/install/bin/build_install.sh > /home/opc/build_install.log 2>&1

touch ~opc/build.`date +%F-%H-%M-%S`.finish
