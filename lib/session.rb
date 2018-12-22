require 'timers'
require_relative 'sessions_watcher'

class Session
  SESSION_TIMEOUT = 6.freeze

  attr_accessor :customer_id, :video_id, :timers

  def initialize(customer_id, video_id)
    @customer_id = customer_id
    @video_id = video_id
    @timers = Timers::Group.new
    @threads = []
    puts "#{self} initiated:\t\t#{Time.now}"
  end

  def touch
    @timers.cancel
    puts "#{self} canceled:\t\t#{Time.now}"
    @timers.after(SESSION_TIMEOUT) { expire }
    @threads << Thread.new do
      @timers.wait
    end
  end

  def expire
    puts "#{self} deleted:\t\t#{Time.now}"
    @threads.each(&:exit)
    SessionsWatcher.instance.null_session(self)
  end

  def to_s
    "Session<#{@customer_id}:#{@video_id}>"
  end
end
