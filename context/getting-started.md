# Getting Started

This guide explains how to use `async-actor` for asynchronous programming.

## Installation

Add the gem to your project:

~~~ bash
$ bundle add async-actor
~~~

## Core Concepts

`async-actor` provides a simple actor model where each actor runs in its own dedicated thread. The {ruby Async::Actor::Proxy} class creates a proxy interface that wraps any object and executes its methods asynchronously in a separate thread, using an event loop. When you call methods on the proxy, they are queued and processed by the internal actor thread, allowing for concurrent execution while maintaining thread isolation.

### Lifecycle Separation

One of the key benefits of actors is **lifecycle separation**. An actor can run for the entire lifetime of your process, independent of your application's async contexts. This means you can have long-running actors that persist even while your frontend usage of Async may start and stop multiple times.

For example, you might have a logging actor or database connection pool that runs continuously, while your web server or other components restart their async contexts as needed. The actor maintains its own thread and state, providing a stable foundation for your application's infrastructure. A common use case is in test suites where you need to cache access to background connection pools for performance reasons - you can create an actor that manages database connections or external service clients, allowing you to reuse these expensive resources between tests while each test runs in its own isolated async context.

## Usage

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

The above code looks deceptively simple, however `wikipedia.lookup` actually sends a message to the actor using a message queue. The proxy creates a dedicated thread that runs an async event loop, and the actor processes the message within this thread. This allows the actor to handle multiple messages concurrently within its own thread while keeping it isolated from the main thread. When the result is ready, the actor thread notifies the caller with the result.

Be aware that as the actor is running in a separate thread, your code will need to be thread-safe, including arguments that you pass to the actor. Any block you provide will also be executed in the actor's thread.

## Return Value Control

The actor proxy provides flexible control over how method calls return values through the `return_value` parameter. This parameter accepts three options:

### `:wait` (Default)

By default, method calls block until the result is available and return the actual result:

```ruby
wikipedia = Async::Actor.new(Wikipedia.new)

# This blocks until the lookup completes and returns the extract
result = wikipedia.lookup("Ruby_(programming_language)")
puts result  # Prints the Wikipedia extract
```

This is equivalent to:

```ruby
result = wikipedia.lookup("Ruby_(programming_language)", return_value: :wait)
```

### `:promise`

Returns an `Async::Promise` immediately, allowing you to wait for the result later:

```ruby
wikipedia = Async::Actor.new(Wikipedia.new)

# Returns immediately with a promise
promise = wikipedia.lookup("Ruby_(programming_language)", return_value: :promise)

# Do other work...
puts "Looking up information..."

# Wait for the result when needed
result = promise.wait
puts result
```

This is useful for fire-and-forget operations or when you want to start multiple operations concurrently:

```ruby
# Start multiple lookups concurrently
ruby_promise = wikipedia.lookup("Ruby_(programming_language)", return_value: :promise)
python_promise = wikipedia.lookup("Python_(programming_language)", return_value: :promise)
java_promise = wikipedia.lookup("Java_(programming_language)", return_value: :promise)

# Wait for all results
puts "Ruby: #{ruby_promise.wait}"
puts "Python: #{python_promise.wait}"
puts "Java: #{java_promise.wait}"
```

### `:ignore`

Executes the method but discards the result, returning `nil` immediately:

```ruby
logger = Async::Actor.new(Logger.new)

# Fire-and-forget logging - returns nil immediately
logger.info("Application started", return_value: :ignore)

# Continue with other work without waiting
puts "Continuing execution..."
```

This is perfect for logging, notifications, or other side-effect operations where you don't need the return value.

## Error Handling

Errors from actor method calls are propagated to the caller:

```ruby
wikipedia = Async::Actor.new(Wikipedia.new)

begin
  # This will raise if the network request fails
  result = wikipedia.lookup("NonexistentPage")
rescue => error
  puts "Lookup failed: #{error.message}"
end
```

With promises, errors are raised when you call `wait`:

```ruby
promise = wikipedia.lookup("NonexistentPage", return_value: :promise)

begin
  result = promise.wait
rescue => error
  puts "Lookup failed: #{error.message}"
end
```
