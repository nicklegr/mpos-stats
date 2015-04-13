# coding: utf-8

require "mongoid"

Mongoid.configure do |config|
  if ENV.key?("MONGODB_PORT_27017_TCP_ADDR")
    # for docker
    config.sessions = { default: { database: "app", hosts: [ "#{ENV['MONGODB_PORT_27017_TCP_ADDR']}:27017" ] }}
  elsif test?
    config.sessions = { default: { database: "app_test", hosts: [ "localhost:27017" ] }}
  else
    config.sessions = { default: { database: "app", hosts: [ "localhost:27017" ] }}
  end
end

# if development?
#   Mongoid.logger.level = Logger::DEBUG
#   Moped.logger.level = Logger::DEBUG
# end