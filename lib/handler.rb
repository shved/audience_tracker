require 'singleton'
require_relative 'default_storage'
# require 'pry'

class Handler
  include Singleton

  def heartbeat(customer_id, video_id)
    @storage.register_heartbeat(customer_id, video_id)
    # TODO: дергать класс отвечающий за протухание с помощью timers
    # и из него дергать стораж
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
