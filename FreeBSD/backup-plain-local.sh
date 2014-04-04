#!/bin/sh
## Remote backup script. Requires duplicity and gpg-agent with the keys and passphrases loaded as root.
## Uses separate encryption and signing keys
## Usage:  'backup_remote.sh'

export HOME=/root
#enc_key=44D79E41
#sign_key=F5C978E3
src="/"
filedest="/root/backup2-freebsd"
dest="file://$filedest"
#dest="scp://chiyobak@192.168.1.9//backup2-freebsd"

## Keychain is used to source the ssh-agent keys when running from a cron job
#type -P keychain &>/dev/null || { echo "I require keychain but it's not installed.  Aborting." >&2; exit 1; }
#eval `keychain --eval web_rsa` || exit 1
### Note: can't use keychain for gpg-agent because it doesn't currently (2.7.1) read in all the keys correctly. 
### Gpg will ask for a passphrase twice for each key...once for encryption/decryption and once for signing. 
### This makes unattended backups impossible, especially when trying to resume an interrupted backup.
#if [ -f "${HOME}/.gnupg/gpg-agent-info" ]; then
#      . "${HOME}/.gnupg/gpg-agent-info"
#      export GPG_AGENT_INFO
#fi

duplicity \
         --verbosity info \
	 --no-encryption \
         --full-if-older-than 60D \
         --num-retries 3 \
         --asynchronous-upload \
         --volsize 100 \
         --archive-dir /root/.cache/duplicity \
         --log-file /var/log/duplicity.log \
         --exclude /proc \
         --exclude /sys \
         --exclude /dev \
         --exclude /tmp \
         --exclude /usr/ports \
	 --exclude $filedest \
         --exclude '**rdiff-backup-data' \
         "$src" "$dest"
