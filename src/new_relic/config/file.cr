require "yaml"

class NewRelic
  class Config
    class File
      include YAML::Serializable
      include YAML::Serializable::Unmapped

      def environments
        @yaml_unmapped
      end
    end
  end
end
