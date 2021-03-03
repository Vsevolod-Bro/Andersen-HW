Description:
This script run netstat command and then search in this output required information (for example, Organization) about connections.
In common case this script implements command:
sudo netstat -tunapl | awk '/firefox/ {print $5}' | cut -d: -f1 | sort | uniq -c | sort | tail -n5 | grep -oP '(\d+\.){3}\d+' | while read IP ; do whois $IP | awk -F':' '/^Organization/ {print $2}' ; done

Modification original script:
** 1. I skipped the first SORT, I don't make sense why it need there
2. I'm using a variable to store the data, also I changed WHILE to FOR. In this case, it's convenient for me.
3. I added the output of all mutable variables that are used in the script
4. At the end added counting number of connection from the same Organization
5. Displays selected IP-s (for checking results)

User Interface and other improves:
1. If the parameter is present in the script call, then the redirection of errors to the LOG-file is disabled and the message is displayed "Errors ON"
2. Added query for key values:
  2.1 Netstat options
  2.2 PID or String for first awk command
  2.3 Number of displayed rows for tail command
  2.4 String that will be used second awk for search in the whois command output
3. The User can just press Enter when asked for input value. Script will put the default values into variables
4. Script detect incorrect values in netstat options and number for tail.
5. Whole errors output redirect to LOG-file with script name ($0). (It's can be disabled through adding any parameter to the script call)
6. If user input netstat options with "-" before, script delete this symbol automatically
7. Before use command netstat with parameters, the  script run the test command, prevent output and check correct command.
   If options incorrect, there is required input repeatedly.