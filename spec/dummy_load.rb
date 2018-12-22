require 'timers'

threads = []
customer_id = 1
video_id = 1
mutex = Mutex.new

100.times do
    threads << Thread.new do
      loop do
        `curl --get localhost:9292/pulse -d customer_id=#{customer_id} -d video_id=#{video_id}`
        sleep 5
      end
    end
    video_id += 1
  end
  customer_id += 1
end

threads.join
