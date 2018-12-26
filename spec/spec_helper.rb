require 'rack/test'
require 'rspec'
require 'simplecov'
require 'mock_redis'

ENV['RACK_ENV'] = 'test'
ENV['STORAGE'] = 'poro_storage'

SimpleCov.start do
  add_filter '/spec/'
end

require File.expand_path '../../core.rb', __FILE__
require File.expand_path '../helpers/request_helper.rb', __FILE__
Dir["./spec/shared/*.rb"].sort.each { |f| require f }

module RSpecMixin
  include Rack::Test::Methods
  def app() AudienceTracker end
end

RSpec.configure do |config|
  config.include RSpecMixin
  config.include RequestHelper

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.include_context 'storage context', :include_shared => true

  config.formatter = :documentation
end
