## [Unreleased]

- Document the inner workings of `has_status` with YARD-style comments.
- Can now check if any of an array of statuses doesn't match when using #not_status?

```ruby
my_object.status # => "Ready"
my_object.not_status?("Ready") # => false
my_object.not_status?("Not Ready") # => true
my_object.not_status?(["Ready", "Not Ready"]) # => false
my_object.not_status?(["Not Ready", "Also Not Ready"]) # => true
```


### 0.3.0.pre - 2018-08-26
- Can now check if any of an array of statuses matches when using #status?

```ruby
my_object.status # => "Ready"
my_object.status?("Ready") # => true
my_object.status?("Not Ready") # => false
my_object.status?(["Ready", "Not Ready"]) # => true
my_object.status?(["Not Ready", "Also Not Ready"]) # => false
```

### 0.2.0.pre - 2018-08-15
- Internal improvements.

### 0.1.0.pre - 2018-08-14
- Initial release!
