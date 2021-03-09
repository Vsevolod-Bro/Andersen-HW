#!/bin/bash
#Objective:
# The script print the list of the most productive contributors (authors of more than 1 open PR) for a repository.
#An url like `https://github.com/$user/$repo` will be passed to the script

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
echo "----------- Script processes: ----------"
echo "User = $user"
echo "Repo = $repo"
echo "----------------------------------------"
echo ""

# Make the query string
strQ="https://api.github.com/repos/"$userrep"/pulls?state=open"

strQ=$(curl $strQ 2> /dev/null)
ex=$?

# Trap the error
if [[ "$ex" -ne 0 ]]
then
  echo "Script aborted! Error in curl command."
  exit 1
fi
# Parse the Curl output - present any data or not
cnt=$(jq '.[].user.login' <<< $strQ 2> /dev/null)
ex=$?
# Trap the error
if [[ "$ex" -ne 0 ]]
then
  echo "Script aborted! Error in jq command."
  exit 1
fi

# Final output
if [[ $cnt == "null" || $cnt == "" ]]; then
  echo "No open Pull Requests"
  exit 1
fi

# Counting PRs for the Contributors
cnt=$(sort <<< "$cnt")
cnt=$(uniq -c <<< "$cnt")

# Get the contributers names
#echo "$cnt"
echo "=== Contributors with more then 1 PR ==="

for name in "$cnt"
do
  Liders=$(awk "{if ( \$1>1 ) print \$2}" <<< "$name")
done

echo ""
# Remove character "" from names
echo "${Liders//'"'}"



echo "----------------------------------------"
echo ""
