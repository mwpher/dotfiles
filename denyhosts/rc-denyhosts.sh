#!/bin/sh
#
# $FreeBSD: head/security/denyhosts/files/denyhosts.in 340872 2014-01-24 00:14:07Z mat $
#
# PROVIDE: denyhosts
# REQUIRE: DAEMON
#

. /etc/rc.subr

name="denyhosts"
rcvar=denyhosts_enable

command="/usr/local/bin/denyhosts.py"
command_interpreter="/usr/local/bin/python2.7"
command_args="--config /usr/local/etc/denyhosts.conf --daemon"
pidfile="/var/run/${name}.pid"

load_rc_config $name

: ${denyhosts_enable="NO"}

run_rc_command "$1"
