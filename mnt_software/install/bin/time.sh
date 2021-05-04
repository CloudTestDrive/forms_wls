echo "-----------------------------------------------------------------------------"
TIME_END=`date +%s`
date
if [ -z "$TIME_START" ]; then
  export TIME_START=$TIME_END
else
  t=$((TIME_END-TIME_START))
  echo "Time since start=$t sec"  
  t=$((TIME_END-TIME_LAST))
  echo "Time since last time=$t sec"  
fi
export TIME_LAST=$TIME_END
echo "-----------------------------------------------------------------------------"
