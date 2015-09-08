# Alerty::Plugin::AmazonCloudwatchLogs

Datadog Event plugin for [alerty](https://github.com/sonots/alerty).

## Spcial Thanks

I used the blog post & source code below as reference. Thank you!!!

- http://blog.livedoor.jp/sonots/archives/45330651.html
- [alerty-plugin-amazon_sns](https://github.com/sonots/alerty-plugin-amazon_sns)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'alerty-plugin-amazon_cloudwatch_logs'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install alerty-plugin-amazon_cloudwatch_logs

## Configuration

following is required.

- **type** : must be datadog_event
- **access_key** : AWS Access Key 
- **secret_access_key** : AWS Secret Access Key 
- **aws_region** : AWS Region Name
- **log_group_name** : CloudWatch Logs Group Name
- **log_stream_name** : CloudWatch Logs Stream Name
- **state_file** : Write SequenceToken
- **subject** : subject of alert. ${command} is replaced with a given command, ${hostname} is replaced with the hostname ran a command

following is an example.

```
log_path: STDOUT
log_level: debug
plugins:
  - type: amazon_cloudwatch_logs
    access_key_id: AKxxxxxxxxxxxxxxxxxxxxx
    secret_access_key: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    aws_region: ap-northeast-1
    log_group_name: foo
    log_stream_name: bar
    state_file: /path/to/alerty_state_file
    subject: "FAILURE: [${hostname}] ${command}"
```

See [examle.yml](https://github.com/inokappa/alerty-plugin-amazon_cloudwatch_logs/blob/master/example.yml).

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/alerty-plugin-amazon_cloudwatch_logs.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

