#!/bin/sh

echo "INSTALLING PUPPET 4 \n\n"
wget http://apt.puppetlabs.com/puppetlabs-release-precise.deb
sudo dpkg -i puppetlabs-release-precise.deb
sudo apt-get update
sudo apt-get install -y puppet
echo `puppet --version`

echo "INSTALL git \n\n"
sudo apt-get install -y git

echo "INSTALLING librarian-puppet \n\n"
sudo gem install librarian-puppet --no-ri --no-rdoc

echo "INSTALL PUPPET MODULES"
librarian-puppet install
