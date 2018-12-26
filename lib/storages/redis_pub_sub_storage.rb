class RedisPubSubStorage
  StorageError = Class.new(StandardError)

  DUMMY_VALUE = 0

  def initialize
    @redis = Redis.new
    @redis.config(:set, 'notify-keyspace-events', 'Ex')
    spawn_subscriber
    @expire_time = AudienceTracker.config.expire_time
  end

  ### handler api do

  def store(customer_id, video_id)
    @redis.multi do
      @redis.sadd(customer_key(customer_id), video_id)
      @redis.sadd(video_key(video_id), customer_id)
      @redis.setex(session_key(customer_id, video_id), @expire_time, DUMMY_VALUE)
    end
  end

  def customer_count(customer_id)
    @redis.smembers(customer_key(customer_id)).count
  end

  def video_count(video_id)
    @redis.smembers(video_key(video_id)).count
  end

  ### handler api end

  private

  def spawn_subscriber
    @subscriber ||= Thread.new do
      redis.subscribe('__keyevent@0__:expired'.to_sym) do |on|
        on.message do |channel, message|
          null_session(key)
        end
      end
    end
  end

  def null_session(key)
    customer_id, video_id = key.split(':')
    @redis.multi do
      @redis.srem(customer_key(customer_id), video_id)
      @redis.srem(video_key(video_id), customer_id)
    end
  end

  def session_key(customer_id, video_id)
    "#{customer_id}:#{video_id}"
  end

  def customer_key(customer_id)
    "customers:#{customer_id}"
  end

  def video_key(video_id)
    "videos:#{video_id}"
  end
end
