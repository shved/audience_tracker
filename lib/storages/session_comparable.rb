module SessionComparable
  def eql?(other)
    @customer_id == other.customer_id && @video_id == other.video_id
  end

  def hash
    (@customer_id + @video_id).hash
  end
end
