#!/usr/bin/env bash
set -e

# Function to print colored messages
function color_echo {
    local color=$1
    shift
    printf "${color}%s${NO_COLOR}\n" "$@"
}

# Color setup 
ERROR_COLOR='\033[1;31m'
INFO_COLOR='\033[1;32m'
REQUIRED_COLOR='\033[1;36m'
WARNING_COLOR='\033[1;33m'
NO_COLOR='\033[0m'

# Define variables
AWS_IAM_AUTH_VERSION="0.5.9"
AWS_IAM_AUTH_DOWNLOAD_URL="https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v${AWS_IAM_AUTH_VERSION}/aws-iam-authenticator_${AWS_IAM_AUTH_VERSION}_darwin_amd64"
KUBE_VERSION="1.25.7"
KUBE_DOWNLOAD_URL="https://s3.us-west-2.amazonaws.com/amazon-eks/$KUBE_VERSION/2023-03-17/bin/darwin/amd64/kubectl"
BIN_DIR="$HOME/bin"
CUSTOM_RC_PATH="$HOME/.customrc"
COMMANDS=("aws" "aws-iam-authenticator" "kubectl")

# Check if the machine is running macOS
if [[ "$(uname)" != "Darwin" ]]; then
    color_echo "$ERROR_COLOR" "This script is only intended to be run on macOS."
    exit 1
fi

# Check if the machine is running on Apple Silicon
if [[ "$(uname -m)" != "arm64" ]]; then
    color_echo "$ERROR_COLOR" "This script is not running on Apple Silicon."
    exit 1
fi

# set directory and file
[ ! -e "$BIN_DIR" ] && mkdir "$BIN_DIR"
[ ! -f "$CUSTOM_RC_PATH" ] && touch "$CUSTOM_RC_PATH"

# Adds the custom rc command to .zshrc
add_custom_rc() {
    if grep -q "source $CUSTOM_RC_PATH" ~/.zshrc; then 
        echo ".customrc already exists in .zshrc"
    else 
        echo "source $CUSTOM_RC_PATH" >> ~/.zshrc
        echo ".customrc added to .zshrc"
    fi
}
add_path_to_custom_rc() {
    if grep -q 'export export PATH=$PATH:$HOME/bin' "$CUSTOM_RC_PATH"; then 
        echo "PATH already setup in .customrc"
    else 
        echo 'export export PATH=$PATH:$HOME/bin' >> "$CUSTOM_RC_PATH"
        echo "PATH added to .customrc"
    fi
}

# Function to download a file from a URL
download_file() {
    local url=$1
    local filename=$2
    if ! curl -sSf "$url" -o "$filename"; then
        color_echo "$ERROR_COLOR" "Failed to download $filename from $url"
        exit 1
    fi
}
# Function to install AWS CLI
install_aws() {
    color_echo "$INFO_COLOR" "Downloading AWS CLI installer..."
    download_file "https://awscli.amazonaws.com/AWSCLIV2.pkg" "AWSCLIV2.pkg"
    color_echo "$INFO_COLOR" "Installing AWS CLI..."
    sudo installer -pkg AWSCLIV2.pkg -target / 
    color_echo "$INFO_COLOR" "Cleaning up temporary files..."
    rm ./AWSCLIV2.pkg 

}

install_aws_iam_authenticator() {
    color_echo "$INFO_COLOR" "Downloading aws-iam-authenticator installer..."
    download_file "$AWS_IAM_AUTH_DOWNLOAD_URL" "aws-iam-authenticator"
    color_echo "$INFO_COLOR" "Changing execute mode ..."
    chmod +x ./aws-iam-authenticator
    mv ./aws-iam-authenticator $BIN_DIR/aws-iam-authenticator
}

install_kubectl() {
    color_echo "$INFO_COLOR" "Downloading kubectl installer..."
    download_file "$KUBE_DOWNLOAD_URL" "kubectl"
    color_echo "$INFO_COLOR" "Changing execute mode ..."
    chmod +x ./kubectl 
    mv ./kubectl $BIN_DIR/kubectl
}

if ! command -v aws >/dev/null 2>&1; then 
    install_aws 
    # Verify the installation
    color_echo "$INFO_COLOR" "Verifying AWS CLI installation..."
    aws --version
else
    echo "aws cli already installed"
    aws --version

fi
if ! command -v aws-iam-authenticator >/dev/null 2>&1; then 
    install_aws-iam-authenticator
    # Verify the installation
    color_echo "$INFO_COLOR" "Verifying aws-iam-authenticator installation..."
    aws-iam-authenticator version
else
    echo "aws-iam-authenticator already installed"
    aws-iam-authenticator version
fi
if ! command -v kubectl >/dev/null 2>&1; then 
    install_kubectl
    # Verify the installation
    color_echo "$INFO_COLOR" "Verifying kubectl installation..."
    kubectl version --short --client
else
    echo "kubectl already installed"
    kubectl version --short --client
fi
