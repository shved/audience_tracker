class RedisStorage
  StorageError = Class.new(StandardError)

  DUMMY_VALUE = 0
  SCAN_STEP = 10_000

  def initialize(url)
    @redis = Redis.new(url: url)
    @expire_time = AudienceTracker.config.expire_time
  end

  def store(customer_id, video_id)
    key = session_key(customer_id, video_id)
    @redis.setex(key, @expire_time, DUMMY_VALUE)
  end

  def customer_count(customer_id)
    scan(:customer, customer_id).size
  end

  def video_count(video_id)
    scan(:video, video_id).size
  end

  private

  def scan(type, id)
    pattern = case type
              when :customer then "#{id}:*"
              when :video    then "*:#{id}"
              else
                raise StorageError.new("empty key pattern")
              end

    enumerator = @redis.scan_each(match: pattern, count: SCAN_STEP)
    Set.new(enumerator)
  end

  def session_key(customer_id, video_id)
    "#{customer_id}:#{video_id}"
  end
end
