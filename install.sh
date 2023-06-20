#!/bin/bash

set -e

##############################################################################
#                                                                            #
# Project 'pterodactyl-installer-script'                                     #
#                                                                            #
#            This script is intended for personal use ONLY                   #
#                                                                            #
#   This program is free software: you can redistribute it and/or modify     #
#   it under the terms of the GNU General Public License as published by     #
#   the Free Software Foundation, either version 3 of the License, or        #
#   (at your option) any later version.                                      #
#                                                                            #
#   This program is distributed in the hope that it will be useful,          #
#   but WITHOUT ANY WARRANTY; without even the implied warranty of           #
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            #
#   GNU General Public License for more details.                             #
#                                                                            #
#   You should have received a copy of the GNU General Public License        #
#   along with this program.  If not, see <https://www.gnu.org/licenses/>.   #
#                                                                            #
# https://github.com/icedmoca/pterodactyl-install-script/blob/master/LICENSE #
#                                                                            #
# This script is not associated with the official Pterodactyl Project.       #
# https://github.com/icedmoca/pterodactyl-install-script                     #
#                                                                            #
##############################################################################

# versioning
GITHUB_SOURCE="master"
SCRIPT_RELEASE="canary"

#################################
######## General checks #########
#################################

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

#################################
########## Variables ############
#################################

# download URLs
WINGS_DL_URL="https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_amd64"
GITHUB_BASE_URL="https://raw.githubusercontent.com/icedmoca/pterodactyl-install-script/$GITHUB_SOURCE"

COLOR_RED='\033[0;31m'
COLOR_NC='\033[0m'

INSTALL_MARIADB=false

# firewall
CONFIGURE_FIREWALL=false
CONFIGURE_UFW=false
CONFIGURE_FIREWALL_CMD=false

# SSL (Let's Encrypt)
CONFIGURE_LETSENCRYPT=false
FQDN=""
EMAIL=""

#################################
####### Version checking ########
#################################

get_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
}

echo "* Retrieving release information.."
WINGS_VERSION="$(get_latest_release "pterodactyl/wings")"

#################################
####### Visual functions ########
#################################

print_error() {
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
  for ((n=0;n<$1;n++)); do
    echo -n "#"
  done
  echo ""
}

hyperlink() {
  echo -e "\e]8;;${1}\a${1}\e]8;;\a"
}

#################################
####### OS check funtions #######
#################################

detect_distro() {
  # Existing code for detecting the distribution (Ubuntu, Debian, CentOS, etc.)
}

check_os_comp() {
  # Existing code for checking the compatibility of the operating system
}

############################
## INSTALLATION FUNCTIONS ##
############################

apt_update() {
  # Existing code for updating packages (APT)
}

yum_update() {
  # Existing code for updating packages (YUM)
}

dnf_update() {
  # Existing code for updating packages (DNF)
}

enable_docker(){
  # Existing code for enabling and starting Docker service
}

install_docker() {
  # Existing code for installing Docker
}

ptdl_dl() {
  # Existing code for downloading Pterodactyl Wings
}

systemd_file() {
  # Existing code for installing systemd service for Wings
}

install_mariadb() {
  # Existing code for installing MariaDB (MySQL) server
}

#################################
##### OS SPECIFIC FUNCTIONS #####
#################################

ask_letsencrypt() {
  # Existing code for asking about Let's Encrypt SSL configuration
}

firewall_ufw() {
  # Existing code for configuring UFW firewall
}

firewall_firewalld() {
  # Existing code for configuring firewalld firewall
}

letsencrypt() {
  # Existing code for obtaining Let's Encrypt SSL certificate
}

####################
## MAIN FUNCTIONS ##
####################

perform_install() {
  # Existing code for performing the installation steps
}

main() {
  # Existing code for the main execution flow
}

function goodbye {
  # Existing code for displaying the completion message
}

# Run the script
main
goodbye
