defmodule Monopoly.Player do
  @enforce_keys [:name, :status, :case_id, :money, :out_of_jail_card, :turn, :die_cast, :move]
  defstruct [:name, :status, :case_id, :money, :out_of_jail_card, :turn, :die_cast, :move]

  alias Monopoly.Logger
  alias __MODULE__

  def start_link(name: name) do
    Agent.start_link(fn ->
      %Player{
        turn: 0,
        move: 0,
        die_cast: 0,
        name: name,
        status: :free,
        case_id: 0,
        money: 150_000,
        out_of_jail_card: 0
      }
    end)
  end

  def move_by(p, die, pass_go_bonus? \\ true) do
    new_case_id = Integer.mod(get(p, :case_id) + die, 40)
    Logger.print("Move player #{get(p, :name)} to", new_case_id)

    if new_case_id < get(p, :case_id) and pass_go_bonus? do
      change_money_by(p, 20_000)
    end

    increment_move_count(p)
    set(p, :case_id, new_case_id)
  end

  def move_to(p, case_id, pass_go_bonus? \\ true) do
    Logger.print("Move player #{get(p, :name)} to", case_id)

    if case_id < get(p, :case_id) and pass_go_bonus? do
      change_money_by(p, 20_000)
    end

    increment_move_count(p)
    set(p, :case_id, case_id)
  end

  def put_in_jail(p) do
    Logger.print("Move player #{get(p, :name)} to jail", nil)
    set(p, :case_id, 10)
    set(p, :status, :in_jail_3)
    increment_move_count(p)
  end

  def update_jail_status(p) do
    case get(p, :status) do
      :free -> nil
      :in_jail_3 -> set(p, :status, :in_jail_2)
      :in_jail_2 -> set(p, :status, :in_jail_1)
      :in_jail_1 -> get_out_of_jail(p)
    end
  end

  def get_out_of_jail(p) do
    Logger.print("Get player #{get(p, :name)} out of jail", nil)
    set(p, :status, :free)
  end

  def change_money_by(p, amount) do
    Logger.print("Change player #{get(p, :name)}'s' money by ", amount)
    set(p, :money, get(p, :money) + amount)
  end

  def add_out_of_jail_card(p) do
    set(p, :out_of_jail_card, get(p, :out_of_jail_card) + 1)
  end

  def use_out_of_jail_card(p) do
    if get(p, :out_of_jail_card) > 0 do
      set(p, :out_of_jail_card, get(p, :out_of_jail_card) - 1)
      set(p, :status, :free)
    end
  end

  def increment_turn_count(p) do
    set(p, :turn, get(p, :turn) + 1)
  end

  def increment_move_count(p) do
    set(p, :move, get(p, :move) + 1)
  end

  def to_string(p) do
    """
    (name: #{get(p, :name)}, case: #{get(p, :case_id)}, money: #{get(p, :money)})
    """
  end

  def get(p, key) do
    Agent.get(p, fn state -> Map.get(state, key) end)
  end

  def set(p, key, value) do
    Agent.update(p, fn state -> Map.put(state, key, value) end)
  end
end
