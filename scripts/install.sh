#1/bin/bash

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