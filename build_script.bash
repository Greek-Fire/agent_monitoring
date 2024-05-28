#!/bin/bash

export USER=foreman

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
if ! id "$USER" &>/dev/null; then
  sudo adduser --disabled-password --gecos "" $USER
fi

# Install Bundler
gem install bundler

# Check if the line is already in .bashrc before adding it
if ! grep -qxF 'export BUNDLE_PATH=/home/$USER/foreman/vendor/bundle' /home/$USER/.bashrc; then
    echo "export BUNDLE_PATH=/home/$USER/foreman/vendor/bundle" | tee -a /home/$USER/.bashrc
fi

if ! grep -qxF 'export BIND=10.0.2.15' /home/$USER/.bashrc; then
    echo "export BIND=10.0.2.15" | tee -a /home/$USER/.bashrc
fi

if ! grep -qxF "export WEBPACK_OPTS=\"--host \$BIND\"" /home/$USER/.bashrc; then
    echo 'export WEBPACK_OPTS="--host $BIND"' | tee -a /home/$USER/.bashrc
fi

source /home/$USER/.bashrc

# Configure PostgreSQL
sudo -u postgres psql -c "CREATE ROLE foreman WITH LOGIN SUPERUSER PASSWORD 'redhat';"

# Clone Foreman repository
sudo -u $USER -H git clone https://github.com/theforeman/foreman.git /home/$USER/foreman
cd /home/$USER/foreman

sudo -u postgres psql -c "CREATE ROLE foreman WITH LOGIN SUPERUSER PASSWORD 'redhat';"
sudo -u $USER -H bundle config set --local path 'vendor/bundle'
sudo -u $USER -H bundle install
sudo -u $USER -H config/settings.yaml.example config/settings.yaml

sudo -u $USER -H bash -c 'cat <<EOL > /home/$USER/foreman/config/database.yml
development:
  adapter: postgresql
  password: redhat
  host: localhost
  port: 5432
  database: foreman
  encoding: utf8
  pool: 10
EOL'

sudo -u $USER -H bash -c 'cat <<EOL > /etc/postgresql/12/main/pg_hba.conf
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

sudo -u $USER -H curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
sudo -u $USER -H source ~/.nvm/nvm.sh
sudo -u $USER -H nvm install 16.0.0
sudo -u $USER -H nvm use 16.0.0
sudo -u $USER -H nvm alias default 16.0.0
sudo -u $USER -H npm install
sudo -u $USER -H bundle exec rake db:migrate
sudo -u $USER -H bundle exec rake permissions:reset password=redhat
sudo -u $USER -H bundle exec foreman start
