#!/bin/bash
#Objective:
# The script checks if there are open pull requests for a repository. An url like `https://github.com/$user/$repo` will be passed to the script
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
echo "--- Script processes: ---"
echo "User = $user"
echo "Repo = $repo"
echo "-------------------------"
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
cnt=$(jq '.[0].user.login' <<< $strQ 2> /dev/null)
ex=$?
# Trap the error
if [[ "$ex" -ne 0 ]]
then
  echo "Script aborted! Error in jq command."
  exit 1
fi

# Final output
if [[ $cnt == "null" ]]; then
  echo "No open Pull Requests"
else
  echo "There is open Pull Requests"
fi

echo""
echo""
