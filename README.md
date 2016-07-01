# GpioTwiddler

This is a simple Nerves application for the BeagleBone Black that is used to
measure the performance of various ways of toggling a GPIO. This is useful to
demonstrate tradeoffs and set expectations for performance in real
applications.

Please, please realize that many of the options compared are not identical.
While they all toggle a GPIO, some are platform dependent, require the Erlang
VM to run as root, run the risk of crashing the VM, can't support other GPIO
features (like notification when an input changes), or require C coding.
TL;DR: The more of these issues or limitations you can put up with, the faster
things go. Even slow microcontrollers can be better than 1 GHz processors
at these low level tasks if hard real-time operation or high performance are
required.

## Replicating the results

Assuming that you have a BeagleBone Black, run through the [Nerves installation guide](https://hexdocs.pm/nerves/installation.html) to set up your system.

Build an SDCard image by running:
```
mix deps.get
mix firmware
```

Then insert a MicroSD card into a reader on your computer and run `mix firmware.burn`.
After burning the MicroSD card, place it in the BBB and boot. You'll be presented
with an Elixir shell prompt on the serial port. All tests toggle Pin 12 on
connector P9 on the BBB. Hook up a logic analyzer to measure this. See the
individual modules for tests, but you can try one or more of the following:

* `GpioTwiddler.Ale.twiddle 10000` - toggle using [elixir_ale](https://hex.pm/packages/elixir_ale)
* `GpioTwiddler.Elixir.twiddle 10000` - toggle using pure Elixir code
* `GpioTwiddler.Erlang.twiddle 10000` - toggle using Erlang standard library calls directly
* `GpioTwiddler.Nif.twiddle 10000` - toggle using a [Nif](http://erlang.org/doc/man/erl_nif.html)
* `GpioTwiddler.C.sysfs 10000` - toggle in C using the [Linux sysfs](https://www.kernel.org/doc/Documentation/gpio/sysfs.txt) interface
* `GpioTwiddler.C.mmap 10000` - toggle in C using [mmap](https://en.wikipedia.org/wiki/Mmap)
