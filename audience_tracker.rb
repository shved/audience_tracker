class AudienceTracker < Roda
  extend Dry::Configurable
  setting :storage
  setting :expire_time
  setting :time_bucket_expire_time_precision_factor

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
      @count = Handler.instance.customer_count(customer_id)
      { count: @count }
    end

    r.get 'videos', Integer do |video_id|
      response.expires 60, public: true

      @count = Handler.instance.video_count(video_id)
      { count: @count }
    end
  end
end

AudienceTracker.configure do |config|
  config.expire_time = ENV['RACK_ENV'] == 'test' ? 2 : 6

  config.storage =
    if ENV['STORAGE']&.match?('redis')
      RedisStorage.new(ENV['STORAGE'])
    elsif ENV['STORAGE'] == 'poro_time_bucket'
      PoroTimeBucketStorage.instance
    elsif ENV['STORAGE'] == 'poro_storage'
      PoroStorage.instance
    end

  config.time_bucket_expire_time_precision_factor = 2
end
