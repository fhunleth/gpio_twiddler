defmodule GpioTwiddler.Ale do

  def twiddle(count) do
    {:ok, pid} = Gpio.start_link(60, :output)
    twiddle_again(pid, count)
    GenServer.stop(pid)
  end

  defp twiddle_again(_gpio_pid, 0), do: :ok
  defp twiddle_again(gpio_pid, count) do
    Gpio.write(gpio_pid, 1)
    Gpio.write(gpio_pid, 0)
    twiddle_again(gpio_pid, count - 1)
  end
end
