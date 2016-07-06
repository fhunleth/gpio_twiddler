defmodule GpioTwiddler do

  @doc """
  Currently, this just sets the current thread to high priority.
  """
  def set_high_priority() do
    Process.flag(:priority, :high)
  end
  def set_normal_priority() do
    Process.flag(:priority, :normal)
  end

end
