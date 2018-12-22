require_relative 'session'
require_relative 'default_storage'

class SessionsWatcher
  include Singleton

  attr_accessor :sessions

  def report
    res = []
    @sessions.each do |s|
      res << [s.customer_id, s.video_id]
    end
    res.each { |row| puts [row[0], row[1]].join("\t") }
    res
  end

  def pulse(customer_id, video_id)
    @lock.synchronize do
      session = fetch_session(customer_id, video_id)

      if session
        session.touch
      else
        @sessions << Session.new(customer_id, video_id)
      end
    end
  end

  def null_session(session)
    @storage.purge_stat(session.customer_id, session.video_id)
    @sessions.delete(session)
  end

  private

  def initialize
    @sessions = Set.new
    @storage = DefaultStorage.instance
    @lock = Mutex.new
    super
  end

  def fetch_session(customer_id, video_id)
    @sessions.find { |s| s.customer_id == customer_id && s.video_id == video_id }
  end
end
