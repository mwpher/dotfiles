#!/bin/sh
set -xv

# "Do you have anything to declare?"
$NAME
$DEST
$FULLPATH
$PASSWORD

NAME=unset	# Nickname for this computer (or a special nick for this backup set)
TARGET=unset	# Target filesystem to back up 
DEST=unset	# Your backup directory (needs trailing slash, $NAME WILL BE APPENDED)
FULLPATH=unset	# $DEST$NAME
PASSWORD=unset	# Self-explanatory

# NAME="Chiyochan-FreeBSD"
# DEST="/usr/home/matt/btsync/backups/"
# FULLPATH="$DEST$NAME"

if ( ! getopts "t:n:d:p:" opt); then
	echo "Usage: `basename $0` options -t /dev/target-fs -n MACHINE_NAME, -d /path/to/backups/directory/, -p PASSWORD";
	exit $E_OPTERROR;
fi

while getopts "t:n:d:p:" opt; do
     case $opt in
	 t)
		 TARGET=$OPTARG
		 echo Target filesystem is $TARGET
		 ;; 
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
         p) 
		 PASSWORD=$OPTARG
		 echo "Password set (won't echo back)" 
		 ;;
     esac
done

if [ $NAME == unset ] || [ $DEST == unset ] || [ $FULLPATH == unset ] || [ $PASSWORD == unset ]; then
       (echo "Not all arguments provided! (-t, -n, -d, -p)") >&2
#	exit 1
fi

type dump || ( (echo "The dump command doesn't appear to exist.") >&2 ; exit 2 )
type bzip2 || ( (echo "The bzip2 command doesn't appear to exist.") >&2 ; exit 2 )
type ccrypt || ( (echo "The ccrypt command doesn't appear to exist.") >&2 ; exit 2 )

echo $TARGET $NAME $DEST $FULLPATH $PASSWORD

dump -0Lauf - /dev/ad0s1d | bzip2 -cz | ccrypt -E PASSWORD > $FULLPATH/`hostname`_`date "%Y-%m-%d_%H.%M"`.dbzc

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
