require "./segment/*"

# A NewRelic::Segment encapsulates a call to NewRelicExt.start_segment,
# and all of the data management around it.
class NewRelic::Segment
  @transaction : Transaction
  @type : Symbol
  @params : NamedTuple(label: String, category: String) |
            NamedTuple(
    product: String,
    collection: String?,
    operation: String?,
    host: String?,
    port_path_or_id: String?,
    database_name: String?,
    query: String?) |
            NamedTuple(uri: String, procedure: String?, library: String?)
  getter segment : NewRelicExt::SegmentT
  getter transaction : Transaction

  def initialize(
    @transaction : Transaction,
    label : String,
    category : String
  )
    @type = :standard
    @params = {label: label, category: category}
    @segment = NewRelicExt.start_segment(@transaction.structure, label, category)
  end

  def initialize(
    @transaction : Transaction,
    product : String,
    collection : String?,
    operation : String?,
    host : String?,
    port_path_or_id : String?,
    database_name : String?,
    query : String?
  )
    @type = :datastore
    params = {
      product:         product,
      collection:      collection,
      operation:       operation,
      host:            host,
      port_path_or_id: port_path_or_id,
      database_name:   database_name,
      query:           query,
    }
    args = Segment::DatastoreParams.new(**params)
    @params = params
    @segment = NewRelicExt.start_datastore_segment(@transaction.structure, args.pointer)
  end

  def initialize(
    @transaction : Transaction,
    uri : String,
    procedure : String?,
    library : String?
  )
    @type = :external
    params = {
      uri:       uri,
      procedure: procedure,
      library:   library,
    }
    args = Segment::ExternalParams.new(**params)
    @params = params
    @segment = NewRelicExt.start_external_segment(@transaction.structure, args.pointer)
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

  def timing(start_time, duration)
    NewRelicExt.set_segment_timing(@segment, start_time, duration)
  end
end
