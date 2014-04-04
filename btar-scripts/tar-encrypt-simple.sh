#!/bin/sh

# "Do you have anything to declare?"
$NAME
$DEST
$FULLPATH
$PASSWORD

PASSWORD=unset

NAME="Chiyochan-FreeBSD"
DEST="/usr/home/matt/btsync/backups/"
FULLPATH="$DEST$NAME"

while getopts "p:" opt; do
     case $opt in
         p) 
		 PASSWORD=$OPTARG
		 echo "Password set (won't echo back)" 
		 ;;
     esac
done

if [ $PASSWORD == unset ]; then
       (echo -n "No password provided on command line.
Please enter one now: ") 
	read PASSWORD
	# Debug:
	# echo $PASSWORD >&2	
fi

type bzip2 || ( (echo "The bzip2 command doesn't appear to be installed.") >&2 ; exit 2 )
type ccrypt || ( (echo "The ccrypt command doesn't appear to be installed.") >&2 ; exit 2 )

echo "Okay, backing up root now! /n"

# And now, to business... 
btar \
	-F bzip2 -cz \
	-F ccrypt -E PASSWORD \
	-j 3 \
	-f $FULLPATH/`hostname`_`date "%Y-%m-%d_%H.%M"`.btar \
	-c / \
	-X /dev/ \
	-X /sys/ \
	-X /tmp/ \
	-X /proc/ \
	-X $DEST 

