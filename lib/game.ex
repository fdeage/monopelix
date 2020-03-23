defmodule Monopoly.Game do
  alias Monopoly.{Card, Board, Player, Logger}

  defp draw_community do
    comm_cards = [
      %Card{name: "Héritez", type: :money, opt: 10_000},
      %Card{name: "Deuxième prix de beauté", type: :money, opt: 1_000},
      %Card{name: "Allez en prison", type: :move_no_20_000, opt: 10},
      %Card{name: "Police d'Assurance", type: :money, opt: -5_000},
      %Card{name: "Note du médecin", type: :money, opt: -5_000},
      %Card{name: "Vente de votre stock", type: :money, opt: -5_000},
      %Card{name: "Libéré de prison", type: :out_of_jail, opt: nil},
      %Card{name: "Intérêt emprunt à 7%", type: :money, opt: 2_500},
      %Card{name: "Payez à l'hôpital", type: :money, opt: -10_000},
      %Card{name: "Anniversaire", type: :birthday, opt: nil},
      %Card{name: "Avancez case départ", type: :move, opt: 0},
      %Card{name: "Revenu annuel", type: :money, opt: 10_000},
      %Card{name: "Amende ou carte chance", type: :fine_or_redraw, opt: nil},
      %Card{name: "Erreur de la banque", type: :money, opt: 20_000},
      %Card{name: "Retournez à Belleville", type: :move_no_20_000, opt: 1},
      %Card{name: "Contributions vous remboursent", type: :money, opt: 2_000}
    ]

    rand =
      comm_cards
      |> length()
      |> :rand.uniform()

    comm = comm_cards |> Enum.at(rand - 1)
    Logger.print("Community card", comm.name)

    comm
  end

  defp draw_chance do
    chance_cards = [
      %Card{name: "Ivresse", type: :money, opt: -2_000},
      %Card{name: "Allez à Henri-Martin", type: :move, opt: 23},
      %Card{name: "Mots croisés", type: :money, opt: 10_000},
      %Card{name: "Allez en prison", type: :move_no_20_000, opt: 10},
      %Card{name: "Allez à GDL", type: :move, opt: 15},
      %Card{name: "Dividende", type: :money, opt: 5_000},
      %Card{name: "Immeuble et prêts", type: :money, opt: 15_000},
      %Card{name: "Réparations", type: :repair, opt: %{maisons: -2_500, hotels: -10_000}},
      %Card{name: "Avancez case départ", type: :move, opt: 0},
      %Card{name: "Reculez de trois cases", type: :move_relative, opt: -3},
      %Card{name: "Amende pour excès de vitesse", type: :money, opt: -1_500},
      %Card{name: "Payez frais de scolarité", type: :money, opt: -15_000},
      %Card{name: "Allez rue de la Paix", type: :move, opt: 39},
      %Card{name: "Réparations", type: :repair, opt: %{maisons: -4_000, hotels: -11_500}},
      %Card{name: "Allez bd de la Villette", type: :move, opt: 11},
      %Card{name: "Libéré de prison", type: :out_of_jail, opt: nil}
    ]

    rand =
      chance_cards
      |> length()
      |> :rand.uniform()

    chance = chance_cards |> Enum.at(rand - 1)
    Logger.print("Chance card", chance.name)

    chance
  end

  defp draw_dice do
    :rand.uniform(6)
  end

  def play_turn(3, %Player{} = player, %Board{} = board) do
    Logger.print("Three doubles in a row")
    player = Player.put_in_jail(player)
    board = Board.increase_case_count(board, 10)

    {player, board}
  end

  def play_turn(double_count, %Player{} = player, %Board{} = board) do
    dice1 = draw_dice()
    dice2 = draw_dice()

    Logger.print("Die: #{dice1} + #{dice2}", dice1 + dice2)

    player =
      player
      |> Player.update_jail_status()
      |> Player.move_by(dice1 + dice2)

    board = Board.increase_case_count(board, player.case_id)

    action =
      case player.case_id do
        0 -> %{type: :money, opt: 40_000}
        2 -> draw_community()
        4 -> %{type: :money, opt: -20_000}
        7 -> draw_chance()
        17 -> draw_community()
        20 -> %{type: :free_park, opt: nil}
        22 -> draw_chance()
        30 -> %{type: :move, opt: 10}
        33 -> draw_community()
        36 -> draw_chance()
        38 -> %{type: :money, opt: -10_000}
        _ -> %{type: nil, opt: nil}
      end

    if action.type, do: Logger.print("Action: ", action.type)

    {player, board} =
      case action.type do
        :money ->
          {Player.change_money_by(player, action.opt), board}

        :repair ->
          {Player.change_money_by(player, action.opt.maisons + action.opt.hotels), board}

        :move ->
          player =
            player
            |> Player.move_to(action.opt)

          board =
            board
            |> Board.increase_case_count(player.case_id)

          {player, board}

        :move_relative ->
          {Player.move_by(player, action.opt), Board.increase_case_count(board, player.case_id)}

        :move_no_20_000 ->
          player = Player.move_to(player, action.opt, false)
          board = Board.increase_case_count(board, player.case_id)
          {player, board}

        :free_park ->
          player = Player.change_money_by(player, board.free_park)
          board = Board.empty_free_park_bounty(board)
          {player, board}

        :fine_or_redraw ->
          {player, board}

        :out_of_jail ->
          {Player.add_out_of_jail_card(player), board}

        :birthday ->
          {player, board}

        nil ->
          {player, board}
      end

    if dice1 === dice2 do
      Logger.print("Double #{dice1}")
      play_turn(double_count + 1, player, board)
    else
      {player, board}
    end
  end

  def init(player_name) when is_binary(player_name) do
    player = %Player{
      turn: 0,
      move: 0,
      die_cast: 0,
      name: player_name,
      status: :free,
      case_id: 0,
      money: 150_000,
      out_of_jail_card: 0
    }

    board = %Board{
      cases: Board.init_cases(),
      free_park: 0,
      players: []
    }

    {player, board}
  end

  def repeat(0, %Player{} = player, %Board{} = board), do: {player, board}

  def repeat(count, %Player{} = player, %Board{} = board) do
    double_count = 0

    {new_player, new_board} = play_turn(double_count, player, board)
    new_player = Player.increase_turn_count(new_player)

    Logger.print(new_player)
    Logger.print("\n")

    repeat(count - 1, new_player, new_board)
  end

  def main(args) do
    options = [switches: [file: :string], aliases: [f: :file]]
    {opts, _, _} = OptionParser.parse(args, options)
    IO.inspect(opts, label: "Command Line Arguments")

    {player, board} = init("Féfé")
    tour = 30_000

    {player, board} = repeat(tour, player, board)

    Board.print_cases(board)
    Player.print(player)
    # IO.inspect(board.cases)
    # IO.inspect(player)
    IO.puts("yo")
  end
end
