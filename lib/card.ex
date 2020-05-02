defmodule Monopoly.Card do
  defstruct [:name, :type, :opt]

  alias __MODULE__

  def start_link(opts \\ []) do
    Agent.start_link(fn ->
      %Card{
        name: opts[:name],
        type: opts[:type],
        opt: opts[:opt]
      }
    end)
  end

  def get(card) do
    Agent.get(card, fn state -> state end)
  end

  def get(card, key) do
    Agent.get(card, fn state -> Map.get(state, key) end)
  end
end
