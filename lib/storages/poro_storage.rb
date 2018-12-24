class PoroStorage
  include Singleton

  attr_reader :sessions

  def store(customer_id, video_id)
    @lock.synchronize do
      session = Session.new(customer_id, video_id)
      session = fetch_session(customer_id, video_id) unless @sessions.add?(session)

      session.touch
    end
  end

  def null_session(session)
    @lock.synchronize do
      @sessions.delete(session)
    end
  end

  def customer_count(customer_id)
    @lock.synchronize do
      @sessions.select { |session| session.customer_id == customer_id }.size
    end
  end

  def video_count(video_id)
    @lock.synchronize do
      @sessions.select { |session| session.video_id == video_id }.size
    end
  end

  def flush!
    @lock.synchronize do
      @sessions.clear
    end
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
