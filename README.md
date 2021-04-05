# new_relic

This library provides support to Crystal for the New Relic observability platform.

It is built on top of the the New Relic C SDK, and depends on the newrelic_daemon.

Read below for instructions on how to build these and on how to run the daemon.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     new_relic:
       github: wyhaines/new_relic
   ```

2. Run `shards install`

## Usage

```crystal
require "new_relic"
```

To use the library to instrument your Crystal software, include the shard in your `shard.yml` as shown above. Once that is done, create a `newrelic.yml` file with your API access key and application information.

Copy the file in `config/newrelic.yml.sample` to `config/newrelic.yml` in your application's source directory, and then edit it.

```yaml
common: &default_settings
  license_key: '231d042757af255395d03ca6add7e5c0560bNRAL' # Fake Key, for illustration only.
  app_name: 'experiment'
production:
  <<: *default_settings
  log_level: info
development: 
  <<: *default_settings
  log_level: debug
```

Once the config file is created, run the `newrelic_daemon`. You are ready to send observability information to New Relic.

Instrumenting your code is currently fairly manual. There isn't currently any support for automated metrics, so one must insert calls in all of the places where one wants to record information.

The basic usage looks like this:

```crystal
require "new_relic"

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
```

This code creates a transactions, which defaults to a web transaction within the New Relic system, and then it records two segments within that transaction.

## Development

Contributions are welcome. Please fork the code as described below. Submit your pull requests with as much details as possible on the change that you are requesting.

## Contributing

1. Fork it (<https://github.com/your-github-user/new_relic/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Kirk Haines](https://github.com/your-github-user) - creator and maintainer
