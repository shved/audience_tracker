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

  def run_buckets_rotator
    @lock.synchronize do
      return if @rotator_started

      @current_bucket_index = 0
      @rotator_started = true

      @buckets_rotator = Thread.new do
        loop do
          time = Process.clock_gettime(::Process::CLOCK_MONOTONIC).floor
          true while time == Process.clock_gettime(::Process::CLOCK_MONOTONIC).floor

          switch_bucket
        end
      end
    end
  end

  def shut_down_rotator
    @lock.synchronize do
      @buckets_rotator.exit
      @rotator_started = false
    end
  end

  private

  def initialize
    @lock = Mutex.new
    @buckets_count = AudienceTracker.config.expire_time + 1 # + 1 in favor of accuracy gap
    @current_bucket_index = 0
    populate_buckets
    @rotator_started = false
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

  def switch_bucket
    @lock.synchronize do
      @current_bucket_index = Process.clock_gettime(::Process::CLOCK_MONOTONIC).floor % @buckets_count

      @buckets[@current_bucket_index].clear
      # handy debugger output
      # puts "#{@buckets.values.map { |s| s.count }}\n"
    end
  end
end
