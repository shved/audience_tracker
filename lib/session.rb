require 'timers'
require_relative 'sessions_watcher'

class Session
  SESSION_TIMEOUT = 6

  attr_accessor :customer_id, :video_id, :timers

  def initialize(customer_id, video_id)
    @customer_id = customer_id
    @video_id = video_id
    @timers = Timers::Group.new
    @lock = Mutex.new
    @threads = []
    debug_report(:initiated)
    touch
  end

  def touch
    @lock.synchronize do
      @timers.cancel
      debug_report(:touched)
      @timers.after(SESSION_TIMEOUT) { expire }

      @threads << Thread.new do
        @timers.wait
      end
    end
  end

  def expire
    @lock.synchronize do
      SessionsWatcher.instance.null_session(self)
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
    puts "#{self} #{action}:\t\t#{Time.now}\tSessions count: #{SessionsWatcher.instance.sessions.count}"
  end
end
