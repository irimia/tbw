#!/bin/bash -x

set -Eeuo pipefail
shopt -s expand_aliases

# shellcheck source=/dev/null
FILE=$HOME/.solarrc && test -f "$FILE" && source "$FILE" # For Solar nodes.

cd $HOME/tbw/core/

# run payments only if `pm2 pay` process is ON
[[ "$(pm2 describe pay)" =~ "online" ]] && python3 tbw.py --manualPay