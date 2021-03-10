**Andersen Homework 1, task3**

__*The Objective*__

Part 1

write a script that checks if there are open pull requests for a repository. An url like `https://github.com/$user/$repo` will be passed to the script

Part 2

print the list of the most productive contributors (authors of more than 1 open PR)

Part 3

print the number of PRs each contributor has created with the labels

Part 4

implement your own feature that you find the most attractive: anything from sorting to comment count or even fancy output format

Part 5

* ask your chat mate to review your code and create a meaningful pull request
* do the same for her xD
* merge your fellow PR! We will see the repo histor

_______________________________________________________________________________

**Implementation**

I used the next utilities: CURL, JQ, AWK

All parts of the task are made by separate functions that are called in the script. The parameter of the main script is passed to the every function.  

*file: PR-all.sh*
**Part 1**

*function Part1*
   - I used the **curl** call like a:
```sh
curl "https://api.github.com/repos/$USER/$REPO/pulls?state=open"
```
to get json data about open pull requests.
   - Next, I parsed curl output with the **jq** utility.
   - Get first object. If returned value is **null** then there is No contributors.
   - Function check if there **no argument** in the invoke
   - It's trap some possible errors and prints its own messages

**Part 2**

*function Part2*
1. The general part of the function is the same as in *function Prat1*, but then I sort and use the **UNIQ** to count the number of entry the same contributors.
2. I used **AWK** for decouple the number and name of contributors.
3. Remove character "" from names.
4. If there are no contributors, then script aborting and print the message.


**Part 3**

*function Part3*
1. As in the previous tasks, the **Errors** are intercepted.
2. All Pull Requests are processed (but not only open ones, because there are few of them).
3. Select with *jq* **user Logins** in the one variable.
4. Select with *jq* **Labels** in the another one.
5. We put the contents of the list variables into arrays. This will enable us to process the content together.
6. Set a separator instead of a space - LF \n because labels contain names of several words.
7. Checking that the number of elements in the array is the same.
8. Checking if labels not equal "null" and not equal empty string, then PR have a label.
9. Sorting list and count the amount of entries the for contributors with **uniq** utility.
10. Print the result.

**Part 4**

*function Part4*
 - Input data for the function as usual  
 - I decided to display the **rating of all repositories for a given user** (usual https-string for the whole task).
 - I used next string to get data:
 ```sh
 curl "https://api.github.com/users/"$user"/repos"
 ```
 - With the help of **df utility** I get data on properties: _**name**_ -Name of repo; _**stargazers_count**_ - rating of repo
1. As in the previous tasks creating to  corresponding arrays and put the data to them.
2. Printing the result from two arrays.

**Part 5**

* I did the Pull Request between my accounts.
* To do this, I opened additional github account.
```https
https://github.com/Bro-VV/Andersen-HW-1
```
* I made the fork. First things first I tried edit README and then made the PR. Then I write script for 3rd part of task1-3 (3pr-open.sh) in the separate branch and made Pull Request for it.
* In the main account I inspected the changes, approved them and I made Merge PR.
