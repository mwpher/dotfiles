#! /bin/bash

# /usr/local/sbin/mktwpol.sh

[[ "${EUID}" != "0" ]]		&& echo " Got root?"		&& exit
[[ ! "${BASH}" =~ "bash" ]]	&& echo " ${0##*/} needs bash"	&& exit

VERSION=06JAN11		# c.cboldt at gmail.com

# A Gentoo-oriented Tripwire Policy Text Generator
# Creates tripwire policy text from lists of package names
# Obtains lists of files associated with a package by reading from /var/db/pkg
#
# - Make sure packages critical to YOUR system are named in a PACKAGES[] list !!
#   (many package names are noted in default lists, but my view is myopic)
# - Optional mktwpol.cfg (or other) script configuration file can be used to:
#	- set default command-line switches
#	- substitute, augment, or modify package lists and file lists

# Tripwire configuration is extracted from tw.cfg (not the text file), if it exists.
# The twcfg.txt file can be removed, for (cough, cough) security purposes.
# The script reads from twcfg.txt, when tw.cfg hasn't been created yet.

TW_CFG=${TW_CFG:=/etc/tripwire/tw.cfg}

# Brief description of array variables used to generate tripwire policies
# =======================================================================
# RULENAME[]	Rule Name, unique to avoid errors by tripwire --init
# PACKAGES[]	Optional list of package names under this Rule Name
# IGNORLST[]	Optional list of files to ignore under this Rule Name
# FILELIST[]	Optional lists of individual file names (wildcards okay)
# COMMENTS[]	Optional comments associated with FileList
# SEVERITY[]	defaults to 100   - written rule-by-rule
#  EMAILTO[]	defaults to empty - written rule-by-rule
#
# Optional rule-by-rule Security *Aliases* for File Property Inspection Masks
# ===========================================================================
#  BIN_SEC[]	defaults to ReadOnly - also applies to files in lib/
#  ETC_SEC[]	defaults to Dynamic  - also applies to Directories
#  LOG_SEC[]	defaults to Growing
#
# Optional list-by-list modifications to default or defined Inspection Masks
# ==========================================================================
#  SEC_MOD[]	defaults to empty - written file-by-file across PACKAGE or FILELIST
#  SFT_MOD[]	defaults to empty - when assigned, applies only to SoftLinks
#  RECURSE[]	defaults to (recurse=true) - when assigned, applies only to Directories
#   EXCEPT[]	defaults to empty - "special" file(s) in expanded wildcard list
#   SEC_EX[]	defaults to empty - *non-alias* security rule for "special" files

# The script handles variables for multiple filelists within a single rule
#   - Useful for specializing Comments and Inspection Masks
# FILELIST_x variable names MUST be sequential, starting with "x" = "2"
# Available correlated variables: COMMENTS_x, SEC_MOD_x, SFT_MOD_x, and RECURSE_x

###########  Start Default Package Lists and RuleName Definitions

# Note:	Script configuration file can replace or augment the default set of rules

  RULENAME[0]='System Auditing Programs'
  PACKAGES[0]='tripwire aide chkrootkit lynis nagios openscap osiris rkhunter yasat'
   EMAILTO[0]='"root@localhost"'
   ETC_SEC[0]='ReadOnly'
COMMENTS_2[0]='Audit programs data directories'
FILELIST_2[0]="/var/lib/rkhunter/db"
 RECURSE_2[0]=' (recurse = 0)'
 SEC_MOD_2[0]=' -sbmcCM'

RULENAME[1]='Invariant Directories'
COMMENTS[1]='Owner and group should remain static'
FILELIST[1]='/ /home /etc /mnt /opt'
SEVERITY[1]='66'
 ETC_SEC[1]='Invariant'
 RECURSE[1]=' (recurse = 0)'

RULENAME[2]='Temporary Directories'
FILELIST[2]='/usr/tmp /var/tmp /tmp'
SEVERITY[2]='33'
 ETC_SEC[2]='Invariant'
 RECURSE[2]=' (recurse = 0)'

RULENAME[3]='[core|diff|find]utils procps'
PACKAGES[3]='coreutils diffutils findutils procps htop lsof'

# Disambiguation by including category with a package name is superfluous
# The script only prints rules for packages that are installed, and then
# only for files that are tested to exist

RULENAME[4]='Compression/Archiving Programs'
PACKAGES[4]="tar star bzip2 app-arch/gzip zip unzip xz-utils app-arch/lzma"

RULENAME[5]='Network - Setup/Services'
PACKAGES[5]="net-tools iproute2 iputils dhcpcd ppp \
 madwifi-ng-tools \
 bind bind-tools djbdns dnsmasq maradns mydns pdns pdnsd unbound \
 distcc mgetty rsync samba telnet-bsd netkit-talk ytalk"
 ETC_SEC[5]='ReadOnly'

RULENAME[6]='Network - Filter/View'
PACKAGES[6]="tcpdump tcp-wrappers mrtg netcat nmap wireshark \
 iptables denyhosts fail2ban knock"
 ETC_SEC[6]='ReadOnly'

RULENAME[7]='Hardware and Device Programs'
PACKAGES[7]="udev pciutils util-linux psmisc kbd hdparm smartmontools \
 lshw ethtool hotplug-base module-init-tools setserial dmraid"
COMMENTS[7]='udev device creation policies and scripts'
FILELIST[7]='/etc/udev/rules.d /etc/udev/scripts'

# progsreiserfs produces no bin/ or /etc/ files  ...
# it produces  /usr/lib/libdal.so and /usr/lib/libreiserfs.so

RULENAME[8]='Filesystem Programs'
PACKAGES[8]="e2fsprogs reiserfsprogs reiser4progs xfs nfs jfs \
 pax-utils sysfsutils autofs lvm2 mdadm fuse sshfs-fuse"
COMMENTS[8]='From progsreiserfs'
FILELIST[8]='/usr/lib/libdal.* /usr/lib/libreiserfs.*'

RULENAME[9]='File Manipulation Programs'
PACKAGES[9]="gawk grep patch cpio file gettext groff less sys-apps/man mlocate \
 ncurses slang sed slocate patchutils debianutils"

RULENAME[10]='Toolchain Programs'
PACKAGES[10]='gcc binutils glibc libtool make autoconf automake'
COMMENTS[10]='From sys-devel/autoconf-wrapper'
FILELIST[10]='/usr/lib/misc/ac-wrapper.sh'

RULENAME[11]='Security Related Programs'
PACKAGES[11]='shadow sys-libs/pam openssl openssh gnupg'

RULENAME[12]='Database Related Programs'
PACKAGES[12]='dev-db/mysql postgresql-server sqlite'

RULENAME[13]='Programming Languages'
PACKAGES[13]='perl dev-lang/python ruby swig tcl tk'

RULENAME[14]='MTA Related Programs'
PACKAGES[14]='sendmail postfix ssmtp mail-client/mailx procmail dovecot clamav spamassassin'

RULENAME[15]='IRC/P2P Related Programs'
PACKAGES[15]="net-irc/inspircd irc-server ircservices ngircd ptlink-ircd \
 ejabberd jabberd jabberd2 mu-conference"

RULENAME[16]='WWW Related Programs'
PACKAGES[16]="apache bozohttpd lighttpd mini_httpd thttpd \
 dev-haskell/cgi dev-libs/cgicc dev-libs/fcgi \
 www-apache/mod_fastcgi www-apache/mod_fcgid www-apache/mod_scgi \
 dev-lang/php php-toolkit phpBB"

RULENAME[17]='Shell Programs'
PACKAGES[17]='bash zsh csh tcsh sash rssh busybox screen'
 ETC_SEC[17]='ReadOnly'

RULENAME[18]='Editor Programs'
PACKAGES[18]='nano joe vim ed emacs'
COMMENTS[18]='Shared config files'
FILELIST[18]='/usr/share/nano'

# Detect new and removed user crontabs.  Ignore modification of existing crontabs.

RULENAME[19]='Cron, Inetd, and Logging'
PACKAGES[19]="anacron bcron cronie dcron fcron incron vixie-cron xinetd \
 newsyslog rsyslog syslog-ng logrotate tmpwatch"
COMMENTS[19]='User-installed crontabs'
FILELIST[19]='/var/spool/cron/crontabs'

  RULENAME[20]='Boot Selector and Kernel'
  PACKAGES[20]='grub lilo kccmp kerneloops ksymoops module-rebuild'
  COMMENTS[20]='Contents of /boot directory are safer on an unmounted partition'
  FILELIST[20]='/boot/* /lib/modules'
COMMENTS_2[20]='Detect current mounting of /boot'
FILELIST_2[20]='/boot'
 SEC_MOD_2[20]=' +mc'

  RULENAME[21]='Package Manager Programs'
  PACKAGES[21]='pacman paludis rpm'

# process_packagename routine filters out */lib/* filenames, but captures *.sh
# If a packages installs scripts without the .sh suffix,
# FILELIST[] can be used to assign rules for scripts installed in /lib/rcscripts

  RULENAME[22]='Gentoo Specific Programs'
  PACKAGES[22]='sys-apps/portage portage-utils gentoolkit baselayout openrc sysvinit eix'
#  COMMENTS[22]='Gentoo-installed scripts'
#  FILELIST[22]='/lib/rcscripts/*/*'
  COMMENTS[22]='Local ebuilds - skip "files" subdirs'
  FILELIST[22]='/usr/local/portage'
   SEC_MOD[22]=' +M'
   RECURSE[22]=' (recurse = 3)'
COMMENTS_2[22]='/usr/lib/pkgconfig is active at package add/remove'
FILELIST_2[22]='/usr/lib/pkgconfig'
 SEC_MOD_2[22]=' -mc'
 RECURSE_2[22]=' (recurse = 0)'

#####  End of PACKAGES[] package lists  #####
#####  Some   FILELIST[] rules below cribbed from Red Hat policy file

# Some local config files, not owned by a package, can be found with:
# for i in `locate --ignore-case --regexp etc.*local`
#   do [ -z "`qfile $i`" ] && echo $i
# done
#
# If one wants to find SUID and SGID files ...
# find / -group kmem -perm -2000 -print # Finds SGID files, owned by kmem
# find /  -user root -perm -4000 -print # Finds SUID files, owned by root

RULENAME[23]='Local Config Files'
FILELIST[23]="/etc/bash/bashrc.local \
 /etc/dovecot/dovecot-local.conf \
 /etc/dnsmasq-local.conf \
 /etc/env.d/00Local \
 /etc/host-local-block \
 /etc/host-banner-ads \
 /etc/hosts \
 /etc/hosts.allow \
 /etc/hosts.deny \
 /etc/lilo.conf \
 /etc/lynx/lynx-site.cfg \
 /etc/ppp/chap-secrets \
 /etc/ppp/ip-up.d/00-local.sh \
 /etc/ppp/ip-down.d/00-local.sh \
 /etc/rkhunter.conf.local \
 /etc/screenrc-local \
 /etc/syslog-ng/syslog-local.conf \
 /etc/udev/rules.d/10-local.rules"
ETC_SEC[23]='ReadOnly'

# Avoids opening devices (recursion) by applying the $(Device) policy to
# block and character special devices.  See "select_policy" routine.
# Assumed that Inode changes for listed /dev files, most under creation by udev
# Note:	A number of changes occur when moving from 2.6.34 to 2.6.35 kernels
#	- /dev/files device number  changes, from "9" to "10"
#	- /proc file inode  numbers change

  RULENAME[24]='Critical Devices'
  COMMENTS[24]='Red Hat config named kmem, mem, null, zero'
  FILELIST[24]="/dev/kmem /dev/mem /dev/null /dev/zero \
 /dev/console /dev/cua0 /dev/initctl /dev/log \
 /dev/tty[0-9] /dev/tty1[012] /dev/urandom"
   SEC_MOD[24]=' -i'
COMMENTS_2[24]='/proc/mounts softlink undergoes time modification'
FILELIST_2[24]='/proc/*'
 SFT_MOD_2[24]=' -mc'

# Note:	Stifle the temptation to use EXCEPT[]/EX_SEC[] for /lib/splash/cache
#	EXCEPT[] requires the listed name appear in expanded FILELIST[] wildcard
# Use (recurse = 0) (or 1), rather than IGNORLST, to limit range of inspection

  RULENAME[25]='OS Bin and Lib Directories'
  FILELIST[25]='/bin /sbin /lib'
   ETC_SEC[25]='ReadOnly'
COMMENTS_2[25]='/lib/splash/cache is an active directory'
FILELIST_2[25]='/lib/splash/cache'
 RECURSE_2[25]=' (recurse = 0)'

# Note:	Inspection of /usr/lib/pkgconfig should be expanded on a system
#	that has a fixed or stable set of installed packages.

  RULENAME[26]='User Bin and Lib Directories'
  COMMENTS[26]=
  FILELIST[26]="/usr/bin /usr/sbin /usr/local/bin /usr/local/games /usr/local/sbin \
 /usr/local/lib"
  SEVERITY[26]='66'
   ETC_SEC[26]='ReadOnly'
COMMENTS_2[26]='Full recursion of /usr/lib is prolix'
FILELIST_2[26]='/usr/lib'
 RECURSE_2[26]=' (recurse = 1)'

# Note:	logrotate can create false alarms
#  - new log file will be smaller than tripwire observation at database creation
#  - logrotate.conf 'nocreate' option can result in alarms at absent log files
# Note: "SEC_MOD=-il" removes the "Growing" test for ALL /var/log files, which
#	makes the "EXCEPT[] / SEC_EX[]" example moot, as a practical matter.
#	It might be feasible to set observed filesize of usually growing logs
#	to a very small value, to enable use of "growing" check, but this moots
#	the point of looking for unauthorized tampering based on shrinking file.
#	Tripwire compares to a "fixed" reference point of day-0, and is unsuited
#	to detect log file tampering based on day-to-day size reduction.
# Note: permissions of /var/log/rkhunter.log change during a --propupd operation
#	going from -rw-r--r-- to -rw-------
#
# Exception for log files in /var/log/*g wildcard, that don't necessarily grow

  RULENAME[27]='Log Files'
  COMMENTS[27]='`logrotate` may change logfile inodes'
  FILELIST[27]='/var/log/critical /var/log/messages /var/log/*g'
  SEVERITY[27]='66'
   SEC_MOD[27]=' -il'
    EXCEPT[27]='/var/log/rkhunter.log /var/log/Xorg.0.log'
    SEC_EX[27]='$(Dynamic) -i'

# Note: Stifling creation of .xauth?????? files is done under xauth program
#	These .xauth?????? files are made by action of a regular user, who uses
#	`su`.  The regular user can stifle creation of .xauth?????? files in
#	/root by adding "export XAUTHORITY=.xauth" in the regular user's .bashrc
#	** but ** this affects display opening permissions under X-win!

RULENAME[28]='Root User Directory'
IGNORLST[28]="/root/.lesshst /root/.bash_history \
 /root/.aumixrc /root/.calc_history \
 /root/.fonts.cache-1 \
 /root/.lynx_cookies \
 /root/.mysql_history \
 /root/.rnd \
 /root/.sc_history \
 /root/.stack.wcd /root/.treedata.wcd /root/bin/wcd.go"
COMMENTS[28]='Config and files for console applications'
FILELIST[28]="/root \
 /root/.bashrc /root/.bash_profile /root/.bash_logout \
 /root/.cshrc /root/.tcshrc /root/.screenrc \
 /root/.htoprc /root/.mc /root/.ncftp \
 /root/Mail /root/mail \
 /root/.elm /root/.pinerc /root/.pinepwd \
 /root/.mailcap /root/.mime.types \
 /root/.addressbook.lu /root/.addressbook /root/.sendxmpprc \
 /root/.links /root/.lynxrc \
 /root/.riprc /root/.sversionrc \
 /root/.esd_auth"
COMMENTS_2[28]='Action in these directories will trigger a warning'
FILELIST_2[28]="/root/bin /root/.ssh /root/.amandahosts /root/.gnupg"
 SEC_MOD_2[28]=' +srbmcCM'
COMMENTS_3[28]='X-Windows should not be run as Root User!'
FILELIST_3[28]="/root/.ICEauthority /root/.xsession-errors /root/.Xresources /root/.Xmodmap \
 /root/.config  /root/.enlightenment /root/.fltk /root/.fvwm /root/.fvwmrc \
 /root/.gconf /root/.gconfd \
 /root/.gnome /root/.gnome2 /root/.gnome_private /root/.gnome-desktop \
 /root/.qt /root/.sawfish \
 /root/.xauth"
COMMENTS_4[28]='Files that change inode number'
FILELIST_4[28]='/root/.Xauthority'
 SEC_MOD_4[28]=' -i'

# Using an incrementing variable instead of hardcoded rule number.
# Using a variable for this is especially useful when adding rules from cfg file.

let NEXT=${#RULENAME[@]}
  RULENAME[${NEXT}]='Security Control File'
  FILELIST[${NEXT}]='/etc/security'
   ETC_SEC[${NEXT}]='ReadOnly'

let NEXT=${#RULENAME[@]}
  RULENAME[${NEXT}]='System Boot Changes'
  COMMENTS[${NEXT}]='Many files change inode number'
  FILELIST[${NEXT}]='/etc/mtab /var/run /var/run/dhcpcd /var/run/sudo'
   SEC_MOD[${NEXT}]=' -i'
   RECURSE[${NEXT}]=' (recurse = 1)'
COMMENTS_2[${NEXT}]='Red Hat Policy File: Files that change when the system boots'
FILELIST_2[${NEXT}]='/etc/ioctl.save /etc/.pwd.lock /var/lock/subsys'
 SEC_MOD_2[${NEXT}]=' -i'

###########  End Default Package Lists and RuleName Definitions

###########  Subroutines for Generating Policy Text Output
#################################################################

# "select_policy" routine runs each filename through a gauntlet
# $Filetype assignment is based on which attribute matched last.

select_policy ()
{
						   Filetype=Config	# Default
  [[ $targetfile =~ ^/etc/ ]]			&& Filetype=Config
  [[ $targetfile =~ /lib/ ]]			&& Filetype=Lib
  [[ $targetfile =~ /log/ ]]			&& Filetype=Log
  [[ $targetfile =~ ^/root/ ]]			&& Filetype=RootFile
  [ -x $targetfile ]				&& Filetype=Bin
  [ -b $targetfile ]				&& Filetype=Block
  [ -c $targetfile ]				&& Filetype=Char
  [ -p $targetfile ]				&& Filetype=Pipe
  [ -S $targetfile ]				&& Filetype=Socket
  [ -d $targetfile ]				&& Filetype=Dir
  [[ "`file -b $targetfile`" =~ kernel ]]	&& Filetype=Kernel
  [[ $targetfile =~ ^/lib/modules ]]		&& Filetype=Kernel
  [ -h $targetfile ]				&& Filetype=SoftLink
  [[ $targetfile =~ ^/dev/tty ]]		&& Filetype=Tty
  [ $targetfile == "/root" ]			&& Filetype=RootDir
  [ ! -d $targetfile ] && \
  [ -u $targetfile -o -g $targetfile ]		&& Filetype=SUID
  [[ "${EXCEPT[$i]}" =~ $targetfile ]]		&& Filetype=Special

case $Filetype in
  Dir	   )	echo "-> \$(${ETC_SEC[$i]:-Dynamic})${SEC_MOD[$i]}${RECURSE[$i]} ;"	;;
  RootFile )	echo "-> \$(${ETC_SEC[$i]:-Dynamic})${SEC_MOD[$i]} ;  # Rootfile"	;;
  RootDir  )	echo "-> \$(IgnoreNone)-amcSH ;  # Catch changes to /root"	;;
  Config   )	echo "-> \$(${ETC_SEC[$i]:-Dynamic})${SEC_MOD[$i]} ;"		;;

  Kernel   )	echo "-> \$(${BIN_SEC[$i]:-ReadOnly})${SEC_MOD[$i]} ;  # Kernel"	;;
  Bin	   )	echo "-> \$(${BIN_SEC[$i]:-ReadOnly})${SEC_MOD[$i]} ;"		;;
  Lib	   )	echo "-> \$(${BIN_SEC[$i]:-ReadOnly})${SEC_MOD[$i]} ;"		;;
  SoftLink )	echo "-> \$(SoftLink)${SFT_MOD[$i]} ;  # Softlink"		;;

  Log	   )	echo "-> \$(${LOG_SEC[$i]:-Growing})${SEC_MOD[$i]} ;"		;;
  SUID	   )	echo "-> \$(IgnoreNone)-aSH ;  # SUID or SGID"			;;
  Tty      )	echo "-> \$(Dynamic)-ipug ;"					;;
  Char	   )	echo "-> \$(Device) ;  # Character device"			;;
  Block	   )	echo "-> \$(Device) ;  # Block device"				;;
  Pipe	   )	echo "-> \$(Device) ;  # Pipe"					;;
  Socket   )	echo "-> \$(Device) ;  # Socket"				;;
  Special  )	echo "-> ${SEC_EX[$i]} ; # Exception"				;;
esac
}

print_header ()
{
# if there is no config file for this script, print warning.
# if there is a config file for this script, search it for a rulename assignment
# if the config file has no rulename assignment, print warning.

[ ! -r "$CONFIG_FILE" ] && default_rule_warning
[ -r "$CONFIG_FILE" ] && \
[ -z "`grep -l RULENAME\\\[.*\\\]= $CONFIG_FILE`" ] && default_rule_warning

echo "  # ==================================================="
echo "  # Tripwire Policy File  http://bugs.gentoo.org/344577"
echo "  # ==================================================="
echo "  # Generated by $0"
echo "  # Version $VERSION"
echo "  # `date '+%B %e, %Y at %R'`"
echo
echo '  # ============================================================================'
echo '  #'
echo '  # Tripwire, Inc. permission statements apply to some fully hardcoded document,'
echo "  # not to generated content produced by the script, ${0##*/}"
echo '  #'
echo '  # That said, here are the Tripwire, Inc. permission statements ...'
echo '  #'
echo '  # Permission is granted to make and distribute verbatim copies of this document'
echo '  # provided the copyright notice and this permission notice are preserved on all'
echo '  # copies.'
echo '  #'
echo '  # Permission is granted to copy and distribute modified versions of this'
echo '  # document under the conditions for verbatim copying, provided that the entire'
echo '  # resulting derived work is distributed under the terms of a permission notice'
echo '  # identical to this one.'
echo '  #'
echo '  # Tripwire is a registered trademark of Tripwire, Inc.'
echo '  # (in the United States and other countries)'
echo '  # All rights reserved.'
echo '  #'
echo '  # ============================================================================'
echo
echo "@@section GLOBAL"
echo "HOSTNAME=\"`hostname`\" ;"
echo
echo '  # Standard Tripwire File Property Mask Aliases (from `man twpolicy`)'
echo '  # --------------------------------------------'
echo '  #	ReadOnly	+pinugtsdbmCM-rlacSH'
echo '  #	Dynamic		+pinugtd-srlbamcCMSH'
echo '  #	Growing		+pinugtdl-srbamcCMSH'
echo '  #	Device		+pugsdr-intlbamcCMSH'
echo '  #	IgnoreAll	-pinugtsdrlbamcCMSH'
echo '  #	IgnoreNone	+pinugtsdrbamcCMSH-l'
echo
echo '@@section FS'
echo
echo '  #   Non-standard File Property Mask Aliases'
echo '  # --------------------------------------------'
echo '  	Invariant	= +pugt ;	 # Permissions, UID, GID, and filetype'
echo '  	SoftLink	= +pinugtsdbmc ; # Skip checking hash values'
echo
echo '# ================== [ Begin Hardcoded Tripwire Rules ] ======================'
echo
echo '('
echo '  rulename = "Tripwire CFG and Data",'
echo '  severity = 100'
echo ')'
echo '{'
echo "  # Tripwire file locations were transposed from ${TW_CFG}"
echo '  # Tripwire creates backup files by renaming tw.cfg and tw.pol,'
echo '  # then creating new files.  The new files have new inode numbers.'
echo "  # Database and backup files in ${DBDIR} do not appear to change inode."
echo
echo "  ${TWCFG_DIR}/tw.cfg			-> \$(ReadOnly) -i ;"
echo "  ${POLFILE}			-> \$(ReadOnly) -i ;"
echo "  ${SITEKEYFILE}		-> \$(ReadOnly) ;"
echo "  ${LOCALKEYFILE}	-> \$(ReadOnly) ;"
echo "  ${DBDIR}			-> \$(Dynamic) ;"
echo
echo '  # Do not scan individual `tripwire --check` reports'
echo
echo "  ${REPORTDIR}		-> \$(Dynamic) (recurse = 0) ;"
echo '}'
echo
echo '# ================== [ Begin Generated Tripwire Rules ] ======================'
}

print_footer ()
{
echo
echo '# ============================================================================'
echo '#'
echo '# Hardcoded and generated output is based on:'
echo '#'
echo '#	- tripwire.pol.gentoo : Darren Kirby : September 5, 2006'
echo '#	  http://bugs.gentoo.org/34662'
echo '#	- Policy file for Red Hat Linux : V1.2.0rh : August 9, 2001'
echo '#	- FreeBSD: ports/security/tripwire/files/twpol.txt : v 1.3 : 2005/08/09'
echo '#	  http://lists.freebsd.org/pipermail/freebsd-security/2005-October/003221.html'
echo '#	- Examples found in tripwire-2.4.2-src.tar.bz2 source code distribution'
echo '#'
echo '# FreeBSD is a registered trademark of the FreeBSD Project Inc.'
echo '# Red Hat is a registered trademark of Red Hat, Inc.'
echo '#'
echo '#################      END of tripwire Policy Text File      #################'
echo
}

###########  Cycle through RULENAME variable arrays

# "print_generated_rules" routine cycles each group of array variables through "print_a_rule"

print_generated_rules ()
{
for (( i = 0 ; i < ${#RULENAME[@]} ; i++ ))
do
  [ "${QUIET^^}" != "YES" -a "${VERBOSE^^}" != "YES" ] && \
  echo -n -e "\\r Processing rule $i of $[(10#${#RULENAME[@]}-1)] rules" >&2
  print_a_rule
done
[ "${QUIET^^}" != "YES" ] && echo >&2
}

# -------------------------------
# "print_a_rule" routine runs once for each RULENAME[]
#   - make a title header for the tripwire rule, including optional "emailto" field
#   - print ignorefiles, if any
#   - forward proposed package names, one-by-one, to process_packagename
#   - forward filelist array(s), if any, to process_filelist

print_a_rule ()
{
echo
echo "# ========================================================================="
echo "#  RuleName: ${RULENAME[$i]}"
echo "# -------------------------------------------------------------------------"
[ -n "${PACKAGES[$i]}" ] && echo " Packages: ${PACKAGES[$i]}" | eval ${FOLD} | sed s/^/"# "/
[ -n "${FILELIST[$i]}" ] && echo "FileNames: ${FILELIST[$i]}" | eval ${FOLD} | sed s/^/"# "/
echo "# ========================================================================="
echo \(
echo "  rulename = \"${RULENAME[$i]}\","
echo -n "  severity = ${SEVERITY[$i]:-100}"
[ -n "${EMAILTO[$i]}" ] && echo -e ",\\n  emailto = ${EMAILTO[$i]}" || echo
echo \)
echo \{

[ -n "${IGNORLST[$i]}" ] && \
  echo -e "\\n# ${RULENAME[$i]}: Ignore changes to these files\\n"
for targetfile in ${IGNORLST[$i]}
  do [ -e "$targetfile" ] && echo "  !$targetfile ;"
done

if [ "${SKIP_PACKAGES}" == "Yes" ]; then
   [ ! -z "${PACKAGES[$i]}" ] && \
   echo -e "\\n# !! NOTICE !!\\n# Skipping ${RULENAME[$i]} Packages !!"
else
  for package in ${PACKAGES[$i]}
    do process_packagename
  done
fi

[ -n "${FILELIST[$i]}" ] && process_filelist

# Code to process pseudo-two-dimensional arrays.
# FLST, CMTS, SCMD, SFMD, and RCRS hold numerically-specific variable names,
# Those variable names are in the style of an array name, e.g., FILELIST_2[26]
# The specific variable names are then indirectly expanded to their contents

for j in {2..100}; do
  FLST=FILELIST_$j[$i]
  CMTS=COMMENTS_$j[$i]
  SCMD=SEC_MOD_$j[$i]
  SFMD=SFT_MOD_$j[$i]
  RCRS=RECURSE_$j[$i]
  FILELIST[$i]="${!FLST}"
  COMMENTS[$i]="${!CMTS}"
  SEC_MOD[$i]="${!SCMD}"
  SFT_MOD[$i]="${!SFMD}"
  RECURSE[$i]="${!RCRS}"
  [ -n "${FILELIST[$i]}" ] && process_filelist  || break
done

echo \}
}

# -------------------------------
# "process_packagename" routine is applied to every listed package name
#   - to qualify for being listed in tmp_array[], and eventually in policy text file:
#     - $targetfile contains "bin/", begins "/etc/" or "/var/log/", or ends ".sh"
#     - $targetfile is not a directory or zero-size file
#   - calls filename and rule printing subroutines for each targetfile in $tmp_array[]
# Note: adding "lib/" results in MUCH longer list, and is not necessary because
#       all files in "/usr/lib" and "/usr/local/lib" directories can be watched
#       under a FILELIST[] rule, albeit not associated with a particular package
# Note: adding a test for executables also results in a MUCH longer list

# DEBUGME

process_packagename ()
{
unset tmp_array
[[ "${package}" =~ "/" ]] || package="*/${package}"
for package_contents_file in `ls /var/db/pkg/${package}-[0-9]*/CONTENTS 2> /dev/null`; do
tmp_array+=(`
  while read -a line
  do fname=${line[@]:1:1}
    case $fname in
	/etc/hosts )
	true ;;
	*bin/* | /etc/* | /var/log/* | *.sh )
	[ ! -d ${fname} -a -s ${fname} ] && echo $fname ;;
# uncomment the default (*) "case" to include executable files
#	* )
#	[ ! -d ${fname} -a -x ${fname} ] && echo $fname ;;
    esac
  done < ${package_contents_file}`)
done

if [ -n "${tmp_array}" ]; then		# Empty array results in NUL output
  echo
  echo "# ${RULENAME[$i]}: $package"
  echo
  for targetfile in ${tmp_array[@]}; do
    output_line; select_policy
  done
fi
}

# -------------------------------
# "process_filelist" routine is used only for FILELIST[] arrays
#   - outputs COMMENTS[], if any, for FILELIST[] array
#   - if file exists, calls for printing filename and tripwire policy
#   - blocks listing of:
#	- any file named "lost+found"
#	- any directory in the /proc/* wildcard

process_filelist ()
{
echo -e "\\n# ${RULENAME[$i]}: ${COMMENTS[$i]}\\n"
for targetfile in ${FILELIST[$i]}; do
  case ${targetfile} in
    */lost+found* )
	true
	;;
    /proc/* )
	if [ ! -d "$targetfile" ]; then
	  output_line; select_policy; fi
	;;
    * )
	if [ -e "$targetfile" ]; then
	  output_line; select_policy; fi
	;;
  esac
done
}

# -------------------------------
# "output_line" routine adds a variable number of tabs to obtain alignment
# The width of the targetfile name is increased by 2 to account for indent
# The maximum number of additional tabs is the digit after "10#"
# The width of the TAB is taken as 8 characters

output_line ()
{
  MAKE_TABS=$[(10#4-(${#targetfile}+2)/8)]	# Calculate number of TABs
  echo -n "  $targetfile"
  echo -e -n \\t				# Output at least one TAB
  for (( z = 0 ; z < MAKE_TABS ; z++ ))		# Up to five TABs, total
  do
    echo -e -n \\t
  done
}

###########  Main Routine for Generating Policy Text Output
#################################################################

print_policy_text ()
{
print_header
print_generated_rules
print_footer
}

###########  Subroutines for the User Interface
#################################################################

###########  Subroutines for Informing the User

# Most messages sent to STDERR and only STDERR (>&2)
#  - to avoid appearing in redirected STDOUT output (the text policy)
#  - to avoid disappearing from view when STDOUT has been redirected

default_rule_warning ()
{
echo
echo "  #############       !!!!  WARNING  !!!!      #############"
echo "  #  Default policies may be useless on your system ...    #"
echo "  #   - the script may have overlooked critical packages   #"
echo "  #   - tripwire inspection policies may be too lax        #"
echo "  ##########################################################"
echo
echo "  #  To view scope of tripwire inspection policies:"
echo "  #  \`twprint -m d -d ${DBFILE}\`"
echo
}

recite_ver ()
{
echo "
 This is ${0##*/} version $VERSION
 A Gentoo-oriented Tripwire Policy Text Generator
" >&2
}

recite_help ()
{
recite_ver
echo " Usage: ${0##*/} [-c configfile] [-u[-r][-q|-v]] [-s] [-h|-V] [debug [#]]

	-c Read RULENAME[], PACKAGELIST[], FILELIST[] from configfile
	   Default (optional) configfile = $TWCFG_DIR/mktwpol.cfg
	-u Create tripwire policy and database after producing policy text file
	-r Remove policy text file after tripwire has processed it
	-q Quiet   - stifle progress display and confirmation prompts
	-v Verbose - display policy text production
	-s Skip processing of PACKAGELIST[] arrays
	-h Output version and help information
	-V Output version information

 \`${0##*/}\` without \"-u\" command line parameter:
	- sends policy text to STDOUT, suitable for redirection with \">\"

 \`${0##*/} -u\`  produces no policy on STDOUT. WON'T REDIRECT!
	- sends policy text to a file in $TWCFG_DIR
	- calls \`twadmin\`  to create tw.pol from that file
	- calls \`tripwire\` to create the system database using tw.pol

 \`${0##*/} debug\`
	- limits output to one selected rule, default RULENAME[0]
" >&2
exit
}

###########  Subroutines for Configuring the Script

assign_misc_mktwpol_defaults ()
{
# Default settings unless changed by script configuration file

# FOLD="${FOLD:=fold -s -w 75}"
FOLD="${FOLD:=fmt -u}"

# User may change ${TW_CFG} from CONFIG_FILE
# Multiple tripwire configuration locations can be maintained this way

# mktwpol.sh -c mktwpol.cfg1 -> /etc/tripwire1/tw.cfg (and /etc/tripwire1/twcfg.txt)
# mktwpol.sh -c mktwpol.cfg2 -> /etc/tripwire2/tw.cfg (and /etc/tripwire2/twcfg.txt)

TWCFG_DIR=${TW_CFG%/*}		# bash shell equivalent to the `dirname` command
}


# -------------------------------
# "config_mktwpol" checks for and reads a script configuration file

config_mktwpol ()
{
TWCFG_DIR=${TW_CFG%/*}
CONFIG_FILE=${CONFIG_FILE:=$TWCFG_DIR/mktwpol.cfg}

# Exit on "non-existence" of non-default script configuration file

if [ "$CONFIG_FILE" != "$TWCFG_DIR/mktwpol.cfg" -a ! -f "$CONFIG_FILE" ]; then
  echo "
 ${0##*/} configuration file, $CONFIG_FILE, does not exist.
 Exiting.  Goodbye.
" >&2
  exit 2
fi

# If a script config file exists, check for the string "RULENAME[.*]="
# If the script config file purports to set a RULENAME[] (any number), and the
# script config file does not say "KEEP_DEFAULT_RULES", unset the defaults

if [ -f "$CONFIG_FILE" ]; then
  if  [ -n "`grep -l RULENAME\\\[.*\\\]= $CONFIG_FILE`" -a \
	-z "`grep -l KEEP_DEFAULT_RULES  $CONFIG_FILE`" ]; then
  unset RULENAME SEVERITY EMAILTO \
	BIN_SEC  ETC_SEC  LOG_SEC \
	IGNORLST \
	PACKAGES \
	FILELIST FILELIST_2 FILELIST_3 FILELIST_4 \
	COMMENTS COMMENTS_2 COMMENTS_3 COMMENTS_4 \
	SEC_MOD  SEC_MOD_2  SEC_MOD_3  SEC_MOD_4  \
	SFT_MOD  SFT_MOD_2  SFT_MOD_3  SFT_MOD_4  \
	RECURSE  RECURSE_2  RECURSE_3  RECURSE_4  \
	EXCEPT   SEC_EX
  fi
  source "$CONFIG_FILE"			# if there is a CONFIG_FILE, source it
fi
}

test_for_dupe_rules ()
{
DUPE_PACKAGES="`echo ${PACKAGES[@]} | tr [:space:] '\n' | sort | uniq -d`"
DUPE_FILELIST="`echo ${FILELIST[@]} ${FILELIST_2[@]} ${FILELIST_3[@]} ${FILELIST_4[@]} \
		| tr [:space:] '\n' | sort | uniq -d`"

if [ -n "${DUPE_PACKAGES}" -o -n "${DUPE_FILELIST}" ]; then
  echo " Uh Oh!  Duplicates Found!" >&2
  echo >&2
  [ -n "${DUPE_PACKAGES}" ] && echo " In more than one PACKAGES[]:" ${DUPE_PACKAGES}	>&2
  [ -n "${DUPE_FILELIST}" ] && echo " In more than one FILELIST[]:" ${DUPE_FILELIST}	>&2
  echo >&2
  echo " Edit $CONFIG_FILE or $0 to resolve the situation."	 >&2
  echo " Exiting.  Goodbye."					 >&2
  exit 4
fi
}

# -------------------------------
# "get_twcfg_variables" reads tripwire configuration file (not the script config file)
# Assuming existence of twadmin ... if tw.cfg exists, it was made by twadmin
# Filename "tw.cfg" is hardcoded in tripwire, and hardcoded here

get_twcfg_variables ()
{
if [ -r ${TWCFG_DIR}/tw.cfg ]; then
  [ "${VERBOSE^^}" == "YES" ] && echo " Reading ${TWCFG_DIR}/tw.cfg"		>&2
  tmp_array=(`twadmin -m f -c ${TWCFG_DIR}/tw.cfg`)
elif [ -r ${TWCFG_DIR}/twcfg.txt ]; then
  [ "${VERBOSE^^}" == "YES" ] && echo " Reading ${TWCFG_DIR}/twcfg.txt"		>&2
  tmp_array=(`cat ${TWCFG_DIR}/twcfg.txt`)
else
  echo " ${0##*/} depends on finding a tripwire configuration file
	${TWCFG_DIR}/tw.cfg	is preferred
	${TWCFG_DIR}/twcfg.txt	is acceptable
 Exiting.  Goodbye.
" >&2
  exit 3
fi

# `z+=2` incrementing shaves a few thousandths of a second
# but risks skipping over the required variable names

for (( z = 0 ; z < ${#tmp_array[@]} ; z++ ))
do
  case ${tmp_array[@]:$z:1} in
    POLFILE | DBFILE | REPORTFILE | SITEKEYFILE | LOCALKEYFILE  )
      assignment=${tmp_array[@]:$((z+1)):1}
      [ "${assignment:0:1}" == "=" ] && \
        export ${tmp_array[@]:$z:1}${assignment}
  ;;
  esac
done
REPORTDIR=${REPORTFILE%/*}	# bash shell equivalent to the `dirname` command
DBDIR=${DBFILE%/*}
[ "${VERBOSE^^}" == "YES" ] && echo >&2
}


###########  Subroutines for Operating

# -------------------------------
update_tripwire_policy ()
{
if [ "${QUIET^^}" != "YES" ]; then
  echo " To create the tripwire policy file (${POLFILE}),
 and tripwire database (in ${DBDIR}/), run:

	twadmin --create-polfile $TRIPWIRE_POL
	tripwire --init
" >&2
  echo -n " Create tripwire policy and database now? [Y/n]: " >&2
  read -n 1 -t 15 RUN_TRIPWIRE
  echo >&2
fi
if [ "${RUN_TRIPWIRE^}" == "N" ]; then
  echo " Skipping creation of tripwire policy and database.  Goodbye.
" >&2
  exit
fi
twadmin --create-polfile $TRIPWIRE_POL

if [ "${REMOVE_POL}" == "Yes" ]; then
  if [ "${QUIET^^}" != "YES" ]; then
    echo -n " Delete $TRIPWIRE_POL now? [Y/n]: " >&2
    read -n 1 -t 15 YES_IM_SURE
    echo >&2
  fi
  if [ "${YES_IM_SURE^}" != "N" ]; then
    rm -f $TRIPWIRE_POL
  fi
fi
tripwire --init
}

# -------------------------------
mode_auto_update ()
{
TRIPWIRE_POL=$TWCFG_DIR/twpol-`date +%y%m%d-%H%M`.txt

if [ "${VERBOSE^^}" == "YES" ]; then
  print_policy_text | tee $TRIPWIRE_POL
elif [ "${QUIET^^}" != "YES" ]; then
  echo " Writing to $TRIPWIRE_POL ..." >&2
fi
if [ "${VERBOSE^^}" != "YES" ]; then
  print_policy_text > $TRIPWIRE_POL
  [ "${QUIET^^}" != "YES" ] && echo >&2
fi
update_tripwire_policy
}

# -------------------------------
mode_echo_policy ()
{
if [ "${QUIET^^}" != "YES" ]; then
  echo " Run \`${0##*/} -h\` for tips on use.
 Creating tripwire policy text ...
" >&2
fi
print_policy_text
}

# -------------------------------
mode_debug ()
{
DEBUGME=y	# Unused variable.  Can be useful for internal debugging.
i=${1:-0}	# User can debug any single rule, default RULENAME[0]
echo
echo "  !! WARNING !!  ${0##*/} is in DEBUG Mode !!"
echo "  !! WARNING !!  Processing --ONLY-- RULENAME[${i}]"
echo
print_a_rule
echo
echo "  !! WARNING !!  ${0##*/} was in DEBUG Mode !!"
echo "  !! WARNING !!  Processed --ONLY-- RULENAME[${i}]"
exit 1
}

###########  Main Routine
#################################################################
# Default RULENAME[] arrays and TW_CFG variable are in memory

# Process command line parameters

while getopts :c:uqvrshV OPTION
do
  case $OPTION in
    c	) CONFIG_FILE=$OPTARG	;;
    u	) UPDATETW=Yes		;;
    q	) QUIET=Yes		;;
    v	) VERBOSE=Yes		;;
    r	) REMOVE_POL=Yes	;;
    s	) SKIP_PACKAGES=Yes	;;
    h	) config_mktwpol; recite_help		;;
    V	) recite_ver; exit	;;
    *	) config_mktwpol; recite_help		;;
  esac
done
shift $(($OPTIND - 1))

config_mktwpol
test_for_dupe_rules
assign_misc_mktwpol_defaults
get_twcfg_variables

[ "$1" == "debug" ] && mode_debug $2

if [ "$UPDATETW" == "Yes" ]; then
     mode_auto_update
else mode_echo_policy
fi
