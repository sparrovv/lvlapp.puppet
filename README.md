# Provisioning with Puppet for lvlapp.com

There is some setup required to get it working. ()

### Install puppet 3 on the box.

```sh
  wget http://apt.puppetlabs.com/puppetlabs-release-precise.deb
  sudo dpkg -i puppetlabs-release-precise.deb
  sudo apt-get update
  sudo apt-get install puppet
  puppet --version
```

Apply puppet manifest:

```sh
  ./puppet_apply vagrant

```

### Adding new modules:

This repo uses librarian-puppet to managed vendor modules, so please use it if you want to add new one

```sh
  gem install librarian-puppet
  gem install puppet
  librarian-puppet install
```

