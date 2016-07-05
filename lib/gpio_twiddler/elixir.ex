defmodule GpioTwiddler.Elixir do

  @doc """
  Twiddle the GPIO. Example calls:

     twiddle(20000, [], :write)  # Open in normal mode, call IO.write/2
     twiddle(20000, [], :binwrite)  # Open in normal mode, call IO.binwrite/2
     twiddle(20000, [:raw], :binwrite)  # Open in raw mode, call IO.binwrite/2
     twiddle(20000, [:raw], :binwrite_list)  # Open in raw mode, call IO.binwrite/2, pass list
  """
  def twiddle(count, options \\ [], twiddler_type \\ :binwrite) do
    export_pin()

    twiddler = get_twiddler(twiddler_type)
    File.open("/sys/class/gpio/gpio60/value", [:write] ++ options,
              &(twiddler.(&1, count)))
  end

  defp get_twiddler(:write), do: &twiddle_write_again/2
  defp get_twiddler(:binwrite), do: &twiddle_binwrite_again/2
  defp get_twiddler(:binwrite_list), do: &twiddle_binwrite_list_again/2

  defp twiddle_binwrite_again(_file, 0), do: :ok
  defp twiddle_binwrite_again(file, count) do
    IO.binwrite(file, "1\n")
    IO.binwrite(file, "0\n")
    twiddle_binwrite_again(file, count - 1)
  end

  defp twiddle_binwrite_list_again(_file, 0), do: :ok
  defp twiddle_binwrite_list_again(file, count) do
    IO.binwrite(file, '1\n')
    IO.binwrite(file, '0\n')
    twiddle_binwrite_again(file, count - 1)
  end

  defp twiddle_write_again(_file, 0), do: :ok
  defp twiddle_write_again(file, count) do
    IO.write(file, "1\n")
    IO.write(file, "0\n")
    twiddle_write_again(file, count - 1)
  end

  def export_pin() do
    if ! File.exists?("/sys/class/gpio/gpio60") do
      File.write!("/sys/class/gpio/export", "60")
      File.write!("/sys/class/gpio/gpio60/direction", "out")
    end
  end
end
