require_relative 'poro_storage/session'
require 'singleton'

class PoroStorage
  include Singleton

  attr_reader :sessions

  def store(customer_id, video_id)
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
    @sessions.delete(session)
  end

  def customer_count(customer_id)
    @sessions.select { |session| session.customer_id == customer_id }.size
  end

  def video_count(video_id)
    @sessions.select { |session| session.video_id == video_id }.size
  end

  private

  def initialize
    @sessions = Set.new
    @lock = Mutex.new
    super
  end

  def fetch_session(customer_id, video_id)
    @sessions.find { |s| s.customer_id == customer_id && s.video_id == video_id }
  end
end
