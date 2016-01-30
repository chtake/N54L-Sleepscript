# Sleepscript
This script was originally written for the **HP Microserver N54L** to let the server go sleep in the night, after shutting down my personal computer. The Server akts also as local Backup Storage with cloud synchronisation. So it should not shutdown until the backup is synchronized completely. So it takes attention to actual traffic on eth0.

In default settings, the script shutdowns the machine if no one is logged in, no 'master' computer (=ip addresses) is online and the traffic is lower than 50 MByte the last 10 minutes.

# Installation
Put the script on your Server (e.g. `/root/sleepScript.sh`) and add execute rights on it: `chmod +x /root/sleepScript.sh`

Add the following line to your root crontab:

    */10 * * * * /root/sleepScript.sh >> /root/log-sleepScript.log


