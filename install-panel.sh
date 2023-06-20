#!/bin/bash

set -e

######## General checks #########

# exit with error status code if user is not root
if [[ $EUID -ne 0 ]]; then
  echo "* This script must be executed with root privileges (sudo)." 1>&2
  exit 1
fi

# check for curl
if ! [ -x "$(command -v curl)" ]; then
  echo "* curl is required in order for this script to work."
  echo "* install using apt (Debian and derivatives) or yum/dnf (CentOS)"
  exit 1
fi

########## Variables ############

# versioning
GITHUB_SOURCE="master"
SCRIPT_RELEASE="canary"

FQDN=""

# Default MySQL credentials
MYSQL_DB="pterodactyl"
MYSQL_USER="pterodactyl"
MYSQL_PASSWORD=""

# Environment
email=""

# Initial admin account
user_email=""
user_username=""
user_firstname=""
user_lastname=""
user_password=""

# Assume SSL, will fetch different config if true
ASSUME_SSL=false
CONFIGURE_LETSENCRYPT=false

# download URLs
PANEL_DL_URL="https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz"
GITHUB_BASE_URL="https://raw.githubusercontent.com/icedmoca/pterodactyl-install-script/$GITHUB_SOURCE"

# ufw firewall
CONFIGURE_UFW=false

# firewall_cmd
CONFIGURE_FIREWALL_CMD=false

# firewall status
CONFIGURE_FIREWALL=false

####### Version checking ########

# define version using information from GitHub
get_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
  grep '"tag_name":' |                                              # Get tag line
  sed -E 's/.*"([^"]+)".*/\1/'                                      # Pluck JSON value
}

# pterodactyl version
echo "* Retrieving release information.."
PTERODACTYL_VERSION="$(get_latest_release "pterodactyl/panel")"

####### lib func #######

array_contains_element () {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

####### Visual functions ########

print_error() {
  COLOR_RED='\033[0;31m'
  COLOR_NC='\033[0m'

  echo ""
  echo -e "* ${COLOR_RED}ERROR${COLOR_NC}: $1"
  echo ""
}

print_warning() {
  COLOR_YELLOW='\033[1;33m'
  COLOR_NC='\033[0m'
  echo ""
  echo -e "* ${COLOR_YELLOW}WARNING${COLOR_NC}: $1"
  echo ""
}

print_brake() {
  for ((n=0;n<$1;n++));
    do
      echo -n "#"
    done
    echo ""
}

hyperlink() {
  echo -e "\e]8;;${1}\a${1}\e]8;;\a"
}

##### User input functions ######

required_input() {
  local  __resultvar=$1
  local  result=''

  while [ -z "$result" ]; do
      echo -n "* ${2}"
      read -r result

      [ -z "$result" ] && print_error "${3}"
  done

  eval "$__resultvar="'$result'""
}

password_input() {
  local  __resultvar=$1
  local  result=''
  local default="$4"

  while true; do
    echo -n "* ${2}"
    if [ "$3" = "silent" ]; then
      read -rs result
      echo ""
    else
      read -r result
    fi

    if [ -z "$result" ]; then
      result="$default"
      break
    fi

    if [ "$result" = "$default" ]; then
      break
    fi

    echo -n "* ${2} (again)"
    if [ "$3" = "silent" ]; then
      read -rs result2
      echo ""
    else
      read -r result2
    fi

    if [ "$result" != "$result2" ]; then
      echo ""
      print_error "Passwords do not match. Please try again."
      echo ""
      continue
    fi

    break
  done

  eval "$__resultvar="'$result'""
}

############### Functions ##############

install_dependencies() {
  echo ""
  echo "* Installing dependencies..."
  if [ -f /etc/debian_version ]; then
    apt-get -y update
    apt-get -y install curl tar unzip git make gcc g++ python2 binutils tar unzip zip libpng-dev lsb-release gnupg software-properties-common dirmngr
  elif [ -f /etc/centos-release ]; then
    yum -y install epel-release
    yum -y update
    yum -y install curl tar unzip git make gcc-c++ python2 binutils tar unzip zip libpng-devel redhat-lsb-core gnupg2
  else
    print_error "Unsupported operating system."
    exit 1
  fi
}

download_panel() {
  echo ""
  echo "* Downloading panel..."
  mkdir -p /var/www/pterodactyl
  cd /var/www/pterodactyl
  curl -L $PANEL_DL_URL | tar --strip-components=1 -xzv
}

configure_environment() {
  echo ""
  echo "* Configuring environment..."
  cp .env.example .env
  if [ "$ASSUME_SSL" = true ]; then
    sed -i 's/http:/https:/g' .env
  fi
  if [ "$CONFIGURE_LETSENCRYPT" = true ]; then
    sed -i 's/LETSENCRYPT_ENABLED=false/LETSENCRYPT_ENABLED=true/g' .env
  fi
  sed -i "s/DB_DATABASE=.*/DB_DATABASE=$MYSQL_DB/g" .env
  sed -i "s/DB_USERNAME=.*/DB_USERNAME=$MYSQL_USER/g" .env
  sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=$MYSQL_PASSWORD/g" .env
  sed -i "s/APP_URL=.*/APP_URL=https:\/\/$FQDN/g" .env
  sed -i "s/MAIL_FROM=.*/MAIL_FROM=$email/g" .env
}

configure_database() {
  echo ""
  echo "* Configuring database..."
  php artisan key:generate --force
  php artisan p:environment:setup --bootstrap
  php artisan migrate --seed --force
}

configure_ufw_firewall() {
  echo ""
  echo "* Configuring UFW firewall..."
  ufw allow 22/tcp
  ufw allow 80/tcp
  ufw allow 443/tcp
  ufw allow 8080/tcp
  ufw --force enable
}

configure_firewall() {
  echo ""
  echo "* Configuring firewall..."
  if [ -x "$(command -v firewall-cmd)" ]; then
    # CentOS with firewalld
    firewall-cmd --zone=public --permanent --add-port=22/tcp
    firewall-cmd --zone=public --permanent --add-port=80/tcp
    firewall-cmd --zone=public --permanent --add-port=443/tcp
    firewall-cmd --zone=public --permanent --add-port=8080/tcp
    firewall-cmd --reload
  elif [ -x "$(command -v ufw)" ]; then
    # Ubuntu with UFW
    ufw allow 22/tcp
    ufw allow 80/tcp
    ufw allow 443/tcp
    ufw allow 8080/tcp
    ufw --force enable
  else
    print_error "Firewall configuration failed. Please configure your firewall manually."
    return 1
  fi
}

start_services() {
  echo ""
  echo "* Starting services..."
  systemctl enable --now redis-server
  systemctl enable --now mariadb
  systemctl enable --now nginx
  systemctl enable --now php${PHP_VERSION}-fpm
  systemctl enable --now wings
}

cleanup() {
  echo ""
  echo "* Cleaning up..."
  cd ~
  rm -rf pterodactyl-installation
}

print_success() {
  echo -e "\n\033[1;32m$1\033[0m"
}

print_error() {
  echo -e "\n\033[1;31m$1\033[0m"
}

############### Main Script ###############

echo ""
echo "==============================="
echo " Pterodactyl Panel Installer"
echo "==============================="
echo ""

# Prompt for database credentials
echo ""
echo "Enter the following information to configure the database:"
password_input MYSQL_DB "Database Name: " silent "$DEFAULT_MYSQL_DB"
password_input MYSQL_USER "Database User: " silent "$DEFAULT_MYSQL_USER"
password_input MYSQL_PASSWORD "Database Password: " silent

# Prompt for panel settings
echo ""
echo "Enter the following information to configure the panel:"
password_input FQDN "Panel FQDN (Fully Qualified Domain Name): " "$DEFAULT_FQDN"
password_input email "Panel Email Address: " "$DEFAULT_EMAIL"
password_input ASSUME_SSL "Assume SSL (true/false): " "$DEFAULT_ASSUME_SSL"

# Prompt for Let's Encrypt settings
echo ""
echo "Configure Let's Encrypt (SSL) for the panel?"
password_input CONFIGURE_LETSENCRYPT "Configure Let's Encrypt (true/false): " "$DEFAULT_CONFIGURE_LETSENCRYPT"

# Install dependencies
install_dependencies

# Download panel
download_panel

# Configure environment
configure_environment

# Configure database
configure_database

# Configure firewall
configure_firewall

# Start services
start_services

# Cleanup
cleanup

print_success "Pterodactyl Panel installation completed successfully!"
