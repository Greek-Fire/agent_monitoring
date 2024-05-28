#!/bin/bash

# Check if user is root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Update and install dependencies
sudo apt-get update
sudo apt-get install -y \
  ruby2.7 \
  ruby2.7-dev \
  build-essential \
  libssl-dev \
  libreadline-dev \
  zlib1g-dev \
  libsqlite3-dev \
  sqlite3 \
  libpq-dev \
  libxml2-dev \
  libxslt1-dev \
  libcurl4-openssl-dev \
  software-properties-common \
  libffi-dev \
  nodejs \
  yarn \
  git \
  postgresql \
  postgresql-contrib \
  curl

# Start and enable PostgreSQL service
sudo systemctl enable postgresql
sudo systemctl start postgresql

# Create foreman user
if ! id "foreman" &>/dev/null; then
  sudo adduser --disabled-password --gecos "" foreman
fi

# Install Bundler
gem install bundler

# Configure PostgreSQL
sudo -u postgres psql -c "CREATE ROLE foreman WITH LOGIN SUPERUSER PASSWORD 'redhat';"

# Clone Foreman repository
sudo -u foreman -H git clone https://github.com/theforeman/foreman.git /home/foreman/foreman
cd /home/foreman/foreman

sudo -u postgres psql -c "CREATE ROLE foreman WITH LOGIN SUPERUSER PASSWORD 'redhat';"
sudo -u foreman -H bundle config set --local path 'vendor/bundle'
sudo -u foreman -H bundle install
sudo -u foreman -H config/settings.yaml.example config/settings.yaml

sudo -u foreman -H bash -c 'cat <<EOL > /home/foreman/foreman/config/database.yml
default: &default
  adapter: postgresql
  encoding: unicode
  pool: 5
  username: foreman
  password: redhat
  host: localhost
EOL'

sudo -u foreman -H bash -c 'cat <<EOL > /etc/postgresql/12/main/pg_hba.conf
# Allow local connections by the foreman user without a password
#local   all             foreman                                trust
# Alternatively, if you prefer password authentication
local   all             foreman                                md5
# IPv4 local connections:
host    all             all             127.0.0.1/32            md5
# IPv6 local connections:
host    all             all             ::1/128                 md5
EOL'

sudo systemctl reload postgresql

sudo -u foreman -H curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
sudo -u foreman -H source ~/.nvm/nvm.sh
sudo -u foreman -H nvm install 16.0.0
sudo -u foreman -H nvm use 16.0.0
sudo -u foreman -H nvm alias default 16.0.0
sudo -u foreman -H npm install
sudo -u foreman -H bundle exec rake db:migrate
sudo -u foreman -H bundle exec rake permissions:reset password=redhat
sudo -u foreman -H bundle exec foreman start
