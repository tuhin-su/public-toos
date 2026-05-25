@echo off
title WSL Ubuntu Laravel Environment Setup
color 0A

echo ==========================================
echo Installing WSL and Ubuntu
echo ==========================================

wsl --install -d Ubuntu

if %errorlevel% neq 0 (
    echo.
    echo WSL installation may already exist or failed.
    echo Continuing...
)

echo.
echo ==========================================
echo Updating WSL
echo ==========================================

wsl --update


echo.
echo ==========================================
echo Running Ubuntu setup
echo ==========================================

wsl -d Ubuntu -- bash -c "
set -e

sudo apt update && sudo apt upgrade -y

sudo apt install -y software-properties-common \
ca-certificates \
apt-transport-https \
lsb-release \
curl \
wget \
gnupg2 \
unzip \
zip \
git \
build-essential \
net-tools \
redis-server \
nginx \
sqlite3

# ======================================
# Add PHP Repository
# ======================================

sudo add-apt-repository ppa:ondrej/php -y
sudo apt update

# ======================================
# PostgreSQL Installation
# ======================================

sudo apt install -y \
postgresql \
postgresql-client \
postgresql-contrib \
libpq-dev

# ======================================
# Install Node.js LTS
# ======================================

curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs

# ======================================
# PHP Versions Installation
# ======================================

PHP_VERSIONS='8.2 8.4 8.5'

for version in $PHP_VERSIONS; do

    echo Installing PHP $version

    sudo apt install -y \
    php$version \
    php$version-cli \
    php$version-common \
    php$version-dev \
    php$version-bcmath \
    php$version-bz2 \
    php$version-curl \
    php$version-enchant \
    php$version-fpm \
    php$version-gd \
    php$version-gmp \
    php$version-imagick \
    php$version-imap \
    php$version-intl \
    php$version-ldap \
    php$version-mbstring \
    php$version-mysql \
    php$version-opcache \
    php$version-pgsql \
    php$version-pspell \
    php$version-readline \
    php$version-redis \
    php$version-snmp \
    php$version-soap \
    php$version-sqlite3 \
    php$version-tidy \
    php$version-xml \
    php$version-xmlrpc \
    php$version-xsl \
    php$version-yaml \
    php$version-zip || true

done

# ======================================
# Set Default PHP Version
# ======================================

sudo update-alternatives --set php /usr/bin/php8.4 || true

# ======================================
# Composer Installation
# ======================================

cd /tmp
curl -sS https://getcomposer.org/installer -o composer-setup.php
php composer-setup.php
sudo mv composer.phar /usr/local/bin/composer

# ======================================
# Laravel Installer
# ======================================

composer global require laravel/installer

echo 'export PATH=$PATH:$HOME/.config/composer/vendor/bin' >> ~/.bashrc

echo 'export PATH=$PATH:$HOME/.composer/vendor/bin' >> ~/.bashrc

# ======================================
# Enable Services
# ======================================

sudo service postgresql start || true
sudo service redis-server start || true
sudo service nginx start || true

# ======================================
# PostgreSQL User Setup
# ======================================

sudo service postgresql start || true

sudo -u postgres psql -c \"ALTER USER postgres WITH PASSWORD 'root';\" || true
sudo -u postgres psql -c \"CREATE USER root WITH SUPERUSER CREATEDB CREATEROLE LOGIN PASSWORD 'root';\" || true
sudo -u postgres psql -c \"ALTER USER root WITH SUPERUSER;\" || true

sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/*/main/postgresql.conf || true

sudo bash -c 'echo "host all all 0.0.0.0/0 md5" >> /etc/postgresql/*/main/pg_hba.conf' || true

sudo service postgresql restart || true

# ======================================
# Currency + Exchange + Intl Support
# ======================================

sudo apt install -y \
libicu-dev \
locales \
locales-all \
currency \
geoip-bin

sudo locale-gen en_US.UTF-8

# ======================================
# Display Versions
# ======================================

php -v
composer --version
node -v
npm -v
psql --version


echo

echo ======================================
echo Installation Completed Successfully
echo ======================================

echo.
echo PHP Versions Installed:
echo - PHP 8.2
echo - PHP 8.4
echo - PHP 8.5 (if available in repo)
echo.
echo PostgreSQL User:
echo Username: root
echo Password: root
echo.
echo Run Ubuntu anytime using:
echo wsl

echo.
echo Laravel create command:
echo laravel new myapp

echo.
"

pause
