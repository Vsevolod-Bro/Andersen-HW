**Andersen Homework 1, task3**

__*The Objective*__
Part 1
write a script that checks if there are open pull requests for a repository. An url like `https://github.com/$user/$repo` will be passed to the script

Part 2
print the list of the most productive contributors (authors of more than 1 open PR)

**Implementation**
Part 1
*file: 1pr-open.sh*
I used the **curl** call like a:
```sh
"https://api.github.com/repos/$USER/$REPO/pulls?state=open"
```
to get json data about open pull requests.
Next, I'm parsed curl output with the **jq** utilite
