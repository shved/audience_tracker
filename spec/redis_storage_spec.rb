require 'spec_helper'

RSpec.describe RedisStorage do
  include_context 'storage context' do
    let!(:storage) { RedisStorage.instance }
  end

  it 'should set video and customer items keys' do
    storage.store(1, 1)
    storage.store(1, 2)
    storage.store(2, 1)
    storage.store(2, 1)

    expect(storage.redis.keys("customers:*").count).to eq 2
    expect(storage.redis.smembers("customers:1").count).to eq 2
    expect(storage.redis.keys("videos:*").count).to eq 2
    expect(storage.redis.smembers("videos:2").count).to eq 1
  end

  it 'should expire sessions in given time' do
    storage.store(1, 1)
    expect(storage.redis.ttl('1:1').to_i).to be > 0
  end
end
