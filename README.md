# Linux - Opdracht 2 Documentatie

### Gebruikte technologie
* Vagrant
* linuxcontainers (LXC)

### Prerequisites
Omdat we gebruik maken van LXC containers is het nodig een provider hiervoor te installeren zodat Vagrant kan communiceren met de containers.

    $ vagrant plugin install vagrant-lxc

We maken ook gebruik van de Ansible provider, dus is het nodig om Ansible te installeren.

    $ apt install ansible

Om later een docker job te kunnen runnen met Nomad is het nodig om container nesting toe te passen. Hiervoor hebben we de lxc container image ([visibilityspots/centos-7.x-minimal](https://app.vagrantup.com/visibilityspots/boxes/centos-7.x-minimal)) moeten aanpassen omdat dit standaard niet toegelaten is. Voeg in <code>~/.vagrant.d/boxes/visibilityspots-VAGRANTSLASH-centos-7.x-minimal/7.8.3/lxc/lxc-config</code>
 de regel <code>lxc.apparmor.profile= unconfined</code> toe. Dit zorgt ervoor dat container nesting toegestaan is.

### Starten van de VM's

    $ vagrant up --provision --provider=lxc

Dit bovenste commando start 1 server en 2 clients op.

De poort 8500 is voor de Consul-server en 4646 is voor de nomad-server. 

![Consul](https://i.imgur.com/r6ID8pQ.png)![enter image description here](https://i.imgur.com/Vb404pO.png)

### Uitleg configuratie

Er worden 2 clients en 1 server aangemaakt met onderstaande vagrantfile. Deze draaien op centos-7.x-minimal. Alle containers krijgen een RAM limiet van 1024MB mee. Nadat alle containers zijn gedefinieerd roepen we de Ansible-provider op. We groeperen de containers en maken een Inventory aan, zowel 'Servers' als 'Clients'. We geven ook een variabele mee aan elke Inventory-groep, wat aanduidt of het een server is of niet. 

De server krijgt de hostname: `server` en die clients krijgen elk de hostname `client1`, `client2`,... Zo veel clients als er nodig zijn. 

#### Vagrantfile
```
# -*- mode: ruby -*-
# vi: set ft=ruby :
VAGRANTFILE_API_VERSION = "2"
CLIENTS = 2

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.ssh.insert_key = false
  config.vm.box = "visibilityspots/centos-7.x-minimal"
#  config.vm.provision "shell", path: "scripts/update.sh"
#  config.vm.provision "shell", path: "scripts/install.sh"
  
  config.vm.define "server" do |server|
	server.vm.hostname = "server"
        server.vm.provider :lxc do |lxc|
          lxc.customize 'cgroup.memory.limit_in_bytes', '1024M'
        end
#	server.vm.provision "shell", path: "scripts/server.sh"
  end
  
  (1..CLIENTS).each do |i|
    config.vm.define "client#{i}" do |client|
      client.vm.hostname = "client#{i}"
      client.vm.provider :lxc do |lxc|
        lxc.customize 'cgroup.memory.limit_in_bytes', '1024M'
      end
#      client.vm.provision "shell", path: "scripts/client.sh"
    end
  end

  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "provisioning/playbook.yml"
    ansible.groups = { 
      "servers" => ["server"],
      "clients" => ["client1", "client2"],
      "servers:vars" => {"is_server" => true},
      "clients:vars" => {"is_server" => false}
    }
  end
end
```
#### Ansible playbook

In het Playbook geven we gewoon de rollen mee die elke Inventory-groep nodig heeft. Deze roepen dan bijhorende rollen op.
```
---
- name: server preparation
  hosts: servers
  become: yes
  roles:
    - consul
    - nomad

- name: client preparation
  hosts: clients
  become: yes
  roles: 
    - consul
    - nomad
    - docker

```

#### Roles

### consul
```
---
- name: update packages
  yum:
    name: '*'
    update_cache: true
    state: 'latest'

- name: install yum-utils
  yum: 
    name: yum-utils
    state: present

- name: add hashicorp repo
  get_url:
    url: https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
    dest: /etc/yum.repos.d/hashicorp.repo

- name: install consul
  yum: 
    name: consul
    state: present

- name: consul server conf
  template:
    src: server.hcl.j2
    dest: /etc/consul.d/consul.hcl
  when: is_server|bool

- name: consul client conf
  template:
    src: client.hcl.j2
    dest: /etc/consul.d/consul.hcl
  when: not is_server|bool   

- name: enable consul
  systemd:
    name: consul
    state: started
    enabled: yes
```

### docker
```
---
- name: update packages
  yum:
    name: '*'
    update_cache: true
    state: 'latest'

- name: install yum-utils
  yum: 
    name: yum-utils
    state: present

- name: add docker repo
  get_url:
    url: https://download.docker.com/linux/centos/docker-ce.repo
    dest: /etc/yum.repos.d/docker-ce.repo

- name: install docker-ce
  yum: 
    name: docker-ce
    state: present

- name: install docker-ce-cli
  yum: 
    name: docker-ce-cli
    state: present

- name: install containerd.io
  yum:
    name: containerd.io
    state: present

- name: enable docker
  systemd: 
    name: docker
    state: started
    enabled: yes

```

### nomad
```
---
- name: update packages
  yum:
    name: '*'
    update_cache: true
    state: 'latest'

- name: install yum-utils
  yum: 
    name: yum-utils
    state: present

- name: add hashicorp repo
  get_url:
    url: https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
    dest: /etc/yum.repos.d/hashicorp.rep

- name: install nomad
  yum: 
    name: nomad
    state: present

- name: nomad server conf
  template:
    src: server.hcl.j2
    dest: /etc/nomad.d/nomad.hcl
  when: is_server|bool

- name: nomad client conf
  template:
    src: client.hcl.j2
    dest: /etc/nomad.d/nomad.hcl
  when: not is_server|bool    

- name: enable nomad
  systemd: 
    name: nomad
    state: started
    enabled: yes
```

#### Templates

Deze templates worden met bovenstaande roles overgekopieerd naar de guests.

### Client template
```
data_dir = "/etc/nomad.d/data"

client {
  enabled = true
  servers = ["server:4647"]
}
```

### Server template
```
data_dir = "/etc/nomad.d/data"

server {
  enabled          = true
  bootstrap_expect = 1
}
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
https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html
https://www.vagrantup.com/docs/provisioning/ansible_intro
https://app.vagrantup.com/visibilityspots
