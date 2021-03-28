require "./config/*"

class NewRelic
  class Config
    MalformedConfig = Exception

    @config : Pointer(NewRelicExt::AppConfigT)
    @env_cfg : NewRelic::Config::Environment
    @environment : String = "development"

    def initialize(configuration_file : String? = nil, app_name : String? = nil, license_key : String? = nil)
      configuration_file = find_config_file if configuration_file.nil?

      cfg = nil
      begin # TODO: This should probably be a separate method.
        cfg = Hash(String, NewRelic::Config::Environment).from_yaml(::File.read(configuration_file)) if !configuration_file.nil?
      rescue
      end

      @env_cfg = NewRelic::Config::Environment.from_yaml("---\n")
      @env_cfg = cfg[environment] if !cfg.nil? && cfg.has_key?(environment)

      @env_cfg.app_name = app_name.strip if !app_name.nil?
      @env_cfg.license_key = license_key.strip if !license_key.nil?

      puts @env_cfg.inspect
      config = NewRelicExt.create_app_config(@env_cfg.app_name, @env_cfg.license_key)

      raise MalformedConfig.new("The config could not be initialized. Double check your app name and your license key.") if config == Pointer(NewRelicExt::AppConfigT).null
      @config = config
    end

    private def find_config_file
      Dir[
        "#{Dir.current}/newrelic.yml",
        "#{__DIR__}/../../../lib/../newrelic.yml",
        "#{Dir.current}/config/**/newrelic.yml",
        "#{Dir.current}/*/newrelic.yml",
        "#{__DIR__}/../../../lib/../config/**/newrelic.yml",
        "#{__DIR__}/../../../lib/../*/newrelic.yml",
      ].first?
    end

    ENV_STRINGS = %w(NEW_RELIC_ENV LUCKY_ENV ATHENA_ENV KEMAL_ENV APP_ENV)

    def environment
      ENV_STRINGS.each do |env|
        if ENV.has_key?(env) && !ENV[env].to_s.empty?
          @environment = ENV[env]
          break
        end
      end

      @environment
    end

    def log_level
      @env_cfg.log_level
    end

    def log_file
      ::File.expand_path(
        @env_cfg.log_file ||
        ::File.join(log_file_path, log_file_name)
      )
    end

    def log_file_name
      @env_cfg.log_file_name
    end

    def log_file_path
      @env_cfg.log_file_path
    end

    def structure
      @config
    end

    def pointer
      pointerof(@config)
    end

    def destroy!
      NewRelicExt.destroy_app_config(pointer)
    end

    def app_name
      @config.app_name
    end

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
