defmodule Monopoly.Player do
  defstruct [:name, :status, :case_id, :money, :out_of_jail_card, :turn, :die_cast, :move]

  alias Monopoly.Logger
  alias __MODULE__

  def move_by(%Player{} = player, die, pass_go_bonus? \\ true) do
    new_case_id = Integer.mod(player.case_id + die, 40)
    Logger.print("Move player #{player.name} to", new_case_id)

    player =
      if new_case_id < player.case_id and pass_go_bonus? do
        Player.change_money_by(player, 20_000)
      else
        player
      end

    %Player{player | move: player.move + 1, case_id: new_case_id}
  end

  def move_to(%Player{} = player, case_id, pass_go_bonus? \\ true) do
    Logger.print("Move player #{player.name} to", case_id)

    player =
      if case_id < player.case_id and pass_go_bonus? do
        Player.change_money_by(player, 20_000)
      else
        player
      end

    %Player{player | move: player.move + 1, case_id: case_id}
  end

  def put_in_jail(%Player{} = player) do
    Logger.print("Move player #{player.name} to jail", nil)
    %Player{player | case_id: 10, status: :in_jail_3, move: player.move + 1}
  end

  def update_jail_status(%Player{} = player) do
    case player.status do
      :free -> player
      :in_jail_3 -> %Player{player | case_id: 10, status: :in_jail_2}
      :in_jail_2 -> %Player{player | case_id: 10, status: :in_jail_1}
      :in_jail_1 -> get_out_of_jail(player)
    end
  end

  def get_out_of_jail(%Player{} = player) do
    Logger.print("Get player #{player.name} out of jail", nil)
    %Player{player | case_id: 10, status: :free}
  end

  def change_money_by(%Player{} = player, amount) do
    Logger.print("Change player #{player.name}'s' money by ", amount)

    %Player{player | money: player.money + amount}
  end

  def add_out_of_jail_card(%Player{} = player) do
    %Player{player | out_of_jail_card: player.out_of_jail_card + 1}
  end

  def use_out_of_jail_card(%Player{} = player) do
    if player.out_of_jail_card > 0 do
      %Player{player | out_of_jail_card: player.out_of_jail_card - 1, status: :free}
    end
  end

  def print(%Player{} = player) do
    Logger.print(player)
  end

  def increase_turn_count(%Player{} = player) do
    %Player{player | turn: player.turn + 1}
  end

  def increase_die_cast_count(%Player{} = player) do
    %Player{player | die_cast: player.die_cast + 1}
  end
end
