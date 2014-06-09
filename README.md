puppet-mcollective
==============

manage mcollective (client, server, middleware)

This module can be used for:
 - Configure RabbitMQ middleware for MCollective (require rabbitmq module)
 - Install and configure MCollective server
 - Install and configure MCollective client
  
# Middleware
class { 'mcollective::middleware':
    stomp_vhost => $::mcollective_vhost,
    stomp_user => $::mcollective_user,
    stomp_pass => $::mcollective_pass
}

# Server
class { 'mcollective':
    stomp_host => 'stop-srv.domain.com',
    stomp_vhost => $::mcollective_vhost,
    stomp_user => $::mcollective_user,
    stomp_pass => $::mcollective_pass
}

# Client
class { 'mcollective::client':
    stomp_host => 'stop-srv.domain.com',
    stomp_vhost => $::mcollective_vhost,
    stomp_user => $::mcollective_user,
    stomp_pass => $::mcollective_pass
}
