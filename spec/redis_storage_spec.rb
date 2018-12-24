require 'spec_helper'

RSpec.describe RedisStorage do
  include_context 'storage context' do
    let!(:storage) { RedisStorage.new }
  end

  let!(:customer_id) { 1000_000 }

  it 'should not store duplicates' do
    threads = []
    100.times do
      threads << Thread.new do
        storage.store(1, 1)
      end
    end

    threads.join

    expect(storage.redis.keys.size).to eq 1
    expect(storage.redis.keys.first).to eq '1:1'
  end

  it 'should expire sessions in given time' do
    storage.store(1, 1)
    puts storage.redis.ttl('1:1')
    expect(storage.redis.ttl('1:1').to_i).to be > 0
  end
end
