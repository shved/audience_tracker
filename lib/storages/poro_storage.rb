require_relative 'poro_storage/sessions_watcher'
require 'singleton'
require 'set'

class PoroStorage
  include Singleton

  def store(customer_id, video_id)
    @lock.synchronize do
      SessionsWatcher.instance.pulse(customer_id, video_id)
      @videos[video_id] << customer_id
      @customers[customer_id] << video_id
    end
  end

  def purge(customer_id, video_id)
    @lock.synchronize do
      @videos[video_id].delete(customer_id)
      @videos.delete(video_id) if @videos[video_id].empty?

      @customers[customer_id].delete(video_id)
      @customers.delete(customer_id) if @customers[customer_id].empty?
    end
  end

  def customer_count(customer_id)
    @customers[customer_id].size
  end

  def video_count(video_id)
    @videos[video_id].size
  end

  private

  def initialize
    @videos = Hash.new { |hash, key| hash[key] = Set.new }
    @customers = Hash.new { |hash, key| hash[key] = Set.new }
    @lock = Mutex.new
  end
end
