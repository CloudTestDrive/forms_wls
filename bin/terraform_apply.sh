# Home directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"/..

# Env
. $DIR/bin/env.sh

if [ $1 = "edelivery" ]; then
  # Rebuild the zip file
  cd $DIR
  rm mnt_software.zip
  zip -r mnt_software.zip mnt_software

  # Run terraform edelivery
  cd $DIR/terraform/edelivery
  terraform init
  terraform apply -auto-approve | tee ../../log/terraform_edelivery_apply.log
elif [ $1 = "wls_stack" ]; then
  # terraform apply
  . $DIR/bin/wls_stack_env.sh
  cd $DIR/terraform/wls_stack
  terraform init
  terraform apply -auto-approve | tee ../../log/terraform_wls_stack_apply.log  
else
  echo "Syntax: terraform_apply.sh <edelivery/wls_stack>"
fi 
date
