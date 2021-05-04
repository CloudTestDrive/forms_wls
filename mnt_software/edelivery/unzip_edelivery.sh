#----------------------------------------------------------------------------
# Script  : unzip_edelivery.sh
# Version : 1.0
# History :
#   mgueury - creation
# Description:
#   unzip all.zip file in the current directory
#----------------------------------------------------------------------------

# Build our directory list
mkdir zip

for i in `ls *.zip`
do
  export FILE=`echo ${i%%.zip*}`
  if [[ "$FILE" == *"_"*"of"* ]];then
    export FILE=`echo ${FILE%%_*}`
  fi
  echo "Creating ${FILE}"
  mkdir ${FILE}
  cd ${FILE}
  echo "unzipping ${i}"
  unzip ../${i}
  cd ..
  mv ${i} zip
done

mv V1003467-01 jdk
mv V983368-01 infrastructure
mv V983392-01 forms
mv V46097-01 db_client
find . -name "*.bin" -exec chmod 755 {} \;