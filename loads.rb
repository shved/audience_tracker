require 'dry-configurable'
require 'dotenv/load'
require 'roda'
require 'singleton'
require 'redis'
require 'timers'
require 'rack/cache'

Dir['./lib/**/*.rb'].each { |file| require file }
