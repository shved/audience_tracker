require_relative 'session'
require_relative 'default_storage'

class SessionsWatcher
  include Singleton

  def pulse(customer_id, video_id)
    @lock.synchronize do
      session = find(customer_id, video_id)

      if session.nil?
        @sessions << Session.new(customer_id, video_id)
      else
        session.touch
      end
    end
  end

  def null_session(session)
    sessions.find { |s| s == session }
    sessions.delete(session)
  end

  private

  def initialize
    @sessions = []
    @storage = DefaultStorage.instance
    @lock = Mutex.new
    super
  end

  def find(customer_id, video_id)
    @sessions.find { |s| s.customer_id == customer_id && s.video_id == video_id }
  end
end
