require 'singleton'

class RedisStorage
  include Singleton

  def store; end

  def customer_count; end

  def video_count; end
end
