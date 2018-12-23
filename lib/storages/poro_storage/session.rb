require 'timers'

class PoroStorage
  class Session
    SESSION_TIMEOUT = 6

    attr_reader :customer_id, :video_id

    def initialize(customer_id, video_id)
      @customer_id = customer_id
      @video_id = video_id
      @timers = Timers::Group.new
      @threads = []
      @lock = Mutex.new
      @storage = AudienceTracker.config.storage
      debug_report(:initiated)
    end

    def touch
      @lock.synchronize do
        @timers.cancel
        @timers.after(SESSION_TIMEOUT) { expire }
        debug_report(:touched)

        @threads << Thread.new do
          @timers.wait
        end
      end
    end

    def expire
      @lock.synchronize do
        @storage.null_session(self)
        debug_report(:deleted)
        @threads.each(&:exit)
      end
    end

    def ==(other)
      @customer_id == other.customer_id && @video_id == other.video_id
    end

    def eql?(other)
      @customer_id == other.customer_id && @video_id == other.video_id
    end

    def hash
      (@customer_id + @video_id).hash
    end

    def to_s
      "Session<#{@customer_id}:#{@video_id}>"
    end

    private

    def debug_report(action)
      puts log_entry(action) if ENV['APP_ENV'] == 'development'
    end

    def log_entry(action)
      "#{self} #{action}:\t\t#{Time.now}\t\tSessions count: #{@storage.sessions.count}"
    end
  end
end
