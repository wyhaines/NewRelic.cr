class NewRelic
  class Segment
    class DatastoreParams
      @structure : NewRelicExt::DatastoreSegmentParamsT
      getter structure : NewRelicExt::DatastoreSegmentParamsT

      def initialize(
        product : String,
        collection : String? = nil,
        operation : String? = nil,
        host : String? = nil,
        port_path_or_id : String? = nil,
        database_name : String? = nil,
        query : String? = nil
      )
        @structure = NewRelicExt::DatastoreSegmentParamsT.new

        @structure.product = product
        @structure.collection = collection
        @structure.operation = operation
        @structure.host = host
        @structure.port_path_or_id = port_path_or_id
        @structure.database_name = database_name
        @structure.query = query
      end

      def pointer
        pointerof(@structure)
      end
    end
  end
end
