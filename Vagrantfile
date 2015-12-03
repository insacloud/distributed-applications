Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"

  config.vm.network "forwarded_port", guest: 80, host: 8080
  for i in 9000..9010
    config.vm.network "forwarded_port", guest: i, host: i
  end  

  config.vm.provision "shell", path: "provision.sh"

  # Forward des connexions ssh
  config.ssh.forward_agent = true

  config.vm.provider "virtualbox" do |v|
    v.name   = "distributed-applications"
    v.memory = 2048
  end
end
