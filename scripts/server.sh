cat << END >/etc/nomad.d/nomad.hcl
data_dir = "/etc/nomad.d"

server {
  enabled          = true
  bootstrap_expect = 1
}
END

cat << END >/etc/consul.d/consul.hcl
bind_addr = "server"

data_dir = "/etc/consul.d"

client_addr= "0.0.0.0"

ui = true

server = true

bootstrap_expect = 1
END

systemctl daemon-reload
systemctl restart nomad
systemctl restart consul