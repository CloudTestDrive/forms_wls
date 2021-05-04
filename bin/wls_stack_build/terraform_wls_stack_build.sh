#
# This script takes the terraforms files of WLS on OCI and modify them to install Forms.
#

# Home directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"/../..

# Unzip the WLS_STACK file downloaded from OCI Marketplace
cd $DIR/terraform
ZIP_FILE=wls_stack.zip
if [ ! -f "$ZIP_FILE" ]; then
  echo "FILE $ZIP_FILE is missing"
  exit
fi

mv wls_stack wls_stack_$(date +"%Y%m%d_%H%M")
mkdir wls_stack
cd wls_stack
unzip ../wls_stack.zip

function backup() {
  echo "== $1 ==" 
  export FILE=$1
  cp $1 $1.orig
}

# MAIN.TF
# - Hardcode the servers as WLS_FORMS / AdminServer / cluster_forms, this is what Forms installation expect
# - Pass the mount_target parameter to compute.tf
backup main.tf
sed -i.old -e 's#format("%s_server_", local.service_name_prefix)#"WLS_FORMS"#g' $FILE
sed -i.old -e 's#format("%s_adminserver", local.service_name_prefix)#"AdminServer"#g' $FILE
sed -i.old -e 's#format("%s_cluster", local.service_name_prefix)#"cluster_forms"#g' $FILE
sed -i.old -e '/tf_script_version.*/ r ../../bin/wls_stack_build/compute_tf_add' $FILE
diff $FILE $FILE.orig

# COMPUTE.TF
# - Pass the mount_target parameter to bootstrap
backup modules/compute/instance/compute.tf
sed -i.old -e '/tf_script_version.*/ r ../../bin/wls_stack_build/compute_tf_add' $FILE
diff $FILE $FILE.orig

# XXXXX-COMPUTE.TF
# - Pass the mount_target parameter to bootstrap
backup modules/compute/instance/jrf-atp-compute.tf
sed -i.old -e '/tf_script_version.*/ r ../../bin/wls_stack_build/compute_tf_add' $FILE
diff $FILE $FILE.orig

backup modules/compute/instance/jrf-ocidb-compute.tf
sed -i.old -e '/tf_script_version.*/ r ../../bin/wls_stack_build/compute_tf_add' $FILE
diff $FILE $FILE.orig

backup modules/compute/instance/jrf-vcn-peered-compute.tf
sed -i.old -e '/tf_script_version.*/ r ../../bin/wls_stack_build/compute_tf_add' $FILE
diff $FILE $FILE.orig

# BOOTSTRAP
# - Run 2 scripts 
#   1. install the forms binaries
#   2. configure the domain for forms
backup modules/compute/instance/userdata/bootstrap
sed -i.old -e '/echo "Executed check_versions.*/ r ../../bin/wls_stack_build/bootstrap_add1' $FILE
sed -i.old -e '/echo "Executed cleanup script".*/ r ../../bin/wls_stack_build/bootstrap_add2' $FILE
diff $FILE $FILE.orig

# LB.TF
backup modules/lb/lb.tf
sed -i.old -e "s#local.health_check_url_path#\"/forms/\"#g" $FILE
sed -i.old -e "s#var.return_code#200#g" $FILE
sed -i.old -e "s#var.wls_ms_port#9001#g" $FILE
sed -i.old -e '/xxxxxxx.*/ r ../../bin/wls_stack_build/lb_tf_add' $FILE
diff $FILE $FILE.orig

# FORMS.TF
# - variable mount_target and output
cp ../../bin/wls_stack_build/forms.tf .

# FORMS_INSTANCE.TF
# - variable mount_target and output
cp ../../bin/wls_stack_build/forms_instance.tf modules/compute/instance/.