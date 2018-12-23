require 'spec_helper'

RSpec.describe 'API Requests', type: :request do
  before(:each) do
    PoroStorage.instance.flush!
  end

  after(:each) do
    PoroStorage.instance.flush!
  end

  it 'should register a pulse from client' do
    get('/pulse?customer_id=1&video_id=1')

    # actually don't have to response pulses
    # but since it responsd—better test it
    expect(response.code.to_i).to eq 200
    expect(response.content_type).to eq('application/json')
  end

  it "should return customer's videos count" do
    get('/customers/1')

    expect(response.code.to_i).to eq 200
    expect(JSON.load(response.body)['count']).to eq 0
  end

  it "should return video's customers count" do
    get('/videos/1')

    expect(response.code.to_i).to eq 200
    expect(JSON.load(response.body)['count']).to eq 0
  end
end
