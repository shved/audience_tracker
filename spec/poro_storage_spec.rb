require 'spec_helper'


RSpec.describe PoroStorage do
  before(:each) do
    PoroStorage.instance.flush!
  end

  after(:each) do
    PoroStorage.instance.flush!
  end

  let!(:sessions) do
    Enumerator.new do |y|
      loop do
        y << [(rand*100).round, (rand*100).round]
      end
    end
  end

  it 'should not store duplicates' do
    threads = []
    100.times do
      threads << Thread.new do
        PoroStorage.instance.store(1, 1)
      end
    end

    threads.join

    expect(PoroStorage.instance.sessions.size).to eq 1
    expect(PoroStorage.instance.sessions.first.eql?(PoroStorage::Session.new(1, 1))).to be true
  end
end
