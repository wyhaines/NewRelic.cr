require "./new_relic/*"

class NewRelic
  @config : NewRelic::Config
  @loglevel : NewRelicExt::LoglevelT
  @app : NewRelicExt::AppT

  getter app : NewRelicExt::AppT

  def initialize(
    name : String,
    key : String,
    @log : String = "./newrelic_crystal.log",
    loglevel : String = "info",
    @wait : Int32 = 10000,
    @type : Symbol = :web,
    config : NewRelic::Config? = nil,
    &blk : NewRelic ->
  )
    @loglevel = loglevels_from_words(loglevel)
    @config = config || Config.new(name, key)
    @app = do_app_setup

    blk.call(self)
  ensure
    destroy!
  end

  def initialize(
    name : String,
    key : String,
    @log : String = "./newrelic_crystal.log",
    loglevel : String = "info",
    @wait : Int32 = 10000,
    @type : Symbol = :web,
    config : NewRelic::Config? = nil
  )
    @loglevel = loglevels_from_words(loglevel)
    @config = config || Config.new(name, key)

    @app = do_app_setup
  end

  private def do_app_setup
    configure_logging
    do_init
    app = NewRelicExt.create_app(@config.structure, @wait)
    NewRelicExt.destroy_app_config(@config.pointer)

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
    if (!NewRelicExt.configure_log(@log, @loglevel))
      raise LogCreationError.new("There was an error when trying to create a log at #{@log}.")
    end
  end

  private def do_init
    if (!NewRelicExt.init(nil, 0))
      raise NewRelicInitializationError.new("There was an error when initializing the New Relic Agent.")
    end
  end

  def transaction(label, &blk : Transaction ->)
    transaction = Transaction.create(self, label, @type)
    puts transaction.inspect
    blk.call(transaction)
  ensure
    transaction.destroy! if transaction
  end

  def destroy!
    NewRelicExt.destroy_app(pointerof(@app))
  end
end
