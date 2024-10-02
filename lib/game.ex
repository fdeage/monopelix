defmodule Monopelix.Game do
  alias Monopelix.{Board, Player, Logger}

  def play_turn(3, player, board) do
    Logger.print("Three doubles in a row")
    Player.put_in_jail(player)
    Board.increase_case_count(board, 10)
  end

  def play_turn(double_count, player, board) do
    dice1 = Board.roll_dice()
    dice2 = Board.roll_dice()

    Logger.print("Die: #{dice1} + #{dice2}", dice1 + dice2)

    Player.update_jail_status(player)
    Player.move_by(player, dice1 + dice2)

    Board.increase_case_count(board, Player.get(player, :case_id))

    action =
      case Player.get(player, :case_id) do
        0 -> %{type: :money, opt: 40_000}
        2 -> Board.draw_community(board)
        4 -> %{type: :money, opt: -20_000}
        7 -> Board.draw_chance(board)
        17 -> Board.draw_community(board)
        20 -> %{type: :free_park, opt: nil}
        22 -> Board.draw_chance(board)
        30 -> %{type: :move, opt: 10}
        33 -> Board.draw_community(board)
        36 -> Board.draw_chance(board)
        38 -> %{type: :money, opt: -10_000}
        _ -> %{type: nil, opt: nil}
      end

    if action.type, do: Logger.print("Action: ", action.type)

    case action.type do
      :money ->
        Player.change_money_by(player, action.opt)

      :repair ->
        Player.change_money_by(player, action.opt.maisons + action.opt.hotels)

      :move ->
        Player.move_to(player, action.opt)
        Board.increase_case_count(board, Player.get(player, :case_id))

      :move_relative ->
        Player.move_by(player, action.opt)
        Board.increase_case_count(board, Player.get(player, :case_id))

      :move_no_20_000 ->
        Player.move_to(player, action.opt, false)
        Board.increase_case_count(board, Player.get(player, :case_id))

      :free_park ->
        Player.change_money_by(player, Board.get_free_park_bounty(board))
        Board.empty_free_park_bounty(board)

      :fine_or_redraw ->
        nil

      :out_of_jail ->
        Player.add_out_of_jail_card(player)

      :birthday ->
        nil

      nil ->
        nil
    end

    if dice1 === dice2 do
      Logger.print("Double #{dice1}")
      play_turn(double_count + 1, player, board)
    end
  end

  def init(name: player_name) when is_binary(player_name) do
    {:ok, player} = Player.start_link(name: player_name)
    {:ok, board} = Board.start_link()

    {player, board}
  end

  def repeat(0, _player, _board), do: {:ok, :game_over}

  def repeat(count, player, board) do
    double_count = 0

    play_turn(double_count, player, board)
    Player.increment_turn_count(player)

    if Application.get_env(:monopoly, :log_level) === :extra do
      Player.to_string(player)
      Logger.print("\n")
    end

    repeat(count - 1, player, board)
  end
end
