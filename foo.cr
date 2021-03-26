require "./src/new_relic"

license_key = File.read("apikey")

config = NewRelic::Config.new("experiment", license_key)

puts config.inspect

puts config == Pointer(NewRelicExt::AppConfigT).null

# if (!NewRelic.configure_log("./c_sdk.log",
#   NewRelic::LoglevelT::NewrelicLogInfo))
#   puts("Error configuring logging.\n")
#   exit -1
# end

# if (!NewRelic.init(nil, 0))
#   puts("Error connecting to daemon.\n")
#   exit -1
# end

# app = NewRelic.create_app(config, 10000)
# NewRelic.destroy_app_config(pointerof(config))

# txn = NewRelic.start_web_transaction(app, "Sample")
# seg = NewRelic.start_segment(txn, "Segment1", "Test")

# sleep(2)

# NewRelic.end_segment(txn, pointerof(seg))
# NewRelic.end_transaction(pointerof(txn))

# NewRelic.destroy_app(pointerof(app))
