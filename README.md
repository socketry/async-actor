# Async::Actor

Implements the actor pattern using an asynchronous message bus. Local messaging is handled directly while distributed messaging uses redis. Built on top of [async] and [async-redis].

[![Build Status](https://secure.travis-ci.org/socketry/async-actor.svg)](https://travis-ci.org/socketry/async-actor)
[![Code Climate](https://codeclimate.com/github/socketry/async-actor.svg)](https://codeclimate.com/github/socketry/async-actor)
[![Coverage Status](https://coveralls.io/repos/socketry/async-actor/badge.svg)](https://coveralls.io/r/socketry/async-actor)

[async]: https://github.com/socketry/async
[async-redis]: https://github.com/socketry/async-redis

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'async-actor'
```

And then execute:

	$ bundle

Or install it yourself as:

	$ gem install async-actor

## Usage

### What is a bus?

A bus is a shared address space for multiple actors to co-exist. A bus needs to provide communication facilities so that actors can interact with each other. There are other properties of the bus which may affect behaviour: persistence, reliability, durability, etc.

### What is an actor?

Any non-primative Ruby object can be an actor. Primitive objects such as integers, strings, arrays, hashs, are serialized and sent over the wire by copy. Any other object is registered into the bus and a token is sent across the wire.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

Released under the MIT license.

Copyright, 2015, by [Samuel G. D. Williams](https://www.codeotaku.com/samuel-williams).

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
