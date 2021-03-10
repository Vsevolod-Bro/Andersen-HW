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
echo "--- Script processes All repositories for: ---"
echo "User: $user"
echo ""

# Make the query string
strQ="https://api.github.com/users/"$user"/repos"

strQ=$(curl $strQ 2>/dev/null )
ex=$?

# Trap the error
if [[ "$ex" -ne 0 ]]
then
  echo "Script aborted! Error in curl command."
  exit 1
fi

#curl 'https://api.github.com/users/TheAlgorithms/repos' | jq '.[].stargazers_count'
#curl 'https://api.github.com/users/TheAlgorithms/repos' | jq '.[].name'


# Parse the Curl output - SELECT THE REPOSITORIES NAMES          =======
cnt=$(jq '.[].name' <<< $strQ 2> /dev/null)
ex=$?
# Trap the error
if [[ "$ex" -ne 0 ]]
then
  echo "Script aborted! Error in jq command with Names."
  exit 1
fi

# If no repositories -------------------------------------
if [[ $cnt == "null" || $cnt == "" ]]; then
  echo "No open Pull Requests"
  exit 1
fi
#---------------------------------------------------------

# Parse the Curl output - SELECT AMOUNT OF STARS                =======
stars=$(jq '.[].stargazers_count' <<< $strQ 2> /dev/null)
ex=$?
# Trap the error
if [[ "$ex" -ne 0 ]]
then
  echo "Script aborted! Error in jq command with Names."
  exit 1
fi


# !! Set a delimiter instead of a space - LF \n because pero names contain of several words
# Save IFS to variable
SAVEIFS=$IFS
IFS=$'\n'
i=0

# Put repo names in the array
for repo in $cnt
do
  repos[$i]=$repo
  i=$[$i+1]
done
isave=$i

# Put amount of stars into array
j=0
for star in $stars
do
  rate[$j]=$star
  j=$[$j+1]
done
jsave=$j

# Return original value of IFS
IFS=$SAVEIFS

# Check matching the quantity of repos and numbers of stars
if [[ $isave != $jsave ]]; then
  echo "Oops! Something went wrong!!!"
  echo "Names= $isave Labels= $jsave"
fi

# Print repos names and appropriate amount of stars
for (( i = 0; i < isave; i++ )); do
  echo "Rep Name = ${repos[$i]}"
  echo "Stars    = ${rate[$i]}"
  echo "------------------------------------------"
done
