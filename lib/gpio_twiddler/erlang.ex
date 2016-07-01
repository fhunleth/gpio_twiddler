defmodule GpioTwiddler.Erlang do

  def twiddle(count) do
    GpioTwiddler.Elixir.export_pin()

    {:ok, fd} = :file.open('/sys/class/gpio/gpio60/value', [:write])
    twiddle_again(fd, count)
    :file.close(fd)
  end

  def twiddle_raw(count) do
    GpioTwiddler.Elixir.export_pin()

    {:ok, fd} = :file.open('/sys/class/gpio/gpio60/value', [:write, :raw])
    twiddle_again(fd, count)
    :file.close(fd)
  end

  defp twiddle_again(_file, 0), do: :ok
  defp twiddle_again(file, count) do
    :file.write(file, "1\n")
    :file.write(file, "0\n")
    twiddle_again(file, count - 1)
  end
end
