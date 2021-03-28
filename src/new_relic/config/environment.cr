require "yaml"

class NewRelic
  class Config
    class Environment
      include YAML::Serializable
      include YAML::Serializable::Unmapped

      @[YAML::Field(key: "app_name")]
      property app_name : String = "placeholder"

      @[YAML::Field(key: "license_key")]
      property license_key : String = "placeholder"

      @[YAML::Field(key: "log_level")]
      property log_level : String = "info"

      @[YAML::Field(key: "log_file", emit_null: true)]
      property log_file : String? = nil

      @[YAML::Field(key: "log_file_name")]
      property log_file_name : String = "newrelic_agent.log"

      @[YAML::Field(key: "log_file_path")]
      property log_file_path : String = "log/"
    end
  end
end
