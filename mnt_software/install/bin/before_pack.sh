#----------------------------------------------------------------------------
# Script  : before_pack.sh
# Version : 2.0
# Author : mgueury 
# Description: Install FMW. Tested with forms/ohs/client/infrastructure/soa/osb
#----------------------------------------------------------------------------

. /mnt/software/install/bin/env.sh $(basename $BASH_SOURCE)

if [ $# -ne 2 ]; then
  echo "Usage: before_pack.sh server_name machine_name"
  exit
fi

export SERVER_NAME=$1
export MACHINE_NAME=$2

${WLST_HOME}/wlst.sh ${INSTALL_DIR}/domain/before_pack.py > /u01/logs/before_pack.log 2>&1