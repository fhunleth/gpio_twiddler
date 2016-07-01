defmodule GpioTwiddler.C do

  def sysfs(count) do
    GpioTwiddler.Elixir.export_pin()

    System.cmd(path(), ["-s", "-n", "#{count}"])
  end

  def mmap(count) do
    GpioTwiddler.Elixir.export_pin()

    System.cmd(path(), ["-n", "#{count}"])
  end

  defp path() do
    :code.priv_dir(:gpio_twiddler) |> to_string |> Path.join("twiddler_c")
  end
end
