class mcollective::agent(
  $ensure=present,
  $stomp_host,
  $stomp_vhost,
  $stomp_user,
  $stomp_pass,
  $stomp_port=61613
)
{
  if ! defined(Package['stomp']) {
    package {'stomp':
      ensure   => '1.2.2',
      provider => gem,
      before   => Package['mcollective-client'],
    }
  }

  if ! defined (Package['mcollective-common']) {
    apt::pin {
      'mcollective-common': version => $mcollective::mcollective_version;
    }
  }

  apt::pin {
    'mcollective-client': version => $mcollective::mcollective_version;
  } ->
  package {
    'mcollective-client': ensure => $mcollective::mcollective_version;
  }

  file { "mcollective-client.cfg":
    path  => "/etc/mcollective/client.cfg",
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    content => template('mcollective/client.cfg.erb')
  }
}
