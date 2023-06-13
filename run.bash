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
    read -p "Enter Password: " USER_PASS
    read -p "Enter SSH port: " SSH_PORT
    read -a "Enter Domains: " DOMAINS
    read -p "Enter Username for panel: " PANEL_USER
    read -p "Enter Password for panel: " PANEL_PASSWORD
    read -p "Enter Port for panel: " PANEL_PORT
    read -p "Enable MTProto Proxy? (y,n)" MTPROTO_Y_N
    if [ "$1" == "v2ray" ]; then 
        source modules/v2ray.bash
        if [ "$MTPROTO_Y_N" == "y" ]; then
            source modules/mtproto.sh
        fi
    elif [ "$1" == "dev" ]; then
        source modules/dev.bash
    fi
}
