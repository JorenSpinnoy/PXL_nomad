# Overwrites the default systemd config file for nomad
cat << END >/etc/nomad.d/nomad.hcl
data_dir = "/etc/nomad.d/data"

client {
  enabled = true
  servers = ["server:4647"]
}
END

# Overwrites the default systemd config file for consul
cat << END >/etc/consul.d/consul.hcl
bind_addr = "{{ GetInterfaceIP \"eth0\" }}"

data_dir = "/etc/consul.d/data"

client_addr = "0.0.0.0"

retry_join = ["server"]
END

systemctl daemon-reload
systemctl restart nomad
systemctl restart consul