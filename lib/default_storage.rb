require 'singleton'
require 'set'

class DefaultStorage
  include Singleton

  StorageError = Class.new(StandardError)

  def store_session(customer_id, video_id)
    @lock.synchronize do
      @videos[video_id] << customer_id
      @customers[customer_id] << video_id
    end
  end

  def delete_session(customer_id, video_id)
    @lock.synchronize do
      @videos[customer_id].delete(video_id)
      @customers[video_id].delete(customer_id)
    end
  end

  def customer_stat(customer_id)
    @customers[customer_id].size
  end

  def video_stat(video_id)
    @videos[video_id].size
  end

  private

  def initialize
    @videos = Hash.new { |hash, key| hash[key] = Set.new }
    @customers = Hash.new { |hash, key| hash[key] = Set.new }
    @lock = Mutex.new
  end
end
