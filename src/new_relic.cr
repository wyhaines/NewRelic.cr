require "./new_relic/*"

class NewRelic
  @config : NewRelic::Config
  @app : NewRelicExt::AppT

  getter app : NewRelicExt::AppT
  getter config : Config

  def initialize(
    configuration_file : String? = nil,
    app_name : String? = nil,
    license_key : String? = nil,
    logfile : String? = nil,
    loglevel : String = "info",
    @wait : Int32 = 10000,
    @type : Symbol = :web,
    config : NewRelic::Config? = nil,
    &blk : NewRelic ->
  )
    @config = config || Config.new(
      configuration_file: configuration_file,
      app_name: app_name,
      license_key: license_key
    )

    @app = do_app_setup

    blk.call(self)
  ensure
    destroy!
  end

  def initialize(
    configuration_file : String? = nil,
    app_name : String? = nil,
    license_key : String? = nil,
    logfile : String? = nil,
    loglevel : String = "info",
    @wait : Int32 = 10000,
    @type : Symbol = :web,
    config : NewRelic::Config? = nil
  )
    @config = config || Config.new(
      configuration_file: configuration_file,
      app_name: app_name,
      license_key: license_key
    )
    @app = do_app_setup
  end

  private def do_app_setup
    configure_logging
    # do_init
    app = NewRelicExt.create_app(@config.structure, @wait)
    @config.destroy!

    app
  end

  private def loglevels_from_words(word) : NewRelicExt::LoglevelT
    case word
    when "debug"
      NewRelicExt::LoglevelT::NewrelicLogDebug
    when "info"
      NewRelicExt::LoglevelT::NewrelicLogInfo
    when "warning"
      NewRelicExt::LoglevelT::NewrelicLogWarning
    when "error"
      NewRelicExt::LoglevelT::NewrelicLogError
    else
      NewRelicExt::LoglevelT::NewrelicLogInfo
    end
  end

  private def configure_logging
    if (!NewRelicExt.configure_log(@config.log_file, loglevels_from_words(@config.log_level)))
      raise LogCreationError.new("There was an error when trying to create a log at #{@config.log_file}.")
    end
  end

  # This only needs to be called if the daemon socket must be initialized with non-standard parameters.
  # And right now we do not support that.
  private def do_init
    if (!NewRelicExt.init(nil, 0))
      raise NewRelicInitializationError.new("There was an error when initializing the New Relic Agent.")
    end
  end

  def transaction(label, blk : Transaction ->, type : Symbol = @type )
    transaction = Transaction.create(self, label, type)
    blk.call(transaction)
  ensure
    transaction.destroy! if transaction
  end

  def transaction(label, type : Symbol = @type, &blk : Transaction -> )
    transaction(label: label, type: type, blk: blk)
  end

  def web_transaction(label, &blk : Transaction -> )
    transaction(label: label, type: :web, blk: blk)
  end

  def non_web_transaction(label, &blk : Transaction ->)
    transaction(label: label, type: :nonweb, blk: blk)
  end

  def destroy!
    NewRelicExt.destroy_app(pointerof(@app))
  end
end
