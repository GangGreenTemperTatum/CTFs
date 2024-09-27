#!/bin/bash

## Dependencies:
### subfinder - https://github.com/projectdiscovery/subfinder
### anew - https://github.com/tomnomnom/anew
### notify - https://github.com/projectdiscovery/notify
### brew coreutils - https://formulae.brew.sh/formula/coreutils
### httpx - https://github.com/projectdiscovery/httpx

## Usage:
### Ensure 'chmod 777' is set on the domains and subdomains text files
### Ensure `chmod +x` is set on this script

# Define the timestamp variable
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

# Define the log file
LOG_FILE="${TIMESTAMP}-subdomain_enum-script.log"

# Redirect stdout and stderr to the log file and the terminal
exec > >(tee -a "$LOG_FILE") 2>&1

set -eo pipefail

BOLD_WHITE='\033[1;37m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
BOLD_RED='\033[1;31m'
RED='\033[0;31m'
BOLD_YELLOW='\033[1;33m'
RESET='\033[0m' # No Color

#NOTIFY_CONFIG="$HOME/.config/notify/provider-config.yaml"
NOTIFY_CONFIG="./example_notify_config.yaml" # test from the repo

TIMEOUT=""
if [ "$(uname -s)" == "Linux" ]; then
  TIMEOUT="timeout -v $RUN_TIME_LIMIT"
else # MacOs
  if [ -x "$(command -v gtimeout)" ]; then
    TIMEOUT="gtimeout -v $RUN_TIME_LIMIT" # from `brew install coreutils`
  else
    echo -e "${BOLD_YELLOW}WARNING${RESET} gtimeout not available"
  fi
fi

function check_command_installed {
  if ! [ -x "$(command -v $1)" ]; then
    echo "Error: $1 is not installed, check the script usage notes to proceed with installation" >&2
    exit 1
  fi
}

check_command_installed subfinder
check_command_installed anew
check_command_installed notify
#check_command_installed coreutils
check_command_installed httpx

function check_file_exists {
  if [ ! -f "$1" ]; then
    echo "Error: $1 does not exist." >&2
    exit 1
  fi
}

# The check file exists is done in the assetdiscovery infinite loop

function print_and_execute() {
  echo "+ $@" >&2
  "$@"
}

## Infinite loop for asset discovery and subdomain enumeration

while true; do # infinite loop
    echo -e "$(date +"%Y-%m-%d %H:%M:%S") ${BOLD_WHITE}Scanning domains with subfinder...\n${RESET}"
    check_file_exists "$NOTIFY_CONFIG"
    subfinder -silent -dL domains.txt -all -o "archive/subdomains-${TIMESTAMP}.txt" | anew "${TIMESTAMP}.txt" | tee -a "archive/diff-${TIMESTAMP}.txt" | notify -bulk -id assetdiscoveryslack -pc "$NOTIFY_CONFIG"
    echo -e "$(date +"%Y-%m-%d %H:%M:%S") ${GREEN}Any diffs identified with anew have been stored in archive/${TIMESTAMP}.txt\n${RESET}"
    #sleep 3600 # 1 hour prevents the infinite loop from running every second
    # alternatively, set the script to run every hour on a cronjob
    echo -e "$(date +"%Y-%m-%d %H:%M:%S") ${GREEN}Completed subfinder scan\n${RESET}"
    echo -e "$(date +"%Y-%m-%d %H:%M:%S") ${BOLD_WHITE}Instatiating httpx...\n\n\n${RESET}"
    httpx -silent -l "archive/diff-${TIMESTAMP}.txt" -o "archive/httpx-findings-${TIMESTAMP}.txt" -sc -cl -ct -rt -probe -fr -fc 200,301,302,307 | notify -bulk -id httpxresultsslack -pc "$NOTIFY_CONFIG"
    echo -e "$(date +"%Y-%m-%d %H:%M:%S") ${GREEN}httpx results sent via Slack and stored in archive/httpx-findings-${TIMESTAMP}.txt...\n${RESET}"
    break # remove this line to run the infinite loop
done
