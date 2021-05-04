#!/bin/bash
#----------------------------------------------------------------------------
# Script  : force_drop_rcu.sh
# Version : 1.0
# Author : mgueury 
# Description: force_drop_rcu
#----------------------------------------------------------------------------
# set -x
. /mnt/software/install/bin/env.sh $(basename $BASH_SOURCE)

if [ ! -z $RCU_PREFIX ]; then
  cp /u01/app/oracle/private/wallet/* $ORACLE_HOME/network/admin/.
  export ORAENV_ASK=NO
  export ORACLE_SID=mid12
  . oraenv
  unset ORAENV_ASK
  echo ORACLE_HOME=$ORACLE_HOME
  echo RCU_PREFIX=$RCU_PREFIX
  sqlplus $DB_USER/$DB_PASSWORD@$DB_SID @rcu/force_drop_rcu.sql $RCU_PREFIX
fi  