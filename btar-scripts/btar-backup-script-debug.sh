#!/bin/sh
set -xv
# "Do you have anything to declare?"
$NAME
$DEST
$FULLPATH
$PASSWORD

NAME=unset
DEST=unset
FULLPATH=unset
PASSWORD=unset

# NAME="Chiyochan-FreeBSD"
# DEST="/usr/home/matt/btsync/backups/"
# FULLPATH="$DEST$NAME"

if ( ! getopts "n:d:p:" opt); then
	echo "Usage: `basename $0` options -n MACHINE_NAME, -f /path/to/backups/directory/, -p PASSWORD";
	exit $E_OPTERROR;
fi

while getopts "n:d:p:" opt; do
     case $opt in
         n) 
		 NAME=$OPTARG
		 echo "Machine name is $NAME"
		 ;;
         d) 
		 DEST=$OPTARG
		 FULLPATH=$DEST$NAME
		 echo "Backup directory is $DEST \n\
		       Full path is        $FULLPATH" 
		 ;;
         c) 
		 PASSWORD=$OPTARG
		 echo "Password set (won't echo back)" 
		 ;;
     esac
done

if [ $NAME -eq unset ] || [ $DEST -eq unset ] || [ $FULLPATH -eq unset ] || [ $PASSWORD -eq unset ]; then
       (echo "Not all arguments provided! (-n, -d, -p)") >&2
#	exit 1
fi

type bzip2 || ( (echo "The bzip2 command doesn't appear to exist.") >&2 ; exit 2 )
type ccrypt || ( (echo "The ccrypt command doesn't appear to exist.") >&2 ; exit 2 )

echo $NAME $DEST $FULLPATH $PASSWORD

# And now, to business... 
#btar \
#	-F bzip2 -cz \
#	-F ccrypt -E PASSWORD \
#	-j 3 \
#	-f $FULLPATH/`hostname`_`date "%Y-%m-%d_%H.%M"`.btar
#	-c /
#	-X /dev/
#	-X /sys/
#	-X /tmp/
#	-X $DEST

