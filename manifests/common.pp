class mcollective::common (
  $ensure=present
)
{

  if $ensure in [ 'present', 'running' ] {
    $ensure_real = 'running'
    $enable_real = true
  } elsif $ensure in ['removed', 'stopped'] {
    $ensure_real = 'stopped'
    $enable_real = false
  } else {
    fail("ensure parameter must be present, running, removed or stopped, got: $ensure")
  }

  'mcollective':
      version => $mcollective_version,
      require => Class['mcollective::common'];
  }

  file{"/etc/mcollective":
    ensure   => directory,
    owner    => root,
    group    => root,
    mode     => 755,
  }

  file{"/etc/mcollective/facts.yaml":
    owner    => root,
    group    => root,
    mode     => 644,
    loglevel => debug,
    content  => inline_template("<%= scope.to_hash.reject { |k,v| k.to_s =~ /(uptime_seconds|timestamp|free)/ }.to_yaml %>"), # exclude rapidly changing facts
    require => File['/etc/mcollective'],
  }

  if ! defined(Package['stomp']) {
    package {'stomp':
      ensure   => '1.2.2',
      provider => gem
    }
  }

  apt::pin {
    'mcollective-common':   version => $mcollective::mcollective_version;
  } ->
  package {
    'mcollective-common':   ensure => $mcollective::mcollective_version;
  }

}