#!/usr/bin/env bash
set -e

# Function to print colored messages
color_echo() {
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
AWS_PROFILES=$(aws configure list-profiles)
COMMANDS=("aws" "aws-iam-authenticator" "kubectl")
AWS_IAM_AUTH_VERSION="0.5.9"
AWS_IAM_AUTH_DOWNLOAD_URL="https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v${AWS_IAM_AUTH_VERSION}/aws-iam-authenticator_${AWS_IAM_AUTH_VERSION}_darwin_amd64"
KUBE_VERSION="1.25.7"
KUBE_DOWNLOAD_URL="https://s3.us-west-2.amazonaws.com/amazon-eks/$KUBE_VERSION/2023-03-17/bin/darwin/amd64/kubectl"
BIN_DIR="$HOME/bin"
CUSTOM_RC_PATH="$HOME/.customrc"

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
        color_echo "$INFO_COLOR" ".customrc already exists in .zshrc"
    else 
        echo "source $CUSTOM_RC_PATH" >> ~/.zshrc
        color_echo "$INFO_COLOR" ".customrc added to .zshrc"
    fi
}
add_path_to_custom_rc() {
    if grep -q 'export export PATH=$PATH:$HOME/bin' "$CUSTOM_RC_PATH"; then 
        color_echo "$INFO_COLOR" "PATH already setup in .customrc"
    else 
        color_echo "$INFO_COLOR" 'export export PATH=$PATH:$HOME/bin' >> "$CUSTOM_RC_PATH"
        color_echo "$INFO_COLOR" "PATH added to .customrc"
    fi
}

# Function to download a file from a URL
download_file() {
    local url=$1
    local filename=$2
    if ! curl -L "$url" -o "$filename"; then
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

# Function to install aws-iam-authenticator
install_aws-iam-authenticator() {
    color_echo "$INFO_COLOR" "Downloading aws-iam-authenticator installer..."
    download_file "$AWS_IAM_AUTH_DOWNLOAD_URL" "aws-iam-authenticator"
    color_echo "$INFO_COLOR" "Changing execute mode ..."
    chmod +x ./aws-iam-authenticator
    mv ./aws-iam-authenticator $BIN_DIR/aws-iam-authenticator
}

# Function to install kubectl
install_kubectl() {
    color_echo "$INFO_COLOR" "Downloading kubectl installer..."
    download_file "$KUBE_DOWNLOAD_URL" "kubectl"
    color_echo "$INFO_COLOR" "Changing execute mode ..."
    chmod +x ./kubectl 
    mv ./kubectl $BIN_DIR/kubectl
}

for command in "${COMMANDS[@]}"; do
    if ! command -v $command >/dev/null 2>&1; then
        "install_$command"
        color_echo "$INFO_COLOR" "$command installed"
    fi
done

# Execute directory and file setup
add_custom_rc
add_path_to_custom_rc

# Commands validation
color_echo "$REQUIRED_COLOR" "$(aws --version)"
color_echo "$REQUIRED_COLOR" "$(aws-iam-authenticator version)"
color_echo "$REQUIRED_COLOR" "$(kubectl version --short --client)"

# Define cluster configurations for each environment
# bash 5.x.x upgrade 
declare -A CLUSTERS=( 
    ["dev-apne2"]="ap-northeast-2"
    ["dev-use1"]="us-east-1" 
    ["prod-apne2"]="ap-northeast-2" 
    ["prod-use1"]="us-east-1"
)

# Function to update kubeconfig for a given cluster and role
update_kubeconfig() {
    local profile="$1"
    local cluster="$2"
    local region="${CLUSTERS[$cluster]}"
    local team_name="$4"
    local role_arn=""
    if [ -n "$team_name" ]; then
        role_arn=$(aws iam get-role --role-name "k8s-$team_name-team" --query 'Role.Arn' --no-cli-pager --output text)
        aws eks update-kubeconfig --profile "$profile" --name "$cluster" --alias "$cluster" --region "$region" --role-arn "$role_arn"
    else 
        aws eks update-kubeconfig --profile "$profile" --name "$cluster" --alias "$cluster" --region "$region"

    fi
}

# Function to prompt the user for their team name
function get_team_name() {
    local team_name=""
    while [ -z "$team_name" ]; do
        read -p "Enter your team name: " team_name
    done
    echo "$team_name"
}

# TEAM_NAME=$(get_team_name)

kubectl_get_contexts() {
    kubectl config get-contexts -o name "$1"
}
# Add cluster 
# AWS_PROFILES=("suite-dev" "suite-prod")
# Loop over cluster configurations for each environment
for profile in "suite-dev" "suite-prod"; do
    for cluster in "${!CLUSTERS[@]}"; do
        if [[ "$profile" =~ "dev" ]] && [[ "$cluster" =~ "dev" ]]; then
            update_kubeconfig "$profile" "$cluster" "${CLUSTERS[$cluster]}" "$TEAM_NAME"
        fi
        if [[ "$profile" =~ "prod" ]] && [[ "$cluster" =~ "prod" ]]; then
            update_kubeconfig "$profile" "$cluster" "${CLUSTERS[$cluster]}" "$TEAM_NAME"
        fi
    done
done

