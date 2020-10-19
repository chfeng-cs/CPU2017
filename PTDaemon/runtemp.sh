#!/usr/bin/env bash
#
# runtemp.sh - run PTD in temperature mode
#
# Copyright 2006-2019 Standard Performance Evaluation Corporation (SPEC)
# $Revision: 1644 $

# NOTE: make sure your sensor is located per Run and Reporting Rules
#  "temperature must be measured no more than 50mm in front of (upwind of)
#     the main airflow inlet of the SUT"
#

echo
echo NOTE: make sure your sensor is located per Run and Reporting Rules
echo  '"temperature must be measured no more than 50mm in front of (upwind of)'
echo  '    the main airflow inlet of the SUT"'
echo

# set PTD to PTD executable path for your OS and installation location
PTD=${PTD_BINARY:-$(dirname $0)/binaries/ptd-linux-x86}

# Set NETWORK_PORT if needed.  8889 is the default used for the temperature device by CCS and SERT
NETWORK_PORT=${PTD_TEMP_PORT:-8889}

# Set DEVICE to the temperature sensor device you will use (1000=dummy temperature sensor)
DEVICE=${PTD_TEMP_DEVICE:-1000}

# Set DEVICE_PORT to the serial port you will connect your temperature sensor to
DEVICE_PORT=${PTD_TEMP_DEVICE_PORT:-/dev/ttyS0}

# To enable logging of measurement data, set the LOGFILE variable to the name of
# the file in which you'd like the CSV data to be stored.  The default is to log
# data to ptd-temp.log and other information and exceptions to ptd-temp.log.debug.
LOGFILE=${PTD_TEMP_LOGFILE:-${SPEC:+${SPEC}/}ptd-temp.log}

# To log measurement data and important events like range settings, warnings, and
# errors to the LOGFILE set above, change the setting below to TRUE
EXTLOG=${PTD_TEMP_EXTLOG:-TRUE}

# code from here on should not normally be changed

shopt -s nocasematch

LOGGING=
if [[ -n $LOGFILE ]]; then
  LOGGING="-l $LOGFILE -d ${LOGFILE}.debug"
  if [[ -n $EXTLOG && !($EXTLOG =~ FALSE) ]]; then
    LOGGING="$LOGGING -e"
  fi
fi

# Start pre-watching the log; we'll start PTDaemon next
declare -a TAILPIDS
if [[ -n ${LOGFILE} ]]; then
  touch ${LOGFILE} ${LOGFILE}.debug
  if [[ $? -ne 0 ]]; then
    echo "Log file ${LOGFILE} and ${LOGFILE}.debug could not be created" >&2
    exit 1
  fi
  tail -n 0 -f $LOGFILE &
  TAILPIDS=($!)
  tail -n 0 -f ${LOGFILE}.debug &
  TAILPIDS+=($!)
fi

destroy_all_processes() {
    local pid=
    local signal=

    # Before sending the uncatchable signal, give the processes a chance to exit
    for signal in TERM KILL; do
        for pid in "$@"; do
            kill -0 $pid >/dev/null 2>&1 && kill -$signal $pid
        done
        sleep 1

        # Figure out whether anything is still alive
        for pid in "$@"; do
            kill -0 $pid >/dev/null 2>&1 && continue 2
        done

        # At this point either we're out of signals or everything is gone
        break
    done
}

# Arrange to get rid of the log tails if the script is interrupted
trap 'destroy_all_processes "${TAILPIDS[@]}"; exit' HUP INT QUIT TERM

# Start PTDaemon
$PTD -t $LOGGING -p $NETWORK_PORT $DEVICE $DEVICE_PORT

# PTD is done; stop watching the logs
destroy_all_processes "${TAILPIDS[@]}"

# Editor settings: (please leave this at the end of the file)
# vim: set filetype=sh syntax=sh shiftwidth=4 tabstop=8 expandtab nosmarttab mouse= colorcolumn=120:
