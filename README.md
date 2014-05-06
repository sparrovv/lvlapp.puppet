# Server provisioning for rails app, based on lvlapp.com

This is still WIP.

This repository contains puppet modules for lvlapp.com.

### Prerequisites 

You need puppet 3 on your box, because in other way you won't be able to use `hiera`.

This is an instruction how to install it on Ubuntu 12.04.

```sh
  wget http://apt.puppetlabs.com/puppetlabs-release-precise.deb
  sudo dpkg -i puppetlabs-release-precise.deb
  sudo apt-get update
  sudo apt-get install puppet
  puppet --version
```

Clone the repository on the server.

Prepare hierdata for your environment (check out the hierdata/vagrant.yaml as an example). Probably the best place to store it is in `/etc/puppet/hierdata/your_environment.yaml` dir.

Run puppet:

```sh
  ./puppet_apply $your_environment
```

### Adding new modules:

This repository uses librarian-puppet to manage vendor modules, so if you want to add something make sure that you have these gems installed:

```sh
  gem install librarian-puppet
  gem install puppet

  librarian-puppet install
```

### Testing with Vagrant (make sure you have Vagrant in version at least 1.5)

Default image used for this project is `ubuntu precise64`, that doesn't have puppet 3 installed.
To get around it, please follow these instructions:

```sh
  vagrant up --no-provision
  vagrant ssh
  sudo su -
  wget http://apt.puppetlabs.com/puppetlabs-release-precise.deb
  dpkg -i puppetlabs-release-precise.deb
  apt-get update
  apt-get install puppet
  exit
  exit
  vagrant provision
```

