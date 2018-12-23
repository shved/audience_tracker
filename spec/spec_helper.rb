require 'rack/test'
require 'rspec'
require 'simplecov'

ENV['RACK_ENV'] = 'test'

SimpleCov.start do
  add_filter '/spec/'
end

require File.expand_path '../../core.rb', __FILE__
require File.expand_path '../helpers/request_helper.rb', __FILE__

module RSpecMixin
  include Rack::Test::Methods
  def app() AudienceTracker end
end

RSpec.configure do |config|
  config.include RSpecMixin
  config.include RequestHelper
end
