require 'singleton'
require_relative 'default_storage'
require_relative 'sessions_watcher'
# require 'pry'

class Handler
  include Singleton

  def pulse(customer_id, video_id)
    @storage.store_session(customer_id, video_id)
    SessionsWatcher.instance.pulse(customer_id, video_id)
  end

  def customer_stat(customer_id)
    @storage.customer_stat(customer_id)
  end

  def video_stat(video_id)
    @storage.video_stat(video_id)
  end

  private

  def initialize
    @storage = pick_storage
    super
  end

  def pick_storage
    case ENV['STORAGE']
    when 'redis' then 'Redis.new'
    else
      DefaultStorage.instance
    end
  end
end
