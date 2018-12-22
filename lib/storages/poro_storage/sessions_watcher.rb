require_relative 'session'
require 'singleton'

class PoroStorage
  class SessionsWatcher
    include Singleton

    attr_reader :sessions

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
      @storage.purge(session.customer_id, session.video_id)
      @sessions.delete(session)
    end

    private

    def initialize
      @sessions = Set.new
      @storage = AudienceTracker.config.storage
      @lock = Mutex.new
      super
    end

    def fetch_session(customer_id, video_id)
      @sessions.find { |s| s.customer_id == customer_id && s.video_id == video_id }
    end
  end
end
