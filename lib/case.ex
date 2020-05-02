defmodule Monopoly.Case do
  defstruct [:name, :count, :percent]

  alias __MODULE__

  def start_link(opts) do
    Agent.start_link(fn -> %Case{name: opts[:name], count: 0, percent: 0} end)
  end

  def get(c, key) do
    Agent.get(c, fn state -> Map.get(state, key) end)
  end

  def set(c, key, value) do
    Agent.update(c, fn state -> Map.put(state, key, value) end)
  end

  def name(c), do: get(c, :name)
  def count(c), do: get(c, :count)
  def percent(c), do: get(c, :percent)

  def increment_count(c) do
    set(c, :count, get(c, :count) + 1)
  end
end
