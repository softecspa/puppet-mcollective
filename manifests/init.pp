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

  file{"/etc/mcollective/facts.yaml":
    owner    => root,
    group    => root,
    mode     => 400,
    loglevel => debug,
    content  => inline_template("<%= scope.to_hash.reject { |k,v| k.to_s =~ /(uptime_seconds|timestamp|free)/ }.to_yaml %>"), # exclude rapidly changing facts
    require => Package['mcollective'],
  }

  if ! defined(Package['stomp']) {
    package {'stomp':
      ensure   => '1.2.2',
      provider => gem,
      before   => Package['mcollective-client'],
    }
  }

  apt::pin {
    'mcollective':               version => $mcollective_version;
    'mcollective-common':        version => $mcollective_version;
  } ->
  package {
    'mcollective':               ensure => $mcollective_version;
    'mcollective-common':        ensure => $mcollective_version;
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
