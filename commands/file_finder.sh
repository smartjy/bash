#!/bin/bash

USER=$(whoami)

ask_prompt () {

  # workspace validation check
  while true
	do
    read -p "# Where is path? (default: $HOME) " workspace
    [ -z "$workspace" ] && workspace="$HOME"
      if [ ! -d "$workspace" ]
  		then
        echo -e "# [ERROR] workspace is not directory or doesn't exists \\n"
      else
  	  	break;
  		fi
	done

  # default path is $HOME and null check
  while true
  do
    read -p "# Enter the name? (file or directory) " name
      if [ -z "$name" ]
      then
        echo -e "# [ERROR] file name is empty \\n"
      else
        break;
      fi
  done

  WORKSPACE="$workspace"
  NAME="$name"

}

find_start () {

  local RESULT=$(find "$WORKSPACE" -user "$USER" -name "$NAME" 2>/dev/null)

  # File type check
  if [ -d "$RESULT" ]
  then
    echo -e "\\n# Found directory \\n"$RESULT" \\n"
  elif [ -f "$RESULT" ]
  then
    echo -e "\\n# Found File \\n"$RESULT" \\n"
  else
    echo -e "\\n# Can not found! No such file or directory \\n"
  fi
  
}

# Function start here
ask_prompt
find_start
