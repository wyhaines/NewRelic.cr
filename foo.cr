require "./src/new_relic"

NewRelic.new() do |app|
  app.transaction("sample") do |txn|
    txn.segment("Segment1") do |seg|
      puts "sleeping 1"
      sleep(rand() * 2)
    end
    txn.segment("Segment2") do |seg|
      puts "sleeping 2"
      sleep(rand() * 2)
    end
  end
end
