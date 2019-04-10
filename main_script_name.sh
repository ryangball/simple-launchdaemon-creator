#!/bin/bash

function writelog () {
    DATE=$(date +%Y-%m-%d\ %H:%M:%S)
    /bin/echo "${1}"
    /bin/echo "$DATE" " $1" >> "/Users/Shared/test_launchdaemon.log"
}

writelog "Testing"

exit 0