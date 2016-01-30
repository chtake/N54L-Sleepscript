#!/bin/bash

# (C) 2013 Eric Kurzhals
# Let shutdown the (home)server if no
# clients available and no (internet) traffic
# accessed by the server last 10 minutes.
# Author: - Eric Kurzhals <eric@kurzhals.info> -

# configuration
lanHosts=( 192.168.2.160 )
minPeriodTraffic=50 # as megabytes

fileNoHostFound=/root/.sleepNoHostFound
fileTrafficLastRun=/root/.sleepLastRun

# end::configuration 

_exit () {
	case $1 in
		1)
			if [ -f ${fileNoHostFound} ] ; then
				rm ${fileNoHostFound}
			fi
			;;
	esac
	exit $1
}

traffic=($( /sbin/ifconfig eth0 | awk 'BEGIN { FS = "[ :]+" }  $3 == "bytes" { printf("%.0f %.0f", $4, $9)} '))

total=$(( (traffic[0] + traffic[1]) / (1024 * 1024))) # as megabytes
if [ ! -f ${fileTrafficLastRun} ]
then
	echo 0 > ${fileTrafficLastRun}
fi

lastRunTotal=`cat ${fileTrafficLastRun}` # get the last script run megabytes traffic
echo ${total} > ${fileTrafficLastRun} # write this run traffic to cache file

trafficDiff=$(( total - lastRunTotal  ))

if [ ${trafficDiff} -ge ${minPeriodTraffic} ]
then
	logger -p local7.info "${trafficDiff} MB Differenz, cancel shutdown"
	_exit 1
fi

# checks if someone is logged in
if [ `who | wc -l` -ge 1 ] ; then
	_exit 1
fi

for ip in ${lanHosts[@]}
do
	# we've found an active lan host and cancel shutdown
	if [ `ping -c 1 -i 1 ${ip} | grep -wc "+1 errors"` -eq 0 ] ; then
		_exit 1
	fi
done

# no hosts active; no inet traffic recognized

# second time no host active; shutdown
if [ -f ${fileNoHostFound} ] ; then
	rm ${fileNoHostFound}
	logger -p local7.info "go sleeping.. [${trafficDiff} MB Difference]"
	/sbin/poweroff
	_exit 0
fi

touch ${fileNoHostFound}
