**Andersen Homework 1, task3**

__*The Objective*__

Part 1

write a script that checks if there are open pull requests for a repository. An url like `https://github.com/$user/$repo` will be passed to the script

Part 2

print the list of the most productive contributors (authors of more than 1 open PR)


**Implementation**

I used the next utilities: CURL, JQ, AWK

Part 1

*file: 1pr-open.sh*
** I used the **curl** call like a:
```sh
curl "https://api.github.com/repos/$USER/$REPO/pulls?state=open"
```
to get json data about open pull requests.
** Next, I parsed curl output with the **jq** utility.
** Get first object. If returned value is **null** then there is No contributors.
** Script check if there **no argument** in the invoke
** It's trap some possible errors and prints its own messages

Part 2

*file: 2pr-open.sh*
1. The general part of script is the same as in *1pr-open.sh*, but then I sort and use the **UNIQ** to count the number of entry the same contributors.
2. I used **AWK** for decouple the number and name of contributors.
3. Remove character "" from names.
4. If there are no contributors, then script aborting and print the message.


Part 3
*file: 3pr-open.sh*
