require 'dotenv/load'
require 'roda'
require_relative './lib/handler'
# require 'pry'

class AudienceTracker < Roda
  plugin :json
  plugin :typecast_params

  route do |r|
    r.get 'heartbeat' do
      video_id = typecast_params.pos_int('video_id')
      customer_id = typecast_params.pos_int('customer_id')
      Handler.instance.heartbeat(customer_id, video_id) if video_id && customer_id
      # не возвращать ответ на этот запрос (найти как в роде это можно делать)
      {}
    end

    r.get 'customers', Integer do |customer_id|
      @count = Handler.instance.customer_stat(customer_id)
      resp = { count: @count }
      puts resp
      resp
      # возвращает стектрейс пятисотки lol
      # a thin рендерит хтмл пятисотки лол
    end

    r.get 'videos', Integer do |video_id|
      @count = Handler.instance.video_stat(video_id)
      resp = { count: @count }
      puts resp
      resp
    end
  end
end
