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
          end
          txn.segment("segment-2") do |seg|
            seg.is_a?(NewRelic::Segment).should be_true
            seg.transaction.should eq txn
            sleep rand
          end
        end
      end
    end

    it "can submit mixed transactions from an app" do
      NewRelic.new do |app|
        app.web_transaction("spec-mixed-web-transaction") do |txn|
          txn.segment("segment-1") do |seg|
            sleep rand
          end
        end
        app.non_web_transaction("spec-mixed-non-web-transaction") do |txn|
          txn.segment("segment-2") do |seg|
            sleep rand
          end
        end
      end
    end

    it "can ignore a transaction" do
      NewRelic.new do |app|
        app.web_transaction("spec-ignored-web-transaction") do |txn|
          txn.segment("segment-1") do |seg|
            sleep rand
          end
          txn.ignore!
        end
        app.non_web_transaction("spec-ignored-non-web-transaction") do |txn|
          txn.segment("segment-2") do |seg|
            sleep rand
          end
          txn.ignore!
        end
      end
    end

    it "can report an error on the transaction" do
      NewRelic.new do |app|
        app.web_transaction("spec-ignored-web-transaction") do |txn|
          txn.segment("segment-1") do |seg|
            sleep rand
          end
          txn.error
        end
        app.non_web_transaction("spec-ignored-non-web-transaction") do |txn|
          txn.segment("segment-2") do |seg|
            sleep rand
          end
          txn.error(
            msg: "This notice should take priority over the default notice.",
            priority: 10
          )
        end
      end
    end

    it "can start a datastore transaction" do
      NewRelic.new do |app|
        app.web_transaction("spec-datastore-web-transaction") do |txn|
          txn.segment(product: "filesystem") do |seg|
            sleep rand
          end
        end
      end
    end

    it "can start an external transaction" do
      NewRelic.new do |app|
        app.web_transaction("spec-external-web-transaction") do |txn|
          txn.segment(uri: "http://localhost") do |seg|
            sleep rand
          end
        end
      end
    end

    it "can record a custom event" do
      NewRelic.new do |app|
        app.web_transaction("spec-custom-event-web-transaction") do |txn|
          txn.custom_event("before sleep", timestamp: Time.local)
          txn.segment("segment-1") do |seg|
            sleep rand
          end
          txn.custom_event("after sleep", timestamp: Time.local)
          puts "after sleep"
        end
      end
    end
  end
{% end %}
