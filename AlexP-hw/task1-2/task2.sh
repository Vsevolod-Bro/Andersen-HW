#!/bin/bash

# THE  FIRST PART of task. Remove GREP'
# jq -r '.prices[][]' quotes.json | tail -n 28 | awk 'BEGIN {FS="\n"; RS="\n"} {if ($1<200) mean+=$1} END {print mean/14}'
#----------------------------------------------------------

#THE SECOND PART - The min volatility Calculating
# Suppose we know that the file contains the interval of values from 2015 to 2020

# 1. Check which years are in the existing sequence
i=0
year_tmp[$i]=2015
go=true
# Creating LOG-file
echo "The Volatility Calculating LOG" > ./task2-2.log
# Init var with big value
VOLA_min=1000000000
while $go ; do
  # Data will be correspond with the current (MSK) time zone

  # ----We need to find the last day of February among the existing values. Since not every single day is presented in the sequence.
  #We don't know how much is days in the February. We'll take some interval of the days
  feb_00=$(date --date='02/20/'${year_tmp[$i]}' 00:00:00' '+%s')000
  feb_24=$(date --date='03/01/'${year_tmp[$i]}' 00:00:00' '+%s')000
  awk_str="\$1>$feb_00 && \$1<$feb_24  {print \$1}"
  # We'll take the very last day.
  feb_l_day=$(jq -r '.prices[][]' quotes.json | awk "$awk_str" | tail -n 1)
  # ----

  # ----We need to find day values for March
  march_tmp_24=$(date --date='03/31/'${year_tmp[$i]}' 23:59:59' '+%s')000

  #--- Getting the gradual increments of values from the last day of February to 31 March
  # Set TAKE to 1 if the date value falls within the Range and the next price value needs to be calc
  # In PREV we remember the previous price value
  awk_str="BEGIN {FS=\"\\n\"; RS=\"\\n\"; take = 0; prev = \$1} {if (\$1 > $feb_l_day && \$1 < $march_tmp_24) take = 1} {if (\$1 < 200 && take == 1) { take = 0; dif = \$1 - prev; print dif} {if (\$1 < 200) prev = \$1}}"

  RES=$(jq -r '.prices[][]' quotes.json)
  INCR=$(awk ''"$awk_str"'' <<< "$RES")


  echo "--------- Changes value of ${year_tmp[$i]} -------------" >> ./task2-2.log
  echo "$INCR" >> ./task2-2.log
  echo "--------------------------------------------------------" >> ./task2-2.log
  # Calc the mean deviation
  awk_str="BEGIN {FS=\"\\n\"; RS=\"\\n\"; count = 0; sum = 0} {count+=1; sum+=\$1} END {print sum/count}"
  MID=$(awk ''"$awk_str"'' <<< "$INCR")

  # Calc the number of values
  awk_str="BEGIN {FS=\"\\n\"; RS=\"\\n\"; count = 0} {count+=1} END {print count}"
  Count_val=$(awk ''"$awk_str"'' <<< "$INCR")
  echo "mid= $MID   count= $Count_val" >> ./task2-2.log

  # --- Calculate volatility

  awk_str="BEGIN {FS=\"\\n\"; RS=\"\\n\"; sum = 0; var = 0} {var = $MID - \$1; sum = (var * var) + sum} END { print sum/$Count_val}"
  VOLA=$(awk ''"$awk_str"'' <<< "$INCR")
  echo "Volatility= $VOLA" >> ./task2-2.log
  # Remember Volatility and Year
  if [[ ${VOLA} < ${VOLA_min} ]]; then
    VOLA_min=${VOLA}
    YEAR=${year_tmp[$i]}
  fi

  i=$[$i + 1]
  year_tmp[$i]=$[2015 + $i]
  if [[ $i > "5" ]]; then
    go=false
  fi
done
echo "Min Volatility in March is: ${VOLA_min} in $YEAR"
echo "Min Volatility in March is: ${VOLA_min} in $YEAR" >> ./task2-2.log
