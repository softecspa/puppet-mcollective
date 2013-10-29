class mcollective(
  $ensure=present,
  $stomp_host,
  $stomp_vhost,
  $stomp_user,
  $stomp_pass,
  $stomp_port=61613
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

  file{"/etc/mcollective/facts.yaml":
    owner    => root,
    group    => root,
    mode     => 400,
    loglevel => debug,
    content  => inline_template("<%= scope.to_hash.reject { |k,v| k.to_s =~ /(uptime_seconds|timestamp|free)/ }.to_yaml %>"), # exclude rapidly changing facts
    require => Package['mcollective'],
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

}
