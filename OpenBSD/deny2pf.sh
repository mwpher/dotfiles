#!/bin/sh
[ -e /etc/hosts.deniedssh ] || exit 1

cat /etc/hosts.deniedssh | sed 's/^.*(\b(?:\d{1,3}\.){3}\d{1,3}\b).*$/\1\n/g' > /etc/pf.bruteforcers
