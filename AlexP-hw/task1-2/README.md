**Andersen Homework 1, task2**
*The Objective*
./quotes.json - historical quotes for EUR/RUB pair since late November 2014

The given script below get the mean value for the last 14 days:
```sh
jq -r '.prices[][]' quotes.json | grep -oP '\d+\.\d+' | tail -n 14 | awk -v mean=0 '{mean+=$1} END {print mean/14}'
```

* 1. remove the `grep -oP '\d+\.\d+'` part, do the same thing without any pattern matching
* 2. tell me which March the price was the least volatile since 2015? To do so you'll have to find the difference between MIN and MAX values for the period.

**Solution first task:**
```sh
jq -r '.prices[][]' quotes.json | tail -n 28 | awk 'BEGIN {FS="\n"; RS="\n"} {if ($1<200) mean+=$1} END {print mean/14}'
```

**Solution second task**


**Modification original script:**

1. I'm using a variable to store the data, also I changed WHILE to FOR. In this case, it's convenient for me.
2. I added the output of all mutable variables that are used in the script
3. At the end added counting number of connection from the same Organization
4. Displays selected IP-s (for checking results)

**User Interface and other improves:**

1. If the parameter is present in the script call, then the redirection of errors to the LOG-file is disabled and the message is displayed "Errors ON"
2. Added query for key values:
   - PID or String for first awk command
   - Number of displayed rows for tail command
   - String that will be used second awk for search in the whois command output
3. The User can just press Enter when asked for input value. Script will put the default values into variables
4. Script detect incorrect number entered by the user for the tail command.
5. Whole errors output redirect to LOG-file with script name ($0). (It's can be disabled through adding any parameter to the script call)





**Notes:**

   For counting numbers of connection from same Organization, I used two arrays. Data in arrays are related by the same indices. In the first array - name, number of occurrences in the other one.

*The Removed option:*

   Require from user Netstat options interactively.
   If user input netstat options with "-" before, script delete this symbol automatically.
   Before use command netstat with parameters, the  script run the test command, prevent output and check correct command.   
   If options incorrect, there is required input repeatedly.
