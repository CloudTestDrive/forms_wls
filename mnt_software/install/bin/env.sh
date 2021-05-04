#----------------------------------------------------------------------------
# Script  : env.sh
# Version : 1.0
# Author : mgueury 
# Description: environment variables (normally no harcoded values)
#----------------------------------------------------------------------------

if [ ! -z "$INSTALL_DIR" ]; then
  echo "Env variables already set"
else
  # Options
  # export INSTALL_WEBUTIL=true
  # export INSTALL_DNS=true

  export INSTALL_DIR=/mnt/software/install
  
  export ORACLE_BASE=/u01
  export ORACLE_SOFTWARE=$ORACLE_BASE/app/oracle
  export MIDTIER_HOME=$ORACLE_SOFTWARE/middleware
  export PATH=$INSTALL_DIR/bin:$PATH:$MIDTIER_HOME/bin
  export WLST_HOME=$MIDTIER_HOME/oracle_common/common/bin
  export ORACLE_HOME=$MIDTIER_HOME   
  
  export WLS_INSTALL_MODE="WLS_MARKETPLACE"
  . /opt/scripts/restart/setEnv.sh
  export PREFIX=$(python /opt/scripts/databag.py service_name_prefix)
  export IS_ADMIN_INSTANCE=$(python /opt/scripts/databag.py is_admin_instance)
  export DB_PASSWORD=$(python /opt/scripts/wls_credentials.py dbPassword)  
  export ADM_PWD=$WLS_PASSWORD
  export ADM_USER=$WLS_ADMIN_USER
  export DOMAIN_NAME=$WLS_DOMAIN_NAME
  export WLS_DOMAIN_PATH=$WLS_DOMAIN_HOME
  export WLS_PREFIX=`echo $WLS_DOMAIN_NAME | awk '{split($0,a,"_"); print a[1]}'`
  export wls_adminHost
  export wls_adminPort
  export wls_msserverName
  export LOADBALANCER_HOSTNAME=`python $INSTALL_DIR/bin/get_loadbalancer_ip.py`
  export FORMS_INSTANCE=forms_${wls_msserverName}

  if [ $IS_ADMIN_INSTANCE == 'true' ]; then
     export wls_msserverName="WLS_FORMS"
     export FORMS_INSTANCE="forms1"
  fi
  export RCU_PREFIX=`cd /opt/scripts;python -c "import db; print db.get_schema_prefix()"`
  
  # XXXX to improve
  export DB_PREFIX=$PREFIX
  # XXXX
  if [[ $INSTALL_MODE = "DBCS" ]]; then
    export DB_USER=SYSTEM
    export DB_SID=pdb1
    export DB_BASE="${DB_PREFIX}db.${DB_PREFIX}subnet.${DB_PREFIX}vcn.oraclevcn.com:1521/${DB_SID}.${DB_PREFIX}subnet.${DB_PREFIX}vcn.oraclevcn.com"
    export DB_URL="jdbc:oracle:thin:@//${DB_BASE}"
    # export DB_URL=jdbc:oracle:thin:@pdb1?TNS_ADMIN=${ORACLE_HOME}/network/admin
  else 
    export DB_USER=ADMIN
    export DB_SID=$(python /opt/scripts/databag.py db_name)_tp  
    export TNS_ADMIN=/u01/app/oracle/private/wallet
    export DB_URL=jdbc:oracle:thin:@${DB_SID}?TNS_ADMIN=${TNS_ADMIN}
  fi
fi
cd $INSTALL_DIR

# If one parameter is given, show a title
if [ "$#" -eq 1 ]; then
  echo "#############################################################################"
  echo "$1"
  echo "#############################################################################"
  echo
  . time.sh
fi

function title() {
  echo "======== $1 ========" 
}

function run_as_root() {
  if [[ $(id -u) -ne 0 ]] ; then
    echo "Please run as root"  
    echo "$(id -u)"  
    exit
  else
    echo "Verifying: Root user: OK"  
  fi
}
