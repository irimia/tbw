#!/bin/bash -x

set -Eeuo pipefail
trap '' SIGINT SIGTERM ERR EXIT
shopt -s expand_aliases
# shellcheck source=/dev/null
FILE=$HOME/.solarrc && test -f "$FILE" && source "$FILE" # For Solar nodes.

CORE2_TBW_PATH=$HOME/core2_tbw
DEV51_TBW_PATH=$HOME/tbw
CONFIG_FILE=$DEV51_TBW_PATH/core/config/config

pause() {
    # shellcheck disable=SC2162
    read -p "Press [Enter] key to continue..."
}

echo "
 _|_|_|_|_|   _|_|_|     _|          _| DEV51
     _|       _|    _|   _|          _|
     _|       _|_|_|     _|    _|    _|
     _|       _|    _|     _|  _|  _|
     _|       _|_|_|         _|  _|     Migration Script

This script will install TBW (version maintained by DEV51)
and migrate your config and database from current install.
"

pause

if [ -d "${CORE2_TBW_PATH}" ]; then
    echo "Installing TBW (version maintained by DEV51)..."
    git clone https://github.com/irimia/tbw && cd "$DEV51_TBW_PATH"

    python3 -m pip install --user --no-warn-script-location -r requirements.txt

    echo "Migrating core2_tbw"
    pm2 stop tbw && pm2 stop pay
    cp "$CORE2_TBW_PATH"/core/config/config "$DEV51_TBW_PATH"/core/config/config

    if ! grep -q "SENTRY_DSN" "$CONFIG_FILE"; then
        echo -e "\n# Misc\nSENTRY_DSN =" '""' >> "$CONFIG_FILE"
    fi

    if ! grep -q "TELEMETRY" "$CONFIG_FILE"; then
        echo 'TELEMETRY = "yes"' >> "$CONFIG_FILE"
    fi

    find "$CORE2_TBW_PATH" -name '*.db' -exec cp "{}" "$DEV51_TBW_PATH" \; || echo "*.db not found. Exiting!"

    cd "$DEV51_TBW_PATH"
    pm2 delete tbw && pm2 delete pay
    pm2 start apps.json --only pay && pm2 start apps.json --only tbw

    echo "Done!"
    pause
else
    echo "core2_tbw installation not found. Exiting!"
fi
