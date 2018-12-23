class PoroStorage
  class Session
    attr_reader :customer_id, :video_id

    def initialize(customer_id, video_id)
      @customer_id = customer_id
      @video_id = video_id
      @timers = Timers::Group.new
      @threads = []
      @lock = Mutex.new
      @storage = AudienceTracker.config.storage
      @expire_time = AudienceTracker.config.expire_time
    end

    def touch
      @lock.synchronize do
        @timers.cancel
        @timers.after(@expire_time) { expire }

        @threads << Thread.new do
          @timers.wait
        end
      end
    end

    def expire
      @lock.synchronize do
        @storage.null_session(self)
        @threads.each(&:exit)
      end
    end

    def eql?(other)
      @customer_id == other.customer_id && @video_id == other.video_id
    end

    def hash
      (@customer_id + @video_id).hash
    end
  end
end
