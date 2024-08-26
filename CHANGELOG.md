## [Unreleased]
- Can now check if any of an array of statuses matches when using #status?

```ruby
my_object.status # => "Ready"
my_object.status?("Ready") # => true
my_object.status?(["Ready", "Not Ready"]) # => true
my_object.status?(["Not Ready", "Also Not Ready"]) # => false
```

### 0.2.0.pre - 2018-08-15
- Internal improvements.

### 0.1.0.pre - 2018-08-14
- Initial release!
