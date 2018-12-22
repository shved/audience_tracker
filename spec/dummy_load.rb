threads = []
customers = (1..5000).to_a
videos = (1..500).to_a

customers.each do |customer|
  threads << Thread.new do
    duration = (5..20).to_a.sample
    video = videos.sample

    # starting offset
    sleep((1..4).to_a.sample)

    duration.times do
      `curl --get -s localhost:9292/pulse -d customer_id=#{customer} -d video_id=#{video}`
      sleep 5
    end
  end
end

threads << Thread.new do
  50.times do
    interval = (3..7).to_a.sample
    video = videos.sample
    sleep interval
    `curl --get -s localhost:9292/videos/#{video}`
  end
end

threads << Thread.new do
  50.times do
    interval = (3..7).to_a.sample
    customer = customers.sample
    sleep interval
    `curl --get -s localhost:9292/customers/#{customer}`
  end
end

threads.each(&:join)
