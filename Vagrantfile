# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "precise64"
  config.vm.network "private_network", ip: "192.168.33.10"

  config.vm.box_url = "http://files.vagrantup.com/precise64.box"
  config.vm.hostname = "rails.dev"

  config.vm.provision :puppet do |puppet|
    puppet.module_path = "modules"
    puppet.manifests_path = "manifests"
    puppet.manifest_file = "default.pp"
    puppet.hiera_config_path = "hiera.yaml"
    puppet.facter = {
      "datacenter" => 'vagrant',
    }
    puppet.options = [
      '--templatedir', '/vagrant/templates',
      '--verbose',
    ]
  end

  config.vm.provider "virtualbox" do |v|
    v.memory = 756
    v.cpus = 1
  end
end
