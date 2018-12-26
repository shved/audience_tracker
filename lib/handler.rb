class Handler
  include Singleton

  def pulse(customer_id, video_id)
    @storage.store(customer_id, video_id)
  end

  def customer_count(customer_id)
    @storage.customer_count(customer_id)
  end

  def video_count(video_id)
    @storage.video_count(video_id)
  end

  private

  def initialize
    @storage = AudienceTracker.config.storage
    # ugly dry-configurable issue workaround for PoroTimeBucketStorage
    @storage.run_buckets_rotator if @storage.respond_to?(:run_buckets_rotator)
  end
end
