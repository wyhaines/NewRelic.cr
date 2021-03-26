struct NewRelic
  struct Config
    MalformedConfig = Exception

    @config : Pointer(NewRelicExt::AppConfigT)

    def initialize(name : String, key : String)
      name = name.strip
      key = key.strip
      config = NewRelicExt.create_app_config(name, key)

      raise MalformedConfig.new("The config could not be initialized. Double check your app name and your license key.") if config == Pointer(NewRelicExt::AppConfigT).null
      @config = config
    end

    def structure
      @config
    end

    # app_name : LibC::Char[255]
    def app_name
      @config.app_name
    end

    # license_key : LibC::Char[255]
    def license_key
      @config.license_key
    end

    # redirect_collector : LibC::Char[100]
    # log_filename : LibC::Char[512]
    # log_level : LoglevelT
    # transaction_tracer : TransactionTracerConfigT
    # datastore_tracer : DatastoreSegmentConfigT
    # distributed_tracing : DistributedTracingConfigT
    # span_events : SpanEventConfigT
  end
end
