#!/bin/sh

# MAKE SURE JAIL HAS THE FOLLOWING OPTION IN ITS EZJAIL CONFIG FILE:
#   export jail_gitlab_parameters="allow.raw_sockets=1 allow.sysvipc=1"

pkg install -y git redis icu libxml2 libxslt python2 bash sudo gcc gmake autoconf automake libtool bison readline libyaml sqlite3 gdbm cmake pkgconf

echo 'redis_enable="YES"' >> /etc/rc.conf
/usr/local/etc/rc.d/redis start

pkg install -y postgresql92-server
echo 'postgresql_enable="YES"' >> /etc/rc.conf
/usr/local/etc/rc.d/postgresql initdb
/usr/local/etc/rc.d/postgresql start

echo 'CREATE USER git CREATEDB;
CREATE DATABASE gitlabhq_production;' > /tmp/gitlab.sql

su -l pgsql -c 'pgsql -d template1 -f /tmp/gitlab.sql'
rm /tmp/gitlab.sql

pw add user -n git -m -s /usr/local/bin/bash -c "GitLab"

echo 
su -l git -c '\curl -sSL https://get.rvm.io | bash -s stable;
source /home/git/.rvm/scripts/rvm;
rvm install 2.1.2;
cd;
git clone https://gitlab.com/gitlab-org/gitlab-ce.git -b 7-1-stable gitlab;
cd /home/git/gitlab
cp config/gitlab.yml.example config/gitlab.yml
sed "s/\/home/\/usr\/home/g" config/gitlab.yml
sed "s/\/usr\/bin\/git/\/usr\/local\/bin\/git/g" config/gitlab.yml
cp config/unicorn.rb.example config/unicorn.rb
cp config/database.yml.postgresql config/database.yml
git config --global user.name "GitLab"
git config --global user.email "hybrid120@gmail.com"
git config --global core.autocrlf input
chown -R git log/
chown -R git tmp/
chmod -R u+rwX log/
chmod -R u+rwX tmp/
chmod -R u+rwX tmp/pids/
chmod -R u+rwX tmp/sockets/
chmod -R u+rwX  public/uploads
mkdir /home/git/gitlab-satellites
chmod u+rwx,g=rx,o-rwx /home/git/gitlab-satellites
gem install bundle

export CC=gcc47
export CXX=c++47
export CPP=cpp47

gem install charlock_holmes -v "0.6.9.4" -- --with-opt-include=/usr/local/include/ --with-opt-lib=/usr/local/lib/
bundle config build.charlock_holmes --with-opt-include=/usr/local/include/ --with-opt-lib=/usr/local/lib/

bundle install --deployment --without development test mysql aws
'
