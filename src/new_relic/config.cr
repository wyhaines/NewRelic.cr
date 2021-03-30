require "./config/*"

class NewRelic
  class Config
    MalformedConfig = Exception

    @config : Pointer(NewRelicExt::AppConfigT)
    @env_cfg : NewRelic::Config::Environment
    @environment : String = "development"

    getter config : Pointer(NewRelicExt::AppConfigT)

    def initialize(configuration_file : String? = nil, app_name : String? = nil, license_key : String? = nil)
      @environment = Config.environment
      @env_cfg = Config.environment_configuration(configuration_file)
      @env_cfg.app_name = app_name.strip if !app_name.nil?
      @env_cfg.license_key = license_key.strip if !license_key.nil?

      config = NewRelicExt.create_app_config(@env_cfg.app_name, @env_cfg.license_key)

      raise MalformedConfig.new("The config could not be initialized. Double check your app name and your license key.") if config == Pointer(NewRelicExt::AppConfigT).null
      @config = config
    end

    # This will return a configuration for the current environment, as
    # specified by environment variable settings (see #environment).
    # Specific elements of the current environment can be overridden
    # or set through the use of environment variables.
    def self.environment_configuration(configuration_file : String? = nil)
      if configuration_file.nil? || !::File.exists?(configuration_file)
        configuration_file = if configuration_file.nil?
                               find_config_file
                             else
                               find_config_file(configuration_file)
                             end
      end

      cfg = nil
      cfg = Hash(String, NewRelic::Config::Environment).from_yaml(::File.read(configuration_file)) if !configuration_file.nil?

      if !cfg.nil? && cfg.has_key?(environment)
        env_cfg = cfg[environment]
      else
        env_cfg = NewRelic::Config::Environment.from_yaml("---\n")
      end

      override_env_cfg_from_environment(env_cfg)
    end

    private def self.override_env_cfg_from_environment(cfg)
      cfg.app_name = ENV["NEWRELIC_APP_NAME"] if ENV.has_key?("NEWRELIC_APP_NAME")
      cfg.license_key = ENV["NEWRELIC_LICENSE_KEY"] if ENV.has_key?("NEWRELIC_LICENSE_KEY")
      cfg.log_level = ENV["NEWRELIC_LOG_LEVEL"] if ENV.has_key?("NEWRELIC_LOG_LEVEL")
      cfg.log_file = ENV["NEWRELIC_LOG_FILE"] if ENV.has_key?("NEWRELIC_LOG_FILE_NAME")
      cfg.log_file_name = ENV["NEWRELIC_LOG_FILE_NAME"] if ENV.has_key?("NEWRELIC_LOG_FILE_NAME")
      cfg.log_file_path = ENV["NEWRELIC_LOG_FILE_PATH"] if ENV.has_key?("NEWRELIC_LOG_FILE_PATH")
      cfg
    end

    def self.find_config_file
      find_config_file(filename: "newrelic.yml")
    end

    def self.find_config_file(filename : String) : String?
      Dir[
        "#{Dir.current}/#{filename}",
        "#{__DIR__}/../../../lib/../#{filename}",
        "#{Dir.current}/config/**/#{filename}",
        "#{Dir.current}/*/#{filename}",
        "#{__DIR__}/../../../lib/../config/**/#{filename}",
        "#{__DIR__}/../../../lib/../*/#{filename}",
      ].first?
    end

    ENV_STRINGS = %w(NEW_RELIC_ENV LUCKY_ENV ATHENA_ENV KEMAL_ENV APP_ENV)

    def self.environment
      ENV_STRINGS.each do |env|
        if ENV.has_key?(env) && !ENV[env].to_s.empty?
          return ENV[env]
        end
      end
      "development"
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
