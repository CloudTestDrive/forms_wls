# Home directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"/..

$DIR/bin/terraform_destroy.sh $1
$DIR/bin/terraform_apply.sh $1

