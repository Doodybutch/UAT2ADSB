UAT2ADSBEXCHANGE Summary - this is a work in progress

Timothy J. Quill <doodybutch@hotmail.com>  March 2022
Expert on Everything
uat2avr, the executable heart of this convertor, is a slightly modified version of uat2esnt
from the github repository mutability/dump978

This "start.sh" script sets up the uat2avr conversion program to receive a UAT data stream
from UAT_SOURCE and makes translated AVR (raw) data available on AVR_OUT_PORT
It requires the uat2avr executable program to be in INSTALL_FOLDER
It optionally maintains a log called "status.log" in INSTALL_FOLDER

It optionally will bailout after MAX_RETRYS if it cannot connect to UAT_SOURCE
It is "normal" for dump978-fa to drop the connection at random about once an hour!
This script is written to compensate for that bug and keep the pipeline intact
It is strongly recommended that you automatically reboot your ADS-B station once a day
during the early morning using an automated crontab entry.  If you do not reboot your station
you should set ENABLE_BAILOUT to false (below)
#
A typical uat2avr installation uses localhost:30978 from dump978-fa as UAT_SOURCE and
localhost port 30977 for AVR_OUT_PORT feeding modeSmixer2 along with dump1090 data
ModeSmixer2 does not understand UAT data but it works perfectly with AVR (raw) data.

You can install "modeSmixer2" directly or install "combiner" (which uses modeSmixer2)
In either case your configuration file should typically contain -

--inConnect localhost:30977
--inConnect localhost:30005
--outServer beast:32005
--web 8787

DO NOT PUT COMMENTS IN THESE modeSmixer2CONFIGURATION FILES!

and maybe other stuff - read the documentation.  YOU DO NOT HAVE TO TELL modeSmixer2 what type
of data stream you are feeding because it automatically detects this.
You feed the combined stream to ADSB Exchange or PlaneFinder by changing the port in
their configuration files from 30005 to 32005.
#
This script and the uat2avr program have been tested with flightaware dump978-fa and with
ADSB Exchange and with PlaneFinder on the Raspberry Pi and Ubuntu Linux.
It does not work with FlightRadar24 or RadarBox.
RadarBox has alternate way to feed UAT data from dump978-fa which I describe in the README.md File.
FlightRadar24 does not display UAT traffic as far as I can tell as of March 2022.
#
You can run this from a terminal.
Just change to the directory where start.sh (this script) is located and enter "./start.sh" without the quotes.
Once you have it running well you can just put this entry into the /etc/rc.local file - "/dir/dir/start.sh"
without the quotes and /dir/dir/ is the directory where start.sh is located and it will start automatically on reboot.
 
