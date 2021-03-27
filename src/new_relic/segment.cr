# A NewRelic::Segment encapsulates a call to NewRelicExt.start_segment,
# and all of the data management around it.
class NewRelic::Segment
  @transaction : Transaction
  getter segment : NewRelicExt::SegmentT

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
end
