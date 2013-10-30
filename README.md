# Faye::RedisDelayed

Delayed Redis engine backend for Faye

## Installation

Add this line to your application's Gemfile:

    gem 'faye-redis-delayed'

## Usage

Pass in the engine and any settings you need when setting up your Faye server.

```rb
require 'faye'
require 'faye/redis'

bayeux = Faye::RackAdapter.new(
  :mount   => '/',
  :timeout => 25,
  :engine  => {
    :type  => Faye::RedisDelayed,
    # more options
  }
)
```

Full list of options see [faye-redis](https://github.com/faye/faye-redis-ruby)

Additional options:

* <b>`:expire`</b> - expire time in seconds, default 60

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
