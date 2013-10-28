puppet-mcollective
==============

manage mcollective (agent, server, middleware)

This module can be used for:
 - Configure RabbitMQ middleware for MCollective (require rabbitmq module)
 - Install and configure MCollective server
 - Install and configure MCollective agent
  
# Middleware
  include mcollective::middleware

# Server
  class { 'mcollective':
    stomp_host => 'rabbitmq-srv.domain.com'
  }

# Agent
  class { 'mcollective::agent':
    stomp_host => 'rabbitmq-srv.domain.com'
  }