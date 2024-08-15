# Statusable

Statusable adds a `has_statuses` macro for defining common status-related methods for use with ActiveRecord objects / Relations.

## Usage

```ruby
class MyModel < ApplicationRecord
  has_statuses(%w[
      Pending
      Running
      Completed
    ])
end
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem "statusable"
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install statusable
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/pdobb/statusable.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. Or, run `rake` to run the tests plus linters as well as `yard` (to confirm proper YARD documentation practices). You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

To release a new version, update the version number in `version.rb` and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
