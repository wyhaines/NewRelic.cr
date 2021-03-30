# A NewRelic::Transaction encapsulates a call to either the
# NewRelicExt::start_web_transaction or the NewRelicExt::start_non_web_transaction
# functions, and all of the data management around it.
class NewRelic::Transaction
  @transaction : NewRelicExt::TxnT
  @app : NewRelic
  @type : Symbol

  getter app : NewRelic
  getter type : Symbol

  # Instead of directly creating a Transaction object with a
  # specified type (:web or :nonweb), one can call #create with
  # an appropriate type parameter and one will get back the subclass
  # which corresponds to that type, either WebTransaction, or
  # NonWebTransaction.
  def self.create(app, label, type = :web)
    case type
    when :web
      WebTransaction.new(app, label)
    else
      NonWebTransaction.new(app, label)
    end
  end

  def initialize(@app, @label : String = "transaction", @type : Symbol = :web)
    case type
    when :web
      @transaction = NewRelicExt.start_web_transaction(@app.app, @label)
    else
      @transaction = NewRelicExt.start_non_web_transaction(@app.app, @label)
    end
  end

  # Return the corresponding C structure for this transaction.
  def structure : NewRelicExt::TxnT
    @transaction
  end

  # Return a pointer to the Transaction.
  def pointer : Pointer(NewRelicExt::TxnT)
    pointerof(@transaction)
  end

  def custom_event(event_type : String, **params)
    event = NewRelicExt.create_custom_event(event_type)
    params.each do |k,v|
      case v.class
      when Int8, Int16, UInt8
        NewRelicExt.custom_event_add_attribute_int(event, k.to_s, v.as(Int32))
      when Int32, Int64, UInt32
        NewRelicExt.custom_event_add_attribute_long(event, k.to_s, v.as(Int64))
      when Float
        NewRelicExt.custom_event_add_attribute_double(event, k.to_s, v.as(Float64))
      else
        NewRelicExt.custom_event_add_attribute_string(event, k.to_s, v.to_s)
      end
    end
    NewRelicExt.record_custom_event(@transaction, pointerof(event))
    NewRelicExt.discard_custom_event(pointerof(event))
  end

  # Get rid of the data structures associated with this transaction.
  # This class must be called before letting this object be garbage
  # collected in order to avoid a memory leak. The easiest way to do
  # this is to use the block based transaction support, as that will
  # ensure that this method is called and that these resources are
  # destroyed.
  def destroy!
    NewRelicExt.end_transaction(pointer)
  end

  # This transaction will be ignored, and the data that it contains
  # will not be sent to New Relic.
  def ignore!
    NewRelicExt.ignore_transaction(@transaction)
  end

  def error(
    msg : String = "Error at #{caller[1]}",
    category : String = "error",
    priority : Int16 = 0
  )
    NewRelicExt.notice_error(@transaction, priority, msg, category)
  end

  def name=(val : String)
    NewRelicExt.set_transaction_name(@transaction, val)
  end

  # Within a transaction, one can create one or more Segments
  # which represent subsections within the transaction.
  def segment(
    label : String = "Segment",
    category : String = "Segment",
    &blk : Segment ->
  )
    segment = Segment.new(self, label, category)
    blk.call(segment)
  ensure
    segment.destroy! if segment
  end

  def timing(start_time, duration)
    NewRelicExt.set_transaction_timing(@segment, start_time, duration)
  end

  def []=(k : String, v : Int)
    case v.class
    when Int8, Int16, UInt8
      NewRelicExt.add_attribute_int(structure, k, v.as(Int32))
    when Int32, Int64, UInt32
      NewRelicExt.add_attribute_long(structure, k, v.as(Int64))
    when Float
      NewRelic.add_attribute_double(structure, k, v.as(Float64))
    else
      NewRelic.add_attribute_string(structure, k, v.to_s)
    end
  end
end

# A subclass of NewRelic::Transaction that specifically
# represents a web transaction.
class NewRelic::WebTransaction < NewRelic::Transaction
  def initialize(app, label : String = "transaction")
    super(app, label, :web)
  end
end

# A subclass of NewRelic::Transaction that specifically
# represents a non-web transaction.
class NewRelic::NonWebTransaction < NewRelic::Transaction
  def initialize(app, label : String = "transaction")
    super(app, label, :nonweb)
  end
end
