#!/bin/bash
jq -r '.prices[][]' quotes.json | grep -oP '\d+\.\d+' | tail -n 14 | awk -v mean=0 '{mean+=$1} END {print mean/14}'

{"legend": ["buy"],
 "tzname": "Europe/Moscow",
  "prices": [[1417122000000, 61.4553], [1417381200000, 64.4348],
