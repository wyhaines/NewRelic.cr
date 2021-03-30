require "./segment/*"

# A NewRelic::Segment encapsulates a call to NewRelicExt.start_segment,
# and all of the data management around it.
class NewRelic::Segment
  @transaction : Transaction
  getter segment : NewRelicExt::SegmentT
  getter transaction : Transaction

  def initialize(
    @transaction,
    @label : String = "segment",
    @category : String = "segment"
  )
    @segment = NewRelicExt.start_segment(@transaction.structure, @label, @category)
  end

  # Return the C structure that corresponds to the Segment.
  def structure : NewRelicExt::SegmentT
    @segment
  end

  # Return a pointer to the C structure that corresponds to the Segment.
  def pointer : Pointer(NewRelicExt::SegmentT)
    pointerof(@segment)
  end

  # Destroy the underlying resources that were allocated for this object.
  # This must be called before this object goes out of scope to avoid memory
  # leaks from resources that have not been freed. Use the block form of the
  # segment support (`NewRelic::Transaction.segment()`) to ensure that these
  # resources are freed.
  def destroy!
    NewRelicExt.end_segment(@transaction.structure, pointerof(@segment))
  end

  def parent=(val)
    NewRelicExt.set_segment_parent(@segment, val)
  end

  def parent_root!
    NewRelicExt.set_segment_parent_root(@segment)
  end

  def start_datastore(params : DatastoreParams)
    NewRelicExt.start_datastore_segment(@transaction.structure, params.pointer)
  end

  def start_datastore(
    product : String,
    collection : String? = nil,
    operation : String? = nil,
    host : String? = nil,
    port_path_or_id : String? = nil,
    database_name : String? = nil,
    query : String? = nil
  )
    start_datastore(
      DatastoreParams.new(
        product: product,
        collection: collection,
        operation: operation,
        host: host,
        port_path_or_id: port_path_or_id,
        database_name: database_name,
        query: query
      )
    )
  end

  def start_external(params : ExternalParams)
    NewRelicExt.start_external_segment(@transaction.structure, params.pointer)
  end

  def start_external(
    uri : String,
    procedure : String? = nil,
    library : String? = nil
  )
    start_external(
      ExternalParams.new(
        uri: uri,
        procedure: procedure,
        library: library
      )
    )
  end

  def timing(start_time, duration)
    NewRelicExt.set_segment_timing(@segment, start_time, duration)
  end
end
