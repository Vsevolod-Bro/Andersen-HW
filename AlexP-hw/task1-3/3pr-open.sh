#!/bin/bash
# Objective:
# Print the number of PRs each contributor has created with the labels.
# An url like `https://github.com/$user/$repo` will be passed to the script

#-------- Start ---------
#https://github.com/$user/$repo`
#0                  19  - user and repo begin from 19st symbol

# Check if there no argument in the invoke
if [ -z "$1" ]; then
  echo "Execution aborted! Don't defined http address."
  exit 1
fi

# Parse the argument and get the user name and repo name
http=$1
userrep=${http:19}
slash=$(expr index $userrep /)
user=${userrep:0:$[$slash-1]}
repo=${userrep:$slash}
echo "------------------ Script processes: -----------------"
echo "User = $user"
echo "Repo = $repo"

echo ""

# Make the query string
strQ="https://api.github.com/repos/"$userrep"/pulls?state=all"

strQ=$(curl $strQ 2>/dev/null )
ex=$?

# Trap the error
if [[ "$ex" -ne 0 ]]
then
  echo "Script aborted! Error in curl command."
  exit 1
fi

# Parse the Curl output - SELECT CONTRIBUTORS          =======
cnt=$(jq '.[].user.login' <<< $strQ 2> /dev/null)
ex=$?
# Trap the error
if [[ "$ex" -ne 0 ]]
then
  echo "Script aborted! Error in jq command with Names."
  exit 1
fi

# If no pull requests-------------------------------------
if [[ $cnt == "null" || $cnt == "" ]]; then
  echo "No open Pull Requests"
  exit 1
fi
#---------------------------------------------------------

# Parse the Curl output - SELECT LABELS                =======
lbl=$(jq '.[].labels[0].name' <<< $strQ 2> /dev/null)
ex=$?
# Trap the error
if [[ "$ex" -ne 0 ]]
then
  echo "Script aborted! Error in jq command with Names."
  exit 1
fi


# !! Set a delimiter instead of a space - LF \n because labels contain names of several words
# Save IFS to variable
SAVEIFS=$IFS
IFS=$'\n'
# -------   Create two matching arrays. ---------
#    One contains usernames, the other contains labels

# Put user names into array (list)
i=0
for user in $cnt
do
  users[$i]=$user
  i=$[$i+1]
done
isave=$i

# Put labels into array (list)
j=0
for label in $lbl
do
  labels[$j]=$label
  j=$[$j+1]
done
jsave=$j

# Return original value of IFS
IFS=$SAVEIFS

# Check matching the quantity of PRs and Labels
if [[ $isave != $jsave ]]; then
  echo "Oops! Something went wrong!!!"
  echo "Names= $isave Labels= $jsave"
fi

# - Another way ))
# Set the symbol LF that will be separate the rows
lf=$'\n'

for (( i = 0; i < jsave; i++ )); do
  if [[ ${labels[$i]} != "null" && ${labels[$i]} != "" ]]; then
    if [[ $labPR == "" ]]; then
      labPR=${users[$i]}
    else
      labPR="${labPR}${lf}${users[$i]}"
    fi
  fi

done

cntPRs=$(sort <<< "$labPR")
# count for every single user number of PRs with labels
cntPRs=$(uniq -c <<< "$cntPRs")

echo "=== Count of PRs with labels for every Contributor ==="
echo "$cntPRs"

echo "------------------------------------------------------"
echo ""
