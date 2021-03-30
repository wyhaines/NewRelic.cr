class NewRelic
  class Segment
    class ExternalParams
      @structure : NewRelicExt::ExternalSegmentParamsT
      getter structure : NewRelicExt::ExternalSegmentParamsT

      def initialize(
        uri : String,
        procedure : String? = nil,
        library : String? = nil
      )
        @structure = NewRelicExt::ExternalSegmentParamsT.new
        @structure.uri = uri
        @structure.procedure = procedure
        @structure.library = library ? library.gsub('/', '_') : library
      end
      
      def pointer
        pointerof(@structure)
      end
    end
  end
end
