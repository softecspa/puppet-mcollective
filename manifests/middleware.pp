class mcollective::middleware {

  include rabbitmq
  include rabbitmq::management
  include rabbitmq::stomp
  class{'rabbitmq::service':
    ensure=>'running'
  }

  rabbitmq::vhost{$::mcollective_vhost : }

  rabbitmq::user{$::mcollective_user:
    vhost => $::mcollective_vhost,
    password => $mcollective_pass,
    require => Rabbitmq::Vhost[$::mcollective_vhost]
  }

  rabbitmq::exchange{'mcollective_directed':
    username => $::mcollective_user,
    password => $::mcollective_pass,
    vhost => $::mcollective_vhost,
    type => 'direct',
    require => Rabbitmq::User[$::mcollective_user]
  }

  rabbitmq::exchange{'mcollective_broadcast':
    username => $::mcollective_user,
    password => $::mcollective_pass,
    vhost => $::mcollective_vhost,
    type => 'topic',
    require => Rabbitmq::User[$::mcollective_user]
  }

}
