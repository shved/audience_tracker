require 'dotenv/load'
require 'roda'
require_relative './lib/handler'
require_relative './lib/sessions_watcher'
# require 'pry'

class AudienceTracker < Roda
  plugin :json
  plugin :typecast_params
  plugin :caching

  route do |r|
    r.get 'pulse' do
      customer_id = typecast_params.pos_int('customer_id')
      video_id    = typecast_params.pos_int('video_id')
      Handler.instance.pulse(customer_id, video_id) if video_id && customer_id
      {}
    end

    r.get 'customers', Integer do |customer_id|
      @count = Handler.instance.customer_stat(customer_id)
      resp = { count: @count }
      puts resp
      resp
    end

    r.get 'videos', Integer do |video_id|
      response.expires 60, public: true
      @count = Handler.instance.video_stat(video_id)
      resp = { count: @count }
      puts resp
      resp
    end

    r.get 'report' do
      SessionsWatcher.instance.report
    end
  end
end
