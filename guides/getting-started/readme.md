# Getting Started

This guide explains how to use `async-actor` for asynchronous programming.

## Installation

Add the gem to your project:

~~~ bash
$ bundle add async-actor
~~~

## Core Concepts

`async-async` provides a simple actor model for asynchronous programming. It is built on top of [async](https://github.com/socketry/async). Each method (message) sent to an actor is processed in a separate task, which is scheduled on the event loop. This allows the actor to process messages concurrently. The main abstraction is the {ruby Async::Actor::Proxy} class, which can be used to create new actors.

## Basic Usage

Any existing object can be wrapped into an actor:

```ruby
require "async/actor"

require "cgi"
require "net/http"
require "json"

class Wikipedia
	def summary_url(title)
		URI "https://en.wikipedia.org/api/rest_v1/page/summary/#{CGI.escape title}"
	end
	
	def lookup(title)
		JSON.parse(Net::HTTP.get(summary_url(title))).fetch("extract")
	end
end

wikipedia = Async::Actor.new(Wikipedia.new)

puts wikipedia.lookup("Ruby_(programming_language)")
```

The above code looks deceptively simple, however `wikipedia.lookup` actually sends a message to the actor using a message queue. The actor then processes the message in a separate task, which is scheduled on the event loop. This allows the actor to process messages concurrently. When the result is ready, the actor notifies the caller with the result.

Be aware that as the actor is running in a separate thread, your code will need to be thread-safe, including arguments that you pass to the actor. Any block you provide will also be executed in the actor's thread.
