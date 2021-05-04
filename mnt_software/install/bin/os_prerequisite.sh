. /mnt/software/install/bin/env.sh $(basename $BASH_SOURCE)
run_as_root

yum install binutils -y
yum install compat-libcap1 -y
yum install compat-libstdc++-33 -y
yum install compat-libstdc++-33.i686 -y
yum install gcc -y
yum install gcc-c++ -y
yum install glibc -y
yum install glibc.i686 -y
yum install glibc-devel -y
yum install glibc-devel.i686 -y
yum install libaio -y
yum install libaio-devel -y
yum install libgcc -y
yum install libgcc.i686 -y
yum install libstdc++ -y
yum install libstdc++.i686 -y
yum install libstdc++-devel -y
yum install ksh -y
yum install make -y
yum install sysstat -y
yum install ocfs2-tools -y
yum install motif -y
yum install motif-devel -y
yum install numactl -y
yum install numactl-devel -y
# xsltproc
yum install libxslt -y
# killall
yum install psmisc -y
# patch
yum install patch -y

# Open port in firewalld
systemctl disable firewalld
systemctl stop firewalld

# certbot
# https://certbot.eff.org/lets-encrypt/centosrhel7-apache.html
yum install snapd -y
systemctl enable --now snapd.socket
systemctl start --now snapd.socket
ln -s /var/lib/snapd/snap /snap
snap install core 
snap refresh core
snap install --classic certbot
ln -s /snap/bin/certbot /usr/bin/certbot
