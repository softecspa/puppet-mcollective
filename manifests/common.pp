# == class mcollective::common
#
#  Install Mcollective common files
#
# === Params
#
# === Examples
#
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
    fail("ensure must be present, running, removed or stopped, got: ${ensure}")
  }

  file{ '/etc/mcollective':
    ensure   => directory,
    owner    => root,
    group    => root,
    mode     => '0755',
  }

  file{ '/etc/mcollective/facts.yaml':
    owner     => root,
    group     => root,
    mode      => '0644',
    loglevel  => debug,
    content   => inline_template("<%= scope.to_hash.reject { |k,v| k.to_s =~ /(uptime_seconds|timestamp|free)/ }.to_yaml %>"), # exclude rapidly changing facts
    require   => File['/etc/mcollective'],
  }

  if ($::lsbdistrelease < '14.04') {
    if ! defined(Package['rubygems']) {
      package { 'rubygems': }
  }

  if ! defined(Package['stomp']) {
    package { 'stomp':
      ensure    => '1.2.2',
      provider  => gem,
      require   => Package['rubygems'];
    }
  }

  apt::pin { 'mcollective-common':
    packages  => 'mcollective-common',
    version   => $mcollective::mcollective_version,
    priority  => '1001'
  } ->
  package { 'mcollective-common':
      ensure => $mcollective::mcollective_version;
  }

}
