#!/bin/bash
# Redirect all errors to name_script.log file
if [ -z "$1" ]; then
  exec 2> "$0".log
else
  echo "Errors - ON"
fi

echo "This script read Netstat and show who do you connect with (or something like that)"

# ===== Run netstat                                  ==
ns_opt="tunapl"
RES=$(netstat -${ns_opt})

#-VV------------ AWK, cut. sort, uniq section -----------------VV
# Default =firefox

# <<< Request INPUT
read -p "Input Name or PID of proc:" awk_opt_str  2>&1

# If user press Enter, value by default
if [[ $awk_opt_str = "" ]]
then
  awk_opt_str="firefox"
fi

# composing a parameter string for AWK (PID or srvName looking up in 7st field)
awk_opt_str="\$7~/$awk_opt_str/ {print \$5}"

# ===== select name of process, print 5st column       ==
RES=$(awk "$awk_opt_str" <<< "$RES")

# ===== Cut the port                                   ==
RES=$(cut -d: -f1  <<< "$RES")

# Sorting for UNIQ work correctly
RES=$(sort <<< "$RES")

# ===== Search uniq rows with number of entries        ==
RES=$(uniq -c <<< "$RES")

# ===== Sort                                           ==
RES=$(sort <<< "$RES")

# -^^------- End of AWK, cut, uniq, sort section --------------^^

# -VV------------------- TAIL section -------------------------VV
# count the number of records
n_rec=$(wc -l <<< "$RES")

tail_num="a"
mask='^[1-9,]+[0-9]*$'
while ! [[ $tail_num =~ $mask ]]
do
  # <<< Request INPUT
  read -p "Input the wanted number of results:" tail_num 2>&1

  # If user press Enter, value by default =5
  if [[ $tail_num = "" ]]
  then
    # Default value
    tail_num=5
  fi
done

# ===== Last N results                                 ==
if [[ $n_rec > $tail_num ]]; then
  RES=$(tail -n${tail_num} <<< "$RES")
else
  tail_num=$n_rec
fi

#-^^------- End of tail section ------------------------------^^

echo "Selected IPs:"
# ===== Grep                                           ==
RES=$(grep -oP '(\d+\.){3}\d+' <<< "$RES")
echo "--------------------"
echo "$RES"
echo "===================="


# -VV------------ AWK-2 section ------------------------------VV

# >>>>  Request INPUT Name PROC
echo "Please Input String which you'd like to find in WHOIS output."
read -p "You can use the special simbols: " awk2_opt_str 2>&1

# If user press Enter, value by default
if [[ $awk2_opt_str = "" ]]
then
  awk2_opt_str="^Organization"
fi

# compose a parameter string for AWK
awk2_opt_str="/$awk2_opt_str/ {print \$2}"
echo " "
echo "Results shown for:"
echo "--------------------------------------------------------"
echo "netstat param is                   : -$ns_opt"
echo "AWK string for Process is          : $awk_opt_str"
echo "Number of showed IP-addresses is   : $tail_num"
echo "String for AWK and Whois command is: $awk2_opt_str"
echo "--------------------------------------------------------"
echo " "
i=0
for IP in  $RES
do
  # ===== Whois                                        ==
  RES=$(whois $IP)
  RES1=$RES
  # ===== AWK-2                                        ==
  RES=$(awk -F':' "$awk2_opt_str" <<< "$RES")
  echo "$RES"
  echo "----------------------------"
  #-----Count connect per Organization------

  arr_org[$i]=$(awk -F':' '/^Organization/ {print $2}' <<< "$RES1")

  i=$[$i+1]
done

# -V--------Сounting the number of occurrences---------------------

i_max=$i
# counter for ready arrays
i3=0
for (( i = 0; i < i_max; i++ )); do

  if [[ ${arr_org[$i]} != "0" ]]; then
    curr=${arr_org[$i]}
    arr_names[$i3]=$curr


    for (( i1 = 0; i1 < i_max; i1++ )); do

      if [[ $curr = ${arr_org[$i1]} ]]; then

         arr_count[$i3]=$[${arr_count[$i3]} + 1]

         arr_org[$i1]="0"
      fi
    done
    i3=$[$i3 + 1]
  fi
done
echo ""
echo "==========================================="
echo "    Сounting the number of occurrences"
echo "==========================================="
for (( i2 = 0; i2 < i3; i2++ )); do
  if [[ ${arr_names[$i2]} = "" ]]; then
    arr_names[$i2]="Unknown Organization"
  fi
  echo "${arr_names[$i2]} = ${arr_count[$i2]}"
  echo "-------------------------------------------"
done
