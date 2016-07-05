defmodule GpioTwiddler.BusyWorker do
  use GenServer

  @moduledoc """
  This module creates a little periodic work so that the Erlang VM isn't
  completely idle.
  """

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  def stop(pid) do
    GenServer.stop(pid)
  end

  def init(_) do
    :timer.send_interval(1, :work_more)
    {:ok, 0}
  end

  def handle_info(:work_more, state) do
    {:noreply, state}
  end
end
