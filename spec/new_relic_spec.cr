require "./spec_helper"

{% if system("pidof newrelic-daemon || echo 'xxx'") == "xxx\n" %}
describe NewRelic do
  pending "Many tests can not run if the newrelic-daemon is not ruinning"
end
{% else %}
describe NewRelic do
  it "Can setup an app and tear it down without errors" do
    NewRelic.new do |app|
      puts app.inspect
      app.class.should eq NewRelic
    end
  end
end
{% end %}