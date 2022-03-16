# !/bin/bash

# Timothy J. Quill <doodybutch@hotmail.com>  March 2022
# Expert on Everything

# This script sets up the uat2avr conversion program to receive a UAT data stream
# from UAT_SOURCE and makes translated AVR (raw) data available on AVR_OUT_PORT
# It requires the uat2avr executable to be in INSTALL_FOLDER
# It optionally maintains a log called "status.log" in INSTALL_FOLDER
# 
# It optionally will bailout after MAX_RETRYS if it cannot connect to UAT_SOURCE
# It is "normal" for dump978-fa to drop the connection at random about once an hour!
# This script is written to compensate for that bug and keep the pipeline intact
# It is assumed that you have UAT data available on your device or LAN (usually port 30978)
# from dump978 or dump978-fa and optionally BEAST data.

# It is strongly recommended that you automatically reboot your ADS-B station once a day
# during the early morning using an automated crontab entry.  If you do not reboot your station
# you should set ENABLE_BAILOUT to false (below)
#
# A typical uat2avr installation uses localhost:30978 from dump978-fa as UAT_SOURCE and
# localhost port 30977 for AVR_OUT_PORT feeding modeSmixer2 along with dump1090 data
# ModeSmixer2 does not understand UAT data but it works perfectly with AVR (raw) data.
# 
# You can install "modeSmixer2" directly or install "combiner" (which uses modeSmixer2)
# In either case your configuration file should typically contain -
# 
# --inConnect localhost:30977
# --inConnect localhost:30005
# --outServer beast:32005
# --web 8787
# 
# DO NOT PUT COMMENTS IN THE modeSmixer2CONFIGURATION FILES.
# 
# YOU DO NOT HAVE TO TELL modeSmixer2 what type
# of data stream you are feeding because it automatically detects this.
# You feed the combined stream to ADSB Exchange, PlaneFinder,etc by changing the port in
# their configuration files from 30005 to 32005.
#
# This script and the uat2avr program have been tested with flightaware dump978-fa and with
# ADSB Exchange and with PlaneFinder on the Raspberry Pi and Ubuntu Linux.
# It does work with FlightRadar24 or RadarBox but they interpret UAT aircraft as ADS-B.
# RadarBox has alternate way to feed UAT data from dump978 which I describe in the README.md File.
#
# You can run this from a terminal.
# Just change to the directory where start.sh (this script) # is located and enter "./start.sh" without the quotes.
# Once you have it running well you can just put this entry into the /etc/rc.local file - "/dir/dir/start.sh"
# without the quotes and /dir/dir/ is the directory where start.sh is located and it will start automatically on reboot.
 

INSTALL_FOLDER=/home/pi/uat2avr/
UAT_SOURCE=localhost:30978
AVR_OUT_PORT=30977
ENABLE_BAILOUT=true  # Enable this if you reboot daily (which you should)
MAX_RETRYS=64
ENABLE_LOG=true

COUNTER=0

if [ ENABLE_LOG ]; then
 chown $USER:$USER ${INSTALL_FOLDER} 
 printf\
 "\nInitializing converter  $(date +%m/%d/%y) $(date +%H:%M:%S)\n"\
 >> ${INSTALL_FOLDER}status.log
fi

socat tcp4-listen:30976,fork STDOUT \
| ${INSTALL_FOLDER}uat2avr | \
socat STDIN tcp4-listen:${AVR_OUT_PORT},forever,fork,interval=5 &

while true  #  YOU NEED THIS LOOP BECAUSE dump978 drops the connection about every hour
do

COUNTER=$((COUNTER + 1))

sleep 10

if [ "$COUNTER" -gt $MAX_RETRYS ] && [ $ENABLE_BAILOUT ]; then
   # Something is wrong with connecting to UAT_SOURCE
   if [ ENABLE_LOG ]; then\
    printf "Maximum retrys exceeded $(date +%m/%d/%y) $(date +%H:%M:%S)\n"\
    >> ${INSTALL_FOLDER}status.log
    fi
   exit 1
fi

if [ ENABLE_LOG ]; then\
 if [ $COUNTER -eq 1 ]; then
  sleep 10
  printf "Starting R-C link   ($COUNTER) $(date +%m/%d/%y) $(date +%H:%M:%S)\n"\
  >> ${INSTALL_FOLDER}status.log
  else
  printf "Restarting R-C link ($COUNTER) $(date +%m/%d/%y) $(date +%H:%M:%S)\n"\
  >> ${INSTALL_FOLDER}status.log
  fi
 fi

# Restart dropped connection to dump978-fa:
socat tcp4:${UAT_SOURCE} tcp4:localhost:30976 

done

exit 1
