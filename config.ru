require './core'

use Rack::Cache,
    metastore: "file:#{__dir__}/tmp/rack-cache/meta",
    entitystore: "file:#{__dir__}/tmp/rack-cache/body",
    verbose: true

run AudienceTracker.freeze.app
