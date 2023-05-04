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
AWS_PROFILES=$(aws configure list-profiles)
CLUSTERS=("dev-apne2" "dev-use1" "prod-apne2" "prod-use1")

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



COMMANDS=("aws" "aws-iam-authenticator" "kubectl")
for command in "${COMMANDS[@]}"; do
    if ! command -v $command >/dev/null 2>&1; then
        install_"$command"
    fi
done

update_kubeconfig() {
    aws eks update-kubeconfig --profile "$1" --name "$2" --alias "$2" --region "$3"
}
kubectl_get_contexts() {
    kubectl config get-contexts -o name
}

# for profile in "${AWS_PROFILES[@]}"; do
#     for cluster in "${CLUSTERS[@]}"; do
#         case $cluster in 
#             *apne2*)
#                 region="ap-northeast-2"
#                 update_kubeconfig "$profile" "$cluster" "$region"
#                 ;;
#             *use1*)
#                 region="us-east-1"
#                 update_kubeconfig "$profile" "$cluster" "$region"
#                 ;;
#         esac
#     done
# done

# echo "Kubernetes contexts:"
# kubectl_get_contexts
