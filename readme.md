# Async::Actor

Provides a simple actor model for asynchronous programming.

[![Development Status](https://github.com/socketry/async-actor/workflows/Test/badge.svg)](https://github.com/socketry/async-actor/actions?workflow=Test)

## Motivation

Async provides a strongly opinionated model for asynchronous programming while trying to be transparent to the user. However, in cases where the scope (life time) of the asynchronous work does not align with the scope of the application code, it can be tricky to combine the two. For example, you may want to introduce a background message queue or job processing system, which takes advantage of async, without changing the execution model of the calling code. The jobs or message queue will almost certainly outlive the scope of the calling code, so it can be advantageous to separate the two.

This is where `Async::Actor` comes in. It provides a simple actor model, which uses an event driven message queue running inside an Async event loop. This separates the life cycle of the calling code and the actor and can be used to introduce asynchronous processing into existing code with minimal changes.

## Usage

Please see the [project documentation](https://socketry.github.io/async-actor/) for more details.

## Contributing

We welcome contributions to this project.

1.  Fork it.
2.  Create your feature branch (`git checkout -b my-new-feature`).
3.  Commit your changes (`git commit -am 'Add some feature'`).
4.  Push to the branch (`git push origin my-new-feature`).
5.  Create new Pull Request.

### Developer Certificate of Origin

This project uses the [Developer Certificate of Origin](https://developercertificate.org/). All contributors to this project must agree to this document to have their contributions accepted.

### Contributor Covenant

This project is governed by [Contributor Covenant](https://www.contributor-covenant.org/). All contributors and participants agree to abide by its terms.
