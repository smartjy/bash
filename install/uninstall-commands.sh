#!/usr/bin/env bash
set -e

# Color setup 
ERROR_COLOR='\033[1;31m'
INFO_COLOR='\033[1;32m'
REQUIRED_COLOR='\033[1;36m'
WARNING_COLOR='\033[1;33m'
NO_COLOR='\033[0m'

# Function to print colored messages
color_echo() {
  local color=$1
  shift
  printf "${color}%s${NO_COLOR}\n" "$@"
}

if command -v aws; then 
  sudo rm $(command -v aws)
  sudo rm /usr/local/bin/aws_completer
  sudo rm -rf /usr/local/aws-cli
  color_echo "$INFO_COLOR" "### aws cli uninstalled"
fi

if command -v aws-iam-authenticator; then
  rm $(command -v aws-iam-authenticator)
  color_echo "$INFO_COLOR" "### aws-iam-authenticator uninstalled"
fi

if command -v kubectl; then 
  rm $(command -v kubectl)
  color_echo "$INFO_COLOR" "### kubectl uninstalled"
fi

color_echo "$INFO_COLOR" "### Script completed successfully"
