# Home directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"/..

# Env
. $DIR/bin/env.sh

if [ $1 = "edelivery" ]; then
  # Run terraform edelivery
  cd $DIR/terraform/edelivery
  terraform init
  terraform plan
elif [ $1 = "wls_stack" ]; then
  # terraform apply
  . $DIR/bin/wls_stack_env.sh
  cd $DIR/terraform/wls_stack
  terraform init
  terraform plan
else
  echo "Syntax: terraform_apply.sh <edelivery/wls_stack>"
fi 
date
