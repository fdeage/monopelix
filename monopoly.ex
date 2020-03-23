defmodule Log do
  def print(msg) when is_binary(msg) or is_integer(msg) or is_atom(msg) do
    # IO.puts(msg)
  end

  def print(msg) do
    # IO.inspect(msg)
  end

  def print(msg, nil) when is_binary(msg) or is_integer(msg) or is_atom(msg) do
    # IO.puts(msg)
  end

  def print(msg1, msg2)
      when (is_binary(msg1) or is_integer(msg1) or is_atom(msg1)) and
             (is_binary(msg2) or is_integer(msg2) or is_atom(msg2)) do
    # IO.puts("#{msg1}: #{msg2}")
  end

  def print(msg1, msg2) do
    # IO.inspect(msg1)
    # IO.inspect(msg2)
  end
end

defmodule Card do
  defstruct [:name, :type, :opt]
end

defmodule Player do
  defstruct [:name, :status, :case_id, :money, :out_of_jail_card, :turn, :die_cast, :move]

  def move_by(%Player{} = player, die, pass_go_bonus? \\ true) do
    new_case_id = Integer.mod(player.case_id + die, 40)
    Log.print("Move player #{player.name} to", new_case_id)

    player =
      if new_case_id < player.case_id and pass_go_bonus? do
        Player.change_money_by(player, 20_000)
      else
        player
      end

    %Player{player | move: player.move + 1, case_id: new_case_id}
  end

  def move_to(%Player{} = player, case_id, pass_go_bonus? \\ true) do
    Log.print("Move player #{player.name} to", case_id)

    player =
      if case_id < player.case_id and pass_go_bonus? do
        Player.change_money_by(player, 20_000)
      else
        player
      end

    %Player{player | move: player.move + 1, case_id: case_id}
  end

  def put_in_jail(%Player{} = player) do
    Log.print("Move player #{player.name} to jail", nil)
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
    Log.print("Get player #{player.name} out of jail", nil)
    %Player{player | case_id: 10, status: :free}
  end

  def change_money_by(%Player{} = player, amount) do
    Log.print("Change player #{player.name}'s' money by ", amount)

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
    Log.print(player)
  end

  def increase_turn_count(%Player{} = player) do
    %Player{player | turn: player.turn + 1}
  end

  def increase_die_cast_count(%Player{} = player) do
    %Player{player | die_cast: player.die_cast + 1}
  end
end

defmodule Case do
  defstruct [:id, :name, :count, :percent]

  def increment_count(%Case{} = c) do
    c |> Map.replace!(:count, c.count + 1)
  end
end

defmodule Board do
  defstruct [:cases, :players, :free_park]

  def increase_case_count(%Board{} = board, case_at) do
    new_case = Case.increment_count(board.cases |> Enum.at(case_at))

    %Board{board | cases: board.cases |> List.replace_at(case_at, new_case)}
  end

  def empty_free_park_bounty(%Board{} = board) do
    %Board{board | free_park: 0}
  end

  def increase_free_park_bounty_by(%Board{} = board, amount) do
    %Board{board | free_park: board.free_park + amount}
  end

  def print_cases(%Board{} = board) do
    total = board.cases |> Enum.reduce(0, fn x, acc -> x.count + acc end)

    board.cases
    |> Enum.sort(fn x, y -> x.count < y.count end)
    |> Enum.map(fn x -> %{x | percent: Float.round(100 * x.count / total, 2)} end)
    |> Log.print()
  end

  def init_cases do
    [
      %Case{id: 0, name: "Case départ", count: 0, percent: 0},
      %Case{id: 1, name: "Boulevard de Belleville", count: 0, percent: 0},
      %Case{id: 2, name: "Communauté", count: 0, percent: 0},
      %Case{id: 3, name: "Rue Lecourbe", count: 0, percent: 0},
      %Case{id: 4, name: "Impôts sur le revenu", count: 0, percent: 0},
      %Case{id: 5, name: "Gare Montparnasse", count: 0, percent: 0},
      %Case{id: 6, name: "Rue de Vaugirard", count: 0, percent: 0},
      %Case{id: 7, name: "Chance", count: 0, percent: 0},
      %Case{id: 8, name: "Rue de Courcelles", count: 0, percent: 0},
      %Case{id: 9, name: "Avenue de la République", count: 0, percent: 0},
      %Case{id: 10, name: "Simple visite", count: 0, percent: 0},
      %Case{id: 11, name: "Boulevard de la Villette", count: 0, percent: 0},
      %Case{id: 12, name: "Compagnie d'Électricité", count: 0, percent: 0},
      %Case{id: 13, name: "Avenue de Neuilly", count: 0, percent: 0},
      %Case{id: 14, name: "Rue de Paradis", count: 0, percent: 0},
      %Case{id: 15, name: "Gare de Lyon", count: 0, percent: 0},
      %Case{id: 16, name: "Avenue Mozart", count: 0, percent: 0},
      %Case{id: 17, name: "Caisse de communauté", count: 0, percent: 0},
      %Case{id: 18, name: "Boulevard Saint-Michel", count: 0, percent: 0},
      %Case{id: 19, name: "Place Pigalle", count: 0, percent: 0},
      %Case{id: 20, name: "Parc gratuit", count: 0, percent: 0},
      %Case{id: 21, name: "Avenue Matignon", count: 0, percent: 0},
      %Case{id: 22, name: "Chance", count: 0, percent: 0},
      %Case{id: 23, name: "Boulevard Malesherbes", count: 0, percent: 0},
      %Case{id: 24, name: "Avenue Henri-Martin", count: 0, percent: 0},
      %Case{id: 25, name: "Gare du Nord", count: 0, percent: 0},
      %Case{id: 26, name: "Faubourg Saint-Honoré", count: 0, percent: 0},
      %Case{id: 27, name: "Place de la Bourse", count: 0, percent: 0},
      %Case{id: 28, name: "Compagnie des Eaux", count: 0, percent: 0},
      %Case{id: 29, name: "Rue La Fayette", count: 0, percent: 0},
      %Case{id: 30, name: "Allez en prison", count: 0, percent: 0},
      %Case{id: 31, name: "Avenue de Breteuil", count: 0, percent: 0},
      %Case{id: 32, name: "Avenue Foch", count: 0, percent: 0},
      %Case{id: 33, name: "Caisse de communauté", count: 0, percent: 0},
      %Case{id: 34, name: "Boulevard des Capucines", count: 0, percent: 0},
      %Case{id: 35, name: "Gare Saint-Lazare", count: 0, percent: 0},
      %Case{id: 36, name: "Chance", count: 0, percent: 0},
      %Case{id: 37, name: "Avenue des Champs-Élysées", count: 0, percent: 0},
      %Case{id: 38, name: "Taxe de luxe", count: 0, percent: 0},
      %Case{id: 39, name: "Rue de la Paix", count: 0, percent: 0}
    ]
  end
end

defmodule Monopoly do
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
    Log.print("Community card", comm.name)

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
    Log.print("Chance card", chance.name)

    chance
  end

  defp draw_dice do
    :rand.uniform(6)
  end

  def play_turn(3, %Player{} = player, %Board{} = board) do
    Log.print("Three doubles in a row")
    player = Player.put_in_jail(player)
    board = Board.increase_case_count(board, 10)

    {player, board}
  end

  def play_turn(double_count, %Player{} = player, %Board{} = board) do
    dice1 = draw_dice()
    dice2 = draw_dice()

    Log.print("Die: #{dice1} + #{dice2}", dice1 + dice2)

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

    if action.type, do: Log.print("Action: ", action.type)

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
      Log.print("Double #{dice1}")
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

    {new_player, new_board} = Monopoly.play_turn(double_count, player, board)
    new_player = Player.increase_turn_count(new_player)

    Log.print(new_player)
    Log.print("\n")

    repeat(count - 1, new_player, new_board)
  end
end

{player, board} = Monopoly.init("Féfé")
tour = 300_000

{player, board} = Monopoly.repeat(tour, player, board)

Board.print_cases(board)
Player.print(player)

IO.inspect(board.cases)
IO.inspect(player)
