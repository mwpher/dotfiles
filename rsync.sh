RC=1 
while [[ RC -ne 0 ]]
do

	rsync -Pvrh --size-only --delete \
		--exclude-from=rsync_exclude.txt \
		/cygdrive/e/ \
		Matthew@192.168.1.29:/mnt/Data/Matt/E-Drive/
	RC=$?
done
