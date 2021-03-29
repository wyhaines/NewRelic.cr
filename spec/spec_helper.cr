require "spec"
require "../src/new_relic"

raise "Specs can not run without an accessible New Relic configuration." unless NewRelic::Config.environment_configuration.license_key != "placeholder"
