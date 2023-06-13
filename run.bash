#!/bin/bash

# if user is not root, exit program
function check_root {
    if [ $UID != 0 ]; then
        echo -e "[!] You must run this script with sudo"
        exit
    fi
}

# getting values from user and running source file
function main() {
    check_root
    read -p "Enter Username: " USER_NAME
    echo -n "Enter Password: "
    read -s USER_PASS
    echo
    read -p "Enter SSH port: " SSH_PORT
    echo -n "Enter Domains: "
    read -a DOMAINS
    read -p "Enter Username for panel: " PANEL_USER
    echo -n "Enter Password for panel: "
    read -s PANEL_PASSWORD
    echo
    read -p "Enter Port for panel: " PANEL_PORT
    read -p "Enable MTProto Proxy? (y,n)" MTPROTO_Y_N
    if [ "$1" == "v2ray" ]; then 
        source modules/v2ray.sh
        if [ "$MTPROTO_Y_N" == "y" ]; then
            bash modules/mtproto.sh
        fi
    elif [ "$1" == "dev" ]; then
        bash modules/dev.sh
    fi
}

main $1
