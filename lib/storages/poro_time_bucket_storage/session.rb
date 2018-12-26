class PoroTimeBucketStorage
  class Session
    include SessionComparable

    attr_reader :customer_id, :video_id

    def initialize(customer_id, video_id)
      @customer_id = customer_id
      @video_id = video_id
    end
  end
end
