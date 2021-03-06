# == class mcollective::middleware
#
#  Setup a middleware used by mcollective
#
# === Params
#
# === Examples
#
class mcollective::middleware(
  $ensure=present,
  $stomp_vhost,
  $stomp_user,
  $stomp_pass,
  $ssl=false
) {

  include rabbitmq
  include rabbitmq::management
  include rabbitmq::stomp
  
  class{'rabbitmq::service':
    ensure => 'running'
  }

  rabbitmq::vhost{$stomp_vhost : }

  rabbitmq::user{$stomp_user:
    vhost => $stomp_vhost,
    password => $stomp_pass,
    administrator => true,
    require => Rabbitmq::Vhost[$stomp_vhost]
  }

  rabbitmq::exchange{'mcollective_directed':
    username => $stomp_user,
    password => $stomp_pass,
    vhost => $stomp_vhost,
    type => 'direct',
    require => Rabbitmq::User[$stomp_user]
  }

  rabbitmq::exchange{'mcollective_broadcast':
    username => $::mcollective_user,
    password => $::mcollective_pass,
    vhost => $::mcollective_vhost,
    type => 'topic',
    require => Rabbitmq::User[$stomp_user]
  }

}
