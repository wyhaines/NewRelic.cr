class NewRelic
  # This exception is thrown when the logfile for the New Relic
  # agent can not be created. Check to ensure that the logging
  # location is writeable.
  class LogCreationError < Exception; end

  # This exception is thrown when the agent fails to properly
  # initialize itself. Ensure that the New Relic Daemon process is
  # running and is on an accessible port.
  class NewRelicInitializationError < Exception; end
end
