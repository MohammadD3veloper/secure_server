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
        function pkg {
            if [ -f "/etc/redhat-release" ]; then 
                pkg=yum
            elif [ -f "/etc/debian_version" ]; then
                pkg=apt-get
            fi
        }

        function change_port {
            sed -i "s/#Port 22/Port $SSH_PORT" /etc/ssh/sshd_config
        }

        function set_firewall {
            if [ "$(command -v ufw)" == 0 ]; then 
                $pkg install ufw 2>&1 /dev/null | echo -e "[!] Installing UFW Firewall"
                ufw allow 80/tcp && ufw allow 443/tcp && ufw allow $SSH_PORT/tcp | echo -e "[!] Opening 80, 443, $SSH_PORT ports"
            else
                ufw allow 80/tcp && ufw allow 443/tcp && ufw allow $SSH_PORT/tcp | echo -e "[!] Opening 80, 443, $SSH_PORT ports"
            fi
        }

        function install_package {
            $pkg update && $pkg upgrade -y 2>&1 /dev/null | echo -e "[+] Updating Package Manager"
            $pkg install docker docker-compose certbot curl wget -y 2>&1 /dev/null | echo -e "[+] Installing needed tools"
        }

        function tls_domains {
            for domain in $DOMAINS
            do
                certbot certonly --standalone --agree-tos --register-unsafely-without-email -d $domain
            done
        }

        function create_and_change_user {
            useradd -mG sudo $USER_NAME -s /bin/bash 2>&1 /dev/null | echo -e "[+] Creating new user"
            echo -e "Set password for new user"
            echo $USER_PASS | passwd $USER_NAME
            su $USER_NAME | echo -e "[!] Switching to new user"
        }

        function install_v2ray {
            curl -O https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh 2>&1 /dev/null | echo -e "[+] Downloading 3XUI installation script"
            chmod +x install.sh | echo -e "[!] Accessing to script"
            echo 'y' | echo $PANEL_USER | echo $PANEL_PASSWORD | echo $PANEL_PORT | sudo ./install.sh | echo -e "[!] Installing and configuring 3XUI"
            rm install.sh
        }


        set_firewall
        change_port
        install_package
        tls_domains
        create_and_change_user
        install_v2ray

        if [ "$MTPROTO_Y_N" == "y" ]; then
            function mtproto_git {
                git clone https://github.com/alexbers/mtprotoproxy.git
                cd mtprotoproxy && python3 mtprotoproxy.py
            }

            function add_systemd_service {
                cat <<EOF >>/etc/systemd/system/mtprotoproxy.service
[Unit]
    Description=Async MTProto proxy for Telegram
    After=network-online.target
    Wants=network-online.target
[Service]
    ExecStart=/home/$USER_NAME/mtprotoproxy/mtprotoproxy.py
    AmbientCapabilities=CAP_NET_BIND_SERVICE
    LimitNOFILE=infinity
    User=$USER_NAME
    Group=$USER_NAME
    Restart=on-failure
[Install]
    WantedBy=multi-user.target
EOF
            }

            function start_systemd {
                systemctl enable mtprotoproxy
                systemctl start mtprotoproxy
            }

            mtproto_git
            add_systemd_service
            start_systemd
        fi
    elif [ "$1" == "dev" ]; then
        bash modules/dev.sh
    fi
}

main $1
