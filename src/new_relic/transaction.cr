# A NewRelic::Transaction encapsulates a call to either the
# NewRelicExt::start_web_transaction or the NewRelicExt::start_non_web_transaction
# functions, and all of the data management around it.
class NewRelic::Transaction
  @transaction : NewRelicExt::TxnT
  @app : NewRelic
  @type : Symbol

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

  # Get rid of the data structures associated with this transaction.
  # This class must be called before letting this object be garbage
  # collected in order to avoid a memory leak. The easiest way to do
  # this is to use the block based transaction support, as that will
  # ensure that this method is called and that these resources are
  # destroyed.
  def destroy!
    NewRelicExt.end_transaction(pointerof(@transaction))
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
