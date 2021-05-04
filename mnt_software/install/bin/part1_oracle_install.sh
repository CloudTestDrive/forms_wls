#----------------------------------------------------------------------------
# Script  : part1_oracle_install.sh
# Version : 1.0
# Author : mgueury 
# Description: Install FMW. Tested with forms/ohs/client/infrastructure/soa/osb
# Idea from : https://oracle-base.com/articles/12c/weblogic-silent-installation-12c
#----------------------------------------------------------------------------

. /mnt/software/install/bin/env.sh $(basename $BASH_SOURCE)

if [ $# -ne 1 ]; then
  echo "Usage: part1_oracle_install.sh <INSTALL_TYPE=infrastructure/ohs/soa/osb>"
  exit
fi
INSTALL_TYPE=$1
echo "Parameter: $INSTALL_TYPE"

# RunInstaller
if [ $INSTALL_TYPE == "forms" ]; then
  /mnt/software/edelivery/forms/fmw_12.2.1.4.0_fr_linux64.bin -silent -responseFile $INSTALL_DIR/forms/forms.rsp -invPtrLoc $ORACLE_BASE/midtier.loc
elif [ $INSTALL_TYPE == "ohs" ]; then
  /mnt/software/ohs/fmw_12.2.1.4.0_ohs_linux64.bin -silent -responseFile $INSTALL_DIR/ohs/ohs.rsp -invPtrLoc $ORACLE_BASE/midtier.loc
elif [ $INSTALL_TYPE == "client" ]; then
  /mnt/software/edelivery/db_client/client/runInstaller -silent -waitforcompletion -responseFile $INSTALL_DIR/database/client.rsp -invPtrLoc $ORACLE_BASE/client.loc
else
  $JAVA_HOME/bin/java -Xmx1024m -jar /mnt/software/edelivery/${INSTALL_TYPE}/fmw_12.2.1.4.0_${INSTALL_TYPE}.jar -silent -responseFile ${INSTALL_DIR}/${INSTALL_TYPE}/${INSTALL_TYPE}.rsp -invPtrLoc $ORACLE_BASE/midtier.loc
fi

### Apply patches 
if [ $INSTALL_TYPE == "forms" ]; then
  # 30613424 - EM login page shows a blank screen in a certain FMW configuration scenarios
  # 31225296 - FADS DEPLOYMENT IS FAILING WHEN USING DBAS LONG CONNECT STRING IN TNSNAMES.ORA FILE
  export ORACLE_HOME=$MIDTIER_HOME
  $ORACLE_HOME/OPatch/opatch apply -silent $INSTALL_DIR/patches/p30613424_122140_Generic.zip
  $ORACLE_HOME/OPatch/opatch apply -silent $INSTALL_DIR/patches/p31225296_122140_Generic.zip
fi
