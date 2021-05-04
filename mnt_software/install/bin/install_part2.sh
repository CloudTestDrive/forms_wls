#----------------------------------------------------------------------------
# Script  : install_part2.sh
# Version : 1.0
# Author : mgueury 
# Description: delete oracle user and reinstall FMW 
#----------------------------------------------------------------------------

# Backup /u01/data
cd /u01
tar cfz data.tgz data
su -c "/mnt/software/install/bin/part2_oracle_config.sh" - oracle > /home/opc/part2_oracle_config.log 2>&1
