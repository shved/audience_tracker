class RedisStorage
  include Singleton
  include KeyFormats

  DUMMY_VALUE = 0

  attr_reader :redis

  def initialize
    @lock = Mutex.new
    @expire_time = AudienceTracker.config.expire_time
    @redis = pick_redis
    setup_redis unless ENV['RACK_ENV'] == 'test'
  end

  ### handler api do

  def store(customer_id, video_id)
    @lock.synchronize do
      @redis.multi do
        @redis.setex(session_key(customer_id, video_id), @expire_time, DUMMY_VALUE)
        @redis.sadd(customer_key(customer_id), collection_item(video_id, timestamp))
        @redis.sadd(video_key(video_id), collection_item(customer_id, timestamp))
      end
    end
  end

  def customer_count(customer_id)
    @lock.synchronize do
      customer_items = @redis.smembers(customer_key(customer_id))
      video_ids = Set.new(items_to_ids(customer_items))
      video_ids.count
    end
  end

  def video_count(video_id)
    @lock.synchronize do
      video_items = @redis.smembers(video_key(video_id))
      customer_ids = Set.new(items_to_ids(video_items))
      customer_ids.count
    end
  end

  ### handler api end

  def exit_support_threads
    @subscriber_thread&.exit
    @gc_thread&.exit
  end

  def flush!
    @redis.flushall
  end

  private

  def setup_redis
    configure_redis
    spawn_subscriber
  end

  def pick_redis
    return MockRedis.new if ENV['RACK_ENV'] == 'test'

    Redis.new
  end

  def configure_redis
    @redis.config(:set, 'notify-keyspace-events', 'Ex')
    @redis.config(:set, 'stop-writes-on-bgsave-error', 'no')
  end

  def spawn_subscriber
    @subscriber_thread ||= Thread.new do
      @subscriber_redis ||= Redis.new
      @subscriber_redis.subscribe('__keyevent@0__:expired'.to_sym) do |on|
        on.message do |_channel, message|
          null_session(message)
        end
      end
    end
  end

  def null_session(key) # rubocop:disable Metrics/AbcSize
    @lock.synchronize do
      expired_items_time = timestamp - @expire_time
      customer_id, video_id = disassemble_session_key(key)

      videos_to_delete = items_to_delete_from(:customers, customer_id, video_id, expired_items_time)
      customers_to_delete = items_to_delete_from(:videos, video_id, customer_id, expired_items_time)

      @redis.multi do
        @redis.srem(customer_key(customer_id), videos_to_delete.to_a) if videos_to_delete.any?
        @redis.srem(video_key(video_id), customers_to_delete.to_a) if customers_to_delete.any?
      end
    end
  end

  def items_to_delete_from(source_type, source_id, item_id, expired_items_time)
    key = case source_type
          when :customers then customer_key(source_id)
          when :videos then video_key(source_id)
          end

    items = Set.new(@redis.smembers(key))
    items_to_delete = items.select do |item|
      set_item_id, item_timestamp = item.split(':').map { |el| el.to_i }
      set_item_id == item_id.to_i && item_timestamp <= expired_items_time
    end

    items_to_delete
  end

  def timestamp
    Time.now.to_i
  end
end
