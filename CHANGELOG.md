## [Unreleased]

### 0.5.0 - 2025-1-4

- Update minimum Ruby version from 3.1 -> 3.2

### 0.4.1 - 2024-11-22

- Fix internal much_stub test/support reference. No external-facing change.

### 0.4.0 - 2024-11-21

- Update minimum Ruby version from 2.7 -> 3.1
- Document the inner workings of `has_status` with YARD-style comments.
- Can now check if any of an array of statuses doesn't match when using #not_status?

```ruby
my_object.status # => "Ready"
my_object.not_status?("Ready") # => false
my_object.not_status?("Not Ready") # => true
my_object.not_status?(["Ready", "Not Ready"]) # => false
my_object.not_status?(["Not Ready", "Also Not Ready"]) # => true
```

### 0.3.0.pre - 2024-08-26

- Can now check if any of an array of statuses matches when using #status?

```ruby
my_object.status # => "Ready"
my_object.status?("Ready") # => true
my_object.status?("Not Ready") # => false
my_object.status?(["Ready", "Not Ready"]) # => true
my_object.status?(["Not Ready", "Also Not Ready"]) # => false
```

### 0.2.0.pre - 2024-08-15

- Internal improvements.

### 0.1.0.pre - 2024-08-14

- Initial release!
