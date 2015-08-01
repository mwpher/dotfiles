rsync -Pvrh --size-only --delete \
	--exclude-from=rsync_exclude.txt \
	/cygdrive/e/ \
	matt@192.168.1.29:/mnt/Data/Matt/E-Drive/
