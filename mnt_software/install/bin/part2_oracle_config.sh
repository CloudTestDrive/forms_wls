. /mnt/software/install/bin/env.sh $(basename $BASH_SOURCE)

. time.sh

### Correct the domains after the extension to a new machine
# - $WLS_DOMAIN_PATH/config/fmwconfig/components and the wallet are not copied by pack/unpack
cd $WLS_DOMAIN_PATH/config/fmwconfig
if [ $IS_ADMIN_INSTANCE == 'true' ]; then
  echo "AdminServer"
  # During the adminserver creation take a backup of components
  tar cfz /mnt/software/share/${PREFIX}_components.tgz components
  # Save the wallet to the share
  cd /u01/app/oracle/private
  tar cfz /mnt/software/share/${PREFIX}_wallet.tgz wallet
else
  echo "ManagedServer"
  # The component directory is missing. Copy it.
  tar xfz /mnt/software/share/${PREFIX}_components.tgz
  # The instance "forms_${wls_msserverName}" is not created neither
  cp -R components/FORMS/instances/forms1 components/FORMS/instances/forms_${wls_msserverName}
  # Copy the wallet
  cd /u01/app/oracle/private
  tar xfz /mnt/software/share/${PREFIX}_wallet.tgz
fi
cp /u01/app/oracle/private/wallet/* $ORACLE_HOME/network/admin/.

### Domain 
# Create the WLS Domain
if [ $IS_ADMIN_INSTANCE == 'true' ]; then
   echo "AdminServer"
   # Create scott user in DB
   cd $INSTALL_DIR
   sqlplus $DB_USER/$DB_PASSWORD@$DB_SID @forms/dept.sql $DB_PASSWORD $DB_SID
   # Create webutil in DB
   cd $MIDTIER_HOME/forms
   sqlplus scott/$DB_PASSWORD@$DB_SID @create_webutil_db.sql
else
   # The ADMIN_URL is created in HTTPS and not working when starting the managed server a second time... ?
   # Replace by the HTTP port
   echo "ManagedServer"
   sed -i "s#ADMIN_URL=.*#ADMIN_URL='http://${wls_adminHost}:${wls_adminPort}'#" $WLS_DOMAIN_PATH/bin/startManagedWebLogic.sh
fi


### Restart 
# /opt/scripts/restart_domain.sh
# . time.sh

### Forms sample 
cd $INSTALL_DIR
cp forms/*.fmb $MIDTIER_HOME/forms/.
cd $MIDTIER_HOME/forms
export TERM=vt220
for FILE in `ls *.pll`; do
  echo "PLL: $FILE"
  frmcmp_batch module=${FILE} module_type=LIBRARY compile_all=special userid=scott/$DB_PASSWORD@$DB_SID
done
for FILE in `ls *.fmb`; do
  echo "FMB: $FILE"
  frmcmp_batch module=${FILE} userid=scott/$DB_PASSWORD@$DB_SID
done
. time.sh

#### Webutil ####
# See Note 2070183.1
# Put this as optional, since it uses a self signed certificate to sign jacob.jar
# as consequence, we need to configure the java client with that certificate 
if [ $INSTALL_WEBUTIL == 'true' ]; then
  cd /tmp
  # Download jacob.jar and dlls
  wget https://github.com/freemansoft/jacob-project/releases/download/Root_B-1_20/jacob-1.20.zip
  unzip jacob-1.20.zip 
  cp jacob-1.20/jacob-1.20-x86.dll $MIDTIER_HOME/forms/webutil/win32/.
  cp jacob-1.20/jacob-1.20-x64.dll $MIDTIER_HOME/forms/webutil/win64/.
  cp jacob-1.20/jacob.jar $MIDTIER_HOME/forms/java/.
  # Modify webutil.cfg for 1.20 version
  cd $WLS_DOMAIN_PATH/config/fmwconfig/components/FORMS/instances/${FORMS_INSTANCE}/server
  cp webutil.cfg webutil.cfg.orig
  sed -i 's#jacob-1.18-M2-x86.dll|167424|1.18-M2#jacob-1.20-x86.dll|189440|1.20>#g' webutil.cfg
  sed -i 's#jacob-1.18-M2-x64.dll|204800|1.18-M2#jacob-1.20-x64.dll|226816|1.20>#g' webutil.cfg
  diff webutil.cfg webutil.cfg.orig

  # Sign the jacob.jar file
  cd $MIDTIER_HOME/forms/java
  cp jacob.jar jacob.jar.unsigned
  # Create a selfsigned keystore if it does not exist
  export KEYSTORE=/mnt/software/share/selfsigned.jks
  if [ ! -f "$KEYSTORE" ]; then
    keytool -genkeypair -alias selfAlias -keystore $KEYSTORE -validity 365 -dname "CN=orablog.org, OU=ID, O=demo, L=demo, S=demo, C=BE" -storepass changeit -keypass changeit -noprompt
    keytool -export -keystore $KEYSTORE -storepass changeit -alias selfAlias -file /mnt/software/share/selfAlias.cer
  fi
  jarsigner -keystore $KEYSTORE -storepass changeit jacob.jar selfAlias

  # extension.jnlp
  cp extensions.jnlp extensions.jnlp.orig
  sed -i 's#<!-- <jar href="jacob.jar"/> -->#<jar href="jacob.jar"/>#g' extensions.jnlp
  diff extensions.jnlp extensions.jnlp.orig
  # To make it work, there are additional steps needed:
  # - Or go in the java console tab security and add https://lb.url in the list of exceptions
  # - Or import /mnt/software/share/selfAlias.cer in java console tab security
  # Ideally, it would be nice to create a certificate (with let's encrypt?) and use it to sign instead
fi

#### formsweb.cfg for the samples
cd $INSTALL_DIR
cat forms/formsweb.cfg.template | sed "s/SYS_PASSWORD/${DB_PASSWORD}/g" | sed "s/PREFIX/${PREFIX}/g" | sed "s/DB_SID/${DB_SID}/g" | sed "s/LOADBALANCER_HOSTNAME/${LOADBALANCER_HOSTNAME}/g" >> $WLS_DOMAIN_PATH/config/fmwconfig/servers/${wls_msserverName}/applications/formsapp_12.2.1/config/formsweb.cfg

#### default.env for the TNS_ADMIN url
sed -i "s#TNS_ADMIN=.*#TNS_ADMIN=/u01/app/oracle/middleware/network/admin#g" $WLS_DOMAIN_PATH/config/fmwconfig/servers/${wls_msserverName}/applications/formsapp_12.2.1/config/default.env

. time.sh
title "DONE"
