#!/bin/bash

function Part1 {
# The func checks if there are open pull requests for a repository. An url like `https://github.com/$user/$repo` will be passed to the script

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
echo "---------------- Script processes: -------------------"
echo "User = $user"
echo "Repo = $repo"
echo "------------------------------------------------------"


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
  echo "Task 1 result: No open Pull Requests"
else
  echo "Task 1 result: There is open Pull Requests"
fi
echo""
echo "Task 2 "

}

function Part2 {
  # The func print the list of the most productive contributors (authors of more than 1 open PR) for a repository.

  http=$1
  userrep=${http:19}
  slash=$(expr index $userrep /)
  user=${userrep:0:$[$slash-1]}
  repo=${userrep:$slash}

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

  # If no pull requests
  if [[ $cnt == "null" || $cnt == "" ]]; then
    echo "No open Pull Requests"
    exit 1
  fi

  # Counting PRs for the Contributors
  cnt=$(sort <<< "$cnt")
  cnt=$(uniq -c <<< "$cnt")

  # Get the contributers names

  echo "========= Contributors with more then 1 PR ==========="

  # Select the contributors
  for name in "$cnt"
  do
    Liders=$(awk "{if ( \$1>1 ) {print \$1,\$2}}" <<< "$name")
  done

  echo ""
  # Remove character "" from names
  Liders="${Liders//'"'}"
  Liders=$(sort -r <<< "$Liders")
  echo "$Liders"

  echo "------------------------------------------------------"
  echo ""
}

function Part3 {
  # Print the number of PRs each contributor has created with the labels.


  http=$1
  userrep=${http:19}
  slash=$(expr index $userrep /)
  user=${userrep:0:$[$slash-1]}
  repo=${userrep:$slash}

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
echo "Task 3"
  echo "=== Count of PRs with labels for every Contributor ==="
  echo "$cntPRs"

  echo "------------------------------------------------------"
  echo ""
}
function Part4 {
  # The script print the list of the most productive contributors (authors of more than 1 open PR) for a repository.


  # Parse the argument and get the user name and repo name
  http=$1
  userrep=${http:19}
  slash=$(expr index $userrep /)
  user=${userrep:0:$[$slash-1]}
  repo=${userrep:$slash}


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
echo "Task 4"
  echo "======= Script processes All repositories for: ======="
  echo "User: $user"
  echo "------------------------------------------------------"
echo " "
  # Print repos names and appropriate amount of stars
  for (( i = 0; i < isave; i++ )); do
    echo "Rep Name = ${repos[$i]}"
    echo "Stars    = ${rate[$i]}"
    echo "------------------------------------------------------"
  done
}
Part1 $1
Part2 $1
Part3 $1
Part4 $1
