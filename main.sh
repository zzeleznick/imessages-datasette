#!/bin/bash
# ** imessages-datasette **
# Description: enable reading imessages in the browser.
# Usage:
#   -h : display help and exit
#   -p : specify datasette port, default 9000
#

# Bash strict mode
set -euo pipefail

# Command Line Options
port=9000

# Configuration constants
CHAT_DB=~/Library/Messages/chat.db
ADDRESS_BOOK=~/Library/Application\ Support/AddressBook/AddressBook-v22.abcddb

display_help() {
    # Displays the help message from the top of this file
    head -n6 "${BASH_SOURCE[0]}" | tail -n5 | sed -E 's/# ?//g'
}

parse_args() {
    while getopts 'p:h' flag; do
      case "${flag}" in
        h) display_help && exit 0 ;;
        p) port="${OPTARG}" ;;
        *) error "Unexpected option ${flag}" ;;
      esac
    done
}

log_error() {
    echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]|E|: $@" >&2
}

validate_setup() {
    dpath="$(command -v datasette)"
    if [[ ! "$dpath" ]]; then
        log_error "datasette does not appear to be installed" && exit 1        
    fi

    if [[ "$dpath" == ~/.pyenv/shims/datasette ]] && [[ $(command -v pyenv) ]] && [[ ! $(pyenv which datasette 2>/dev/null) ]]; then
        PYENV_VERSION="$(pyenv whence datasette)"
        export PYENV_VERSION
    fi
}

run_datasette() {
    set -x
    datasette -p $port --crossdb $CHAT_DB "$ADDRESS_BOOK"
}


main() {
    parse_args "$@"
    validate_setup
    run_datasette
}

main "$@"
