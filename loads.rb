require 'dry-configurable'
require 'dotenv/load'
require 'roda'
require 'singleton'
require 'redis'
require 'timers'
require 'rack/cache'
require_relative './lib/storages/session_comparable'

Dir['./lib/**/*.rb'].each { |file| require file }
