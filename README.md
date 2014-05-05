# Server provisioning for rails app, based on lvlapp.com

This is still WIP.

This repository contains puppet modules for lvlapp.com.

### How to use it:

Install puppet 3 on the box.

```sh
  wget http://apt.puppetlabs.com/puppetlabs-release-precise.deb
  sudo dpkg -i puppetlabs-release-precise.deb
  sudo apt-get update
  sudo apt-get install puppet
  puppet --version
```

Clone the repository on the server.

Prepare hierdata for your environment (check out the hierdata/vagrant.yaml as an example). Probably the best place is to put in `/etc/puppet/hierdata/your_environment.yaml` dir.

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

