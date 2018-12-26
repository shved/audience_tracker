require 'spec_helper'
require 'securerandom'

RSpec.describe PoroStorage do
  include_context 'storage context' do
    let!(:storage) { described_class.instance }
  end

  let!(:customer_id) { 1_000_000 }

  it 'should not store duplicates' do
    threads = []

    100.times do
      threads << Thread.new do
        storage.store(1, 1)
      end
    end
    threads.join

    expect(storage.sessions.size).to eq 1
    expect(storage.sessions.first.eql?(described_class::Session.new(1, 1))).to be true
  end

  it 'should return actual customer counter' do
    threads = []
    wait_to_start = true

    10.times do
      threads << Thread.new do
        true while wait_to_start
        10.times do
          storage.store(customer_id, SecureRandom.random_number(1000000))
        end
      end
    end

    10.times do
      threads << Thread.new do
        true while wait_to_start
        10.times do
          storage.store(*[(rand*1000).round, (rand*1000).round])
        end
      end
    end

    wait_to_start = false

    threads.each(&:join)

    customer_counter = storage.customer_count(customer_id)

    expect(customer_counter).to eq 100
  end

  it 'should expire sessions in given time' do
    storage.store(1, 1)
    puts "\tWaiting for session to expire..."
    sleep(AudienceTracker.config.expire_time + 0.5)
    expect(storage.sessions.size).to eq 0
  end
end
