#!/bin/bash
# DO THIS ONCE TO ENABLE WRITE status.log: sudo chown -R $USER:$USER /home/tim/Desktop/uat2avr

cd /home/tim/Desktop/uat2avr
COUNTER=0

printf "Starting converter  $(date +%m/%d/%y) $(date +%H:%M:%S)\n" >> status.log


socat tcp4-listen:30976,fork STDOUT \
| ./uat2avr | \
socat STDIN tcp4-listen:30977,forever,fork,interval=5 &

while true  
do

COUNTER=$((COUNTER + 1))

sleep 10

if [[ "$COUNTER" -gt 100 ]]; then  #Something is wrong
   printf "Maximum restarts exceeded $(date +%m/%d/%y) $(date +%H:%M:%S)\n" >> status.log
   exit 1
fi

printf "Start R->C link ($COUNTER) $(date +%m/%d/%y) $(date +%H:%M:%S)\n" >> status.log

#Restart dropped connection:
socat tcp4:192.168.1.55:30978 tcp4:localhost:30976 

done

exit 1
