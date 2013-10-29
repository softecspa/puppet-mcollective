class mcollective(
  $ensure=present,
  $stomp_host,
  $stomp_vhost,
  $stomp_user,
  $stomp_pass,
  $stomp_port=61613,
  $ssl_plugin=false,
)
{

  $mcollective_version = '2.2.4-1'

  if $ensure in [ 'present', 'running' ] {
    $ensure_real = 'running'
    $enable_real = true
  } elsif $ensure in ['removed', 'stopped'] {
    $ensure_real = 'stopped'
    $enable_real = false
  } else {
    fail("ensure parameter must be present, running, removed or stopped, got: $ensure")
  }

  if ! defined(Class['mcollective::common']) {
    class {'mcollective::common':
      ensure => $ensure
    }
  }

  apt::pin {
    'mcollective':
      version => $mcollective_version,
      require => Class['mcollective::common'];
  } ->
  package {
    'mcollective':  ensure => $mcollective_version;
  }

  file { "mcollective-server.cfg":
    path  => "/etc/mcollective/server.cfg",
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    content => template('mcollective/server.cfg.erb'),
    require => Package['mcollective'],
    notify => Service['mcollective']
  }

  service { 'mcollective':
    ensure     => $ensure_real,
    enable     => $enable_real,
    hasstatus  => true,
    hasrestart => true,
    require    => Package['mcollective'],
  }

  file{
    "/etc/mcollective/clients":
      ensure   => directory,
      owner    => root,
      group    => root,
      mode     => 755,
      require  => Package['mcollective'];
    "/etc/mcollective/server_certs":
      ensure   => directory,
      owner    => root,
      group    => root,
      mode     => 755,
      require  => Package['mcollective'];
  }
}
