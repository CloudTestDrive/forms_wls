# Home directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"/..

# Env
. $DIR/bin/env.sh

if [ $1 = "edelivery" ]; then
  # terraform destroy
  cd $DIR/terraform/edelivery
  terraform destroy -auto-approve | tee ../../log/terraform_edelivery_destroy.log

  # Remove the build from the known_hosts of SSH
  sed -i old '/^build./d' $HOME/.ssh/known_hosts 
elif [ $1 = "wls_stack" ]; then
  # terraform destroy
  . $DIR/bin/wls_stack_env.sh
  cd $DIR/terraform/wls_stack
  terraform destroy -auto-approve | tee ../../log/terraform_wls_stack_destroy.log
else
  echo "Syntax: terraform_destroy.sh <edelivery/wls_stack>"
fi 
  
