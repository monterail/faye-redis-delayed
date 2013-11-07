# Faye::RedisDelayed

Delayed Redis engine backend for [Faye](http://faye.jcoglan.com/) ruby server.
It allows delivey of messages sent **before** client connects to the channel.

Turn this timeline:

![Regular faye](https://monterail-share.s3.amazonaws.com/public/codetunes/2013-02-11-robust-dashboard-application-with-faye/tymon-faye-timeline1.png)

into this

![RedisDelayed faye](https://monterail-share.s3.amazonaws.com/public/codetunes/2013-02-11-robust-dashboard-application-with-faye/tymon-faye-timeline2.png)


Read the [real world story behind it](http://codetunes.com/2013/robust-dashboard-application-with-faye/).

## Installation

Add this line to your application's Gemfile:

    gem 'faye-redis-delayed'

## Usage

Pass in the engine and any settings you need when setting up your Faye server.

```rb
# faye config.ru
require 'faye'
require 'faye/redis'

bayeux = Faye::RackAdapter.new(
  :mount   => '/',
  :timeout => 25,
  :engine  => {
    :type   => Faye::RedisDelayed,  # set the engine type
    :expire => 30                   # not delivered message will wait for 30 seconds
    # other Faye::Redis engine options
  }
)
```

Additional options provided by `Faye::DelayedRedis` engine:

* `:expire` - expire time in seconds, defaults to 60

For full list of `Faye::Redis` engine options see [faye-redis](https://github.com/faye/faye-redis-ruby) engine.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
