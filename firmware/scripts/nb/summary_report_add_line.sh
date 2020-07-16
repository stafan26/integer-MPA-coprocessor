#!/bin/bash
#script attaches timing data to file

TIMING_DATA=$(grep -A 6 "Design Timing Summary" $1 | tail -n 1)
printf "%s" "$TIMING_DATA" >> $2
