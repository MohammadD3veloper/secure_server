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
