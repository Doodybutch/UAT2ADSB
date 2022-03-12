#!/bin/bash
# DO THIS ONCE TO ENABLE PERMISSIONS status.log: sudo chown -R $USER:$USER /home/pi/piavr

cd /home/pi/piavr
COUNTER=0

printf "Starting converter  $(date +%m/%d/%y) $(date +%H:%M:%S)\n" >> status.log


socat tcp4-listen:30976,fork STDOUT \
| ./uat2avr | \
socat STDIN tcp4-listen:30977,forever,fork,interval=5 &

# YOU NEED THIS LOOP BECAUSE dump978-fa drops the connection at random every 1-4 hours
while true  
do

COUNTER=$((COUNTER + 1))

sleep 10

if [[ "$COUNTER" -gt 100 ]]; then  #Something is wrong
   printf "Maximum restarts exceeded $(date +%m/%d/%y) $(date +%H:%M:%S)\n" >> status.log
   exit 1
fi

printf "Start R->C link ($COUNTER) $(date +%m/%d/%y) $(date +%H:%M:%S)\n" >> status.log

#Restart dropped connection to dump978-fa:
socat tcp4:localhost:30978 tcp4:localhost:30976 

done

exit 1
