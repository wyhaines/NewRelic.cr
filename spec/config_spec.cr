require "./spec_helper"

describe NewRelic::Config do
  it "will return a default environment selection" do
    tmp_env = ENV
    ENV.clear
    NewRelic::Config.environment.should eq "development"
    tmp_env.each {|k,v| ENV[k] = v}
  end

  it "can determine environment from a variety of framework env variables" do
    restore = Hash(String, String?).new
    vars = %w(NEW_RELIC_ENV LUCKY_ENV ATHENA_ENV KEMAL_ENV APP_ENV)
    vars.each do |var|
      restore[var] = ENV[var]?
      ENV.delete var
    end

    vars.each do |var|
      ENV[var] = "xyzzy"
      NewRelic::Config.environment.should eq "xyzzy"
      ENV.delete var
    end

    restore.each do |k, v|
      ENV[k] = v if !v.nil?
    end
  end

  it "can find a configuration file by looking in standard places" do
    envcfg = NewRelic::Config.environment_configuration("newrelic.yml.sample")
    envcfg.app_name.should eq "experiment"
    envcfg.license_key.should eq "231d042757af255395d03ca6add7e5c0560bNRAL"
  end

  it "can find a configuration file when given the specific path" do
    envcfg = NewRelic::Config.environment_configuration("#{__DIR__}/../config/newrelic.yml.sample")
    envcfg.app_name.should eq "experiment"
    envcfg.license_key.should eq "231d042757af255395d03ca6add7e5c0560bNRAL"
  end

  it "returns a fully accessible environment config object" do
    envcfg = NewRelic::Config.environment_configuration("newrelic.yml.sample")
    envcfg.app_name.should eq "experiment"
    envcfg.license_key.should eq "231d042757af255395d03ca6add7e5c0560bNRAL"
    envcfg.log_level.should eq "debug"
    envcfg.log_file.should be_nil
    envcfg.log_file_name.should eq "newrelic_agent.log"
    envcfg.log_file_path.should eq "log/"
  end

  it "accepts overrides for all configuration options from ENV variables" do
    restore = Hash(String, String?).new
    vars = %w(
      NEWRELIC_APP_NAME
      NEWRELIC_LICENSE_KEY
      NEWRELIC_LOG_LEVEL
      NEWRELIC_LOG_FILE
      NEWRELIC_LOG_FILE_NAME
      NEWRELIC_LOG_FILE_PATH
    )
    vars.each do |var|
      restore[var] = ENV[var]?
      ENV.delete var
    end

    vars.each do |var|
      ENV[var] = "xyzzy"
    end

    envcfg = NewRelic::Config.environment_configuration("newrelic.yml.sample")

    envcfg.app_name.should eq "xyzzy"
    envcfg.license_key.should eq "xyzzy"
    envcfg.log_level.should eq "xyzzy"
    envcfg.log_file.should eq "xyzzy"
    envcfg.log_file_name.should eq "xyzzy"
    envcfg.log_file_path.should eq "xyzzy"

    restore.each do |k, v|
      ENV.delete k
      ENV[k] = v if !v.nil?
    end
  end
end
