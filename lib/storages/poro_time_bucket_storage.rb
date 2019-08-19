class PoroTimeBucketStorage
  include Singleton

  ### handler api do

  def store(customer_id, video_id)
    @lock.synchronize do
      @buckets[@current_bucket_index] << Session.new(customer_id, video_id)
    end
  end

  def customer_count(customer_id)
    gather_sessions.select { |session| session.customer_id == customer_id }.size
  end

  def video_count(video_id)
    gather_sessions.select { |session| session.video_id == video_id }.size
  end

  ### handler api end

  def gather_sessions
    @lock.synchronize do
      @buckets.reduce(Set.new) do |memo, (_index, sessions)|
        memo | sessions
      end
    end
  end

  def flush!
    @lock.synchronize do
      @buckets.each { |index, _sessions| @buckets[index].clear }
    end
  end

  def run_rotator_thread
    @lock.synchronize do
      return if @rotator_started

      @current_bucket_index = bucket_time
      @rotator_started = true

      @rotator_thread = Thread.new do
        rotator_loop
      end
    end
  end

  def exit_rotator_thread
    @lock.synchronize do
      @rotator_thread&.exit
      @rotator_started = false
    end
  end

  private

  def initialize
    @lock = Mutex.new
    @buckets_count = AudienceTracker.config.expire_time + 1 # + 1 in favor of accuracy gap
    populate_buckets
    run_rotator_thread
  end

  def populate_buckets
    @lock.synchronize do
      return @buckets if defined?(@buckets)

      @buckets = {}
      @buckets_count.times do |index|
        @buckets[index] = Set.new
      end
      @buckets
    end
  end

  def rotator_loop
    loop do
      time = Process.clock_gettime(::Process::CLOCK_MONOTONIC).floor
      random_throttling

      switch_bucket if time >= Process.clock_gettime(::Process::CLOCK_MONOTONIC).floor
    end
  end

  def random_throttling
    sleep(rand() / 40 + 0.01)
  end

  def switch_bucket
    @lock.synchronize do
      @current_bucket_index = bucket_time

      @buckets[@current_bucket_index].clear
    end
  end

  def bucket_time
    Process.clock_gettime(::Process::CLOCK_MONOTONIC).floor % @buckets_count
  end
end
