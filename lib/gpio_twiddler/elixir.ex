defmodule GpioTwiddler.Elixir do

  def export_pin() do
    if ! File.exists?("/sys/class/gpio/gpio60") do
      File.write!("/sys/class/gpio/export", "60")
      File.write!("/sys/class/gpio/gpio60/direction", "out")
    end
  end

  def twiddle(count) do
    export_pin()

    File.open("/sys/class/gpio/gpio60/value", [:write],
              fn(file) -> twiddle_again(file, count) end)
  end

  defp twiddle_again(_file, 0), do: :ok
  defp twiddle_again(file, count) do
    IO.write(file, "1\n")
    IO.write(file, "0\n")
    twiddle_again(file, count - 1)
  end

end
