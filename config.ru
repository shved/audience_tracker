require './core'

use Rack::Cache,
    metastore: "file:#{__dir__}/tmp/rack-cache/meta",
    entitystore: "file:#{__dir__}/tmp/rack-cache/body",
    verbose: true

run AudienceTracker.freeze.app

Signal.trap('INT') do
  PoroTimeBucketStorage.instance.exit_rotator_thread
  RedisStorage.instance.exit_subscriber_thread
end
