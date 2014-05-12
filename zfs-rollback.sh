#!/usr/bin/bash
#
# Dr. Martin Menzel
# Dr. Menzel IT - www.dr-menzel-it.de
# 11.08.2013
#
# Use at your own risk. No warranty. No fee.
#
# parameter list:
#   (1) the filesystem to be used to start decendant recursion
#       example: apool/zones/webzone
#   (2) the snapshot to which the filesystems should be rolled back
#       example: @2013-07-21-083500
#
for snap in `zfs list -H -t snapshot -r $1 | grep "$2" | cut -f 1`; do
        # -r : also destroys the snapshots newer than the specified one
        # -R : also destroys the snapshots newer than the one specified and their clones
        # -f : forces an unmount of any clone file systems that are to be destroyed
        echo -n "rolling back to [$snap] : ";zfs rollback -r -R -f $snap;       echo "  Done."
done
