require 'benchmark'
require_relative '../lib/storages/poro_storage/session'
require_relative '../audience_tracker'

# 10_000 size set
#        user     system      total        real
# find  1.498329   0.006008   1.504337 (  1.509464)
# add?  0.005236   0.000275   0.005511 (  0.005562)
#
# 100_000 size set
#        user     system      total        real
# find 17.520905   0.046223  17.567128 ( 17.624355)
# add?  0.009079   0.000365   0.009444 (  0.009500)

size = 20000
sessions = Set.new
size.times do
  sessions << PoroStorage::Session.new((rand*10000).round, (rand*10000).round)
end

pairs = []
4000.times do
  pairs << [(rand*10000).round, (rand*10000).round]
end

pairs = pairs.lazy

Benchmark.bm do |bm|
  bm.report('find') do
    1000.times do
      customer_id, video_id = pairs.next
      ses = sessions.find { |s| s.customer_id == customer_id && s.video_id == video_id }
    end
  end

  bm.report('add?') do
    1000.times do
      customer_id, video_id = pairs.next
      sessions.add?(PoroStorage::Session.new(customer_id, video_id))
    end
  end

  bm.report('eqls find') do
    1000.times do
      customer_id, video_id = pairs.next
      ses = PoroStorage::Session.new(customer_id, video_id)
      sessions.find { |s| s.eql?(ses) }
    end
  end

  bm.report('delete') do
    1000.times do
      customer_id, video_id = pairs.next
      ses = PoroStorage::Session.new(customer_id, video_id)
      sessions.delete(ses)
    end
  end
end
