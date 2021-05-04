# Home directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"/..
. $DIR/bin/env.sh

cd $DIR/mnt_software
# ssh opc@${BUILD} sudo /mnt/software/backup/backup_install.sh
rsync -r -a -v -e ssh --delete install opc@${TF_VAR_build_public_ip}:/mnt/software
date

