#!/bin/sh
if [ $# -eq 1 -a "$1" == "-d"]; then
    exec ccdecrypt -E PASSWORD
else
    exec ccrypt -E PASSWORD
fi

