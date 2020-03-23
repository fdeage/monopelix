defmodule Monopoly.Case do
  defstruct [:id, :name, :count, :percent]

  alias __MODULE__

  def increment_count(%Case{} = c) do
    c |> Map.replace!(:count, c.count + 1)
  end
end
