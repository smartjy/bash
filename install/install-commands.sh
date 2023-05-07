#!/usr/bin/env bash
set -e

# Color setup 
ERROR_COLOR='\033[1;31m'
INFO_COLOR='\033[1;32m'
REQUIRED_COLOR='\033[1;36m'
WARNING_COLOR='\033[1;33m'
NO_COLOR='\033[0m'

# Define variables
COMMANDS=("aws" "aws-iam-authenticator" "kubectl")
AWS_IAM_AUTH_VERSION="0.5.9"
AWS_IAM_AUTH_DOWNLOAD_URL="https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v${AWS_IAM_AUTH_VERSION}/aws-iam-authenticator_${AWS_IAM_AUTH_VERSION}_darwin_amd64"
KUBE_VERSION="1.25.7"
KUBE_DOWNLOAD_URL="https://s3.us-west-2.amazonaws.com/amazon-eks/$KUBE_VERSION/2023-03-17/bin/darwin/amd64/kubectl"

# Function to print colored messages
color_echo() {
  local color=$1
  shift
  printf "${color}%s${NO_COLOR}\n" "$@"
}

download_file() {
  local url=$1
  local filename=$2
  if ! curl -L "$url" -o "$filename"; then
    color_echo "$ERROR_COLOR" "### Failed to download $filename from $url"
    exit 1
  fi
}

# Function to install AWS CLI
install_aws() {
  color_echo "$INFO_COLOR" "### Downloading AWS CLI installer..."
  download_file "https://awscli.amazonaws.com/AWSCLIV2.pkg" "AWSCLIV2.pkg"
  color_echo "$INFO_COLOR" "### Installing AWS CLI..."
  sudo installer -pkg AWSCLIV2.pkg -target / 
  color_echo "$INFO_COLOR" "### Cleaning up temporary files..."
  rm ./AWSCLIV2.pkg 
}

# Function to install aws-iam-authenticator
install_aws-iam-authenticator() {
  color_echo "$INFO_COLOR" "### Downloading aws-iam-authenticator installer..."
  download_file "$AWS_IAM_AUTH_DOWNLOAD_URL" "aws-iam-authenticator"
  color_echo "$INFO_COLOR" "### Changing execute mode ..."
  chmod +x ./aws-iam-authenticator
  mv ./aws-iam-authenticator $BIN_DIR/aws-iam-authenticator
}

# Function to install kubectl
install_kubectl() {
  color_echo "$INFO_COLOR" "### Downloading kubectl installer..."
  download_file "$KUBE_DOWNLOAD_URL" "kubectl"
  color_echo "$INFO_COLOR" "### Changing execute mode ..."
  chmod +x ./kubectl 
  mv ./kubectl $BIN_DIR/kubectl
}

commands_version() {
  aws --version
  aws-iam-authenticator version
  kubectl version --short --client
}

for command in "${COMMANDS[@]}"; do
  if ! command -v $command >/dev/null 2>&1; then
    "install_$command"
    color_echo "$INFO_COLOR" "### $command installed"
  else
    color_echo "$WARNING_COLOR" "### $command already installed"
  fi
  color_echo "$INFO_COLOR" "### $command $(commands_version)"
done
