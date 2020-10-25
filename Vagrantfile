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
