class TestRequest
  attr_reader :code, :content_type, :body

  def initialize(lr)
    @code = lr.status.to_s || nil
    @content_type = lr.original_headers["Content-Type"]
    @body = lr.body
  end
end

module RequestHelper
  def response
    TestRequest.new(last_response)
  end
end
