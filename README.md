# Statusable

[![Gem Version](https://img.shields.io/github/v/release/pdobb/statusable)](https://img.shields.io/github/v/release/pdobb/statusable)

Statusable adds a `has_statuses` macro for defining common status-related methods for use with ActiveRecord objects / Relations.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "statusable"
```

And then execute:

```bash
$ bundle
```

Or install it yourself:

```bash
$ gem install statusable
```

## Configuration

First, add a `status` column to your model. Or pick any other name you may want instead of `status`... the column name is configurable. (See [Advanced Usage](#advanced-usage).)

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

Finally, call the `has_statuses` macro in your model, along with an array of your desired status names. See below for [Basic Usage](#basic-usage) and [Advanced Usage](#advanced-usage).

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

This adds a number of methods, named_scopes, and even ActiveModel validations to the model.

```ruby
# The following are equivalent:

job = Job.new(status: "Pending")
job = Job.new(status: Job.status_pending)
job = Job.new; job.set_status_pending

# Check current status:

job.status_pending?    # => true
job.status?("Pending") # => true

job.not_status_running?    # => true
job.not_status?("Running") # => true

# Set status without saving:

job.set_status_running
# => #<Job:0x000000012fc3b060 id: nil, status: "Running", created_at: nil, updated_at: nil>
job.status_running? # => true

# Set status and save:

job.set_status_running!
# => #<Job:0x000000012fc3b560 id: 1, status: "Running", created_at: "...", updated_at: "...">

# Get status names/lists:

Job.status_pending # => "Pending"
job.status_pending # => "Pending"

Job.status_options # => ["Pending", "Running", "Completed"]
job.status_options # => ["Pending", "Running", "Completed"]

Job.humanized_statuses_list # => "Pending, Running, or Completed"
job.humanized_statuses_list # => "Pending, Running, or Completed"

# Named scopes:

Job.for_status("Pending").to_sql
# => SELECT "jobs".* FROM "jobs" WHERE "jobs"."status" = 'Pending'
Job.for_status(%w[Pending Running]).to_sql
# => SELECT "jobs".* FROM "jobs" WHERE "jobs"."status" IN ('Pending', 'Running')

Job.not_for_status("Pending").to_sql
# => SELECT "jobs".* FROM "jobs" WHERE "jobs"."status" != 'Pending'
Job.not_for_status(%w[Pending Running]).to_sql
# => SELECT "jobs".* FROM "jobs" WHERE "jobs"."status" NOT IN ('Pending', 'Running')

Job.for_status_pending.to_sql
# => SELECT "jobs".* FROM "jobs" WHERE "jobs"."status" = 'Pending'
Job.not_for_status_pending.to_sql
# => SELECT "jobs".* FROM "jobs" WHERE "jobs"."status" != 'Pending'

Job.by_status_asc.to_sql
# => SELECT "jobs".* FROM "jobs" ORDER BY "jobs"."status"
Job.by_status_desc.to_sql
# => SELECT "jobs".* FROM "jobs" ORDER BY "jobs"."status" DESC

Job.group_by_status.to_sql
# => SELECT "jobs".* FROM "jobs" GROUP BY "jobs"."status"

# Validation:

# By default, we don't validate on presence, but this can be changed.
# See the Advanced Usage section.
job.status = nil
job.validate; job.errors[:status] # => []

job.status = "Invalid Status"
job.validate; job.errors[:status]
# => ["must be one of Pending, Running, or Completed"]
```

## Advanced Usage

The column name is customizable, as is whether or not to validate on presence or inclusion. Validating on inclusion means: ensuring that the current status value is included in the list of possible status values.

Defaults:

- `col_name = "status"`
- `validate_presence = false`
- `validate_inclusion = true`

_Note: Be sure that the column name in your migration matches whatever you choose for `col_name`, below._

```ruby
class Job < ApplicationRecord
  include Statusable::HasStatuses

  has_statuses(%w[
      Pending
      Running
      Completed
    ],
    col_name: "lifecycle_state",
    validate_presence: true,
    validate_inclusion: true)
end
```

This adds a number of methods, named_scopes, and even ActiveModel validations to the model--the same ones shown in Basic Usage. However, the "status" name varies, and this time we include a presence validation:

```ruby
# The following are equivalent:

job = Job.new; job.set_lifecycle_state_pending

# Check current status:

job.lifecycle_state_pending?    # => true
job.lifecycle_state?("Pending") # => true

job.not_lifecycle_state_running?    # => true
job.not_lifecycle_state?("Running") # => true

# Set status without saving:

job.set_lifecycle_state_running
# => #<Job:0x000000012fc3b060 id: nil, lifecycle_state: "Running", created_at: nil, updated_at: nil>
job.lifecycle_state_running? # => true

# Set status and save:

job.set_lifecycle_state_running!
# => #<Job:0x000000012fc3b560 id: 1, lifecycle_state: "Running", created_at: "...", updated_at: "...">

# Get status names/lists:

Job.lifecycle_state_pending # => "Pending"
job.lifecycle_state_pending # => "Pending"

Job.lifecycle_state_options # => ["Pending", "Running", "Completed"]
job.lifecycle_state_options # => ["Pending", "Running", "Completed"]

Job.humanized_lifecycle_states_list # => "Pending, Running, or Completed"
job.humanized_lifecycle_states_list # => "Pending, Running, or Completed"

# Named scopes:

Job.for_lifecycle_state("Pending").to_sql
# => SELECT "jobs".* FROM "jobs" WHERE "jobs"."lifecycle_state" = 'Pending'
Job.for_lifecycle_state(%w[Pending Running]).to_sql
# => SELECT "jobs".* FROM "jobs" WHERE "jobs"."lifecycle_state" IN ('Pending', 'Running')

Job.not_for_lifecycle_state("Pending").to_sql
# => SELECT "jobs".* FROM "jobs" WHERE "jobs"."lifecycle_state" != 'Pending'
Job.not_for_lifecycle_state(%w[Pending Running]).to_sql
# => SELECT "jobs".* FROM "jobs" WHERE "jobs"."lifecycle_state" NOT IN ('Pending', 'Running')

Job.for_lifecycle_state_pending.to_sql
# => SELECT "jobs".* FROM "jobs" WHERE "jobs"."lifecycle_state" = 'Pending'
Job.not_for_lifecycle_state_pending.to_sql
# => SELECT "jobs".* FROM "jobs" WHERE "jobs"."lifecycle_state" != 'Pending'

Job.by_lifecycle_state_asc.to_sql
# => SELECT "jobs".* FROM "jobs" ORDER BY "jobs"."lifecycle_state"
Job.by_lifecycle_state_desc.to_sql
# => SELECT "jobs".* FROM "jobs" ORDER BY "jobs"."lifecycle_state" DESC

Job.group_by_lifecycle_state.to_sql
# => SELECT "jobs".* FROM "jobs" GROUP BY "jobs"."lifecycle_state"

# Validation:

job.lifecycle_state = nil
job.validate; job.errors[:lifecycle_state] # => ["can't be blank"]

job.lifecycle_state = "Invalid lifecycle_state"
job.validate; job.errors[:lifecycle_state]
# => ["must be one of Pending, Running, or Completed"]
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/pdobb/statusable.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. Or, run `rake` to run the tests plus linters as well as `yard` (to confirm proper YARD documentation practices). You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

### Testing

To test this gem:

```bash
rake
```

#### Linters

```bash
rubocop

reek

npx prettier . --check
npx prettier . --write
```

### Releases

To release a new version of this gem to RubyGems:

1. Update the version number in `version.rb`
2. Update the release date, etc. in `CHANGELOG.md`
3. Run `bundle` to update Gemfile.lock with the latest version info
4. Commit the changes. e.g. `Bump to vX.Y.Z`
5. Run `rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
