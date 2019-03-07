#!/bin/bash

# valid parameters
# --demo (dont execute, just compose and show the commands)
# --config=file (define a config file)
# --quiet (no verbose)
# --debug (for debug, activate --verbose too)
# --verbose (active by default, see the commands and your out)
#
# https://github.com/sandrocustodiobr/syncBash

function go_rsync
{
    # verbose
    if [ "$VERBOSE" == "true" ]; then
        echo "$mode mode: $command $from_to" | tee -a $LOG
    fi

    # debug
    if [ "$DEBUG" == "true" ]; then
            echo "Debug: Executing $command $from_to" | tee -a $LOG
    fi

    # go or demo
    if [ "$GO" == "true" ]; then # go
        # executing here
        $command $from_to | tee -a $LOG
        #echo Command... $command $deleteoption $from_to | tee -a $LOG
    else # DEMO (--demo)
        echo Demo: Command... $command $from_to | tee -a $LOG
    fi 
}

function command_assembly {
    # the command is assembly here, according data and configs
    # rsync --recursive --update/--checksum --delete --verbose ${from} ${to}

    command="rsync --recursive"

    if [ "$mode" == "duplex" ]; then
        command="$command --checksum"
    else # send / receive
        command="$command --update"

        if [ "$delete" == "delete" ]; then
            command="$command --delete"
        fi
    fi

    if [ "$VERBOSE" == "true" ]; then
        command="$command --verbose"
    fi
}

# BEGIN

# default values of settings
CONFIG=sync.conf 
GO="true" # --demo for desactivate
DEBUG="false"
CFG="false"
VERBOSE="true"
LOG=logs/`basename $0`.`date "+%Y%m%d_%H%M"`.log

# verifing parameters ($*=all $#=number_of $0=script_name $1=first_param)
for p in $*
do
    #debug echo $p
    case "$p" in
        "--demo")
            GO="false"
            ;;
        "--config="*)
            CFG="true"
            CONFIG=`echo $p | cut -b 10-`
            ;;
        "--quiet")
            VERBOSE="false"
            ;;
        "--debug")
            DEBUG="true"
            VERBOSE="true"
            ;;
        "--verbose")
            VERBOSE="true"
            ;;
    esac
done

# DEBUG
if [ "$DEBUG" == "true" ]; then
    if [ "$GO" == "true" ]; then
        echo "Debug: GO option active." | tee -a $LOG
    fi
    if [ "$CFG" == "true" ]; then
        echo "Debug: Config file informed: $CONFIG." | tee -a $LOG
    fi
fi

# verify config file
if [ ! -e "$CONFIG" ]; then
    echo "Error (`basename $0`): Config file not existis: $CONFIG" | tee -a $LOG
    exit 0
fi

# getting from config file
TO=`grep -E "^set:TO:" $CONFIG | cut -d: -f3`
FROM=`grep -E "^set:FROM:" $CONFIG | cut -d: -f3`

if [ "$VERBOSE" == "true" ]; then
    echo From: $FROM | tee -a $LOG
    echo To: $TO | tee -a $LOG
fi

# processing backup for each directory
cat $CONFIG | grep -E "^sync:" | while read line
do
    # basic data
    mode=`echo $line | cut -d: -f2`
    delete=`echo $line | cut -d: -f3`
    pathname=`echo $line | cut -d: -f4`
    newpath=`echo $line | cut -d: -f5`
    
    if [ "$newpath" == "" ]; then
        newpath="$pathname"
    fi

    # debug
    if [ "$DEBUG" == "true" ]; then
        echo "Debug: Mode:$mode Delete:$delete Pathname:$pathname Newpath:$newpath" | tee -a $LOG
    fi

    # if not mounted or not exists
    if [ ! -d "$TO$newpath" ]; then
        echo "Error (`basename $0`): Target directory dont exists or not mounted: $TO$newpath" | tee -a $LOG
        exit 0
    fi
    if [ ! -d "$FROM$pathname" ]; then
        echo "Error (`basename $0`): Directory dont exists or not mounted: $FROM$pathname" | tee -a $LOG
        exit 0
    fi

    # doing
    command=""
    if [ "$mode" == "send" ] || [ "$mode" == "receive" ] || [ "$mode" == "duplex" ]; then
        command_assembly # the command is assembly here, according data and configs

        if [ "$mode" == "send" ] || [ "$mode" == "duplex" ]; then
            from_to="$FROM$pathname $TO$newpath"
            go_rsync # GO
        fi
        if [ "$mode" == "receive" ] || [ "$mode" == "duplex" ]; then
            from_to="$TO$newpath $FROM$pathname"
            go_rsync # GO
        fi
    fi
done
