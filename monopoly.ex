defmodule Log do
  def print(msg1, msg2) do
    # IO.puts(msg1)
    # IO.inspect(msg2)
  end
end

defmodule Card do
  defstruct [:name, :type, :opt]
end

defmodule Player do
  defstruct [:name, :status, :case_id, :money]

  def move_by(%Player{} = player, die) do
    new_case_id = Integer.mod(player.case_id + die, 40)
    Log.print("Move player #{player.name} to", new_case_id)

    %Player{player | case_id: new_case_id}
  end

  def move_to(%Player{} = player, case_id) do
    Log.print("Move player #{player.name} to", case_id)

    %Player{player | case_id: case_id}
  end

  def put_in_jail(%Player{} = player) do
    Log.print("Move player #{player.name} to jail", nil)
    %Player{player | case_id: 10, status: :in_jail_3}
  end
end

defmodule Case do
  defstruct [:id, :name, :count]

  def increment_count(%Case{} = c) do
    c |> Map.replace!(:count, c.count + 1)
  end
end

defmodule Board do
  defstruct [:cases, :players]

  def increase_case_count(board, case_at) do
    new_case = Case.increment_count(board.cases |> Enum.at(case_at))

    %Board{board | cases: board.cases |> List.replace_at(case_at, new_case)}
  end
end

defmodule Monopoly do
  defp draw_community do
    comm_cards = [
      %Card{name: "Héritez", type: :money, opt: 10_000},
      %Card{name: "Deuxième prix de beauté", type: :money, opt: 1_000},
      %Card{name: "Allez en prison", type: :move, opt: 10},
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
    Log.print("Community card", comm)
    comm
  end

  defp draw_chance do
    chance_cards = [
      %Card{name: "Ivresse", type: :money, opt: -2_000},
      %Card{name: "Allez à Henri-Martin", type: :move, opt: 23},
      %Card{name: "Mots croisés", type: :money, opt: 10_000},
      %Card{name: "Allez en prison", type: :move, opt: 10},
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
    Log.print("Chance card", chance)

    chance
  end

  defp draw_dice do
    :rand.uniform(6)
  end

  def play(3, board: board, player: player) do
    player = Player.put_in_jail(player)
    board = Board.increase_case_count(board, 10)

    [board: board, player: player]
  end

  def play(double_count, board: board, player: player) do
    dice1 = draw_dice()
    dice2 = draw_dice()

    Log.print("Dés: #{dice1} + #{dice2}", dice1 + dice2)

    player = Player.move_by(player, dice1 + dice2)
    board = Board.increase_case_count(board, player.case_id)

    action =
      case player.case_id do
        0 -> %{type: :money, opt: 40_000}
        2 -> draw_community()
        4 -> %{type: :money, opt: 40_000}
        7 -> draw_chance()
        17 -> draw_community()
        22 -> draw_chance()
        30 -> %{type: :move, opt: 10}
        32 -> draw_community()
        _ -> %{type: nil, opt: nil}
      end

    Log.print("Action: ", action)

    case action.type do
      :money ->
        player = %Player{player | money: player.money + action.opt}

      :repair ->
        player = %Player{player | money: player.money + action.opt.maisons + action.opt.hotels}

      :move ->
        player = Player.move_to(player, action.opt)
        # handle 20_000
        board = Board.increase_case_count(board, player.case_id)

      :move_relative ->
        player = Player.move_by(player, action.opt)
        board = Board.increase_case_count(board, player.case_id)

      :move_no_20_000 ->
        player = Player.move_by(player, action.opt)
        board = Board.increase_case_count(board, player.case_id)

      nil ->
        player

      :fine_or_redraw ->
        player

      :out_of_jail ->
        player

      :birthday ->
        player
    end

    if dice1 === dice2 do
      [board: board, player: player] = play(double_count + 1, board: board, player: player)
    end

    [board: board, player: player]
  end

  def init(player_name) do
    player = %Player{name: player_name, status: :free, case_id: 0, money: 150_000}

    board = %Board{
      cases: [
        %Case{id: 0, name: "Case départ", count: 0},
        %Case{id: 1, name: "Boulevard Belleville", count: 0},
        %Case{id: 2, name: "Communauté", count: 0},
        %Case{id: 3, name: "Rue Lecourbe", count: 0},
        %Case{id: 4, name: "Impôts sur le revenu", count: 0},
        %Case{id: 5, name: "Gare Montparnasse", count: 0},
        %Case{id: 6, name: "Rue de Vaugirard", count: 0},
        %Case{id: 7, name: "Chance", count: 0},
        %Case{id: 8, name: "Rue de Courcelles", count: 0},
        %Case{id: 9, name: "Avenue de la République", count: 0},
        %Case{id: 10, name: "Simple visite", count: 0},
        %Case{id: 11, name: "Boulevard de la Villette", count: 0},
        %Case{id: 12, name: "Compagnie d'Électricité", count: 0},
        %Case{id: 13, name: "Avenue de Neuilly", count: 0},
        %Case{id: 14, name: "Rue de Paradis", count: 0},
        %Case{id: 15, name: "Gare de Lyon", count: 0},
        %Case{id: 16, name: "Avenue Mozart", count: 0},
        %Case{id: 17, name: "Caisse de communauté", count: 0},
        %Case{id: 18, name: "Boulevard Saint-Michel", count: 0},
        %Case{id: 19, name: "Place Pigalle", count: 0},
        %Case{id: 20, name: "Parc gratuit", count: 0},
        %Case{id: 21, name: "Avenue Matignon", count: 0},
        %Case{id: 22, name: "Chance", count: 0},
        %Case{id: 23, name: "Boulevard Malesherbes", count: 0},
        %Case{id: 24, name: "Avenue Henri-Martin", count: 0},
        %Case{id: 25, name: "Gare du Nord", count: 0},
        %Case{id: 26, name: "Faubourg Saint-Honoré", count: 0},
        %Case{id: 27, name: "Place de la Bourse", count: 0},
        %Case{id: 28, name: "Compagnie des Eaux", count: 0},
        %Case{id: 29, name: "Rue La Fayette", count: 0},
        %Case{id: 30, name: "Allez en prison", count: 0},
        %Case{id: 31, name: "Avenue de Breteuil", count: 0},
        %Case{id: 32, name: "Avenue Foch", count: 0},
        %Case{id: 33, name: "Caisse de communauté", count: 0},
        %Case{id: 34, name: "Boulevard des Capucines", count: 0},
        %Case{id: 35, name: "Gare Saint-Lazare", count: 0},
        %Case{id: 36, name: "Chance", count: 0},
        %Case{id: 37, name: "Avenue des Champs-Élysées", count: 0},
        %Case{id: 38, name: "Taxe de luxe", count: 0},
        %Case{id: 39, name: "Rue de la Paix", count: 0}
      ],
      players: []
    }

    {board, player}
  end

  def repeat(0, board: board, player: player), do: [board: board, player: player]

  def repeat(count, board: board, player: player) do
    double_count = 0
    [board: board, player: player] = Monopoly.play(double_count, board: board, player: player)
    repeat(count - 1, board: board, player: player)
  end
end

{board, player} = Monopoly.init("Féfé")
tour = 10_000

[board: board, player: player] = Monopoly.repeat(tour, board: board, player: player)

IO.inspect(player)
IO.inspect(board.cases)
