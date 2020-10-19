cat << END >/etc/nomad.d/nomad.hcl
data_dir = "/etc/nomad.d"

server {
  enabled          = true
  bootstrap_expect = 1
}
END

systemctl daemon-reload

systemctl enable nomad
systemctl start nomad