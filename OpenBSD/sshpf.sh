#!/bin/sh

[ -e /etc/hosts.deniedssh ] || touch /etc/hosts.deniedssh
[ -e /var/log/sshpf ] || touch /var/log/sshpf

[ -r /var/log/authlog ] || exit -2

[ -w /etc/hosts.deniedssh ] || exit 1
[ -w /var/log/sshpf ] || exit -1


