#!/usr/bin/env elixir

defmodule Parser do

  defp to_float(s) do
    s |> String.trim |> String.to_float
  end
  defp to_integer(s) do
    s |> String.trim |> String.to_integer
  end
  defp string_list_to_tuple([time,value]) do
    {to_float(time), to_integer(value)}
  end

  defp csv_to_tuple(line) do
    line |> String.split(",") |> string_list_to_tuple
  end

  def load_csv(filename) do
    File.stream!(filename)
    |> Stream.drop(16) # Drop the header row and initial data points to allow for some warmup
    |> Enum.map(&csv_to_tuple/1)
  end
end

defmodule Analyzer do
  # Convert list of {absolute_time, value} pairs
  # to {delta_time, value} pairs.
  def times_to_deltas(tvtuples) do
    times_to_deltas(tvtuples, [])
  end
  defp times_to_deltas([{_,_}], result) do
    Enum.reverse(result)
  end
  defp times_to_deltas([{abs_time, value}, {next_abs_time, next_value} | rest], result) do
    times_to_deltas([{next_abs_time, next_value} | rest],
      [{next_abs_time - abs_time, value} | result])
  end

  def split_out_hiccups(times, threshold) do
    case Enum.group_by(times, &(&1 > threshold)) do
      %{false => n, true => h} -> {n, h}
      %{false => n} -> {n, []}
      %{true => h} -> {[], h}
      %{} -> {[], []}
    end
  end

  def mean(values) do
    Enum.reduce(values, &+/2) / Enum.count(values)
  end
  def median(values) do
    sorted = Enum.sort(values)
    n = Enum.count(sorted)
    case rem(n, 2) do
      0 -> (Enum.at(sorted, div(n, 2) - 1) + Enum.at(sorted, div(n, 2))) / 2
      1 -> Enum.at(sorted, div(n, 2))
    end
  end
  def stdev(values) do
    m = mean(values)
    sum = Enum.reduce(values, 0, &(&2 + (&1 - m) * (&1 - m)))
    n = Enum.count(values)
    :math.sqrt(sum / n)
  end
  def max([]), do: 0
  def max(values) do
    Enum.reduce(values, &max/2)
  end
  def min([]), do: 0
  def min(values) do
    Enum.reduce(values, &min/2)
  end
end

if Enum.empty?(System.argv()) do
  IO.puts "Pass a .csv file to analyze"
  System.halt
end

filename = System.argv() |> Enum.at(0)

p = filename
  |> Parser.load_csv
  |> Analyzer.times_to_deltas

%{1 => ontime_tuples, 0 => offtime_tuples} =
  Enum.group_by(p, fn({_, value}) -> value end)

{ontimes, _} = Enum.unzip(ontime_tuples)
{offtimes, _} = Enum.unzip(offtime_tuples)
{alltimes, _} = Enum.unzip(p)

mean = Analyzer.mean(alltimes)
ontime_median = Analyzer.median(ontimes)
offtime_median = Analyzer.median(offtimes)

# Split out the outliers
{ontime_normal, ontime_hiccups} =
  Analyzer.split_out_hiccups(ontimes, 10 * ontime_median)

{offtime_normal, offtime_hiccups} =
  Analyzer.split_out_hiccups(offtimes, 10 * offtime_median)

all_hiccups = ontime_hiccups ++ offtime_hiccups
longest = Analyzer.max(ontimes ++ offtimes)

# Don't run the outliers through the mean and stdev since
# they're often orders of magnitude away from the 99% case
ontime_mean = Analyzer.mean(ontime_normal)
ontime_stdev = Analyzer.stdev(ontime_normal)
offtime_mean = Analyzer.mean(offtime_normal)
offtime_stdev = Analyzer.stdev(offtime_normal)

IO.puts "#{filename},#{Enum.count(all_hiccups)},#{longest},#{ontime_mean},#{ontime_stdev},#{ontime_median},#{offtime_mean},#{offtime_stdev},#{offtime_median}"

if false do
IO.puts "# hiccups: #{Enum.count(all_hiccups)}"
IO.puts "Longest hiccup: #{longest}"
IO.puts "Overall mean is #{mean}"
IO.puts "The mean on time is #{ontime_mean}"
IO.puts "The stdev on time is #{ontime_stdev}"
IO.puts "The mean off time is #{offtime_mean}"
IO.puts "The stdev off time is #{offtime_stdev}"
IO.puts "The median on time is #{ontime_median}"
IO.puts "The median off time is #{offtime_median}"
end
