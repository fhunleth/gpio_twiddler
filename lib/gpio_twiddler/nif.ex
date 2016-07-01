defmodule GpioTwiddler.Nif do
  @compile {:autoload, false}
  @on_load {:init, 0}

  def init() do
    path = :filename.join(:code.priv_dir(:gpio_twiddler), 'twiddler_nif')
    case :erlang.load_nif(path, 0) do
      :ok -> :ok
      error -> {:error, error}
    end
  end

  def gpio_high(),             do: exit(:nif_library_not_loaded)
  def gpio_low(),              do: exit(:nif_library_not_loaded)

end
