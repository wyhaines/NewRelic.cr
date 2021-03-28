require "./src/new_relic"

license_key = File.read("apikey").chomp

NewRelic.new(app_name: "experiment", license_key: license_key, type: :xweb) do |app|
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
