# Linux - Opdracht 1 Documentatie

### Starten van de VM's

    $ vagrant up --provision

Dit bovenste commando start 1 server en x aantal clients op.

Door het uit te voeren van beide onderstaande commandos in twee verschillende terminal-vensters krijgen we een web user interface op onze host. De sessie verloopt bij het sluiten van deze SSH-connectie. De poort 8500 is voor de Consul-server en 4646 is voor de nomad-server. Bij Hyper-V is dit de enigste manier want dit is een limitatie van het netwerkconfiguratie van Hyper-V zoals vermeld hier: https://www.vagrantup.com/docs/providers/hyperv/limitations .

    $ vagrant ssh server -- -L 8500:localhost:8500
    $ vagrant ssh server -- -L 4646:localhost:4646

![Consul](https://i.imgur.com/r6ID8pQ.png)![enter image description here](https://i.imgur.com/Vb404pO.png)

### Uitleg configuratie

Er worden 3 clients en 1 server aangemaakt met onderstaande vagrantfile. Deze draaien op centos/7. Op alle VM's wordt `update.sh` en `install.sh` uitgevoerd.  `update.sh` checkt of de VM up to date is en update vervolgens als dat nodig is. `install.sh` installeert nomad, consul en docker op alle VM's en start deze op als systemd-service. 

De server krijgt de hostname: `server` en die clients krijgen elk de hostname `client1`, `client2`, `client3`... Zo veel clients als er nodig zijn. Voor de server wordt vervolgens een script `server.sh` uitgevoerd en voor de clients `client.sh` voor de configuratie nomad en consul.

#### Vagrantfile
```
# -*- mode: ruby -*-
# vi: set ft=ruby :
VAGRANTFILE_API_VERSION = "2"
CLIENTS = 3

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = "centos/7"
  config.vm.provision "shell", path: "scripts/update.sh"
  config.vm.provision "shell", path: "scripts/install.sh"
  
  config.vm.define "server" do |server|
	server.vm.hostname = "server"
	server.vm.provision "shell", path: "scripts/server.sh"
  end
  
  (1..CLIENTS).each do |i|
    config.vm.define "client#{i}" do |client|
      client.vm.hostname = "client#{i}"
      client.vm.provision "shell", path: "scripts/client.sh"
    end
  end
end
```
#### Server Configuratie
Onderstaand is het script `server.sh`. We overschrijven de default-configs voor nomad.hcl en consul.hcl met onderstaande configs die geplaatst worden in `/etc/nomad.d/nomad.hcl` en `/etc/nomad.d/consul.hcl`. We geven aan in beide configs dat dit de server gaat zijn. 

`bind_addr = "{{ GetInterfaceIP \"eth0\" }}"` neemt het IP dat Hyper-V heeft toegekent aan de interface `eth0` en koppelt dit aan de consul-server. Vervolgens restarten we beide services om de config-files opnieuw in te laden.

```bash
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
```

#### Client Configuratie
Onderstaand is het script `client.sh`.  We overschrijven de default-configs voor nomad.hcl en consul.hcl met onderstaande configs die geplaatst worden in `/etc/nomad.d/nomad.hcl` en `/etc/nomad.d/consul.hcl`. Dit is de configuratie voor de clients. Vervolgens restarten we beide services om de config-files opnieuw in te laden.

```bash
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
```
#### Hyper-V als DHCP & DNS
Voor `servers = ["server:4647"]` en `retry_join = ["server"]` geef ik geen ip-adres in maar alleen de hostname van de server. Dit gaat werken omdat alle VM's binnen de Default Switch zitten van Hyper-V en elke VM een IP-adres krijgt van Hyper-V DHCP-server, ook zorgt Hyper-V voor name resolution met de DNS `mshome.net`.

**Groot voordeel hiervan is dat we nergens IP's moeten definiëren in config-files en maakt alles een heel stuk overzichtelijker!** 

Ping van client1 naar server.
![pingclient1](https://i.imgur.com/Ak2RBpj.png)
Ping van server naar client1.
![pingserver](https://i.imgur.com/hGC817M.png)
#### Update-script
Dit script kijkt of updates nodig zijn en installeert ze vervolgens.
```bash
yum check-update > /dev/null

UPDATES_COUNT=$(yum check-update --quiet | grep -v "^$" | wc -l)

if [[ $UPDATES_COUNT -gt 0 ]]; then
   echo "${UPDATES_COUNT} Updates available, installing"
   yum -y upgrade
else
   echo "${UPDATES_COUNT} updates available"
fi
```

#### Install-script
Onderstaand script installeert Nomad, Consul en Docker en start deze op als systemd-services.
```bash
# Install Nomad
yum install -y yum-utils
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
yum -y install nomad
nomad --version

systemctl enable nomad
systemctl start nomad

# Install Consul
yum -y install consul
consul --version

systemctl enable consul
systemctl start consul

# Install Docker
yum install -y yum-utils
yum-config-manager \
	--add-repo \
	https://download.docker.com/linux/centos/docker-ce.repo

yum install -y docker-ce docker-ce-cli containerd.io

systemctl enable docker
systemctl start docker
```

### Uitvoeren van een job

Het uitvoeren van een job gaat op twee manieren. Ofwel met het commando `$ nomad job run job.nomad` ofwel met de GUI die we hebben opgezet op `http://localhost:4646` op de host-machine.

#### Nomad job
Onderstaande job zal een webserver opstarten met behulp van `driver = "docker"`.  We gebruiken `image="nginx"` om een nginx-webserver op te starten op poort 80.
```bash
job "webserver" {
  datacenters = ["dc1"]
  type = "service"
  
  group "webserver" {
    count = 3
  
    task "webserver" {
      driver = "docker"
      config {
        image = "nginx"
		force_pull = true
		port_map = {
		  webserver_web = 80
		} 
		logging {
		  type = "journald"
		  config {
		    tag = "WEBSERVER"
		 }
		}	
      }
	  
	  service {
	    name = "webserver"
	    port = "webserver_web"
	  } 
      resources {
        network {
          port "webserver_web" {
            static = "80"
          }
        }
      }
    }
  }
}
```

#### Starten van de nomad-job
Om een job te starten surf je naar `http://localhost:4646` op de host-machine en klik je vervolgens op `Run Job`. 
![Nomad-job](https://i.imgur.com/01Z6N2a.png)

In het volgende venster plak je de job die je wilt uitvoeren en klik je op `Plan`
![nomadplan](https://i.imgur.com/3j5yZJE.png)

Vervolgens klik je op `Run` en zal de task starten.
![nomadrun](https://i.imgur.com/ZWIvs3t.png)

De webserver zal op 3 clients gestart worden en dan kunnen we er naar surfen via het IP-adres van die client.
![webserver](https://i.imgur.com/m37PSaI.png)
Ik kan surfen naar het IP-adres van 1 van de clients en dit zal de website tonen. Dit werkt met Hyper-V omdat de host-machine ook een binnen de Default Switch zit van Hyper-V en daarbij ook een IP-adres krijgt.
![enter image description here](https://i.imgur.com/6l14tie.png)



### Gebruikte bronnen
https://www.consul.io/docs/agent/options.html
https://www.vagrantup.com/docs/providers/hyperv/limitations
https://learn.hashicorp.com/tutorials/nomad/get-started-install
https://learn.hashicorp.com/tutorials/nomad/production-deployment-guide-vm-with-consul
https://learn.hashicorp.com/tutorials/nomad/get-started-jobs
