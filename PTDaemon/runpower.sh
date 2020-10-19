#!/usr/bin/env bash
#
# runpower.sh - run PTD in power mode
#
# Copyright 2006-2019 Standard Performance Evaluation Corporation (SPEC)
# $Revision: 1644 $


# set PTD to PTD executable path for your OS and installation location
PTD=${PTD_BINARY:-$(dirname $0)/binaries/ptd-linux-x86}

# Set NETWORK_PORT if needed.  8888 is the default used for the power device by CCS and SERT
NETWORK_PORT=${PTD_POWER_PORT:-8888}

# Set DEVICE to the power analyzer device you will use (0=dummy device)
DEVICE=${PTD_POWER_DEVICE:-0}

# Set channel number for multichannel analyzers operating in single channel mode
#  Default = 0
CHANNELNO=${PTD_POWER_CHANNEL:-}

# DEVICE_PORT describes the physical address of the connection to the analyzer
# If using an RS-232 interface, set to the serial port you will connect your power analyzer to
# If using a TCP/IP interface, set this to the IP address of the analyzer
DEVICE_PORT=${PTD_POWER_DEVICE_PORT:-/dev/ttyS0}

# To enable logging of measurement data, set the LOGFILE variable to the name of
# the file in which you'd like the CSV data to be stored.  The default is to log
# data to ptd-power.log and other information and exceptions to ptd-power.log.debug.
LOGFILE=${PTD_POWER_LOGFILE:-${SPEC:+${SPEC}/}ptd-power.log}

# To log measurement data and important events like range settings, warnings, and
# errors to the LOGFILE set above, change the setting below to TRUE
EXTLOG=${PTD_POWER_EXTLOG:-TRUE}

# set to TRUE if you are using a TCP/IP interface. Device port above will
# be used as the network (IP) address
IS_TCPIP_DEVICE=${PTD_POWER_TCPIP_DEVICE:-FALSE}


# code from here on should not normally be changed

shopt -s nocasematch

LOGGING=
if [[ -n $LOGFILE ]]; then
  LOGGING="-l $LOGFILE -d ${LOGFILE}.debug"
  if [[ -n $EXTLOG && !($EXTLOG =~ FALSE) ]]; then
    LOGGING="$LOGGING -e"
  fi
fi

DEVICE_TYPE=
if [[ $IS_TCPIP_DEVICE =~ TRUE ]]; then
  DEVICE_TYPE="-n"
fi

CHANNEL=
if [[ -n $CHANNELNO ]]; then
  CHANNEL="-c $CHANNELNO"
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
$PTD $LOGGING $CHANNEL $DEVICE_TYPE -p $NETWORK_PORT $DEVICE $DEVICE_PORT

# PTD is done; stop watching the logs
destroy_all_processes "${TAILPIDS[@]}"

# Editor settings: (please leave this at the end of the file)
# vim: set filetype=sh syntax=sh shiftwidth=4 tabstop=8 expandtab nosmarttab mouse= colorcolumn=120:
