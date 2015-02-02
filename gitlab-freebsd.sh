#!/bin/sh

# MAKE SURE JAIL HAS THE FOLLOWING OPTION IN ITS EZJAIL CONFIG FILE:
#   export jail_gitlab_parameters="allow.raw_sockets=1 allow.sysvipc=1"

pkg install sudo bash icu cmake pkgconf git nginx ruby ruby20-gems logrotate redis postgresql94-server postfix krb5

gem install bundler --no-ri --no-rdoc

sysrc sshd_enable="YES"  
sysrc redis_enable="YES"  
sysrc postgresql_enable="YES"  
sysrc gitlab_enable="YES"
sysrc nginx_enable="YES"
sysrc postfix_enable="YES"  
sysrc sendmail_enable="NO"  
sysrc sendmail_submit_enable="NO"  
sysrc sendmail_outbound_enable="NO"  
sysrc sendmail_msp_queue_enable="NO"  

# Create user
pw add user -n git -m -s /usr/local/bin/bash -c "GitLab"

# Add 'git' user to 'redis' group (this will come in useful later!)
pw user mod git -G redis

echo '#!/bin/sh
PGDATA="/usr/local/pgsql/data"
export PGDATA="/usr/local/pgsql/data"' > /usr/local/pgsql/.profile

service postgresql initdb
service postgresql start

echo 'CREATE USER git CREATEDB;
CREATE DATABASE gitlabhq_production OWNER git;' > /tmp/gitlab.sql

su -l pgsql -c 'psql -d template1 -f /tmp/gitlab.sql'

# Disable Redis listening on TCP by setting 'port' to 0
sed 's/^port .*/port 0/' /usr/local/etc/redis.conf.orig | sudo tee /usr/local/etc/redis.conf

# Enable Redis socket
echo 'unixsocket /usr/local/var/run/redis/redis.sock' | sudo tee -a /usr/local/etc/redis.conf

# Grant permission to the socket to all members of the redis group
echo 'unixsocketperm 770' | sudo tee -a /usr/local/etc/redis.conf

# Create the directory which contains the socket
mkdir -p /usr/local/var/run/redis  
chown redis:redis /usr/local/var/run/redis  
chmod 755 /usr/local/var/run/redis

# Restart redis
sudo service redis restart

# Change to git home directory
cd /home/git

# Clone GitLab source
sudo -u git -H git clone https://gitlab.com/gitlab-org/gitlab-ce.git -b 7-6-stable gitlab

# Go to GitLab source folder
cd /home/git/gitlab

# Copy the example GitLab config
sudo -u git -H cp config/gitlab.yml.example config/gitlab.yml

sudo -u git -H sed "s/\/home/\/usr\/home/g" config/gitlab.yml
sudo -u git -H sed "s/\/usr\/bin\/git/\/usr\/local\/bin\/git/g" config/gitlab.yml

cd /home/git/gitlab  
chown -R git log/  
chown -R git tmp/  
chmod -R u+rwX,go-w log/  
chmod -R u+rwX tmp/

su - git -c '
cd /home/git/gitlab

# Make folder for satellites and set the right permissions
mkdir /home/git/gitlab-satellites  
chmod u+rwx,g=rx,o-rwx /home/git/gitlab-satellites

# Make sure GitLab can write to the tmp/pids/ and tmp/sockets/ directories
chmod -R u+rwX tmp/pids/  
chmod -R u+rwX tmp/sockets/

# Make sure GitLab can write to the public/uploads/ directory
chmod -R u+rwX  public/uploads

# Copy the example Unicorn config
cp config/unicorn.rb.example config/unicorn.rb

# Set the number of workers to at least the number of cores
vim config/unicorn.rb

# Copy the example Rack attack config
cp config/initializers/rack_attack.rb.example config/initializers/rack_attack.rb

# Configure Git global settings for git user, useful when editing via web
# Edit user.email according to what is set in gitlab.yml
git config --global user.name "GitLab"  
git config --global user.email "example@example.com"  
git config --global core.autocrlf input

# Copy Redis connection settings
cp config/resque.yml.example config/resque.yml

# Configure Redis to use the modified socket path
# Change "production" line to "unix:/usr/local/var/run/redis/redis.sock"
vim config/resque.yml

# Copy database config
cp config/database.yml.postgresql config/database.yml

# Install Ruby Gems
bundle install --deployment --without development test mysql aws  

# Run the rake task for installing gitlab-shell
bundle exec rake gitlab:shell:install[v2.4.0] REDIS_URL=unix:/usr/local/var/run/redis/redis.sock RAILS_ENV=production

# Edit the gitlab-shell config
# Change the "socket" option to "/usr/local/var/run/redis/redis.sock"
# Change the "gitlab_url" option to "http://localhost:8080/"
# Don"t bother configuring any SSL stuff in here because it"s used internally
vim /home/git/gitlab-shell/config.yml  
'

sudo -u git -H bundle exec rake gitlab:setup RAILS_ENV=production GITLAB_ROOT_PASSWORD=5iveL!fe
cp /home/git/gitlab/lib/support/init.d/gitlab /usr/local/etc/rc.d/gitlab

cd /home/git/gitlab
su - git -c 'bundle exec rake gitlab:env:info RAILS_ENV=production
bundle exec rake assets:precompile RAILS_ENV=production
'

service gitlab start

echo 'server {  
    server_name yourserver.yourdomain;
    server_tokens off;

    listen 80 default accept_filter=httpready;

    # Uncomment if you want to use SSL
    # listen 443 ssl;

    # Configure your SSL certificate locations here
    # ssl_certificate        /usr/local/etc/nginx/ssl/gitlab/ssl-bundle.crt;
    # ssl_certificate_key  /usr/local/etc/nginx/ssl/gitlab/gitlab.key;

    # Uncomment to force SSL connections
    # if ($ssl_protocol = "") {
    #    rewrite ^   https://$server_name$request_uri? permanent;
    # }

    location / {
        proxy_set_header   X-Real-IP $remote_addr;
        proxy_set_header   Host      $http_host;
        proxy_pass         http://127.0.0.1:8080;
    }
}' > /usr/local/etc/nginx/nginx.conf

service nginx restart

su - git -c 'cd /home/git/gitlab

bundle exec rake gitlab:check RAILS_ENV=production'
