#----------------------------------------------------------------------------
# Script  : install_part1.sh
# Version : 1.0
# Author : mgueury 
# Description: delete oracle user and reinstall FMW 
#----------------------------------------------------------------------------

. /mnt/software/install/bin/env.sh $(basename $BASH_SOURCE)

# Correct the existing env
usermod --shell /bin/bash root
cd /opt/scripts
cp create_12c_domain.py create_12c_domain.py.orig
sed -i "s%UnixMachine%Machine%g" create_12c_domain.py
sed -i "/closeDomain.*/ r $INSTALL_DIR/domain/apply_forms_template.py" create_12c_domain.py
sed -i "s%machine_name = machine_name_prefix + str(databag.getHostIndex())%machine_name = 'AdminServerMachine'%g" create_12c_domain.py
sed -i "s%managed_server_name = server_name_prefix+ str(databag.getHostIndex())%managed_server_name = 'WLS_FORMS'%g" create_12c_domain.py

cp extend_12c_domain.py extend_12c_domain.py.orig
sed -i "/#pack domain/ r $INSTALL_DIR/domain/call_before_pack.py" extend_12c_domain.py

cd $INSTALL_DIR

# Idea
# - Add selectTemplate in create_12c_domain.py
#   drop domain_create.sh 
# - change the ADMIN_URL of startManagedWebLogic before nmStart
part1_root_install.sh forms > /home/opc/part1_root_install.log 2>&1




