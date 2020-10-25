# Overwrites the default systemd config file for nomad
cat << END >/etc/nomad.d/nomad.hcl
data_dir = "/etc/nomad.d/data"

server {
  enabled          = true
  bootstrap_expect = 1
}
END

# Overwrites the default systemd config file for consul
cat << END >/etc/consul.d/consul.hcl
bind_addr = "{{ GetInterfaceIP \"eth0\" }}"

data_dir = "/etc/consul.d/data"

client_addr = "0.0.0.0"

ui = true

server = true

bootstrap_expect = 1
END

systemctl daemon-reload
systemctl restart nomad
systemctl restart consul