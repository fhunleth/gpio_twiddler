defmodule GpioTwiddler.Stress do

  @doc """
  Start the stress program up
  """
  def start_c() do
    spawn(fn -> System.cmd("stress", ["--cpu", "1"]) end)
  end

  @doc """
  Start an Elixir version of stress going
  """
  def start_elixir() do
    spawn(&sqrt_forever/0)
  end

  defp sqrt_forever() do
    _ = :math.sqrt(:rand.uniform())
    sqrt_forever()
  end

end
