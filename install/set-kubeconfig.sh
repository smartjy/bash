#!/usr/bin/env bash
set -e

# Color setup 
ERROR_COLOR='\033[1;31m'
INFO_COLOR='\033[1;32m'
REQUIRED_COLOR='\033[1;36m'
WARNING_COLOR='\033[1;33m'
NO_COLOR='\033[0m'

# Define cluster configurations for each environment
# bash 5.x.x upgrade 
declare -A CLUSTERS=( 
  ["dev-apne2"]="ap-northeast-2"
  ["dev-use1"]="us-east-1" 
  ["prod-apne2"]="ap-northeast-2" 
  ["prod-use1"]="us-east-1"
)

# Function to print colored messages
color_echo() {
  local color=$1
  shift
  printf "${color}%s${NO_COLOR}\n" "$@"
}

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
    read -p "$(color_echo "$WARNING_COLOR" "team_name was not selected. May not work this script? [Press Enter]") " choice
  fi
  echo $team_name
}

TEAM_NAME=$(get_team_name)

# Function to check if a context already exists in kubeconfig
context_exists() {
  kubectl config get-contexts -o name | grep -q "^$1$"
}

# Loop over cluster configurations for each environment
for profile in "suite-dev" "suite-prod"; do
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

color_echo "$INFO_COLOR" "### Script completed successfully"
