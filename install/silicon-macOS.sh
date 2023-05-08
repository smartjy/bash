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

# Define variables
COMMANDS=("aws" "aws-iam-authenticator" "kubectl")
AWS_IAM_AUTH_VERSION="0.5.9"
# Ref: https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html
AWS_IAM_AUTH_DOWNLOAD_URL="https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v${AWS_IAM_AUTH_VERSION}/aws-iam-authenticator_${AWS_IAM_AUTH_VERSION}_darwin_amd64"
# Ref: https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/install-kubectl.html
KUBE_VERSION="1.25.7"
KUBE_DOWNLOAD_URL="https://s3.us-west-2.amazonaws.com/amazon-eks/$KUBE_VERSION/2023-03-17/bin/darwin/amd64/kubectl"
ZSHRC_FILE="$HOME/.zshrc"
CUSTOM_RC_FILE="$HOME/.customrc"
BIN_DIR="$HOME/bin"
ADD_HOME_BIN_PATH='export PATH=$PATH:$HOME/bin'

# AWS Profile list
AWS_PROFILES=( "suite-dev" "suite-prod" )

# Define Functions
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

# Functions commans version
commands_version() {
  local cmd=$1
  case $cmd in
    aws)
      $cmd --version ;;
    aws-iam-authenticator)
      $cmd version ;;
    kubectl)
      $cmd version --short --client ;;
  esac
}

# Install commands start
for command in "${COMMANDS[@]}"; do
  if ! command -v $command >/dev/null 2>&1; then
    "install_$command"
    color_echo "$INFO_COLOR" "### $command installed"
    color_echo "$REQUIRED_COLOR" "$(commands_version $command)"
  else
    color_echo "$WARNING_COLOR" "### $command already installed"
    color_echo "$REQUIRED_COLOR" "$(commands_version $command)"
  fi
done

# color_echo "$INFO_COLOR" "### Commands install completed successfully"

# set directory and file
[ ! -d "$BIN_DIR" ] && mkdir "$BIN_DIR" && color_echo "$INFO_COLOR" "### Created $BIN_DIR"
[ ! -e "$CUSTOM_RC_FILE" ] && touch "$CUSTOM_RC_FILE" && color_echo "$INFO_COLOR" "### Created $CUSTOM_RC_FILE"

# Adds the custom rc command to .zshrc
add_custom_rc() {
  if grep -q "source $CUSTOM_RC_FILE" "$ZSHRC_FILE"; then 
    color_echo "$WARNING_COLOR" "### $CUSTOM_RC_FILE already exists in $ZSHRC_FILE"
  else 
    echo "source $CUSTOM_RC_FILE" >> "$ZSHRC_FILE"
    color_echo "$INFO_COLOR" "### $CUSTOM_RC_FILE added to $ZSHRC_FILE"
  fi
}
add_path_to_custom_rc() {
  if grep -q "$ADD_HOME_BIN_PATH" "$CUSTOM_RC_FILE"; then 
    color_echo "$WARNING_COLOR" "### $ADD_HOME_BIN_PATH already exists in $CUSTOM_RC_FILE"
  else 
    echo "$ADD_HOME_BIN_PATH" >> "$CUSTOM_RC_FILE"
    color_echo "$INFO_COLOR" "### $ADD_HOME_BIN_PATH added to $CUSTOM_RC_FILE"
  fi
}

add_custom_rc
add_path_to_custom_rc

# color_echo "$INFO_COLOR" "### Customrc add completed successfully"

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
  if [ -z "$team_name" ]; then
    aws eks update-kubeconfig --profile "$profile" --name "$cluster" --alias "$cluster" --region "$region"
  else 
    role_arn=$(aws iam get-role --role-name "k8s-$team_name-team" --query 'Role.Arn' --no-cli-pager --output text)
    aws eks update-kubeconfig --profile "$profile" --name "$cluster" --alias "$cluster" --region "$region" --role-arn "$role_arn"
  fi
}

# Function to prompt the user for their team name
get_team_name() {
  local team_name=""
  read -p "$(color_echo "$REQUIRED_COLOR" "### Enter your team name:") " team_name

  if [ -z "$team_name" ]; then
    read -p "$(color_echo "$REQUIRED_COLOR" "team_name was not selected. May not work this script? [Press Enter]") "
  fi
  echo $team_name
}
# Put TEAM_NAME
TEAM_NAME=$(get_team_name)

# Function to check if a context already exists in kubeconfig
context_exists() {
  kubectl config get-contexts -o name | grep -q "^$1$"
}

# Loop over cluster configurations for each environment
for profile in "${AWS_PROFILES[@]}"; do
  for cluster in "${!CLUSTERS[@]}"; do
    if [[ "$profile" =~ "dev" ]] && [[ "$cluster" =~ "dev" ]]; then
      if ! context_exists "$cluster"; then 
        update_kubeconfig "$profile" "$cluster" "${CLUSTERS[$cluster]}" "$TEAM_NAME"
        color_echo "$INFO_COLOR" "### Kubeconfig updated for profile $profile and cluster $cluster"
      else
        color_echo "$WARNING_COLOR" "### Context $cluster already exists in kubeconfig for profile $profile"
      fi
    fi
    if [[ "$profile" =~ "prod" ]] && [[ "$cluster" =~ "prod" ]]; then
      if ! context_exists "$cluster"; then 
        update_kubeconfig "$profile" "$cluster" "${CLUSTERS[$cluster]}" "$TEAM_NAME"
        color_echo "$INFO_COLOR" "### Kubeconfig updated for profile $profile and cluster $cluster"
      else
        color_echo "$WARNING_COLOR" "### Context $cluster already exists in kubeconfig for profile $profile"
      fi
    fi
  done
done

color_echo "$INFO_COLOR" "### AWS EKS Cluster add completed successfully"