# -*- mode: ruby -*-
# vi: set ft=ruby :
VAGRANTFILE_API_VERSION = "2"
CLIENTS = 2

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = "visibilityspots/centos-7.x-minimal"
  config.vm.provision "shell", path: "scripts/update.sh"
  config.vm.provision "shell", path: "scripts/install.sh"
  
  config.vm.define "server" do |server|
	server.vm.hostname = "server"
        server.vm.provider :lxc do |lxc|
          lxc.customize 'cgroup.memory.limit_in_bytes', '1024M'
        end
	server.vm.provision "shell", path: "scripts/server.sh"
  end
  
  (1..CLIENTS).each do |i|
    config.vm.define "client#{i}" do |client|
      client.vm.hostname = "client#{i}"
      client.vm.provider :lxc do |lxc|
        lxc.customize 'cgroup.memory.limit_in_bytes', '1024M'
      end
      client.vm.provision "shell", path: "scripts/client.sh"
    end
  end
end
