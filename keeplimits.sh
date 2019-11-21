#!/bin/bash

if [ $EUID != 0 ]; then
    sudo "$0" "$@"
    exit $?
fi

TMPFILE_PATH="/tmp/keepspeed"
COMMAND="/Library/Application Support/VoltageShift/voltageshift"
ARGS_UP="powerlimit 28.5 28 40 0.03"
ARGS_DOWN="powerlimit 15 28 44 0.002"

timeout=30
setval=0
daemonval=0

usage() {
	echo "Usage: keeplimits [-d] [-t <timeout>] [-s <up|down>] [-h]"
    echo "If no parameters are passed, the program will act as if only -d was passed"
    echo "This program works best if automatically run by root at startup"
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
	typeset -i val=$(<$TMPFILE_PATH)
    if [ "$val" -eq "1" ]; then
        eval \"${COMMAND}\" $ARGS_UP
    else
        eval \"${COMMAND}\" $ARGS_DOWN
    fi
}

setpl() {
	if [ "$1" = "up" ]; then
		echo 1 > $TMPFILE_PATH
		reapply
	else 
		if [ "$1" = "down" ]; then
			echo 0 > $TMPFILEPATH
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

if ! [ "$setval" = "0" ]; then setpl $setval; fi
if [ $# -eq 0 ] || [ $daemonval -eq 1 ]; then daemon; fi
