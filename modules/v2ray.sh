#!/bin/bash

function pkg {
    if [ -f "/etc/redhat-release" ]; then 
        pkg=yum
    elif [ -f "/etc/debian_version" ]; then
        pkg=apt-get
    fi
    return $pkg
}

function set_firewall {
    if [ "$(command -v ufw)" == 0 ]; then 
        pkg install ufw 2&>1 /dev/null | echo -e "[!] Installing UFW Firewall"
        ufw allow 80/tcp && ufw allow 443/tcp | echo -e "[!] Opening 80 and 443 ports"
    else
        ufw allow 80/tcp && ufw allow 443/tcp | echo -e "[!] Opening 80 and 443 ports"
    fi
}

function install_package {
    pkg update && pkg upgrade -y 2&>1 /dev/null | echo -e "[+] Updating Package Manager"
    pkg install docker docker-compose certbot curl wget -y 2&>1 /dev/null | echo -e "[+] Installing needed tools"
}

function tls_domains {
    for domain in $DOMAINS
    do
        certbot certonly --standalone --agree-tos --register-unsafely-without-email -d $domain
    done
}

function create_and_change_user {
    useradd -mG sudo $USER_NAME -s /bin/bash 2&>1 /dev/null | echo -e "[+] Creating new user"
    echo -e "Set password for new user"
    echo $USER_PASS | passwd $USER_NAME
    su $USER_NAME | echo -e "[!] Switching to new user"
}

function install_v2ray {
    curl -O https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh 2&>1 /dev/null | echo -e "[+] Downloading 3XUI installation script"
    chmod +x install.sh | echo -e "[!] Accessing to script"
    echo 'y' | echo $PANEL_USER | echo $PANEL_PASSWORD | echo $PANEL_PORT | sudo ./install.sh | echo -e "[!] Installing and configuring 3XUI"
    rm install.sh
}
