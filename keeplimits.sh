#!/bin/bash

timeout=30
setval=0
daemonval=0

usage() {
	echo "Usage: keepspeed [-d] [-t <timeout>] [-s <up|down>] [-h]"
	echo "	[-d]: explicitly runs the daemon"
	echo "	[-t]: sets the daemon timeout period in seconds (default = 30), and explicitely runs the daemon"
	echo "	[-s]: sets and applies the specified setting"
	echo "	[-h]: shows this help"
	exit 0
}

daemon() {
	echo "Starting as a daemon, refresh timeout is $timeout seconds"
	while :; do
		sleep $timeout
		reapply
	done
}

reapply() {
	typeset -i val=$(</tmp/keepspeed)
        if [ "$val" -eq "1" ]; then
                "/Library/Application Support/VoltageShift/voltageshift" powerlimit 28.5 28 40 0.03
        else
                "/Library/Application Support/VoltageShift/voltageshift" powerlimit 15 28 44 0.002
        fi
}

set() {
	if [ "$1" = "up" ]; then
		/usr/bin/speedup
		reapply
	else 
		if [ "$1" = "down" ]; then
			/usr/bin/speeddown
			reapply
		else
			usage
		fi
	fi
}


while getopts ":hs:t:d" opt; do
	case ${opt} in
		t) timeout=${OPTARG}; daemonval=1;;
		s) setval=${OPTARG};;
		d) daemonval=1;;
	h | * | ?) usage;;
	esac
done

if ! [ "$setval" = "0" ]; then set $setval; fi
if [ $# -eq 0 ] || [ $daemonval -eq 1 ]; then daemon; fi
