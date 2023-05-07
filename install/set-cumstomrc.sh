#!/usr/bin/env bash
set -e

# Color setup 
ERROR_COLOR='\033[1;31m'
INFO_COLOR='\033[1;32m'
REQUIRED_COLOR='\033[1;36m'
WARNING_COLOR='\033[1;33m'
NO_COLOR='\033[0m'

# Define variables
ZSHRC_FILE="$HOME/.zshrc"
CUSTOM_RC_FILE="$HOME/.customrc1"
BIN_DIR="$HOME/bin1"
ADD_HOME_BIN_PATH='export PATH=$PATH:$HOME/bin'

# Function to print colored messages
color_echo() {
  local color=$1
  shift
  printf "${color}%s${NO_COLOR}\n" "$@"
}

# set directory and file
[ ! -e "$BIN_DIR" ] && mkdir "$BIN_DIR"; color_echo "$INFO_COLOR" "### Created $BIN_DIR"
[ ! -f "$CUSTOM_RC_FILE" ] && touch "$CUSTOM_RC_FILE"; color_echo "$INFO_COLOR" "### Created $CUSTOM_RC_FILE"

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
