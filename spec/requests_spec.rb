require 'spec_helper'

RSpec.describe 'API Requests', type: :request do
  include_context 'storage context' do
    let!(:storage) { PoroStorage.instance }
  end

  it 'should register a pulse from client' do
    get('/pulse?customer_id=1&video_id=1')

    # actually don't have to response pulses
    # but since it responds anyway—better test it
    expect(response.code.to_i).to eq 200
    expect(response.content_type).to eq('application/json')
  end

  context 'with initial two pulse requests' do
    before(:each) do
      get('/pulse?customer_id=1&video_id=1')
      get('/pulse?customer_id=1&video_id=1')
    end

    it "should return customer's videos count" do
      get('/customers/1')

      expect(response.code.to_i).to eq 200
      expect(JSON.load(response.body)['count']).to eq 1
    end

    it "should return video's customers count" do
      get('/videos/1')

      expect(response.code.to_i).to eq 200
      expect(JSON.load(response.body)['count']).to eq 1
    end
  end
end
