**Andersen Homework 1, task2**

__*The Objective*__


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

I decided to do the calculation of historical volatility for financial markets.
Here is a rough formula for that:
![alt text](https://github.com/Vsevolod-Bro/Andersen-HW/blob/main/AlexP-hw/task1-2/Formula.JPG?raw=true)

**Method:**

1. For the calculation, you need to create a sequence not of the values ​​themselves, but changes between the current and the previous value.
2. Then, from this sequence, you need to find the average value of the increments and their number.
3. Then you need to calculate the sum of the squares of the increments and divide this by the number of measurements.
4. Find the minimum

**Algorithm:**

1. Create log file
2. In json file no values for March of 2014 so start from 2015
3. Go to "While"
4. To select the increments for March, we need to find the last day of February.
5. Calculate timestamp for middle of February date and 00:00:00 of 01 march.
6. Find the last day in sequence above. It's last day of February with exist value
7. Generate a sequence of value increments by March dates. For it filtering the dates by march. If date in the range, then set the flag that the next value must be added to the list.
8. Calculate the mean value of list of increments and count number of values.
9. Calculate the sum of squares changes and divide by the number of values
10. If this average adequate low then current, then remember this one.
11. Print the result.


__*Logging:*__

Calculation log is output to a log file (task1-2.log) for verification
