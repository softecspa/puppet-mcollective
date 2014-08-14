# == class mcollective
#
#  Setup Mcollective server
#
# === Params
#
# === Examples
#
class mcollective(
  $ensure=present,
  $stomp_host,
  $stomp_vhost,
  $stomp_user,
  $stomp_pass,
  $stomp_port=61613,
  $ssl_middleware=false,
  $ssl_plugin=false,
)
{

  $mcollective_version = '2.5.1-1puppetlabs1'

  if $ensure in [ 'present', 'running' ] {
    $ensure_real = 'running'
    $enable_real = true
  } elsif $ensure in ['removed', 'stopped'] {
    $ensure_real = 'stopped'
    $enable_real = false
  } else {
    fail("ensure must be present, running, removed or stopped, got: ${ensure}")
  }

  if ! defined(Class['mcollective::common']) {
    class {'mcollective::common':
      ensure => $ensure
    }
  }

  apt::pin {'mcollective':
      packages  => 'mcollective',
      version   => $mcollective_version,
      priority  => '1001'
  } ->
  package {'mcollective':
    ensure  => $mcollective_version,
    require => Class['mcollective::common'];
  }

  file { 'mcollective-server.cfg':
    path    => '/etc/mcollective/server.cfg',
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    content => template('mcollective/server.cfg.erb'),
    require => Package['mcollective'],
    notify  => Service['mcollective']
  }

  service { 'mcollective':
    ensure     => $ensure_real,
    enable     => $enable_real,
    hasstatus  => true,
    hasrestart => true,
    require    => Package['mcollective'],
  }

  file {
    '/etc/mcollective/clients':
      ensure   => directory,
      owner    => root,
      group    => root,
      mode     => '0755',
      require  => Package['mcollective'];
    '/etc/mcollective/server_certs':
      ensure   => directory,
      owner    => root,
      group    => root,
      mode     => '0755',
      require  => Package['mcollective'];
  }
}
