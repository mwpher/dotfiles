# Make it impossible to login to root directly in multi-user mode, or to login to root without a password while in single-user mode.
sed 's/secure/insecure/g' /etc/ttys > /tmp/ttys-secure ; mv /tmp/ttys-secure /etc/ttys

# Restrict cron to root
echo "root" > /var/cron/allow
echo "root" > /var/at/at.allow
chmod o= /etc/crontab
chmod o= /usr/bin/crontab
chmod o= /usr/bin/at
chmod o= /usr/bin/atq
chmod o= /usr/bin/atrm
chmod o= /usr/bin/batch

# Keep important files away from non-root users
chmod o= /etc/fstab
chmod o= /etc/ftpusers
chmod o= /etc/group
chmod o= /etc/hosts
chmod o= /etc/hosts.allow
chmod o= /etc/hosts.equiv
chmod o= /etc/hosts.lpd
chmod o= /etc/inetd.conf
chmod o= /etc/login.access
chmod o= /etc/login.conf
chmod o= /etc/newsyslog.conf
chmod o= /etc/rc.conf
chmod o= /etc/ssh/sshd_config
chmod o= /etc/sysctl.conf
chmod o= /etc/syslog.conf
chmod o= /etc/ttys

# Restrict Log Access so attackers can't hide their activities
chmod o= /var/log
chflags sappnd /var/log
chflags sappnd /var/log/*

# Users shouldn't be running these
chmod o= /usr/bin/users
chmod o= /usr/bin/w
chmod o= /usr/bin/who
chmod o= /usr/bin/lastcomm
chmod o= /usr/sbin/jls
chmod o= /usr/bin/last
chmod o= /usr/sbin/lastlogin

# Things that nobody should really be using
chmod ugo= /usr/bin/rlogin
chmod ugo= /usr/bin/rsh

########
# Add any other programs that only root should use here
# chmod o= /usr/local/bin/nmap
# chmod o= /usr/local/bin/nessus
clear_tmp_enable="YES"
