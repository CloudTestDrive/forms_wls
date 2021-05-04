#----------------------------------------------------------------------------
# Script  : part1_root_install.sh
# Version : 2.0
# Author : mgueury 
# Description: Install FMW. Tested with forms/ohs/client/infrastructure/soa/osb
# Ideas from: https://oracle-base.com/articles/12c/oracle-forms-and-reports-12c-silent-installation-on-oracle-linux-6-and-7
#----------------------------------------------------------------------------

. /mnt/software/install/bin/env.sh $(basename $BASH_SOURCE)
run_as_root

if [ $# -ne 1 ]; then
  echo "Usage: part1_root_install.sh <INSTALL_TYPE=forms/soa/osb>"
  exit
fi
export INSTALL_TYPE=$1
echo "part1_root_install.sh"
echo " - INSTALL_TYPE=$INSTALL_TYPE"

# OS setup
os_prerequisite.sh
su -c "/mnt/software/install/bin/oracle_user_oracle.sh" - oracle

# Inventory files
title 'Create inventory loc file for ORACLE_HOME'
cat >> $ORACLE_BASE/midtier.loc <<ABC
inventory_loc=$ORACLE_BASE/app/oraInventory
inst_group=oracle
ABC

# INSTALL_FORMS
. time.sh
FILE=/mnt/software/backup/${INSTALL_TYPE}_12214.tgz
if [ ! -f "$FILE" ]; then
  title "Install $INSTALL_TYPE"
  su -c "$INSTALL_DIR/bin/part1_oracle_install.sh $INSTALL_TYPE" - oracle
  
  title 'Create backup'
  cd /u01
  tar cpfz app.tgz app
  cp app.tgz $FILE
else
  cd /u01
  title 'Restore from backup'
  tar xpfz $FILE
fi
cd $INSTALL_DIR
. time.sh

if [ -f $ORACLE_HOME/root.sh ]; then
  $ORACLE_HOME/root.sh -silent
fi

# RCU_PREFIX (used by /opt/scripts/db.prefix)
# - Remove it if it was by accident added in the backup file
title 'Reset RCU PREFIX'
chown oracle /u01/app/oracle/private/
rm /u01/app/oracle/private/schemaPrefix

# /etc/oratab
cat forms/oratab >> /etc/oratab

if [ $IS_ADMIN_INSTANCE == 'true' ]; then
  title 'Force drop the RCU'
  # Force drop the RCU, it seems to stay between 2 terraforms apply
  su -c "/mnt/software/install/bin/force_drop_rcu.sh $RCU_PREFIX" - oracle 
else 
  title 'Create Wallet Directory'
  mkdir -p /u01/app/oracle/private/wallet
  chown oracle /u01/app/oracle/private/wallet
fi

# Install Let'Encrypt Certbot
# certbot --apache --non-interactive --agree-tos --domains ${PREFIX}lb.orablog.org --email mgueury@skynet.be

# Patch util
su -c "patch-utils setup -r eu-frankfurt-1 -m /u01/app/oracle/middleware" - opc

. time.sh
title "DONE"