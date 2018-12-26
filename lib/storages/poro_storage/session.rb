class PoroStorage
  class Session
    include SessionComparable

    attr_reader :customer_id, :video_id

    def initialize(customer_id, video_id)
      @customer_id = customer_id
      @video_id = video_id
      @timers = Timers::Group.new
      @threads = []
      @lock = Mutex.new
      @storage = PoroStorage
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
        @storage.instance.null_session(self)
        @threads.each(&:exit)
      end
    end
  end
end
