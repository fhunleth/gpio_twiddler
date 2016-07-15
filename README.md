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
things go. Old 16 MHz 8-bit microcontrollers are better suited to some tasks.

## Naming

Data for each experiment is named with the following convention:

`kernel_erlang_work_test.csv`

`kernel` is one of the following:
  * `rt` - Linux kernel compiled with CONFIG_PREEMPT_RT_FULL, HZ=250
  * `ll` - Linux kernel compiled with CONFIG_PREEMPT_LL (low-latency desktop),
    HZ=250

`erlang` is one of the following:
  * `smp` - Erlang compiled with SMP enabled
  * `nosmp` - Erlang compiled with SMP disabled

`work` is one of the following:
  * `idle` - Nothing else is going on. The twiddler has 100% of the CPU.
  * `timer` - A `GenServer` gets a timer event sent to it every 1 ms.
  * `stress` - The C `stress` program is started and instructed to max out the
    CPU.
  * `estress` - An Elixir process is started that computes square roots
    constantly (similar to `stress`, but in Elixir)
  * `estress2` - Same as `estress`, but the twiddler runs at the Erlang `high`
    priority level. `GpioTwiddler.Stress` runs at the `normal` priority level.

`test` is one of the following:
  * `ale` - `GpioTwiddler.Ale.twiddle`
  * `elixirwrite` - Use sysfs via `IO.write/2` in normal mode.`GpioTwiddler.Elixir.twiddle(20000, [], :write)`
  * `elixirbinwrite` - Use sysfs via `IO.binwrite/2` in normal mode.`GpioTwiddler.Elixir.twiddle(20000, [], :binwrite)`
  * `elixirrawbinwrite` - Use sysfs via `IO.binwrite/2` in raw mode.`GpioTwiddler.Elixir.twiddle(20000, [:raw], :binwrite)`
  * `erlangwrite` - Use sysfs via `:file.write/2` in normal mode.`GpioTwiddler.Erlang.twiddle(20000)`
  * `erlangrawwrite` - Use sysfs via `:file.write/2` in raw mode.`GpioTwiddler.Erlang.twiddle_raw(20000)`
  * `sysfs` - Use sysfs in C. `GpioTwiddler.C.sysfs(20000)`
  * `mmap` - Use mmap in C. `GpioTwiddler.C.mmap(20000)`
  * `nif` - Use mmap via a NIF. `GpioTwidder.Nif.twiddle(20000)`
  * `nifenum` - Use mmap via a NIF, but in Elixir iterate using `Enum.each`. `GpioTwiddler.Nif.twiddle_enum(20000)`

The filename `arduino-uno-r3` is for captures using an Arduino Uno R3 running
the code in `arduino/twiddle_fast`.

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
