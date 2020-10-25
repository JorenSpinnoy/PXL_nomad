# -*- mode: ruby -*-
# vi: set ft=ruby :
VAGRANTFILE_API_VERSION = "2"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = "centos/7"
  config.vm.provision "shell", path: "scripts/update.sh"
  config.vm.provision "shell", path: "scripts/install.sh"
  
  config.vm.define "server" do |server|
	server.vm.hostname = "server"
	server.vm.provision "shell", path: "scripts/server.sh"
  end

  config.vm.define "client1" do |client1|
	client1.vm.hostname = "client1"
	client1.vm.provision "shell", path: "scripts/client.sh"
  end
  
  config.vm.define "client2" do |client2|
	client2.vm.hostname = "client2"
	client2.vm.provision "shell", path: "scripts/client.sh"
  end
  
    config.vm.define "client3" do |client3|
	client3.vm.hostname = "client3"
	client3.vm.provision "shell", path: "scripts/client.sh"
  end
  
end
