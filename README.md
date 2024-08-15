# Statusable

Statusable adds a `has_statuses` macro for defining common status-related methods for use with ActiveRecord objects / Relations.

## Installation

First, add a data migration to add a `status` column to your model. Or pick any name you want instead of `status`.

```ruby
# db/migrate/<version>_add_status_to_jobs.rb

def change
  add_column :jobs, :status, :string, null: false, default: "Initializing"
  add_index :jobs, :status
end
```

Next, include `Statusable::HasStatuses` either into your model or into ApplicationRecord, per your preference.

```ruby
class Job < ApplicationRecord
  include Statusable::HasStatuses
end
```

Finally, call the `has_statuses` macro in your model, along with an array of your desired status names. See below for basic usage and advanced usage.

## Basic Usage

```ruby
class Job < ApplicationRecord
  include Statusable::HasStatuses

  has_statuses(%w[
      Pending
      Running
      Completed
    ])
end
```

This adds a number of methods, named_scopes, and even ActiveModel validations to Job.

```ruby
job = Job.new(status: "Pending")

# Check current status:

job.status_pending? # => true
job.status_running? # => false

job.not_status_pending? # => false
job.not_status_running? # => true

job.status?("Pending") # => true
job.status?("Running") # => false

# Set status without saving:

job.set_status_running # => #<Job:0x000000012fc3b060 id: nil, status: "Running", created_at: nil, updated_at: nil>
job.status_pending? # => false
job.status_running? # => true

# Set status and save:

job.set_status_running! # => #<Job:0x000000012fc3b560 id: 1, status: "Running", created_at: "...", updated_at: "...">

# Get statuses/names/lists:

Job.status_options # => ["Pending", "Running", "Completed"]
job.status_options # => ["Pending", "Running", "Completed"]

Job.humanized_statuses_list # => "Pending, Running, or Completed"
job.humanized_statuses_list # => "Pending, Running, or Completed"

Job.status_pending # => "Pending"
job.status_pending # => "Pending"

# Named scopes:

Job.for_status("Pending").to_sql # => SELECT "jobs".* FROM "jobs" WHERE "jobs"."status" = 'Pending'
Job.for_status(%w[Pending Running]).to_sql # => SELECT "jobs".* FROM "jobs" WHERE "jobs"."status" IN ('Pending', 'Running')
Job.not_for_status("Pending").to_sql # => SELECT "jobs".* FROM "jobs" WHERE "jobs"."status" != 'Pending'
Job.not_for_status(%w[Pending Running]).to_sql # => SELECT "jobs".* FROM "jobs" WHERE "jobs"."status" NOT IN ('Pending', 'Running')

Job.for_status_pending.to_sql # => SELECT "jobs".* FROM "jobs" WHERE "jobs"."status" = 'Pending'
Job.not_for_status_pending.to_sql # => SELECT "jobs".* FROM "jobs" WHERE "jobs"."status" != 'Pending'

Job.by_status_asc.to_sql # => SELECT "jobs".* FROM "jobs" ORDER BY "jobs"."status"
Job.by_status_desc.to_sql # => SELECT "jobs".* FROM "jobs" ORDER BY "jobs"."status" DESC
Job.group_by_status.to_sql # => SELECT "jobs".* FROM "jobs" GROUP BY "jobs"."status"

# Validation:

job.status = nil
job.validate; job.errors[:status] # => []

job.status = "Invalid Status"
job.validate; job.errors[:status] # => ["must be one of Pending, Running, or Completed"]
```

## Advanced Usage

TODO

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
