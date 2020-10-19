sudo cat << END >/etc/nomad.d/server.hcl
data_dir = "/etc/nomad.d"

server {
  enabled          = true
  bootstrap_expect = 1
}
END

sudo cat << END >/etc/systemd/system/nomad.service
[Unit]
Description=Nomad
Documentation=https://nomadproject.io/docs/
Wants=network-online.target
After=network-online.target

[Service]
ExecReload=/bin/kill -HUP $MAINPID
ExecStart=/usr/local/bin/nomad agent -config /etc/nomad.d/server.hcl
KillMode=process
KillSignal=SIGINT
LimitNOFILE=infinity
LimitNPROC=infinity
Restart=on-failure
RestartSec=2
StartLimitBurst=3
StartLimitIntervalSec=10
TasksMax=infinity

[Install]
WantedBy=multi-user.target
END

sudo systemctl daemon-reload

sudo systemctl enable nomad
sudo systemctl start nomad