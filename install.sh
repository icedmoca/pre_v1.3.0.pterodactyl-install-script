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

SCRIPT_VERSION="v0.2"

# exit with error status code if user is not root or sudo
if [[ $EUID -ne 0 ]]; then
  echo "* This script must be executed with root privileges (sudo)." 1>&2
  exit 1
fi

# check for curl
if ! [ -x "$(command -v curl)" ]; then
  echo "* curl is required in order for this script to work."
  echo "* Install curl using apt:"
  echo "  sudo apt update"
  echo "  sudo apt install curl"
  exit 1
fi

output() {
  echo -e "* ${1}"
}

error() {
  COLOR_RED='\033[0;31m'
  COLOR_NC='\033[0m'

  echo ""
  echo -e "* ${COLOR_RED}ERROR${COLOR_NC}: $1"
  echo ""
}

done=false

output "Pterodactyl installation script @ $SCRIPT_VERSION"
output
output "https://github.com/icedmoca/pterodactyl-install-script"
output
output "This script is not associated with the official Pterodactyl Project."

output

panel() {
  bash <(curl -s https://raw.githubusercontent.com/icedmoca/pterodactyl-install-script/$SCRIPT_VERSION/install-panel.sh) --ubuntu-22.04
}

wings() {
  bash <(curl -s https://raw.githubusercontent.com/icedmoca/pterodactyl-install-script/$SCRIPT_VERSION/install-wings.sh) --ubuntu-22.04
}

while [ "$done" == false ]; do
  options=(
    "Install the panel"
    "Install Wings"
    "Install both [0] and [1] on the same machine (wings script runs after panel)\n"
  )

  actions=(
    "panel"
    "wings"
    "panel; wings"
  )

  output "Pick an option:"

  for i in "${!options[@]}"; do
    output "[$i] ${options[$i]}"
  done

  echo -n "* Input 0-$((${#actions[@]}-1)): "
  read -r action

  [ -z "$action" ] &&
  [ -z "$action" ] && error "Input is required" && continue

  valid_input=("$(for ((i=0;i<=${#actions[@]}-1;i+=1)); do echo "${i}"; done)")
  [[ ! " ${valid_input[*]} " =~ ${action} ]] && error "Invalid option"
  [[ " ${valid_input[*]} " =~ ${action} ]] && done=true && eval "${actions[$action]}"
done
