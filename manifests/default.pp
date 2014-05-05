## if is_vagrant is defined, then we're running under Vagrant.  Use other
## logic/facts to detect environmental stuff.

Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

class settings{
  $app_name = hiera('app_name')
  $app_user = hiera('app_user')
  $mysql_user = hiera('mysql_user')
  $mysql_root_password = hiera('mysql_root_password')
  $mysql_user_password = hiera('mysql_user_password')
}

resources { "firewall":
  purge => true
}

Firewall {
  before  => Class['appserv::fw_post'],
  require => Class['appserv::fw_pre'],
}

class appserv{
  include '::ntp'
  class{'firewall':}
  class { ['appserv::fw_pre', 'appserv::fw_post']: }

  class { locales:
    default_value => "en_GB.UTF-8",
    available   => ["en_GB.UTF-8 UTF-8"]
  } ->
  class {'appserv::update_aptget': } ->
  class {"appserv::packages":} ->
  class {"appserv::user" :} ->
  class {"appserv::app" :} ->
  class {"appserv::db":} ->
  class {"appserv::web" :}
}

class appserv::app{
  file { "/home/${settings::app_user}/.lvlapp.env" :
    owner   => "${settings::app_user}",
    group   => "${settings::app_user}",
    mode    => 700,
    ensure  => present,
    content => "# GENERATED BY PUPPET
export RAILS_ENV=production
export DB_USERNAME=$settings::mysql_user
export DB_PASSWORD=$settings::mysql_user_password
export LVLAPP_SMTP_USER_NAME=
export LVLAPP_SMTP_PASSWORD=
export GOOGLE_API_KEY=
export WORDNIK_API=
export AZURE_PRIMARY_ACCOUNT_KEY=
export AZURE_CUSTOMER_ID=
export AZURE_SECRET=
export RAVEN_DSN=
#export RAILS_SECRET_KEY_BASE=
"
  }
  file {"/home/${settings::app_user}/.bashrc":
    ensure=>present,
    owner   => "${settings::app_user}",
    group   => "${settings::app_user}",
    mode=>0755,
    content=>'# GENERATED BY PUPPET
alias be="bundle exec"
alias v=vim
[ -f ~/.lvlapp.env ] && source ~/.lvlapp.env
    '
  }
}
class appserv::user {
  group { 'admin':
    ensure => present,
  }

  # Setup the user accounts
  user { "${settings::app_user}" :
    ensure => present,
    groups => 'admin',
    shell => '/bin/bash',
    managehome => true,
    home => "/home/${settings::app_user}",
    require => Group['admin']
  }

  file { "/home/${settings::app_user}/.ssh" :
    owner => "${settings::app_user}",
    group => "${settings::app_user}",
    mode => 700,
    ensure => 'directory',
  }

  $authorized_keys = hiera_array('authorized_keys')
  file { "/home/${settings::app_user}/.ssh/authorized_keys" :
    content => template('authorized_keys'),
    owner => "${settings::app_user}",
    group => "${settings::app_user}",
    mode => 664,
  }

  file { "/home/${settings::app_user}/.ssh/known_hosts" :
    content => template('known_hosts'),
    owner => "${settings::app_user}",
    group => "${settings::app_user}",
    mode => 664,
  }
}

class appserv::db{
  class { '::mysql::server':
    root_password          => $settings::mysql_root_password,
    override_options       => { 'mysqld'                                   => { 'max_connections' => '1024' } },
    databases             => {
      "${settings::app_name}_production" => {
        ensure            => 'present',
        charset           => 'utf8',
      },
    },
    users                  => {
      "${settings::app_user}@localhost" => {
        ensure             => 'present',
        password_hash      => mysql_password($settings::mysql_user_password),
      },
    },
    grants                                     => {
      "${settings::app_user}@localhost/lvlapp_production.*" => {
        ensure                                 => 'present',
        options                                => ['GRANT'],
        privileges                             => ['ALL'],
        table                                  => "${settings::app_name}_production.*",
        user                                   => "${settings::app_user}@localhost",
      },
    },
  }

  class {'mysql::bindings' :
    ruby_enable => true,
  }
}

# just some packages
class appserv::packages{
  package{"curl": ensure => installed}
  package{"vim":  ensure => installed}
  package{"git":  ensure => installed}
  package{"screen":  ensure => installed}

  package{["build-essential", "zlib1g-dev", "libssl-dev", "libreadline6-dev", "libyaml-dev", "libmysqlclient-dev"] :
    ensure => installed
  }

  package{"ruby1.9.3":  ensure => installed}
}


# brings the system up-to-date after importing it with Vagrant
class appserv::update_aptget{
  exec{"apt-get update && touch /tmp/apt-get-updated":
    unless => "test -e /tmp/apt-get-updated"
  }
}

class appserv::web{
  class { 'nginx': }

  firewall { '101 accept http':
    proto  => 'tcp',
    port   => [80],
    action => 'accept',
  }

  file { "lvlvapp.conf":
    path    => "/etc/nginx/sites-enabled/lvlapp.conf",
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('nginx.lvlapp.conf'),
    notify  => Service[nginx]
  }
}

class appserv::fw_post {
  firewall { '999 drop all':
    proto   => 'all',
    action  => 'drop',
    before  => undef,
  }
}

class appserv::fw_pre{
  Firewall {
    require => undef,
  }

  # Default firewall rules
  firewall { '000 accept all icmp':
    proto   => 'icmp',
    action  => 'accept',
  }->
  firewall { '002 accept ssh':
    proto  => 'tcp',
    port   => [22, 2222],
    action => 'accept',
  }->
  firewall { '004 accept all to lo interface':
    proto   => 'all',
    iniface => 'lo',
    action  => 'accept',
  }->
  firewall { '005 accept related established rules':
    proto   => 'all',
    ctstate => ['RELATED', 'ESTABLISHED'],
    action  => 'accept',
  }
}

class{'appserv' :}
