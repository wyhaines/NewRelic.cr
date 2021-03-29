require "./spec_helper"

# Macros to the rescue. Only run these specs if the newrelic-daemon is running.
{% if system("pidof newrelic-daemon || echo 'xxx'") == "xxx\n" %}
describe NewRelic do
  pending "Many tests can not run if the newrelic-daemon is not ruinning"
end
{% else %}
describe NewRelic do
  it "Can setup an app and tear it down without errors using a block" do
    NewRelic.new do |app|
      app.class.should eq NewRelic
      app.config.config.should eq Pointer(NewRelicExt::AppConfigT).null
    end
  end

  it "can setup and tear down an app with explicit methods" do
    app = NewRelic.new
    app.class.should eq NewRelic
    app.config.config.should eq Pointer(NewRelicExt::AppConfigT).null
    app.destroy!
  end

  it "can submit a complete web transaction, with segments" do
    NewRelic.new do |app|
      app.class.should eq NewRelic
      app.config.config.should eq Pointer(NewRelicExt::AppConfigT).null
      app.transaction("spec-complete-web-transaction") do |txn|
        txn.is_a?(NewRelic::Transaction).should be_true
        txn.app.should eq app
        txn.segment("segment-1") do |seg|
          seg.is_a?(NewRelic::Segment).should be_true
          seg.transaction.should eq txn
          sleep rand
        end.should be_true
        txn.segment("segment-2") do |seg|
          seg.is_a?(NewRelic::Segment).should be_true
          seg.transaction.should eq txn
          sleep rand
        end.should be_true
      end
    end    
  end

  it "can submit mixed transactions from an app" do
    NewRelic.new do |app|
      app.web_transaction("spec-mixed-web-transaction") do |txn|
        txn.segment("segment-1") do |seg|
          sleep rand
        end.should be_true
      end
      app.non_web_transaction("spec-mixed-non-web-transaction") do |txn|
        txn.segment("segment-2") do |seg|
          sleep rand
        end.should be_true
      end
    end
  end
end
{% end %}