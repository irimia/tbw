#!/bin/bash

shopt -s expand_aliases
# shellcheck source=/dev/null
FILE=$HOME/.solarrc && test -f "$FILE" && source "$FILE" # For Solar nodes.

# A menu driven shell script sample template
## ----------------------------------
# Step #1: Define variables
# ----------------------------------
RED='\033[0;41;30m'
STD='\033[0;0;39m'

required_packages=(
    "python3-pip"
    "python3-dev"
    "python3-venv"
    "python3-wheel"
    "libudev-dev"
    "build-essential"
    "autoconf"
    "libtool"
    "pkgconf"
    "libpq-dev"
)

# ----------------------------------
# Step #2: User defined function
# ----------------------------------
pause() {
    # shellcheck disable=SC2162
    read -p "Press [Enter] key to continue..."
}

install_packages() {
    sudo -k
    if sudo true; then
        sudo apt-get install "${required_packages[@]}" -y
    fi

    dpkg -s "${required_packages[@]}" >/dev/null 2>&1 || missing_package # For Solar user which shouldn't be in sudoers

    python3 -m pip install --user --upgrade pip
    python3 -m pip install --user --no-warn-script-location setuptools
    python3 -m pip install --user --no-warn-script-location wheel
    python3 -m pip install --user --no-warn-script-location -r requirements.txt
}

missing_package() {
    echo -e "Run the following as root:\n
apt install python3-pip python3-dev python3-venv python3-wheel libudev-dev build-essential autoconf libtool pkgconf libpq-dev -y\n
Then run again 'bash tbw.sh'"
    exit 1
}

install() {
    install_packages
    pause
}

update() {
    echo "Soon"
    pause
}

initialize() {
    version=$(python3 -c "import sys; print(''.join(map(str, sys.version_info[:2])))")

    if [[ "$version" -lt 36 ]]; then
        echo "Python 3.6 minimum version is required"
        exit 1
    fi

    cd core || exit
    python3 tbw.py
    cd ..
    pause
}

all() {
    cd core || exit
    pm2 start apps.json
    cd ..
    pause
}

tbw() {
    cd core || exit
    pm2 start apps.json --only tbw
    cd ..
    pause
}

pay() {
    cd core || exit
    pm2 start apps.json --only pay
    cd ..
    pause
}

custom() {
    cd core || exit
    pm2 start apps.json --only custom
    cd ..
    pause
}

pool() {
    cd core || exit
    pm2 start apps.json --only pool
    cd ..
    pause
}

stop() {
    cd core || exit
    pm2 stop apps.json
    cd ..
    pause
}

# function to display menus
show_menus() {
    clear
    echo "~~~~~~~~~~~~~~~~~~~~~"
    echo " M A I N - M E N U"
    echo "~~~~~~~~~~~~~~~~~~~~~"
    echo "1. Install / Update"
    echo "2. Initialize"
    echo "3. Start All"
    echo "4. Start TBW Only"
    echo "5. Start Pay Only"
    echo "6. Start Custom Only"
    echo "7. Start Pool Only"
    echo "8. Stop All"
    echo "9. Exit"
}
read_options() {
    local choice
    read -p "Enter choice [ 1 - 9] " choice
    case $choice in
    1) install ;;
    2) initialize ;;
    3) all ;;
    4) tbw ;;
    5) pay ;;
    6) custom ;;
    7) pool ;;
    8) stop ;;
    9) exit 0 ;;
    *) echo -e "${RED}Error...${STD}" && sleep 2 ;;
    esac
}

# ----------------------------------------------
# Step #3: Trap CTRL+C, CTRL+Z and quit singles
# ----------------------------------------------
trap '' SIGINT SIGQUIT SIGTSTP

# -----------------------------------
# Step #4: Main logic - infinite loop
# ------------------------------------
while true; do
    show_menus
    read_options
done
