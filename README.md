# Server provisioning for rails app, based on lvlapp.com

This is still WIP.

This repository contains puppet modules for lvlapp.com.

### Prerequisites to run it on your server:

- git or rsync to get repository on server.
- puppet 3, so we can use [hiera](http://docs.puppetlabs.com/hiera/1/).
- ruby and librarian-puppet gem to install puppet modules.

Check the `./boostrap.sh` to see all the dependencies, and how to install them.

### How to execute:

Clone repository on the server.

Prepare `hierdata` for your environment (check out the hierdata/vagrant.yaml as an example).
(Probably the best place to store it is in `/etc/puppet/hierdata/datacenter.yaml` dir.)

Run puppet:

```sh
  ./puppet_apply $your_environment
```

### Testing with Vagrant (Vagrant in version at least 1.5)

Default image used for this project is `ubuntu precise64`, that doesn't have puppet 3 installed.
To get around it, please follow these instructions:

```sh
  vagrant up --no-provision
  vagrant ssh
  cd /vagrant
  ./bootstrap.sh
```

### Additional information

This repository uses librarian-puppet to manage modules:

```sh
  gem install librarian-puppet
  gem install puppet

  librarian-puppet install
```

### What does it really do:

- creates user: `deployer` and sets application sepcific environment variables.
- install and configure: ntp, firewall, git, locales, mysq, nginx, ruby 2.1, logrotate, vim.
